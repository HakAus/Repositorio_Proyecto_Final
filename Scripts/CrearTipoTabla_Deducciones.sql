USE [Proyecto]
GO

/****** Object:  UserDefinedTableType [dbo].[Deducciones]    Script Date: 11/23/2019 3:15:43 AM ******/
CREATE TYPE [dbo].[Deducciones] AS TABLE(
	[DocumentoIdentificacion] [nvarchar](100) NULL,
	[TipoDeduccion] [nvarchar](100) NULL,
	[Monto] [money] NULL
)
GO

