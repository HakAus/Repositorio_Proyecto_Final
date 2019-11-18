USE [Proyecto]
GO
/****** Object:  StoredProcedure [dbo].[SP_CargarDatos]    Script Date: 11/18/2019 4:35:19 PM ******/
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

	BEGIN TRY

	DECLARE @Deducciones TABLE
	(
	Sec int identity(1,1),
	Tipo nvarchar(50),
	Detalle nvarchar(50)
	)
	
	-- Insercion del Deduccion 
		DECLARE @DocHandle int, @Deduccion xml, @temp xml
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
