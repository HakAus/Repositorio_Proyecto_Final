USE [Proyecto]
GO

/****** Object:  StoredProcedure [dbo].[SP_AgregarEmpleado]    Script Date: 11/23/2019 3:13:12 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================
-- Autores: <Austin Hakanson y Antony Artavia>
-- Fecha creacion: <22-11-2019>
-- Fecha de ultima modificacion: <22-11-2019>
-- Descripcion: <SP para la creacion de un nuevo empleado en la simulacion>
-- ============================================================================
CREATE OR ALTER PROCEDURE [dbo].[SP_AgregarEmpleado]
	-- Parametros
	@xml xml,
	@fechaIteracion date
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @NuevosEmpleados Empleados 
		DECLARE @InicioTran int

		IF (@@TRANCOUNT = 0)	-- Para correr solo una transaccion a la vez
		BEGIN
			SET TRANSACTION ISOLATION LEVEL READ COMMITTED
			BEGIN TRANSACTION AgregarEmpleado
			SET @InicioTran = 1
		END

		-- Se carga el xml en el tipo de variable tabla
		INSERT INTO @NuevosEmpleados
		SELECT Tab.Col.value('(@docId)[1]','nvarchar(100)'),
			   Tab.Col.value('(@nombre)[1]','nvarchar(100)'),
		       Tab.Col.value('(@puesto)[1]','nvarchar(100)'),
		       Tab.Col.value('(@jornadaInicial)[1]','nvarchar(100)')
		FROM @xml.nodes('FechaOperacion/NuevoEmpleado') Tab(Col)	

		-- Se inserta el empleado
		INSERT INTO Empleado (IdPuesto, Nombre, DocumentoIdentificacion)
		SELECT P.Id, N.Nombre, N.DocumentoIdentificacion
		FROM @NuevosEmpleados N
		INNER JOIN Puesto P ON P.Puesto = N.Puesto
		INNER JOIN TipoJornada TJ ON TJ.Nombre = N.JornadaInicial

		-- Se asigna la jornada al empleado
		INSERT INTO Jornada
		SELECT DISTINCT E.Id, TJ.Id, S.Id
		FROM @NuevosEmpleados N
		INNER JOIN Empleado E ON E.DocumentoIdentificacion = N.DocumentoIdentificacion
		INNER JOIN TipoJornada TJ ON TJ.Nombre = N.JornadaInicial
		INNER JOIN Semana S ON S.FechaInicio = @fechaIteracion

		IF (@InicioTran = 1)
		BEGIN 
			COMMIT TRANSACTION AgregarEmpleado		-- Si todo esta correcto se hace el commit de la transaccion
		END
	END TRY
	BEGIN CATCH
		IF (@InicioTran = 1)
		BEGIN 
			ROLLBACK TRANSACTION AgregarEmpleado	-- Si hay error se hace revierten los cambios
		END
		RETURN @@ERROR * -1
	END CATCH
END
GO

