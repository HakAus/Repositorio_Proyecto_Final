USE [Proyecto]
GO

/****** Object:  StoredProcedure [dbo].[ReiniciarTablas]    Script Date: 11/25/2019 12:25:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ================================================================================================
-- Autores:		<Austin Hakanson y Antony Artavia>
-- Fecha de creacion: <21-11-2019>
-- Fecha de Ultima Actualizacion: <21-11-2019>
-- Descripcion:	SP para eliminar todos los registros de las tablas y reiniciar los contadores
-- ================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[ReiniciarTablas]

AS
BEGIN
	SET NOCOUNT ON;

    -- /// SCRIPT PARA REINICIAR LAS TABLAS ///
	DELETE FROM [dbo].[PlanillaSemanal]
	DBCC CHECKIDENT ('PlanillaSemanal', RESEED, 0)

	DELETE FROM [dbo].[PlanillaMensual]
	DBCC CHECKIDENT ('PlanillaMensual', RESEED, 0)

	DELETE FROM [Proyecto].[dbo].[MovPlanilla]
	DBCC CHECKIDENT ('MovPlanilla', RESEED, 0)

	DELETE FROM [Proyecto].[dbo].[Asistencia]
	DBCC CHECKIDENT ('Asistencia', RESEED, 0)

	DELETE FROM [Proyecto].[dbo].[DeduccionXEmpleado]
	DBCC CHECKIDENT ('DeduccionXEmpleado', RESEED, 0)

	DELETE FROM [Proyecto].[dbo].[Jornada]
	DBCC CHECKIDENT ('Jornada', RESEED, 0)

	DELETE FROM [Proyecto].[dbo].[Semana]
	DBCC CHECKIDENT ('Semana', RESEED, 0)

	DELETE FROM [Proyecto].[dbo].[Empleado]
	DBCC CHECKIDENT ('Empleado', RESEED, 0)

	DELETE FROM [Proyecto].[dbo].[SalarioPorHora]
	DBCC CHECKIDENT ('SalarioPorHora', RESEED, 0)

	DELETE FROM [Proyecto].[dbo].[Puesto]
	DBCC CHECKIDENT ('Puesto', RESEED, 0)

	DELETE FROM [Proyecto].[dbo].Feriado
	DBCC CHECKIDENT ('Feriado', RESEED, 0)

	DELETE FROM [Proyecto].[dbo].TipoJornada
	DBCC CHECKIDENT ('TipoJornada', RESEED, 0)

	DELETE FROM [Proyecto].[dbo].[TipoMovPlanilla]
	DBCC CHECKIDENT ('TipoMovPlanilla', RESEED, 0)

	DELETE FROM [Proyecto].[dbo].[Fija]

	DELETE FROM [Proyecto].[dbo].[Porcentual]

	DELETE FROM [Proyecto].[dbo].[TipoDeduccion]
	DBCC CHECKIDENT ('TipoDeduccion', RESEED, 0)

END
GO

