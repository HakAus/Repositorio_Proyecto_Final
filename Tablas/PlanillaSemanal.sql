USE [Proyecto]
GO

/****** Object:  Table [dbo].[PlanillaSemanal]    Script Date: 11/24/2019 7:29:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PlanillaSemanal](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdEmpleado] [int] NOT NULL,
	[IdSemana] [int] NOT NULL,
	[IdPlanillaMensual] [int] NOT NULL,
	[SalarioDevengado] [money] NOT NULL,
 CONSTRAINT [PK_PlanillaSemanal] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PlanillaSemanal]  WITH CHECK ADD  CONSTRAINT [FK_PlanillaSemanal_Empleado] FOREIGN KEY([IdEmpleado])
REFERENCES [dbo].[Empleado] ([Id])
GO

ALTER TABLE [dbo].[PlanillaSemanal] CHECK CONSTRAINT [FK_PlanillaSemanal_Empleado]
GO

ALTER TABLE [dbo].[PlanillaSemanal]  WITH CHECK ADD  CONSTRAINT [FK_PlanillaSemanal_PlanillaMensual] FOREIGN KEY([IdPlanillaMensual])
REFERENCES [dbo].[PlanillaMensual] ([Id])
GO

ALTER TABLE [dbo].[PlanillaSemanal] CHECK CONSTRAINT [FK_PlanillaSemanal_PlanillaMensual]
GO

ALTER TABLE [dbo].[PlanillaSemanal]  WITH CHECK ADD  CONSTRAINT [FK_PlanillaSemanal_Semana] FOREIGN KEY([IdSemana])
REFERENCES [dbo].[Semana] ([Id])
GO

ALTER TABLE [dbo].[PlanillaSemanal] CHECK CONSTRAINT [FK_PlanillaSemanal_Semana]
GO

