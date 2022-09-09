CREATE TABLE [dbo].[StudentIEPRef]
(
[iep_Id] [numeric] (20, 0) NULL,
[studentUniqueId] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iepUniqueId] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iepBeginDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iepEndDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dateSigned] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[educationOrganizationId] [bigint] NULL,
[ProgramEdOrgId] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
