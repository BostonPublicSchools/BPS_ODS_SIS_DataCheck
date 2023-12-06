SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Marco Martinez
-- Create date: 2023-12-04
-- Description:	Compare Section Data in EDFI not Matching 
--               WITH Student and Master Schedule in ASPEN 
-- =============================================
CREATE PROCEDURE [dbo].[CheckODSSISSectionDataAspen]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#aspen_sections') IS NOT NULL
    BEGIN
        DROP TABLE #aspen_sections;
    END;

    IF OBJECT_ID('tempdb..#ods_sections') IS NOT NULL
    BEGIN
        DROP TABLE #ods_sections;
    END;


    DECLARE @Year AS INT;

    SELECT @Year = CTX_SCHOOL_YEAR
    FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.DISTRICT_SCHOOL_YEAR_CONTEXT
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.ORGANIZATION
            ON CTX_OID = ORG_CTX_OID_CURRENT
               AND ORG_ORG_OID_PARENT IS NULL;


    /* :: GET ASPEN SECTIONS ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
    CREATE TABLE #aspen_sections
    (
        SchoolId INT,
        SchoolName VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CS_AS,
        LocalCourseCode VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS,
        SectionIdentifier VARCHAR(10) COLLATE SQL_Latin1_General_CP1_CS_AS,
        CourseTitle VARCHAR(25) COLLATE SQL_Latin1_General_CP1_CS_AS,
        CourseCode VARCHAR(20) COLLATE SQL_Latin1_General_CP1_CS_AS,
        excludedSection VARCHAR(1),
        excludedCourse VARCHAR(1),
        MST_OID CHAR(14) COLLATE SQL_Latin1_General_CP1_CS_AS,
        SCH_SCHEDULE_NAME VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS,
        scheduleIsActive VARCHAR(1),
        MST_ENROLLMENT_TOTAL INT
    );

    INSERT INTO #aspen_sections
    (
        SchoolId,
        SchoolName,
        LocalCourseCode,
        SectionIdentifier,
        CourseTitle,
        CourseCode,
        excludedSection,
        excludedCourse,
        MST_OID,
        SCH_SCHEDULE_NAME,
        scheduleIsActive,
        MST_ENROLLMENT_TOTAL
    )
    SELECT DISTINCT
           skl.SKL_SCHOOL_ID AS SchoolId,
           skl.SKL_SCHOOL_NAME AS SchoolName,
           csk.CSK_COURSE_NUMBER + '-' + COALESCE(trm.TRM_TERM_CODE, 'TRM missing') AS LocalCourseCode,
           mst.MST_SECTION_NUMBER AS SectionIdentifier,
           crs.CRS_SHORT_DESCRIPTION AS CourseTitle,
           crs.CRS_COURSE_NUMBER AS CourseCode,
           CASE
               WHEN MST_FIELDA_005 = 1 THEN
                   'Y'
               ELSE
                   'N'
           END 'excludedSection',
           CASE
               WHEN CRS_FIELDA_002 = 1 THEN
                   'Y'
               ELSE
                   'N'
           END 'excludedCourse',
           mst.MST_OID,
           sch.SCH_SCHEDULE_NAME,
           CASE
               WHEN SKX_OID IS NULL THEN
                   'N'
               ELSE
                   'Y'
           END 'scheduleIsActive',
           mst.MST_ENROLLMENT_TOTAL
    FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHEDULE_MASTER mst
        LEFT JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHEDULE_TERM trm
            ON trm.TRM_OID = mst.MST_TRM_OID

        -- Use Schedule & Schedule Context to ensure the sections are active
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHEDULE sch
            ON sch.SCH_OID = mst.MST_SCH_OID
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHOOL_SCHEDULE_CONTEXT skx
            ON sch.SCH_OID = skx.SKX_SCH_OID_ACTIVE
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.COURSE_SCHOOL csk
            ON csk.CSK_OID = mst.MST_CSK_OID
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHOOL skl
            ON skl.SKL_OID = csk.CSK_SKL_OID
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.DISTRICT_SCHOOL_YEAR_CONTEXT ctx
            ON ctx.CTX_OID = skl.SKL_CTX_OID_CURRENT
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.COURSE crs
            ON crs.CRS_OID = csk.CSK_CRS_OID
               AND skl.SKL_CTX_OID_CURRENT = crs.CRS_CTX_OID
               AND crs.CRS_MASTER_TYPE = 'Class' -- this is the only publishable course type
               AND COALESCE(CRS_FIELDA_002, '0') = '0' -- DOE EXCLUDE CRS
        LEFT JOIN
        (
            SELECT RCD_CODE,
                   RCD_CODE_SYSTEM,
                   RCD_CODE_EDFI
            FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.REF_TABLE
                JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.REF_CODE
                    ON RTB_OID = RCD_RTB_OID
                       AND COALESCE(RCD_DISABLED_IND, '0') = '0'
            WHERE RTB_OID = 'rtbSchTermCode'
        ) refCode
            ON trm.TRM_TERM_CODE = refCode.RCD_CODE
    WHERE COALESCE(TRY_CAST(skl.SKL_SCHOOL_ID AS INT), -1) > 0 -- schoolId is numeric
          AND skl.SKL_SCHOOL_NAME NOT LIKE 'Summer%'
          -- exclude sections w/out enrolled students because this is either stale or changing data
          AND COALESCE(mst.MST_ENROLLMENT_TOTAL, 0) <> 0
          AND COALESCE(MST_FIELDA_005, '0') = '0'; -- DOE EXCLUDE MST



    /* :: GET ODS SECTIONS :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
    CREATE TABLE #ods_sections
    (
        SchoolId INT,
        SchoolName VARCHAR(100),
        LocalCourseCode NVARCHAR(60) COLLATE SQL_Latin1_General_CP1_CS_AS,
        SectionIdentifier NVARCHAR(255) COLLATE SQL_Latin1_General_CP1_CS_AS,
        CourseTitle NVARCHAR(60) COLLATE SQL_Latin1_General_CP1_CS_AS,
        CourseCode NVARCHAR(60) COLLATE SQL_Latin1_General_CP1_CS_AS
    );


    INSERT INTO #ods_sections
    (
        SchoolId,
        SchoolName,
        LocalCourseCode,
        SectionIdentifier,
        CourseTitle,
        CourseCode
    )
    SELECT CAST(SC.SchoolId AS VARCHAR(20)) AS SchoolId,
           eo.ShortNameOfInstitution AS SchoolName,
           CO.LocalCourseCode COLLATE SQL_Latin1_General_CP1_CS_AS AS LocalCourseCode,
           SC.SectionIdentifier COLLATE SQL_Latin1_General_CP1_CS_AS AS SectionIdentifier,
           CS.CourseTitle COLLATE SQL_Latin1_General_CP1_CS_AS AS CourseTitle,
           CO.CourseCode COLLATE SQL_Latin1_General_CP1_CS_AS AS CourseCode
    FROM EDFISQL01.[s3v5ys_EdFi_BPS_ProdYS_Ods_2024].[edfi].[Section] AS SC
        JOIN EDFISQL01.[s3v5ys_EdFi_BPS_ProdYS_Ods_2024].[edfi].[CourseOffering] AS CO
            ON CO.LocalCourseCode = SC.LocalCourseCode
               AND CO.SchoolId = SC.SchoolId
               AND CO.SchoolYear = SC.SchoolYear
               AND CO.SessionName = SC.SessionName
        INNER JOIN EDFISQL01.[s3v5ys_EdFi_BPS_ProdYS_Ods_2024].[edfi].[Course] AS CS
            ON CS.EducationOrganizationId = CO.EducationOrganizationId
               AND CS.CourseCode = CO.CourseCode
        JOIN EDFISQL01.[s3v5ys_EdFi_BPS_ProdYS_Ods_2024].[edfi].[EducationOrganization] eo
            ON SC.SchoolId = eo.EducationOrganizationId
    WHERE SC.SchoolYear = @Year
    -- and SC.CreateDate < format(getdate(), 'yyyy-MM-dd') -- limit to records created yesterday or earlier (uncomment if using ExtractAspen)
    ORDER BY SchoolId,
             CourseCode,
             SectionIdentifier;


    /* :: COMPARE SECTIONS :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
    SELECT #aspen_sections.SchoolId,
           #aspen_sections.SchoolName,
           #aspen_sections.LocalCourseCode,
           #aspen_sections.SectionIdentifier,
           #aspen_sections.CourseTitle,
           #aspen_sections.CourseCode,
           COUNT(1) OVER (PARTITION BY x.SchoolId) 'school_section_count',
           #aspen_sections.MST_ENROLLMENT_TOTAL '#enrolled',
           #aspen_sections.SCH_SCHEDULE_NAME 'schedule_name',
           #aspen_sections.scheduleIsActive,
           --, #aspen_sections.excludedSection
           --, #aspen_sections.excludedCourse
           #aspen_sections.MST_OID
    FROM #aspen_sections
        JOIN
        (
            SELECT SchoolId,
                   LocalCourseCode,
                   SectionIdentifier,
                   CourseTitle,
                   CourseCode,
                   excludedSection,
                   excludedCourse
            FROM #aspen_sections EXCEPT
            SELECT SchoolId,
                   LocalCourseCode,
                   SectionIdentifier,
                   CourseTitle,
                   CourseCode,
                   'N',
                   'N'
            FROM #ods_sections
        ) x
            ON x.SchoolId = #aspen_sections.SchoolId
               AND x.CourseCode = #aspen_sections.CourseCode
               AND x.LocalCourseCode = #aspen_sections.LocalCourseCode
               AND x.SectionIdentifier = #aspen_sections.SectionIdentifier
        LEFT JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHEDULE_MASTER mst
            ON #aspen_sections.MST_OID = mst.MST_OID
        LEFT JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHEDULE sch
            ON sch.SCH_OID = mst.MST_SCH_OID
    ORDER BY #aspen_sections.SchoolId,
             #aspen_sections.CourseCode,
             #aspen_sections.LocalCourseCode,
             #aspen_sections.SectionIdentifier;


    /* :: REMOVE TEMP TABLES :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
    IF OBJECT_ID('tempdb..#ods_section') IS NOT NULL
    BEGIN
        DROP TABLE #ods_section;
    END;

    IF OBJECT_ID('tempdb..#aspen_section') IS NOT NULL
    BEGIN
        DROP TABLE #aspen_section;
    END;
END;
GO
