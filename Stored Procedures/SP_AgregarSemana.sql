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
CREATE PROCEDURE AgregarSemana
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
