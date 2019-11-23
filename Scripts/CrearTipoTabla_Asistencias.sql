USE [Proyecto]
GO

/****** Object:  UserDefinedTableType [dbo].[Asistencias]    Script Date: 11/23/2019 3:15:28 AM ******/
CREATE TYPE [dbo].[Asistencias] AS TABLE(
	[DocumentoIdentificacion] [nvarchar](100) NULL,
	[HoraInicio] [time](0) NULL,
	[HoraFin] [time](0) NULL
)
GO

