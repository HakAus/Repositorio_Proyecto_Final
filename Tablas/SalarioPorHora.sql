USE [Proyecto]
GO

/****** Object:  Table [dbo].[SalarioPorHora]    Script Date: 11/23/2019 3:22:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SalarioPorHora](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdPuesto] [int] NOT NULL,
	[IdTipoJornada] [int] NOT NULL,
	[Salario] [money] NOT NULL,
 CONSTRAINT [PK_SalarioXHora] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SalarioPorHora]  WITH CHECK ADD  CONSTRAINT [FK_SalarioPorHora_Puesto] FOREIGN KEY([IdPuesto])
REFERENCES [dbo].[Puesto] ([Id])
GO

ALTER TABLE [dbo].[SalarioPorHora] CHECK CONSTRAINT [FK_SalarioPorHora_Puesto]
GO

ALTER TABLE [dbo].[SalarioPorHora]  WITH CHECK ADD  CONSTRAINT [FK_SalarioPorHora_TipoJornada] FOREIGN KEY([IdTipoJornada])
REFERENCES [dbo].[TipoJornada] ([Id])
GO

ALTER TABLE [dbo].[SalarioPorHora] CHECK CONSTRAINT [FK_SalarioPorHora_TipoJornada]
GO

