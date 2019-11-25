USE [Proyecto]
GO

/****** Object:  UserDefinedFunction [dbo].[esUltimoDiaDelMes]    Script Date: 11/25/2019 12:31:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER function [dbo].[esUltimoDiaDelMes](@fecha smalldatetime, @dia varchar(10))
RETURNS int
AS
BEGIN
--DSG 11/11/2015 You can pass in a date and dayofweek like: getdate(), 'Friday' and the function will return 1 if the date you passed in was the last Friday of the month.
--Example call:
--if dbo.isDateLastXDayOfMonth('12/25/2015','Friday')=1 select 'Yes' else select 'No'
select @fecha=CONVERT(char(10), @fecha,126)
declare @year int
set @year =datepart(yyyy,@fecha)
declare @retval int
select @retval=case when @fecha=last_friday then 1 else 0 end from (
select min(dates) as first_friday,max(dates) as last_friday from
(
select dateadd(day,number-1,DATEADD(year,@year-1900,0))
as dates from master..spt_values
where type='p' and number between 1 and
DATEDIFF(day,DATEADD(year,@year-1900,0),DATEADD(year,@year-1900+1,0))
) as t
where DATENAME(weekday,dates)= @dia 
group by DATEADD(month,datediff(month,0,dates),0)
)x where datepart(mm,last_friday)=datepart(mm,@fecha)
RETURN @retval
END
GO

