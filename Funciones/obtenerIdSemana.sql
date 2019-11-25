USE [Proyecto]
GO

/****** Object:  UserDefinedFunction [dbo].[obtenerIdSemana]    Script Date: 11/25/2019 4:28:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =====================================================================================
-- Autor:		<Austin Hakanson>
-- Fecha de creacion: <24-11-2019>
-- Fecha de ultima modificacion: <24-11-2019>
-- Descripcion:	<Funcion que devuelve el id de la semana a la pertenece una fecha dada>
-- =====================================================================================
CREATE OR ALTER FUNCTION [dbo].[obtenerIdSemana]
(
	-- Parametros
	@Fecha date
)
RETURNS int
AS
BEGIN

	DECLARE @IdSemana int

	SELECT @IdSemana = S.Id 
	FROM Semana S
	WHERE @Fecha >= S.FechaInicio and @Fecha < S.FechaFin

	RETURN @IdSemana
END
GO

