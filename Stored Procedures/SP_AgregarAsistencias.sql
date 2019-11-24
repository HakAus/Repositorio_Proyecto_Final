USE [Proyecto]
GO

/****** Object:  StoredProcedure [dbo].[SP_AgregarAsistencias]    Script Date: 11/24/2019 7:31:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ================================================================
-- Autor:		<Austin Hakanson>
-- Fecha de creacion: <23-11-2019>
-- Fecha de ultima modificacion: <23-11-2019>
-- Descripcion: <SP para insertar una asistencia de un empleado>
-- ================================================================
CREATE OR ALTER PROCEDURE [dbo].[SP_AgregarAsistencias]
	-- Parametros
	@xml xml
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @NuevasAsistencias Asistencias 
	DECLARE @InicioTran int = 0

	BEGIN TRY
		IF (@@TRANCOUNT = 0) -- Para que las transacciones corran solas
		BEGIN
			SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
			BEGIN TRANSACTION AgregarAsistencias
			SET @InicioTran = 1
			-- Se insertan los datos del xml en el la variable de tipo tabla 
			INSERT INTO @NuevasAsistencias
			SELECT Tab.Col.value('(@docId)[1]','nvarchar(100)'),
				   Tab.Col.value('(@horaInicio)[1]','time(0)'),			   
				   Tab.Col.value('(@horaFin)[1]','time(0)')
			FROM @xml.nodes('FechaOperacion/Asistencia') Tab(Col)

			INSERT INTO Asistencia
			SELECT J.Id, N.HoraInicio, N.HoraFin
			FROM @NuevasAsistencias N		
			INNER JOIN Jornada J ON J.IdEmpleado = (SELECT E.Id FROM Empleado E WHERE E.DocumentoIdentificacion = N.DocumentoIdentificacion)

			COMMIT TRANSACTION AgregarAsistencias
		END
	END TRY

	BEGIN CATCH
		IF (@InicioTran = 1)
		BEGIN
			ROLLBACK TRANSACTION AgregarAsistencia
		END
		RETURN @@ERROR * -1
	END CATCH

	
    
END
GO

