USE [Proyecto]
GO

/****** Object:  UserDefinedFunction [dbo].[ObtenerUltimoDiaDelMes]    Script Date: 11/25/2019 4:28:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER function [dbo].[ObtenerUltimoDiaDelMes](@fecha smalldatetime, @NombreDia varchar(9))
RETURNS datetime
AS
BEGIN

DECLARE @anio int = DATEPART(YEAR,@fecha), @mes int = DATEPART(MONTH,@fecha), @Resultado datetime

-- First and Last Sunday by SqlServerCurry.com
select @Resultado = max(dates) from
(
select dateadd(day,number-1,DATEADD(year,@anio-1900,0))
as dates from master..spt_values
where type='p' and number between 1 and
DATEDIFF(day,DATEADD(year,@anio-1900,0),DATEADD(year,@anio-1900+1,0))
) as t
where DATENAME(weekday,dates)=@NombreDia and DATEPART(MONTH,dates) = @mes
group by DATEADD(month,datediff(month,0,dates),0)

RETURN @Resultado
END
GO

