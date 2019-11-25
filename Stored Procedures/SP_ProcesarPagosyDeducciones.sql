
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================================
-- Author:		<Austin Hakanson y Antony Artavia>
-- Fecha de creacion: <25-11-2019>
-- Fecha de ultima modificacion: <25-11-2019>
-- Description:	<SP que se encarga de todos los pagos y deducciones a los empleados asi como sus movimientos>
-- =============================================================================================================
ALTER PROCEDURE dbo.SP_ProcesarPagosyDeducciones
	-- Parametros
	@FechaIteracion date
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY
		DECLARE @InicioTran int = 0
		DECLARE @IdSemanaDePago int
		DECLARE @PagosDelDia TABLE
		(
		Sec int identity(1,1),
		Fecha date,
		Empleado int,
		IdPuesto int,
		IdJornada int,
		IdTipoJornada int,
		HoraEntrada time(0),
		HoraSalida time(0),
		HorasExtra int,
		MontoSalarioBase money,
		MontoPorHorasExtra money
		)
		DECLARE @DeduccionesDeLaSemana TABLE
		(
		Sec int identity(1,1),
		IdPlanillaSemanal int,
		IdTipoDeduccion int,
		IdEmpleado int,
		IdSemana int,
		SalarioAntesDeDeduccion money,
		Fecha date
		)

		SET TRANSACTION ISOLATION LEVEL READ COMMITTED
		BEGIN TRANSACTION ProcesarPagosyDeducciones
		SET @InicioTran = 1
	
		-- Se obtiene el id de la semana de pago
		SET @IdSemanaDePago = dbo.obtenerIdSemana(@fechaIteracion)

		--///////-----------------CREDITOS----------------------/////////

		-- Se carga toda la informacion de pagos del dia
		INSERT INTO @PagosDelDia
		SELECT @fechaIteracion, E.Id, P.Id, J.Id, TJ.Id, A.HoraEntrada, A.HoraSalida,dbo.DiferenciaEntreHoras(TJ.HoraFin,A.HoraSalida), SPH.Salario * dbo.DiferenciaEntreHoras(A.HoraEntrada,A.HoraSalida),
		-- Monto en que la fecha no es feriado ni domingo
		CASE WHEN (@fechaIteracion IN (SELECT F.Fecha FROM Feriado F) or DATENAME(WEEKDAY,@fechaIteracion) = 'Sunday') THEN SPH.Salario * dbo.DiferenciaEntreHoras(TJ.HoraFin,A.HoraSalida) * 2
		-- Caso para feriados y domingos
		ELSE SPH.Salario * dbo.DiferenciaEntreHoras(TJ.HoraFin,A.HoraSalida) * 1.5 END
		FROM Asistencia A
		INNER JOIN Semana S ON A.Fecha BETWEEN S.FechaInicio and S.FechaFin
		INNER JOIN Jornada J ON J.Id = A.IdJornada and J.IdSemana = S.Id
		INNER JOIN Empleado E ON E.Id = J.IdEmpleado
		INNER JOIN Puesto P ON P.Id = E.IdPuesto
		INNER JOIN TipoJornada TJ ON TJ.Id = J.IdTipoJornada
		INNER JOIN SalarioPorHora SPH ON SPH.IdPuesto = P.Id and SPH.IdTipoJornada = TJ.Id
		WHERE A.Fecha = @fechaIteracion
		GROUP BY E.Id, P.Id, J.Id, TJ.Id, A.HoraEntrada, A.HoraSalida, SPH.Salario, TJ.HoraFin

		-- Se actualiza la planilla de los empleados correspondientes para la semana actual.
		UPDATE PlanillaSemanal
		SET SalarioDevengado = SalarioDevengado + PDD.MontoSalarioBase + PDD.MontoPorHorasExtra
		FROM @PagosDelDia PDD
		WHERE IdEmpleado = PDD.Empleado and IdSemana = @IdSemanaDePago

		--///////-----------MOVIMIENTOS DE CREDITOS-------------/////////

		-- Se registra el movimiento de horas ordinarias.
		INSERT INTO MovPlanilla
		SELECT TMP.Id, PS.Id, @fechaIteracion, PDD.MontoSalarioBase, 'Pago de horas ordinarias de trabajo a ' + E.Nombre
		FROM PlanillaSemanal PS
		INNER JOIN @PagosDelDia PDD ON PDD.Empleado = PS.IdEmpleado
		INNER JOIN Empleado E ON E.Id = PS.IdEmpleado
		INNER JOIN TipoMovPlanilla TMP ON TMP.Nombre = 'Hora ordinaria'
		WHERE PDD.Fecha = @fechaIteracion

		-- Se registra el movimiento de horas extraordinarias normales
		INSERT INTO MovPlanilla
		SELECT TMP.Id, PS.Id, @fechaIteracion, PDD.MontoPorHorasExtra, CASE WHEN DATENAME(WEEKDAY,PDD.Fecha) = 'Sunday' 
																	   THEN 'Pago de ' + CAST(PDD.HorasExtra as varchar(2)) + ' horas extra dobles de trabajo a ' + E.Nombre
																	   ELSE 'Pago de ' + CAST(PDD.HorasExtra as varchar(2)) + ' horas extra de trabajo a ' + E.Nombre END
		FROM PlanillaSemanal PS
		INNER JOIN @PagosDelDia PDD ON PDD.Empleado = PS.IdEmpleado
		INNER JOIN Empleado E ON E.Id = PS.IdEmpleado
		INNER JOIN TipoMovPlanilla TMP ON TMP.Nombre = 'Hora extra'
		WHERE PDD.Fecha = @fechaIteracion and PDD.HorasExtra != 0

		-- Se registran los movimientos de planilla que son de credito
		INSERT INTO Credito
		SELECT MP.Id, A.Id
		FROM MovPlanilla MP
		INNER JOIN PlanillaSemanal PS ON PS.Id = MP.IdPlanillaSemanal
		INNER JOIN Empleado E ON E.Id = PS.IdEmpleado
		INNER JOIN Jornada J ON J.IdEmpleado = E.Id
		INNER JOIN Asistencia A ON A.IdJornada = J.Id
		WHERE MP.Fecha = @fechaIteracion and A.Fecha = @fechaIteracion

		--///////-----------------DEDUCCIONES----------------------/////////
	
		-- Para deducciones PORCENTUALES

		INSERT INTO @DeduccionesDeLaSemana
		SELECT PS.Id, TD.Id, E.Id, S.Id, PS.SalarioDevengado, @fechaIteracion
		FROM DeduccionXEmpleado DXE
		INNER JOIN TipoDeduccion TD ON TD.Id = DXE.IdTipoDeduccion
		INNER JOIN Empleado E ON E.Id = DXE.IdEmpleado
		INNER JOIN PlanillaSemanal PS ON PS.IdEmpleado = E.Id
		INNER JOIN Semana S ON S.Id = PS.IdSemana
		WHERE S.FechaFin = @fechaIteracion	-- Con esta condicion se actualiza solo al final de cada semana

		UPDATE PlanillaSemanal
		SET SalarioDevengado = SalarioDevengado - (SalarioDevengado*(DXE.Monto/100))
		FROM @DeduccionesDeLaSemana DS
		INNER JOIN Empleado E ON E.Id = DS.IdEmpleado
		INNER JOIN DeduccionXEmpleado DXE ON DXE.IdEmpleado = E.Id
		INNER JOIN TipoDeduccion TD ON TD.Id = DS.IdTipoDeduccion
		INNER JOIN Porcentual P on P.IdTipoDeduccion = TD.Id
		INNER JOIN Semana S ON S.Id = DS.IdSemana
		WHERE S.FechaFin = @fechaIteracion	-- Con esta condicion se actualiza solo al final de cada semana

		-- Se inserta el movimiento de deducciones PORCENTUALES
		INSERT INTO MovPlanilla
		SELECT TMP.Id, PS.Id, @fechaIteracion, DPS.SalarioAntesDeDeduccion*(DXE.Monto/100), 'Deduccion porcentual de ' + CAST(DXE.Monto as varchar(20)) + ' %, por concepto de ' + TD.Nombre + ' a ' + E.Nombre
		FROM @DeduccionesDeLaSemana DPS
		INNER JOIN Empleado E ON E.Id = DPS.IdEmpleado
		INNER JOIN PlanillaSemanal PS ON PS.IdEmpleado = E.Id
		INNER JOIN DeduccionXEmpleado DXE ON DXE.IdEmpleado = E.Id
		INNER JOIN TipoDeduccion TD ON TD.Id = DPS.IdTipoDeduccion and TD.Id = DXE.IdTipoDeduccion
		INNER JOIN Porcentual P ON P.IdTipoDeduccion = TD.Id
		INNER JOIN TipoMovPlanilla TMP ON TMP.Nombre = 'Deducción porcentual'
		WHERE DPS.Fecha = @fechaIteracion

		-- Para deducciones FIJAS

		UPDATE PlanillaSemanal
		SET SalarioDevengado = SalarioDevengado - (SalarioDevengado*(DXE.Monto/100))
		FROM @DeduccionesDeLaSemana DS
		INNER JOIN Empleado E ON E.Id = DS.IdEmpleado
		INNER JOIN DeduccionXEmpleado DXE ON DXE.IdEmpleado = E.Id
		INNER JOIN TipoDeduccion TD ON TD.Id = DS.IdTipoDeduccion
		INNER JOIN Fija F on F.IdTipoDeduccion = TD.Id
		INNER JOIN Semana S ON S.Id = DS.IdSemana
		WHERE S.FechaFin = @fechaIteracion	-- Con esta condicion se actualiza solo al final de cada semana

		-- Se inserta el movimiento de deducciones FIJAS
		INSERT INTO MovPlanilla
		SELECT TMP.Id, PS.Id, @fechaIteracion, DXE.Monto, 'Deduccion fija de ' + CAST(DXE.Monto as varchar(20)) + ', por ' + TD.Nombre + ' a ' + E.Nombre
		FROM @DeduccionesDeLaSemana DPS
		INNER JOIN Empleado E ON E.Id = DPS.IdEmpleado
		INNER JOIN PlanillaSemanal PS ON PS.IdEmpleado = E.Id
		INNER JOIN DeduccionXEmpleado DXE ON DXE.IdEmpleado = E.Id
		INNER JOIN TipoDeduccion TD ON TD.Id = DPS.IdTipoDeduccion and TD.Id = DXE.IdTipoDeduccion
		INNER JOIN Fija F ON F.IdTipoDeduccion = TD.Id
		INNER JOIN TipoMovPlanilla TMP ON TMP.Nombre = 'Deducción fija'
		WHERE DPS.Fecha = @fechaIteracion
	
		COMMIT TRANSACTION ProcesarPagosyDeducciones
		SET @InicioTran = 0
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION ProcesarPagosyDeducciones
		SET @InicioTran = 0
		RETURN @@ERROR * -1
	END CATCH
END
GO
