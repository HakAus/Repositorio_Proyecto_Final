USE [Proyecto]
GO

/****** Object:  UserDefinedFunction [dbo].[ContarSemanasEnElMes]    Script Date: 11/25/2019 4:27:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================================================
-- Author:		<Austin Hakanson>
-- Fecha creacion: <25-11-2019>
-- Fecha de ultima modificacion: <25-11-2019>
-- Descripcion: <Cuenta la cantidad de semanas entre la fecha actual y el ultimo viernes del mes>
-- ===============================================================================================
CREATE OR ALTER FUNCTION [dbo].[ContarSemanasEnElMes]
(
	-- Parametros
	@fecha date
)
RETURNS int
AS
BEGIN
	DECLARE @Semanas int
	SELECT @Semanas = DATEDIFF(WEEK, M.FechaInicio, M.FechaFin)
	FROM Mes M
	WHERE @fecha BETWEEN M.FechaInicio and M.FechaFin

	-- Return the result of the function
	RETURN @Semanas

END
GO

