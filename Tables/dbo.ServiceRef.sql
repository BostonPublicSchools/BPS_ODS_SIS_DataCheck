CREATE TABLE [dbo].[ServiceRef]
(
[serviceDescriptor] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serviceDuration] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serviceDurationIn] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serviceDurationPer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serviceDurationFrequency] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serviceBeginDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serviceEndDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serviceLocation] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serviceClass] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iep_Id] [numeric] (20, 0) NULL
) ON [PRIMARY]
GO
