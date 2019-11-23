USE [Proyecto]
GO

/****** Object:  UserDefinedTableType [dbo].[TipoJornada]    Script Date: 11/23/2019 3:16:16 AM ******/
CREATE TYPE [dbo].[TipoJornada] AS TABLE(
	[DocumentoIdentificacion] [nvarchar](100) NULL,
	[Jornada] [nvarchar](100) NULL
)
GO

