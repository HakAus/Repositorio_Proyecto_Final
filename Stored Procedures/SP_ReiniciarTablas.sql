USE [Proyecto]
GO

/****** Object:  StoredProcedure [dbo].[ReiniciarTablas]    Script Date: 11/22/2019 7:45:42 AM ******/
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

	DELETE FROM [Proyecto].[dbo].[Puesto]
	DBCC CHECKIDENT ('Puesto', RESEED, 0)

	DELETE FROM [Proyecto].[dbo].Feriado
	DBCC CHECKIDENT ('Feriado', RESEED, 0)

	DELETE FROM [Proyecto].[dbo].TipoJornada
	DBCC CHECKIDENT ('TipoJornada', RESEED, 0)

	DELETE FROM [Proyecto].[dbo].[TipoMovPlanilla]
	DBCC CHECKIDENT ('TipoMovPlanilla', RESEED, 0)


END
GO

