CREATE TABLE [dbo].[iepRef]
(
[iep_Id] [numeric] (20, 0) NULL,
[iepUniqueId] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beginDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[endDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iepBeginDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iepEndDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iepReviewDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastEvaluationDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reasonExitedDescriptor] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schoolHoursPerWeek] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[servedOutsideOfRegularSession] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[specialEducationHoursPerWeek] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialEducationSetting] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exitDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parentResponse] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dateSigned] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Agency] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CostShare] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
