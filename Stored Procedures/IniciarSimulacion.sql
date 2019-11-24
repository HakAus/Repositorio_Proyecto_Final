USE [Proyecto]
GO

/****** Object:  StoredProcedure [dbo].[IniciarSimulacion]    Script Date: 11/24/2019 7:30:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[IniciarSimulacion]
AS
BEGIN
	EXEC ReiniciarTablas
	EXEC SP_CargarDatos
	EXEC Simulacion
END
GO

