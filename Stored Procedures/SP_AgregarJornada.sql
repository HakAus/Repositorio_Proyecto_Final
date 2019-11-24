USE [Proyecto]
GO

/****** Object:  StoredProcedure [dbo].[SP_AgregarJornada]    Script Date: 11/24/2019 7:32:30 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =================================================================
-- Autor:		<Austin Hakanson>
-- Fecha creacion: <23-11-2019>
-- Fecha ultima modificacion: <23-11-2019>
-- Descripcion: <SP para agregar nuevas jornadas a los empleados 
--				desde el xml que recibe por parametro>
-- =================================================================
CREATE OR ALTER PROCEDURE [dbo].[SP_AgregarJornada]
	-- Parametros
	@xml xml
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY 
		DECLARE @UltimaSemana int, @CambiosTipoJornada TipoJornada

		INSERT INTO @CambiosTipoJornada
		SELECT Tab.Col.value('(@docId)[1]','nvarchar(100)'),
				Tab.Col.value('(@jornada)[1]','nvarchar(100)')
		FROM @xml.nodes('FechaOperacion/TipoJornada') Tab(Col)

		-- Se obtiene el id de la semana mas reciente
		SELECT @UltimaSemana = max(S.Id)
		FROM Semana S

		-- Se inserta la nueva jornada
		INSERT INTO Jornada
		SELECT E.Id, TJ.Id, S.Id
		FROM @CambiosTipoJornada C
		INNER JOIN Empleado E ON E.DocumentoIdentificacion = C.DocumentoIdentificacion
		INNER JOIN TipoJornada TJ ON TJ.Nombre = C.Jornada
		INNER JOIN Semana S ON S.Id = @UltimaSemana
	END TRY
	BEGIN CATCH
		RETURN @@ERROR * -1
	END CATCH
END
GO

