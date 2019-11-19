USE [Proyecto]
GO
/****** Object:  StoredProcedure [dbo].[SP_CargarDatos]    Script Date: 11/18/2019 7:56:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Austin Hakanson y Antony Artavia>
-- Create date: <18/11/2019>
-- Fecha de Ultima Modification: <18-11-2019>
-- Description:	<SP para cargar datos de tablas [Deduccion], [Feriado], [Puesto], [SalarioXHora],
											--  [TipoJornada],[TipoMovimientoPlanilla]>
-- =============================================
ALTER PROCEDURE [dbo].[SP_CargarDatos]

AS
BEGIN
	SET NOCOUNT ON;

	-- /// VARIABLES ///
	DECLARE @DocHandle int, @temp xml, @Deduccion xml, @Feriado xml, @Puesto xml, @TipoJornada xml, @TipoMovPlanilla xml

	-- /// TABLAS VARIABLES ///
	DECLARE @Deducciones TABLE
	(
	Sec int identity(1,1),
	Tipo nvarchar(50),
	Detalle nvarchar(50)
	)

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

		SELECT * FROM Puesto

	END TRY

	BEGIN CATCH
		return @@ERROR * -1
	END CATCH

	-- /// INSERCION DE LOS FERIADOS ///
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

		SELECT * FROM Feriado

	END TRY

	BEGIN CATCH
		return @@ERROR * -1
	END CATCH

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

		SELECT * FROM TipoJornada

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

		SELECT * FROM TipoMovPlanilla

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
		SELECT Tipo, Detalle
		FROM OPENXML(@DocHandle, '/Deducciones/Deduccion',1) -- El uno es para que sea attribute centric
		WITH
		(
		Tipo nvarchar(50) '@tipo',
		Detalle nvarchar(50) '@detalle'
		)

		EXEC sp_xml_removedocument @DocHandle

		SELECT * FROM @Deducciones
	END TRY

	BEGIN CATCH
		return @@ERROR * -1
	END CATCH

	
END
