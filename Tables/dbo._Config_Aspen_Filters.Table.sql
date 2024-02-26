USE [BPSDataCheck]
GO
/****** Object:  Table [dbo].[_Config_Aspen_Filters]    Script Date: 2/26/2024 2:18:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_Config_Aspen_Filters](
	[Id] [int] NOT NULL,
	[SchoolYearId] [nvarchar](max) NOT NULL,
	[SchoolYear] [numeric](4, 0) NULL,
	[StartDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
