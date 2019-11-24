USE [Proyecto]
GO

/****** Object:  StoredProcedure [dbo].[SP_CargarDatos]    Script Date: 11/24/2019 7:31:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =================================================================================================
-- Autores:		<Austin Hakanson y Antony Artavia>
-- Fecha de creacion: <18/11/2019>
-- Fecha de Ultima Modification: <21-11-2019>
-- Descripcion:	<SP para cargar datos de tablas [Deduccion], [Feriado], [Puesto], [SalarioXHora],
											--  [TipoJornada],[TipoMovimientoPlanilla]>
-- =================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[SP_CargarDatos]

AS
BEGIN
	SET NOCOUNT ON;

	-- /// VARIABLES ///
	DECLARE @DocHandle int, @temp xml, @Deduccion xml, @Feriado xml, 
		    @Puesto xml, @TipoJornada xml, @TipoMovPlanilla xml, @SalarioPorHora xml

	-- /// TABLAS VARIABLES ///
	DECLARE @Deducciones TABLE
	(
	Sec int identity(1,1),
	Detalle nvarchar(50),
	Tipo nvarchar(50)
	)
	DECLARE @Feriados TABLE
	(
	Sec int identity(1,1),
	Nombre nvarchar(100),
	Fecha date
	)
	DECLARE @TiposJornada TABLE
	(
	Sec int identity(1,1),
	Nombre nvarchar(100),
	HoraInicio time(0),
	HoraFin time(0)
	)
	DECLARE @TiposMovPlanilla TABLE 
	(
	Sec int identity(1,1),
	Nombre nvarchar(100)
	)
	DECLARE @SalariosPorHora TABLE 
	(
	Sec int identity (1,1),
	Puesto nvarchar(100),
	Jornada nvarchar(100),
	Salario money
	)
	DECLARE @Puestos TABLE
	(
	Sec int identity(1,1),
	Nombre nvarchar(100)
	)


	-- /// INSERCION DE LOS TIPOS DE JORNADA ///
	BEGIN TRY
		SELECT @TipoJornada = TJ
		FROM OPENROWSET (Bulk '\\Mac\Home\Documents\Ing. Computación\IV Semestre\Bases de datos I\Proyecto Final\XML\TipoJornada.xml',Single_BLOB) AS TipoJornada(TJ)
		EXEC sp_xml_preparedocument @DocHandle OUTPUT, @TipoJornada  

		INSERT INTO TipoJornada
		SELECT Nombre, HoraInicio, HoraFin
		FROM OPENXML(@DocHandle, '/TiposJornada/TipoJornada',1) -- El uno es para que sea attribute centric
		WITH
		(
		Nombre nvarchar(100) '@nombre',
		HoraInicio time(0) '@horaInicio',
		HoraFin time(0) '@horaFin'
		)

		EXEC sp_xml_removedocument @DocHandle

	END TRY

	BEGIN CATCH
		return @@ERROR * -1
	END CATCH

	-- /// INSERCION DE LOS PUESTOS ///
	BEGIN TRY
		SELECT @Puesto = P
		FROM OPENROWSET (Bulk '\\Mac\Home\Documents\Ing. Computación\IV Semestre\Bases de datos I\Proyecto Final\XML\Puesto.xml',Single_BLOB) AS Puesto(P)
		EXEC sp_xml_preparedocument @DocHandle OUTPUT, @Puesto  

		INSERT INTO Puesto
		SELECT Nombre
		FROM OPENXML(@DocHandle, '/Puestos/Puesto',1) -- El uno es para que sea attribute centric
		WITH
		(
		Nombre nvarchar(100) '@nombre'
		)
		EXEC sp_xml_removedocument @DocHandle

	END TRY

	BEGIN CATCH
		return @@ERROR * -1
	END CATCH

	-- /// INSERCION DE LOS SALARIOS POR HORA ///
	BEGIN TRY
		
		-- Insercion en tabla variable de salarios por hora
		SELECT @SalarioPorHora = SPH
		FROM OPENROWSET (Bulk '\\Mac\Home\Documents\Ing. Computación\IV Semestre\Bases de datos I\Proyecto Final\XML\SalarioxHora.xml',Single_BLOB) AS SalarioPorHora(SPH)
		EXEC sp_xml_preparedocument @DocHandle OUTPUT, @SalarioPorHora  

		INSERT INTO @SalariosPorHora
		SELECT Puesto, Jornada, Salario
		FROM OPENXML(@DocHandle, '/SalariosxHora/SalarioxHora',1) -- El uno es para que sea attribute centric
		WITH
		(
		Puesto nvarchar(100) '@puesto',
		Jornada nvarchar(100) '@jornada',
		SAlario money '@salario'
		)

		EXEC sp_xml_removedocument @DocHandle

		INSERT INTO SalarioPorHora
		SELECT P.Id, TJ.id, V.Salario
		FROM @SalariosPorHora V
		INNER JOIN Puesto P ON P.Puesto = V.Puesto
		INNER JOIN TipoJornada TJ ON TJ.Nombre = V.Jornada

	
	END TRY

	BEGIN CATCH
		return @@ERROR * -1
	END CATCH

	--/// INSERCION DE LOS FERIADOS ///
	BEGIN TRY
		SELECT @Feriado = F
		FROM OPENROWSET (Bulk '\\Mac\Home\Documents\Ing. Computación\IV Semestre\Bases de datos I\Proyecto Final\XML\Feriado.xml',Single_BLOB) AS Feriado(F)
		EXEC sp_xml_preparedocument @DocHandle OUTPUT, @Feriado  

		INSERT INTO Feriado
		SELECT Nombre, Fecha
		FROM OPENXML(@DocHandle, '/Feriados/Feriado',1) -- El uno es para que sea attribute centric
		WITH
		(
		Nombre nvarchar(100) '@nombre',
		Fecha date '@fecha'
		)

		EXEC sp_xml_removedocument @DocHandle

	END TRY

	BEGIN CATCH
		return @@ERROR * -1
	END CATCH

	-- /// INSERCION DE LOS TIPOS DE MOVIMIENTO DE PLANILLA ///
	BEGIN TRY
		SELECT @TipoMovPlanilla = TMP
		FROM OPENROWSET (Bulk '\\Mac\Home\Documents\Ing. Computación\IV Semestre\Bases de datos I\Proyecto Final\XML\TipoMovimientoPlanilla.xml',Single_BLOB) AS TipoMovPlanilla(TMP)
		EXEC sp_xml_preparedocument @DocHandle OUTPUT, @TipoMovPlanilla  

		INSERT INTO TipoMovPlanilla
		SELECT Nombre 
		FROM OPENXML(@DocHandle, '/TiposMovimientoPlanilla/TipoMovimientoPlanilla',1) -- El uno es para que sea attribute centric
		WITH
		(
		Nombre nvarchar(100) '@nombre'
		)

		EXEC sp_xml_removedocument @DocHandle

	END TRY

	BEGIN CATCH
		return @@ERROR * -1
	END CATCH

	-- /// INSERCION DE LAS DEDUCCIONES ///
	BEGIN TRY
		
		SELECT @Deduccion = D
		FROM OPENROWSET (Bulk '\\Mac\Home\Documents\Ing. Computación\IV Semestre\Bases de datos I\Proyecto Final\XML\Deduccion.xml',Single_BLOB) AS Deduccion(D)
		EXEC sp_xml_preparedocument @DocHandle OUTPUT, @Deduccion  

		INSERT INTO @Deducciones
		SELECT Detalle, Tipo
		FROM OPENXML(@DocHandle, '/Deducciones/Deduccion',1) -- El uno es para que sea attribute centric
		WITH
		(
		Detalle nvarchar(50) '@detalle',
		Tipo nvarchar(50) '@tipo'
		)

		EXEC sp_xml_removedocument @DocHandle

		DECLARE @InicioTran int = 0

		-- Inicia la transaccion que inserta los valores en las tablas [Deduccion],[Fija] y [Porcentual]
		IF (@@TRANCOUNT = 0)
		BEGIN 
			SET TRANSACTION ISOLATION LEVEL READ COMMITTED
			SET @InicioTran = 1
			BEGIN TRANSACTION AgregarDeducciones
		
			-- Se insertan todos los tipos de deducciones
			INSERT INTO TipoDeduccion
			SELECT D.Detalle
			FROM @Deducciones D

			-- Se especializan los tipos de deduccion por herencia
			INSERT INTO Fija
			SELECT TD.Id
			FROM TipoDeduccion TD
			INNER JOIN @Deducciones D ON TD.Nombre = D.Detalle
			WHERE D.Tipo = 'Fija'

			INSERT INTO Porcentual
			SELECT TD.Id
			FROM TipoDeduccion TD
			INNER JOIN @Deducciones D ON TD.Nombre = D.Detalle
			WHERE D.Tipo = 'Porcentual'

			COMMIT TRANSACTION AgregarDeducciones
			SET @InicioTran = 0
			END
		
	END TRY

	BEGIN CATCH
		IF (@InicioTran = 1)
		BEGIN
			ROLLBACK TRANSACTION AgregarDeducciones
		END
		return @@ERROR * -1
	END CATCH

END
GO

