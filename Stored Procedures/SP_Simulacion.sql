USE [Proyecto]
GO

/****** Object:  StoredProcedure [dbo].[Simulacion]    Script Date: 11/25/2019 12:25:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ==========================================================================================
-- Autores:		<Austin Hakanson y Antony Artavia>
-- Fecha de creacion: <18/11/2019>
-- Fecha de ultima modificacion <24-11-2019>
-- Descripcion:	<SP para hacer la simulacion de actividades de planillas de obreros>
-- ==========================================================================================

CREATE OR ALTER PROCEDURE [dbo].[Simulacion]
AS

BEGIN
	SET NOCOUNT ON 

	--	///		TABLAS VARIABLES	//

	DECLARE @Fechas TABLE 
	(
	Sec int primary key identity(1,1),
	Fecha date
	)
	DECLARE @DeduccionXEmpleado TABLE
	(
	Sec int identity(1,1),
	DocID nvarchar(50),
	TipoDeduccion nvarchar(50),
	Monto money
	)
	DECLARE @Asistencia TABLE
	(
	Sec int identity(1,1),
	DocId nvarchar(50),
	HoraInicio time(0),	-- time(0) para que no tenga decimales
	HoraFinal time(0)
	)
	DECLARE @TipoJornada TABLE
	(
	Sec int identity(1,1),
	DocId nvarchar(50),
	Jornada nvarchar(50)
	)
	DECLARE @PagosSemana TABLE
	(
	Sec int identity(1,1),
	Empleado int,
	IdPuesto int,
	IdJornada int,
	IdTipoJornada int,
	HoraEntrada time(0),
	HoraSalida time(0),
	SalarioPorHora money,
	SalarioDelDia money
	)

	DECLARE @DocHandle int, @DocumentoXML xml, @temp xml
	DECLARE @CambiosTipoJornada TipoJornada

	BEGIN TRY
		-- Se cargan los datos del XML a la variable XML
		SELECT @DocumentoXML = F
		--  Se crea una representacion interna del documento XML
		FROM OPENROWSET (Bulk '\\Mac\Home\Documents\Ing. Computación\IV Semestre\Bases de datos I\Proyecto Final\XML\Simulacion.xml',Single_BLOB) AS Fechas(F)
		EXEC sp_xml_preparedocument @DocHandle OUTPUT, @DocumentoXML   -- Se ejecuta el SP que carga el XML

		-- Se cargan las fechas de operacion
		INSERT INTO @Fechas
		SELECT fecha 
		FROM OPENXML (@DocHandle, '/Simulacion/FechaOperacion',1) -- El uno al final indica que la lectura es <atribute-centric> 
		  WITH (fecha date)
		EXEC sp_xml_removedocument @DocHandle	-- Se remueva de la memoria el documento

		DECLARE @fechaIteracion date
		DECLARE @fechaFin date

		SELECT @fechaIteracion = min (F.fecha),
			   @fechaFin = max(F.fecha)
		FROM @Fechas F
	END TRY
	BEGIN CATCH
		SELECT 'Hubo un error'
	END CATCH

	DECLARE @fechaPrueba date = '2017-01-14'
	DECLARE @IdSemanaDePago int
	

	WHILE @fechaIteracion <= @fechaPrueba
	BEGIN
		-- Se cargan en @temp los datos XML de la fecha @fechaIteracion
		SET @temp = (select @DocumentoXML.query('/Simulacion/FechaOperacion[@fecha= sql:variable("@fechaIteracion")]'))

		-- ///	INGRESO DE NUEVO MES	///
		EXEC SP_AgregarMes @FechaIteracion

		-- ///	INGRESO DE NUEVA SEMANA	///
		EXEC SP_AgregarSemana @FechaIteracion

		-- ///	INGRESO DE NUEVOS EMPLEADOS	///
		EXEC SP_AgregarEmpleado @temp, @fechaIteracion

		-- ///	INGRESO DE ASISTENCIA ///
		EXEC SP_AgregarAsistencias @temp

		-- ///	CAMBIO DE TIPO DE JORNADA POR EMPLEADO	///
		EXEC SP_AgregarJornada @temp

		-- ///	INGRESO DE DEDUCCIONES DE EMPLEADOS	///
		EXEC SP_AgregarDeduccion @temp, @fechaIteracion

		-- ///	PROCESAMIENTO DE PAGO A LOS EMPLEADOS /// --> Cada dia se actualiza la planilla semanal 

		-- //	INGRESO DE LOS MOVIMIENTOS DE PLANILLA	//

		-- Se obtiene el id de la semana de pago
		SET @IdSemanaDePago = dbo.obtenerIdSemana(@fechaIteracion)

		IF (@fechaIteracion NOT IN (SELECT F.Fecha FROM Feriado F) or DATENAME(WEEKDAY,@fechaIteracion) != 'Sunday')
		BEGIN 
			INSERT INTO @PagosSemana
			SELECT E.Id, P.Id, J.Id, TJ.Id, A.HoraEntrada, A.HoraSalida, SPH.Salario,
			-- Caso para horas extra regulares
			CASE WHEN DATEDIFF(HOUR,TJ.HoraFin, A.HoraSalida) > 0
			THEN SPH.Salario * DATEDIFF(HOUR,A.HoraEntrada, A.HoraSalida) + SPH.Salario * DATEDIFF(HOUR,TJ.HoraFin,A.HoraSalida) * 1.5 
			-- Caso para horas ordinarias
			ELSE SPH.Salario * DATEDIFF(HOUR,A.HoraEntrada, A.HoraSalida) END
			FROM Asistencia A
			INNER JOIN Jornada J ON J.Id = A.IdJornada
			INNER JOIN Empleado E ON E.Id = J.IdEmpleado
			INNER JOIN Puesto P ON P.Id = E.IdPuesto
			INNER JOIN TipoJornada TJ ON TJ.Id = J.IdTipoJornada
			INNER JOIN SalarioPorHora SPH ON SPH.IdPuesto = P.Id and SPH.IdTipoJornada = TJ.Id
			GROUP BY E.Id, P.Id, J.Id, TJ.Id, A.HoraEntrada, A.HoraSalida, SPH.Salario, TJ.HoraFin

			UPDATE PlanillaSemanal
			SET SalarioDevengado = SalarioDevengado + P.SalarioDelDia
			FROM @PagosSemana P
			WHERE IdEmpleado = P.Empleado and IdSemana = @IdSemanaDePago 
			END
			
			INSERT INTO MovPlanilla
			SELECT TMP.Nombre, PS.Id, @fechaIteracion, PS.SalarioDevengado, 'Pago de horas de trabajo'
			FROM PlanillaSemanal PS, TipoMovPlanilla TMP
			WHERE TMP.Nombre = 'Hora ordinaria' and PS.IdSemana = @IdSemanaDePago 

		-- Se registra el pago de las horas

		

		

		-- Este es le caso para las horas de trabajo ordinarias
	--	IF (@fechaIteracion NOT IN (SELECT F.Fecha FROM Feriado F) or DATENAME(WEEKDAY,@fechaIteracion) != 'Sunday')
	--	BEGIN
	--		-- Seleccion de casos con horas ordinarias y horas extra
	--		INSERT INTO @PagosSemana
	--		SELECT E.Id as IdEmpleado, P.Id as IdPuesto, J.Id as IdJornada, TJ.Id as IdJornada, A.HoraEntrada, A.HoraSalida, SPH.Salario as SalarioPorHora,
	--			   CASE WHEN DATEDIFF(HOUR,TJ.HoraFin, A.HoraSalida) > 0 THEN SPH.Salario * DATEDIFF(HOUR,A.HoraEntrada, A.HoraSalida) + SPH.Salario * DATEDIFF(HOUR,TJ.HoraFin,A.HoraSalida) * 1.5 
	--					ELSE SPH.Salario * DATEDIFF(HOUR,A.HoraEntrada, A.HoraSalida) END AS SalarioDelDia
	--		FROM Asistencia A
	--		INNER JOIN Jornada J ON J.Id = A.IdJornada
	--		INNER JOIN Empleado E ON E.Id = J.IdEmpleado
	--		INNER JOIN Puesto P ON P.Id = E.IdPuesto
	--		INNER JOIN TipoJornada TJ ON TJ.Id = J.IdTipoJornada
	--		INNER JOIN SalarioPorHora SPH ON SPH.IdPuesto = P.Id and SPH.IdTipoJornada = TJ.Id
	--		GROUP BY E.Id, P.Id, J.Id, TJ.Id, A.HoraEntrada, A.HoraSalida, SPH.Salario, TJ.HoraFin

	--		SELECT E.Nombre, SUM(P.SalarioDeLaSemana) as SalarioTotal
	--		FROM @PagosSemana P
	--		INNER JOIN Empleado E ON E.Id = P.Empleado
	--		GROUP BY E.Nombre

	--		--IF (SELECT S.Id FROM Semana S WHERE S.FechaFin = @fechaIteracion) IS NOT NULL
	--		--BEGIN
				
	--		--END
	--	END
	--	-- Este es el caso para el pago de feriados y horas extra por ser domingo
	--	ELSE
	--	BEGIN 
	--		-- Seleccion de casos con horas ordinarias y horas extra
	--		INSERT INTO @PagosSemana
	--		SELECT E.Id as IdEmpleado, P.Id as IdPuesto, J.Id as IdJornada, TJ.Id as IdJornada, A.HoraEntrada, A.HoraSalida, SPH.Salario as SalarioPorHora, COUNT(A.Id) as Asistencias,
	--			   CASE WHEN DATEDIFF(HOUR,TJ.HoraFin, A.HoraSalida) > 0 THEN SPH.Salario * DATEDIFF(HOUR,A.HoraEntrada, A.HoraSalida) + SPH.Salario * DATEDIFF(HOUR,TJ.HoraFin,A.HoraSalida) * 2
	--					ELSE SPH.Salario * DATEDIFF(HOUR,A.HoraEntrada, A.HoraSalida) END AS SalarioDeLaSemana
	--		FROM Asistencia A
	--		INNER JOIN Jornada J ON J.Id = A.IdJornada
	--		INNER JOIN Empleado E ON E.Id = J.IdEmpleado
	--		INNER JOIN Puesto P ON P.Id = E.IdPuesto
	--		INNER JOIN TipoJornada TJ ON TJ.Id = J.IdTipoJornada
	--		INNER JOIN SalarioPorHora SPH ON SPH.IdPuesto = P.Id and SPH.IdTipoJornada = TJ.Id
	--		GROUP BY E.Id, P.Id, J.Id, TJ.Id, A.HoraEntrada, A.HoraSalida, SPH.Salario, TJ.HoraFin

	--		SELECT E.Nombre, SUM(P.SalarioDeLaSemana)
	--		FROM @PagosSemana P
	--		INNER JOIN Empleado E ON E.Id = P.IdEmpleado
	--		GROUP BY E.Nombre
	--	END
	
		SET @fechaIteracion = DATEADD(DAY, 1, @fechaIteracion)
	END

	SELECT * FROM PlanillaMensual

	SELECT * FROM PlanillaSemanal
END
GO

