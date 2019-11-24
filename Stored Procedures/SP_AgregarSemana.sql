USE [Proyecto]
GO

/****** Object:  StoredProcedure [dbo].[SP_AgregarSemana]    Script Date: 11/24/2019 7:31:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================
-- Author:		<Austin Hakanson y Antony Artavia>
-- Fecha de creacion: <22-11-2019>
-- Fecha de ultima modificacion: <22-11-2019>
-- Description:	<SP para ir agregar una semana a la tabla Semana>
-- ==============================================================
CREATE OR ALTER PROCEDURE [dbo].[SP_AgregarSemana]
	-- Parametros
	@Fecha date
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @UltimaFecha date
		SELECT @UltimaFecha = max(S.FechaFin)
		FROM Semana S

		IF @UltimaFecha IS NOT NULL
		BEGIN
			IF (@UltimaFecha = @Fecha)
			BEGIN
				INSERT INTO Semana
				VALUES
				(
				@Fecha,
				DATEADD(WEEK, 1, @Fecha)
				)
			END
		END
		ELSE
		BEGIN
			INSERT INTO Semana
			VALUES
			(
			@Fecha,
			DATEADD(WEEK, 1, @Fecha)
			)
		END
	END TRY
	BEGIN CATCH
		RETURN @@ERROR * -1
	END CATCH

END
GO

