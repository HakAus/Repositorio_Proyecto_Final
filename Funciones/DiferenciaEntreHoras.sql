USE [Proyecto]
GO

/****** Object:  UserDefinedFunction [dbo].[DiferenciaEntreHoras]    Script Date: 11/25/2019 4:27:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Autor:		<Austin Hakanson>
-- Fecha creacion: <25-11-2019>
-- Descripcion:	<Funncion de calcula la diferencia entre 2 horas diferentes>
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[DiferenciaEntreHoras]
(
	-- Add the parameters for the function here
	@hora1 time(0), @hora2 time(0)
)
RETURNS int
AS
BEGIN
	DECLARE @Diferencia int

	IF (@hora1 = @hora2)
	BEGIN 
		SET @Diferencia = 0
	END
	ELSE
	BEGIN 
		IF (@hora1 < @hora2)
		SELECT @Diferencia = DATEDIFF(HOUR,@hora1,@hora2)
		ELSE
		SELECT @Diferencia = 24 + DATEDIFF(HOUR,@hora1,@hora2)
	END

	RETURN @Diferencia
END
GO

