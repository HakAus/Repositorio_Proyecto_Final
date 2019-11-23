USE [Proyecto]
GO

/****** Object:  StoredProcedure [dbo].[SP_AgregarSemana]    Script Date: 11/23/2019 3:13:40 AM ******/
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
	@Fecha date
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO Semana
	VALUES
	(
	@Fecha,
	DATEADD(WEEK, 1, @Fecha)
	)

END
GO

