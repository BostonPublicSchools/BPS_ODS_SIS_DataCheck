USE [BPS_ODS_SIS_DataCheck]
GO
/****** Object:  StoredProcedure [dbo].[CheckODSSISSectionData]    Script Date: 8/14/2020 5:03:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------
---- Author:		Ragha
---- Create date: 2020-05-04
---- Description:	Compare Section Data in EDFI not Matching 
----WITH Student and Master Schedule in ASPEN 
-----------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[CheckODSSISSectionData]
AS
BEGIN
SELECT CAST(SC.SchoolId AS VARCHAR(20)) AS SchooldId,
       CS.CourseCode,
       CS.CourseDescription,
       COUNT(CS.CourseCode) AS ENRL_Count --SSA.* --DISTINCT CS.CourseDescription
FROM EdFi_BPS_Production_Ods.edfi.Section AS SC
    JOIN EdFi_BPS_Production_Ods.edfi.CourseOffering AS CO
        ON CO.LocalCourseCode = SC.LocalCourseCode 
           AND CO.SchoolId = SC.SchoolId
           AND CO.SchoolYear = SC.SchoolYear
           AND CO.TermDescriptorId = SC.TermDescriptorId
    INNER JOIN EdFi_BPS_Production_Ods.edfi.Course AS CS
        ON CS.EducationOrganizationId = CO.EducationOrganizationId
           AND CS.CourseCode = CO.CourseCode
WHERE --SC.SchoolId = 1010
      --AND SC.ClassPeriodName = 'Homeroom'
      --AND 
	  SC.SchoolYear = '2020'
GROUP BY SC.SchoolId,
         CS.CourseCode,
         CS.CourseDescription
--ORDER BY CS.CourseCode ASC
EXCEPT
SELECT SKL_SCHOOL_ID COLLATE SQL_Latin1_General_CP1_CI_AS,
       CRS_COURSE_NUMBER COLLATE SQL_Latin1_General_CP1_CI_AS,
       CRS_COURSE_DESCRIPTION COLLATE SQL_Latin1_General_CP1_CI_AS,
       COUNT(CRS_COURSE_NUMBER)
FROM [BPSDATA-03].ExtractAspen.dbo.SCHEDULE_MASTER
    JOIN [BPSDATA-03].ExtractAspen.dbo.SCHEDULE
        ON SCH_OID = MST_SCH_OID
    JOIN [BPSDATA-03].ExtractAspen.dbo.SCHOOL_SCHEDULE_CONTEXT
        ON SCH_OID = SKX_SCH_OID_ACTIVE
    JOIN [BPSDATA-03].ExtractAspen.dbo.SCHOOL
        ON SCH_SKL_OID = SKL_OID
           --AND SKL_SCHOOL_ID = '1010'
    JOIN [BPSDATA-03].ExtractAspen.dbo.DISTRICT_SCHOOL_YEAR_CONTEXT
        ON CTX_OID = SCH_CTX_OID
    JOIN [BPSDATA-03].ExtractAspen.dbo.ORGANIZATION
        ON CTX_OID = ORG_CTX_OID_CURRENT
           AND ORG_ORG_OID_PARENT IS NULL
    JOIN [BPSDATA-03].ExtractAspen.dbo.COURSE_SCHOOL
        ON CSK_OID = MST_CSK_OID
    JOIN [BPSDATA-03].ExtractAspen.dbo.COURSE
        ON CSK_CRS_OID = CRS_OID
WHERE COALESCE(CRS_FIELDA_002, '0') = '0' -- Exculded items for ODS Import 
      AND MST_ENROLLMENT_TOTAL > 0
	  AND CRS_MASTER_TYPE='Class'
--AND MST_DESCRIPTION = 'Homeroom'
GROUP BY SKL_SCHOOL_ID,
         CRS_COURSE_NUMBER,
         CRS_COURSE_DESCRIPTION
UNION
SELECT SKL_SCHOOL_ID COLLATE SQL_Latin1_General_CP1_CI_AS,
       CRS_COURSE_NUMBER COLLATE SQL_Latin1_General_CP1_CI_AS,
       CRS_COURSE_DESCRIPTION COLLATE SQL_Latin1_General_CP1_CI_AS,
       COUNT(CRS_COURSE_NUMBER)
FROM [BPSDATA-03].ExtractAspen.dbo.SCHEDULE_MASTER
    JOIN [BPSDATA-03].ExtractAspen.dbo.SCHEDULE
        ON SCH_OID = MST_SCH_OID
    JOIN [BPSDATA-03].ExtractAspen.dbo.SCHOOL_SCHEDULE_CONTEXT
        ON SCH_OID = SKX_SCH_OID_ACTIVE
    JOIN [BPSDATA-03].ExtractAspen.dbo.SCHOOL
        ON SCH_SKL_OID = SKL_OID
           --AND SKL_SCHOOL_ID = '1010'
    JOIN [BPSDATA-03].ExtractAspen.dbo.DISTRICT_SCHOOL_YEAR_CONTEXT
        ON CTX_OID = SCH_CTX_OID
    JOIN [BPSDATA-03].ExtractAspen.dbo.ORGANIZATION
        ON CTX_OID = ORG_CTX_OID_CURRENT
           AND ORG_ORG_OID_PARENT IS NULL
    JOIN [BPSDATA-03].ExtractAspen.dbo.COURSE_SCHOOL
        ON CSK_OID = MST_CSK_OID
    JOIN [BPSDATA-03].ExtractAspen.dbo.COURSE
        ON CSK_CRS_OID = CRS_OID
WHERE COALESCE(CRS_FIELDA_002, '0') = '0' -- Exculded items for ODS Import 
      AND MST_ENROLLMENT_TOTAL > 0
	  AND CRS_MASTER_TYPE='Class'
--AND MST_DESCRIPTION = 'Homeroom'
GROUP BY SKL_SCHOOL_ID,
         CRS_COURSE_NUMBER,
         CRS_COURSE_DESCRIPTION
EXCEPT
SELECT CAST(SC.SchoolId AS VARCHAR(20)) AS SchooldId,
       CS.CourseCode,
       CS.CourseDescription,
       COUNT(CS.CourseCode) AS ENRL_Count --SSA.* --DISTINCT CS.CourseDescription
FROM EdFi_BPS_Production_Ods.edfi.Section AS SC
    JOIN EdFi_BPS_Production_Ods.edfi.CourseOffering AS CO
        ON CO.LocalCourseCode = SC.LocalCourseCode 
           AND CO.SchoolId = SC.SchoolId
           AND CO.SchoolYear = SC.SchoolYear
           AND CO.TermDescriptorId = SC.TermDescriptorId
    INNER JOIN EdFi_BPS_Production_Ods.edfi.Course AS CS
        ON CS.EducationOrganizationId = CO.EducationOrganizationId
           AND CS.CourseCode = CO.CourseCode
WHERE --SC.SchoolId = 1010
      --AND SC.ClassPeriodName = 'Homeroom'
      --AND 
	  SC.SchoolYear = '2020'
GROUP BY SC.SchoolId,
         CS.CourseCode,
         CS.CourseDescription
END








