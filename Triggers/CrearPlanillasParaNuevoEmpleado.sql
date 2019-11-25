USE [Proyecto]
GO

/****** Object:  Trigger [dbo].[CrearPlanillasParaNuevoEmpleado]    Script Date: 11/25/2019 12:32:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================================================
-- Autor:		<Austin Hakanson>
-- Fecha de creacion: <24-11-2019>
-- Fecha de ultima actualizacion: <24-11-2019>
-- Descripcion:	<Trigger que crea una planilla mensual y semanal para un empleado recientemente contratado>
-- ==========================================================================================================
CREATE OR ALTER TRIGGER [dbo].[CrearPlanillasParaNuevoEmpleado] ON [dbo].[Empleado]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @InicioTran int = 0
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
		BEGIN TRANSACTION IniciarPlanillas
		SET @InicioTran = 1

		DECLARE @Empleados TABLE
		(
		Sec int identity(1,1),
		IdEmpleado int
		)
		INSERT INTO @Empleados
		SELECT EmpleadoNuevo.Id 
		FROM inserted EmpleadoNuevo;

		-- Se inserta el id del empleado insertado y el id del ultimo mes agregado
		-- con salario total y neto en 0
		INSERT INTO PlanillaMensual
		SELECT max(M.Id),E.IdEmpleado,0,0
		FROM Mes M, @Empleados E
		GROUP BY E.IdEmpleado

		-- Se inserta el id de la ultima semana agregada, el id del empleado agregado
		-- el id de la planilla mensual del empleado insertado y el salario devengado en 0
		INSERT INTO PlanillaSemanal
		SELECT max(S.Id), E.IdEmpleado, PM.Id, 0
		FROM Semana S, @Empleados E
		INNER JOIN PlanillaMensual PM ON PM.IdEmpleado = E.IdEmpleado
		GROUP BY PM.Id, E.IdEmpleado

		COMMIT TRANSACTION IniciarPlanillas
	END TRY
	BEGIN CATCH
		IF (@InicioTran = 1)
		BEGIN
			ROLLBACK TRANSACTION IniciarPlanillas
		END
	END CATCH
	

END
GO

ALTER TABLE [dbo].[Empleado] ENABLE TRIGGER [CrearPlanillasParaNuevoEmpleado]
GO

