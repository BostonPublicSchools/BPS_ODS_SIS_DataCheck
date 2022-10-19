CREATE TABLE [dbo].[StudentIEPRefv1]
(
[iep_Id] [numeric] (20, 0) NULL,
[studentUniqueId] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iepUniqueId] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iepBeginDate] [date] NULL,
[iepEndDate] [date] NULL,
[dateSigned] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[educationOrganizationId] [bigint] NULL,
[ProgramEdOrgId] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [date] NULL
) ON [PRIMARY]
GO
