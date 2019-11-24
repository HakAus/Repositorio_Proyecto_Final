USE [Proyecto]
GO

/****** Object:  StoredProcedure [dbo].[Simulacion]    Script Date: 11/24/2019 7:30:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ==========================================================================================
-- Autores:		<Austin Hakanson y Antony Artavia>
-- Fecha de creacion: <18/11/2019>
-- Fecha de ultima modificacion <23-11-2019>
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

		-- ///	PROCESAMIENTO DE PAGO A LOS EMPLEADOS ///

		-- Se obtiene el id de la semana anterior
		SET @IdSemanaDePago = (SELECT S.Id FROM Semana S WHERE S.FechaFin = @fechaIteracion)
		
		IF @IdSemanaDePago IS NOT NULL 
		BEGIN
			-- Se hace el movimiento de deducciones fijas de la planilla 
			--INSERT INTO MovPlanilla (IdTipoMovPlanilla, IdPlanillaSemanal, Fecha, Monto, Descripcion)
			SELECT E.Nombre, DXE.Monto, DXE.Detalle
			FROM DeduccionXEmpleado DXE
			INNER JOIN Empleado E ON E.Id = DXE.IdEmpleado
			INNER JOIN PlanillaSemanal PS ON PS.IdEmpleado = E.Id
			WHERE PS.IdSemana = @IdSemanaDePago and DXE.IdTipoDeduccion IN (SELECT F.IdTipoDeduccion FROM Fija F)
		END
	

		--SELECT E.Nombre, @IdSemanaDePago, PM.Id, 
		--FROM Jornada J
		--INNER JOIN Empleado E ON J.IdEmpleado = E.Id
		--INNER JOIN PlanillaMensual PM ON PM.IdEmpleado = E.Id
		--INNER JOIN MovPlanilla 
		--WHERE J.IdSemana = @IdSemanaDePago
	
		SET @fechaIteracion = DATEADD(DAY, 1, @fechaIteracion)
	END
END
GO

