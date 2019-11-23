USE [Proyecto]
GO

/****** Object:  StoredProcedure [dbo].[SP_AgregarDeduccion]    Script Date: 11/23/2019 3:12:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===================================================================
-- Autor:		<Austin Hakanson>
-- Fecha de creacion: <22-11-2019>
-- Fecha de ultima creacion: <22-11-2019>
-- Descripcion: <SP para ingresar las deducciones a los empleados>
-- ===================================================================
CREATE OR ALTER PROCEDURE [dbo].[SP_AgregarDeduccion]
	-- Parametros
	@xml xml
AS
BEGIN

	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @NuevasDeducciones Deducciones
		DECLARE @InicioTran int = 0
		IF (@@TRANCOUNT = 0)
		BEGIN
			SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
			BEGIN TRANSACTION AgregarDeducciones
			SET @InicioTran = 1
		END

		-- Se agregan los datos del xml a la variable tabla
		INSERT INTO @NuevasDeducciones
		SELECT Tab.Col.value('(@docId)[1]','nvarchar(100)'),
			   Tab.Col.value('(@tipoDeduccion)[1]','nvarchar(100)'),
			   Tab.Col.value('(@monto)[1]','money')
		FROM @xml.nodes('FechaOperacion/DeduccionxEmp') Tab(Col)

		-- Agregar deduccion
		INSERT INTO DeduccionXEmpleado
		SELECT TD.Id, E.Id, N.TipoDeduccion, N.Monto
		FROM @NuevasDeducciones N
		INNER JOIN Empleado E ON E.DocumentoIdentificacion = N.DocumentoIdentificacion
		INNER JOIN TipoDeduccion TD ON TD.Nombre = N.TipoDeduccion
			
		IF (@InicioTran = 1)
		BEGIN
			COMMIT TRANSACTION AgregarDeducciones
		END
	END TRY

	BEGIN CATCH
	IF (@InicioTran = 1)
	BEGIN
		ROLLBACK TRANSACTION AgregarDeducciones
	END
	RETURN @@ERROR * -1

	END CATCH

END
GO

