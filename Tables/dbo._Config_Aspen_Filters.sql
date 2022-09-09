CREATE TABLE [dbo].[_Config_Aspen_Filters]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[SchoolYear] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_Config_Aspen_Filters] ADD CONSTRAINT [PK_Aspen_Filters] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
