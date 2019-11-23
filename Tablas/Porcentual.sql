USE [Proyecto]
GO

/****** Object:  Table [dbo].[Porcentual]    Script Date: 11/23/2019 3:22:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Porcentual](
	[Id] [int] NOT NULL,
 CONSTRAINT [PK_Porcentual] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Porcentual]  WITH CHECK ADD  CONSTRAINT [FK_Porcentual_TipoDeduccion] FOREIGN KEY([Id])
REFERENCES [dbo].[TipoDeduccion] ([Id])
GO

ALTER TABLE [dbo].[Porcentual] CHECK CONSTRAINT [FK_Porcentual_TipoDeduccion]
GO

