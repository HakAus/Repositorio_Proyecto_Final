USE [Proyecto]
GO

/****** Object:  StoredProcedure [dbo].[SP_AgregarMes]    Script Date: 11/25/2019 12:29:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================
-- Autor:		<Austin Hakanson>
-- Fecha de creacion: <24-11-2019>
-- Fecha de ultima modificacion: <24-11-2019>
-- Descripcion:	<SP para ir agregar un mes a la tabla Mes>
-- ==============================================================
CREATE OR ALTER PROCEDURE [dbo].[SP_AgregarMes]
	-- Parametros
	@Fecha date
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @UltimaFecha date
		SELECT @UltimaFecha = max(M.FechaFin)
		FROM Mes M

		IF @UltimaFecha IS NOT NULL
		BEGIN
			IF (@UltimaFecha = @Fecha)
			BEGIN
				INSERT INTO Mes
				VALUES
				(
				@Fecha,
				DATEADD(MONTH, 1, @Fecha)
				)
			END
		END
		ELSE
		BEGIN
			INSERT INTO Mes
			VALUES
			(
			@Fecha,
			DATEADD(MONTH, 1, @Fecha)
			)
		END
	END TRY
	BEGIN CATCH
		RETURN @@ERROR * -1
	END CATCH

END
GO

