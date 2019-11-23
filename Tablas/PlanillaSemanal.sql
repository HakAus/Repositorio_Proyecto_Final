USE [Proyecto]
GO

/****** Object:  Table [dbo].[PlanillaSemanal]    Script Date: 11/23/2019 3:22:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PlanillaSemanal](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdSemana] [int] NOT NULL,
	[IdMovPlanilla] [int] NOT NULL,
	[SalarioMensual] [money] NOT NULL,
 CONSTRAINT [PK_PlanillaSemanal] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PlanillaSemanal]  WITH CHECK ADD  CONSTRAINT [FK_PlanillaSemanal_MovPlanilla] FOREIGN KEY([IdMovPlanilla])
REFERENCES [dbo].[MovPlanilla] ([Id])
GO

ALTER TABLE [dbo].[PlanillaSemanal] CHECK CONSTRAINT [FK_PlanillaSemanal_MovPlanilla]
GO

ALTER TABLE [dbo].[PlanillaSemanal]  WITH CHECK ADD  CONSTRAINT [FK_PlanillaSemanal_Semana] FOREIGN KEY([IdSemana])
REFERENCES [dbo].[Semana] ([Id])
GO

ALTER TABLE [dbo].[PlanillaSemanal] CHECK CONSTRAINT [FK_PlanillaSemanal_Semana]
GO

