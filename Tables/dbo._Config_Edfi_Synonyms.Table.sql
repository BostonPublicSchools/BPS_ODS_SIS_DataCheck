USE [BPSDataCheck]
GO
/****** Object:  Table [dbo].[_Config_Edfi_Synonyms]    Script Date: 2/26/2024 2:18:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_Config_Edfi_Synonyms](
	[Id] [int] NOT NULL,
	[edfi_syn_name] [nvarchar](max) NOT NULL,
	[edfi_db_object] [nvarchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
