CREATE TABLE [dbo].[EdFiMigrationCalendarConfig]
(
[Schoolid] [smallint] NOT NULL,
[SchoolYear] [smallint] NOT NULL,
[BeginDate] [date] NOT NULL,
[EndDate] [date] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EdFiMigrationCalendarConfig] ADD CONSTRAINT [PK_EdFiMigrationCalendarConfig] PRIMARY KEY CLUSTERED ([Schoolid], [SchoolYear]) ON [PRIMARY]
GO
