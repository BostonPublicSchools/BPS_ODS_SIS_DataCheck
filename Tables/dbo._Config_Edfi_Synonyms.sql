CREATE TABLE [dbo].[_Config_Edfi_Synonyms]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[edfi_syn_name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[edfi_db_object] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[_Config_Edfi_Synonyms] ADD CONSTRAINT [PK_Logs] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
