USE [Proyecto]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[ReiniciarTablas]

SELECT	'Return Value' = @return_value

GO
