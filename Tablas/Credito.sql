USE [Proyecto]
GO

/****** Object:  Table [dbo].[Credito]    Script Date: 11/23/2019 3:19:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Credito](
	[Id] [int] NOT NULL,
	[IdAsistencia] [int] NOT NULL,
 CONSTRAINT [PK_Credito] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Credito]  WITH CHECK ADD  CONSTRAINT [FK_Credito_Asistencia] FOREIGN KEY([IdAsistencia])
REFERENCES [dbo].[Asistencia] ([Id])
GO

ALTER TABLE [dbo].[Credito] CHECK CONSTRAINT [FK_Credito_Asistencia]
GO

ALTER TABLE [dbo].[Credito]  WITH CHECK ADD  CONSTRAINT [FK_Credito_MovPlanilla] FOREIGN KEY([Id])
REFERENCES [dbo].[MovPlanilla] ([Id])
GO

ALTER TABLE [dbo].[Credito] CHECK CONSTRAINT [FK_Credito_MovPlanilla]
GO

