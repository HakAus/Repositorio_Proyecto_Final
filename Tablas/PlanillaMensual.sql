USE [Proyecto]
GO

/****** Object:  Table [dbo].[PlanillaMensual]    Script Date: 11/23/2019 3:22:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PlanillaMensual](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdDeduccionTotal] [int] NOT NULL,
	[SalarioTotal] [money] NOT NULL,
	[SalarioNeto] [money] NOT NULL,
 CONSTRAINT [PK_PlanillaMensual] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PlanillaMensual]  WITH CHECK ADD  CONSTRAINT [FK_PlanillaMensual_DeduccionTotal] FOREIGN KEY([IdDeduccionTotal])
REFERENCES [dbo].[DeduccionTotal] ([Id])
GO

ALTER TABLE [dbo].[PlanillaMensual] CHECK CONSTRAINT [FK_PlanillaMensual_DeduccionTotal]
GO

