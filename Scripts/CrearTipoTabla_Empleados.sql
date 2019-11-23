USE [Proyecto]
GO

/****** Object:  UserDefinedTableType [dbo].[Empleados]    Script Date: 11/23/2019 3:16:00 AM ******/
CREATE TYPE [dbo].[Empleados] AS TABLE(
	[DocumentoIdentificacion] [nvarchar](100) NULL,
	[Nombre] [nvarchar](100) NULL,
	[Puesto] [nvarchar](100) NULL,
	[JornadaInicial] [nvarchar](100) NULL
)
GO

