USE [Proyecto]
GO
/****** Object:  StoredProcedure [dbo].[Simulacion]    Script Date: 11/18/2019 3:34:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================================
-- Autores:		<Austin Hakanson y Antony Artavia>
-- Fecha de creacion: <18/11/2019>
-- Descripcion:	<SP para hacer la simulacion de actividades de planillas de obreros>
-- ==========================================================================================

ALTER PROCEDURE [dbo].[Simulacion]
AS

BEGIN
	SET NOCOUNT ON 

	--	///		TABLAS VARIABLES	//

	DECLARE @Fechas TABLE 
	(
	Sec int primary key identity(1,1),
	Fecha date
	)
	DECLARE @NuevosEmpleados TABLE
	(
	Sec	int identity(1,1),
	DocId nvarchar(50),
	Nombre nvarchar(100),
	Puesto nvarchar(100),
	JornadaInicial nvarchar(50)
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
		SELECT 'Hubo un error en la carga de las fechas de operacion'
	END CATCH

	WHILE @fechaIteracion <= @fechaFin
	BEGIN
		-- Se cargan todos los datos del XML en @XmlDocument
		SELECT @DocumentoXML = C
		FROM OPENROWSET (Bulk '\\Mac\Home\Documents\Ing. Computación\IV Semestre\Bases de datos I\Proyecto Final\XML\Simulacion.xml',Single_BLOB) AS Clientes(C)

		-- Se cargan en @temp los datos XML de la fecha @fechaIteracion
		SET @temp = (select @DocumentoXML.query('/xml/Simulacion/FechaOperacion[@fecha= sql:variable("@fechaIteracion")]'))

	-- ///	INGRESO DE NUEVOS EMPLEADOS	///
	
	END
END
