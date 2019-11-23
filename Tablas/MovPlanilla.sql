USE [Proyecto]
GO

/****** Object:  Table [dbo].[MovPlanilla]    Script Date: 11/23/2019 3:22:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MovPlanilla](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdTipoPlanilla] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[Monto] [money] NOT NULL,
	[Descripcion] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_MovPlanilla] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[MovPlanilla]  WITH CHECK ADD  CONSTRAINT [FK_MovPlanilla_TipoMovPlanilla] FOREIGN KEY([IdTipoPlanilla])
REFERENCES [dbo].[TipoMovPlanilla] ([Id])
GO

ALTER TABLE [dbo].[MovPlanilla] CHECK CONSTRAINT [FK_MovPlanilla_TipoMovPlanilla]
GO
