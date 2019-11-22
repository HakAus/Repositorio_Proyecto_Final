-- /// SCRIPT PARA REINICIAR LAS TABLAS ///

DELETE FROM [Proyecto].[dbo].[Puesto]
DBCC CHECKIDENT ('Puesto', RESEED, 0)

DELETE FROM [Proyecto].[dbo].Feriado
DBCC CHECKIDENT ('Feriado', RESEED, 0)

DELETE FROM [Proyecto].[dbo].TipoJornada
DBCC CHECKIDENT ('TipoJornada', RESEED, 0)

DELETE FROM [Proyecto].[dbo].[TipoMovPlanilla]
DBCC CHECKIDENT ('TipoMovPlanilla', RESEED, 0)

