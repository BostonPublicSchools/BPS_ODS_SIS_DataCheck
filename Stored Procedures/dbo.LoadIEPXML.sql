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
       ISNULL(prog.educationOrganizationId,350000) AS ProgramEdOrgID
INTO #stgiepref
FROM dbo.iepRef iep
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

SELECT stu.iepUniqueId,
       stu.studentUniqueId,
       stu.iepBeginDate,
       stu.iepEndDate,
       stu.ProgramEdOrgId,
       stu.educationOrganizationId,
       stu.dateSigned,
	   stu.LoadDate
	   INTO #maxtemp
FROM dbo.StudentIEPRefv1 stu
WHERE LoadDate =
(
    SELECT MAX(LoadDate)
    FROM dbo.StudentIEPRefv1 ref
    WHERE ISNULL(stu.studentUniqueId ,'')= ISNULL(ref.studentUniqueId,'')
          AND ISNULL(stu.iepUniqueId,'') = ISNULL(ref.iepUniqueId,'')
          
)
;

INSERT INTO dbo.StudentIEPRefv1
(
    [iep_Id],
    [studentUniqueId],
    [iepUniqueId],
    [iepBeginDate],
    [iepEndDate],
    [dateSigned],
    [educationOrganizationId],
    [ProgramEdOrgId],
	LoadDate
)
SELECT DISTINCT
       stg.[iep_Id],
       stg.studentUniqueId,
       stg.[iepUniqueId],
       stg.[iepBeginDate],
       stg.[iepEndDate],
       stg.BeginDate,
       stg.[educationOrganizationId],
       ISNULL(stg.ProgramEdOrgID,350000),
       GETDATE()
--GETDATE()
FROM #stgiepref stg
    INNER JOIN dbo.StudentIEPRefv1 iep
        ON iep.iepUniqueId = stg.iepUniqueId
           AND
           (
               ISNULL(iep.studentUniqueId,'') <> ISNULL(stg.studentUniqueId,'')
               OR ISNULL(iep.[iepBeginDate],'') <> ISNULL(stg.iepBeginDate,'')
               OR ISNULL(iep.[iepEndDate],'') <> ISNULL(stg.iepEndDate,'')
               OR ISNULL(iep.dateSigned,'') <> ISNULL(stg.BeginDate,'')
               OR ISNULL(iep.[educationOrganizationId],'') <> ISNULL(stg.educationOrganizationId,'')
               OR ISNULL(iep.ProgramEdOrgId,'') <> ISNULL(stg.ProgramEdOrgID,'')
           )
WHERE NOT EXISTS
(
    SELECT 1
    FROM #maxtemp temp
    WHERE ISNULL(temp.educationOrganizationId,'') = ISNULL(stg.educationOrganizationId,'')
          AND ISNULL(temp.iepBeginDate,'') = ISNULL(stg.iepBeginDate,'')
          AND ISNULL(temp.iepEndDate,'') = ISNULL(stg.iepEndDate,'')
          AND ISNULL(temp.iepUniqueId,'') = ISNULL(stg.iepUniqueId,'')
          AND ISNULL(temp.ProgramEdOrgId ,'')= ISNULL(stg.ProgramEdOrgID,'')
          AND ISNULL(temp.studentUniqueId,'') = ISNULL(stg.studentUniqueId,'')
          AND ISNULL(temp.dateSigned,'') = ISNULL(stg.BeginDate,''))
;
INSERT INTO dbo.StudentIEPRefv1
(
    [iep_Id],
    [studentUniqueId],
    [iepUniqueId],
    [iepBeginDate],
    [iepEndDate],
    [dateSigned],
    [educationOrganizationId],
    [ProgramEdOrgId],
	LoadDate
)
SELECT DISTINCT
       stg.[iep_Id],
       stg.studentUniqueId,
       stg.[iepUniqueId],
       stg.[iepBeginDate],
       stg.[iepEndDate],
       stg.BeginDate,
       stg.[educationOrganizationId],
       ISNULL(stg.ProgramEdOrgID,350000),
       GETDATE()
--GETDATE()
FROM #stgiepref stg
    WHERE NOT EXISTS(SELECT 1 from dbo.StudentIEPRefv1 iepuni
        where iepuni.iepUniqueId = stg.iepUniqueId)

DROP TABLE #stgiepref;
DROP TABLE #maxtemp;

END;
GO
