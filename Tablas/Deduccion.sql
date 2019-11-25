USE [Proyecto]
GO

/****** Object:  Table [dbo].[Deduccion]    Script Date: 11/25/2019 4:26:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Deduccion](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdMovPlanilla] [int] NOT NULL,
 CONSTRAINT [PK_Deduccion] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Deduccion]  WITH CHECK ADD  CONSTRAINT [FK_Deduccion_MovPlanilla] FOREIGN KEY([IdMovPlanilla])
REFERENCES [dbo].[MovPlanilla] ([Id])
GO

ALTER TABLE [dbo].[Deduccion] CHECK CONSTRAINT [FK_Deduccion_MovPlanilla]
GO

