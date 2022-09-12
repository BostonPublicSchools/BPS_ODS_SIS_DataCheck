SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-----------------------------------------------------------------------
--Ragha  08/25/2022   load new IEP
-----------------------------------------------------------------------
CREATE PROCEDURE [dbo].[LoadIEPXML]
AS
BEGIN
SELECT DISTINCT
       iep.[iep_Id],
       stu.studentUniqueId,
       [iepUniqueId],
       [iepBeginDate],
       [iepEndDate],
       [dateSigned] AS BeginDate,
       [ed].[educationOrganizationId],
       prog.educationOrganizationId AS ProgramEdOrgID
	   INTO #stgiepref
FROM dbo.IEPRef iep
    FULL OUTER JOIN dbo.StudentRef stu
        ON stu.iep_Id = iep.iep_Id
    FULL OUTER JOIN dbo.EdOrgRef ed
        ON ed.iep_Id = iep.iep_Id
    FULL OUTER JOIN dbo.ProgRef prog
        ON prog.iep_Id = iep.iep_Id
    FULL OUTER JOIN dbo.ServiceRef ser
        ON ser.iep_Id = iep.iep_Id
WHERE iep.iepUniqueId IS NOT NULL
AND stu.studentUniqueId IS NOT NULL
;

INSERT INTO dbo.StudentIEPRef
(
    [iep_Id],
    [studentUniqueId],
    [iepUniqueId],
    [iepBeginDate],
    [iepEndDate],
    [dateSigned],
    [educationOrganizationId],
    [ProgramEdOrgId],
	[LoadDate]
)
SELECT DISTINCT
       [iep_Id],
       studentUniqueId,
       [iepUniqueId],
       [iepBeginDate],
       [iepEndDate],
       BeginDate,
       [educationOrganizationId],
       ProgramEdOrgID,
	   --'2022-09-23' AS LoadDate
	   GETDATE() AS LoadDate
FROM #stgiepref stg
WHERE EXISTS
(
    SELECT 1
    FROM dbo.StudentIEPRef iep
    WHERE iep.iepUniqueId = stg.iepUniqueId
          AND
          (
              iep.studentUniqueId <> stg.studentUniqueId
              OR iep.[iepBeginDate] <> stg.iepBeginDate
              OR iep.[iepEndDate] <> stg.iepEndDate
              OR iep.dateSigned <> stg.BeginDate
              OR iep.[educationOrganizationId] <> stg.educationOrganizationId
              OR iep.ProgramEdOrgID <> stg.ProgramEdOrgID
          )
);

TRUNCATE TABLE dbo.IEPRef;
TRUNCATE TABLE dbo.StudentRef;
TRUNCATE TABLE dbo.EdOrgRef;
TRUNCATE TABLE dbo.ServiceRef;
TRUNCATE TABLE dbo.ProgRef;
DROP TABLE #stgiepref;

END
GO
