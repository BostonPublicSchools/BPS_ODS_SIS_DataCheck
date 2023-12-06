SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Marco Martinez
-- Create date: 2023-12-05
-- Description:	Compare Section Data in EDFI not Matching 
--              WITH Student and Master Schedule in ASPEN 
-- =============================================
CREATE PROCEDURE [dbo].[CheckODSSISSectionDataODS]
AS
BEGIN

    SET NOCOUNT ON;

    /* :: REMOVE OLD TEMP TABLES (IF THEY EXIST) :::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
    IF OBJECT_ID('tempdb..#aspen_sections', 'U') IS NOT NULL
    BEGIN
        DROP TABLE #aspen_sections;
    END;

    IF OBJECT_ID('tempdb..#ods_sections', 'U') IS NOT NULL
    BEGIN
        DROP TABLE #ods_sections;
    END;

    IF OBJECT_ID('tempdb..#dpi_data', 'U') IS NOT NULL
    BEGIN
        DROP TABLE #dpi_data;
    END;

    DECLARE @Year AS INT;
    DECLARE @Zone AS VARCHAR(10);

    SELECT @Year = CTX_SCHOOL_YEAR,
           @Zone = 'ODS-' + CAST(CTX_SCHOOL_YEAR AS VARCHAR)
    FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.DISTRICT_SCHOOL_YEAR_CONTEXT
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.ORGANIZATION
            ON CTX_OID = ORG_CTX_OID_CURRENT
               AND ORG_ORG_OID_PARENT IS NULL;


    /* :: GET ASPEN SECTIONS ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
    CREATE TABLE #aspen_sections
    (
        SchoolId INT,
        SchoolName VARCHAR(100),
        LocalCourseCode VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS,
        SectionIdentifier VARCHAR(10) COLLATE SQL_Latin1_General_CP1_CS_AS,
        CourseTitle VARCHAR(25) COLLATE SQL_Latin1_General_CP1_CS_AS,
        CourseCode VARCHAR(20) COLLATE SQL_Latin1_General_CP1_CS_AS,
        CourseType VARCHAR(20) COLLATE SQL_Latin1_General_CP1_CS_AS,
        ExcludedSection VARCHAR(1),
        ExcludedCourse VARCHAR(1),
        SCH_SCHEDULE_NAME VARCHAR(50),
        ScheduleIsActive VARCHAR(5),
        MST_OID CHAR(14) COLLATE SQL_Latin1_General_CP1_CS_AS,
        MST_ENROLLMENT_TOTAL INT,
        RosterCount INT,
        AddCount INT,
        DropCount INT
    );

    INSERT INTO #aspen_sections
    (
        SchoolId,
        SchoolName,
        LocalCourseCode,
        SectionIdentifier,
        CourseTitle,
        CourseCode,
        CourseType,
        ExcludedSection,
        ExcludedCourse,
        SCH_SCHEDULE_NAME,
        ScheduleIsActive,
        MST_OID,
        MST_ENROLLMENT_TOTAL,
        RosterCount,
        AddCount,
        DropCount
    )
    SELECT skl.SKL_SCHOOL_ID AS SchoolId,
           skl.SKL_SCHOOL_NAME AS SchoolName,
           csk.CSK_COURSE_NUMBER + '-' + COALESCE(trm.TRM_TERM_CODE, 'TRM missing') AS LocalCourseCode,
           mst.MST_SECTION_NUMBER AS SectionIdentifier,
           crs.CRS_SHORT_DESCRIPTION AS CourseTitle,
           crs.CRS_COURSE_NUMBER AS CourseCode,
           crs.CRS_MASTER_TYPE AS CourseType,
           mst.MST_FIELDA_005 AS ExcludedSection,
           crs.CRS_FIELDA_002 AS ExcludedCourse,
           SCH_SCHEDULE_NAME,
           CASE
               WHEN SKX_OID IS NULL THEN
                   'N'
               ELSE
                   'Y'
           END 'ScheduleIsActive',
           mst.MST_OID,
           mst.MST_ENROLLMENT_TOTAL,
           (
               SELECT COUNT(1)
               FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.STUDENT_SCHEDULE
               WHERE SSC_MST_OID = MST_OID
           ) 'RosterCount', -- to doublecheck the MST_ENROLLMENT_TOTAL
           (
               SELECT COUNT(1)
               FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.STUDENT_SCHEDULE_CHANGE
               WHERE SCC_MST_OID = MST_OID
                     AND SCC_CHANGE_TYPE_CODE = 'Add'
           ) 'AddCount',    -- to check for previous enrollments
           (
               SELECT COUNT(1)
               FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.STUDENT_SCHEDULE_CHANGE
               WHERE SCC_MST_OID = MST_OID
                     AND SCC_CHANGE_TYPE_CODE = 'Drop'
           ) 'DropCount'    -- to check for previous enrollments
    FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHEDULE_MASTER mst
        LEFT JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHEDULE_TERM trm
            ON trm.TRM_OID = mst.MST_TRM_OID

        -- Use Schedule & Schedule Context to ensure the sections are active
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHEDULE sch
            ON sch.SCH_OID = mst.MST_SCH_OID
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.DISTRICT_SCHOOL_YEAR_CONTEXT ctx
            ON ctx.CTX_OID = sch.SCH_CTX_OID
        LEFT JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHOOL_SCHEDULE_CONTEXT skx
            ON sch.SCH_OID = skx.SKX_SCH_OID_ACTIVE
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.ORGANIZATION org
            ON ctx.CTX_OID = org.ORG_CTX_OID_CURRENT
               AND org.ORG_ORG_OID_PARENT IS NULL
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.COURSE_SCHOOL csk
            ON csk.CSK_OID = mst.MST_CSK_OID
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.COURSE crs
            ON crs.CRS_OID = csk.CSK_CRS_OID
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHOOL skl
            ON skl.SKL_OID = csk.CSK_SKL_OID
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
          AND skl.SKL_SCHOOL_NAME NOT LIKE 'Summer%';



    /* :: GET ODS SECTIONS :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
    CREATE TABLE #ods_sections
    (
        SchoolId INT,
        SchoolName VARCHAR(100),
        LocalCourseCode NVARCHAR(60) COLLATE SQL_Latin1_General_CP1_CS_AS,
        SectionIdentifier NVARCHAR(255) COLLATE SQL_Latin1_General_CP1_CS_AS,
        CourseTitle NVARCHAR(60) COLLATE SQL_Latin1_General_CP1_CS_AS,
        CourseCode NVARCHAR(60) COLLATE SQL_Latin1_General_CP1_CS_AS,
        SectionID15 VARCHAR(38) COLLATE SQL_Latin1_General_CP1_CS_AS,
        CourseOfferingID15 VARCHAR(38) COLLATE SQL_Latin1_General_CP1_CS_AS,
        CourseID15 VARCHAR(38) COLLATE SQL_Latin1_General_CP1_CS_AS
    );

    INSERT INTO #ods_sections
    (
        SchoolId,
        SchoolName,
        LocalCourseCode,
        SectionIdentifier,
        CourseTitle,
        CourseCode,
        SectionID15,
        CourseOfferingID15,
        CourseID15
    )
    SELECT CAST(SC.SchoolId AS VARCHAR(20)) AS SchoolId,
           EO.ShortNameOfInstitution AS SchoolName,
           CO.LocalCourseCode COLLATE SQL_Latin1_General_CP1_CS_AS AS LocalCourseCode,
           SC.SectionIdentifier COLLATE SQL_Latin1_General_CP1_CS_AS AS SectionIdentifier,
           CS.CourseTitle COLLATE SQL_Latin1_General_CP1_CS_AS AS CourseTitle,
           CO.CourseCode COLLATE SQL_Latin1_General_CP1_CS_AS AS CourseCode,
           LOWER(REPLACE(CONVERT(CHAR(36), SC.Id), '-', ''))COLLATE SQL_Latin1_General_CP1_CS_AS AS SectionID15,
           LOWER(REPLACE(CONVERT(CHAR(36), CO.Id), '-', ''))COLLATE SQL_Latin1_General_CP1_CS_AS AS CourseOfferingID15,
           LOWER(REPLACE(CONVERT(CHAR(36), CS.Id), '-', ''))COLLATE SQL_Latin1_General_CP1_CS_AS AS CourseID15
    FROM EDFISQL01.[s3v5ys_EdFi_BPS_ProdYS_Ods_2024].[edfi].[Section] AS SC
        JOIN EDFISQL01.[s3v5ys_EdFi_BPS_ProdYS_Ods_2024].[edfi].[CourseOffering] AS CO
            ON CO.LocalCourseCode = SC.LocalCourseCode
               AND CO.SchoolId = SC.SchoolId
               AND CO.SchoolYear = SC.SchoolYear
               AND CO.SessionName = SC.SessionName
        INNER JOIN EDFISQL01.[s3v5ys_EdFi_BPS_ProdYS_Ods_2024].[edfi].[Course] AS CS
            ON CS.EducationOrganizationId = CO.EducationOrganizationId
               AND CS.CourseCode = CO.CourseCode
        JOIN EDFISQL01.[s3v5ys_EdFi_BPS_ProdYS_Ods_2024].[edfi].[EducationOrganization] EO
            ON SC.SchoolId = EO.EducationOrganizationId
    WHERE SC.SchoolYear = @Year
    --and SC.CreateDate < format(getdate(), 'yyyy-MM-dd')
    ORDER BY SchoolId,
             CourseCode,
             SectionIdentifier;



    /* :: get Section DPI info :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
    CREATE TABLE #dpi_data
    (
        DPI_OID VARCHAR(14) COLLATE SQL_Latin1_General_CP1_CS_AS,
        DPI_OBJ_OID_01 VARCHAR(14) COLLATE SQL_Latin1_General_CP1_CS_AS,
        DPI_OBJ_ID_15 VARCHAR(38) COLLATE SQL_Latin1_General_CP1_CS_AS,
        DPI_SRC_STATUS VARCHAR(50),
        DPI_DST_STATUS VARCHAR(50)
    );

    INSERT INTO #dpi_data
    (
        DPI_OID,
        DPI_OBJ_OID_01,
        DPI_OBJ_ID_15,
        DPI_SRC_STATUS,
        DPI_DST_STATUS
    )
    SELECT DPI_OID,
           DPI_OBJ_OID_01,
           DPI_OBJ_ID_15,
           DPI_SRC_STATUS,
           DPI_DST_STATUS
    FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.DATA_PUBLISH_IMAGE
    WHERE DPI_TYPE = 'EdFi'
          AND DPI_ENTITY_TYPE = 'Section'
          AND DPI_SRC_STATUS NOT IN ( 'Error', 'Deleted' )
          AND DPI_ZONE = @Zone
          AND DPI_YEAR = @Year;



    /* :: COMPARE SECTIONS :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
    SELECT x.SchoolId,
           #ods_sections.SchoolName,
           x.LocalCourseCode,
           x.SectionIdentifier,
           x.CourseTitle,
           x.CourseCode,
           COUNT(1) OVER (PARTITION BY x.SchoolId) 'school_section_count',
           #ods_sections.SectionID15,
           dpi.DPI_SRC_STATUS,
           dpi.DPI_DST_STATUS,
           dpi.DPI_OID,
           mst.MST_OID,
           REPLACE(REPLACE(COALESCE(mst.ExcludedSection, 'N'), '0', 'N'), '1', 'Y') 'ExcludedSection',
           REPLACE(REPLACE(COALESCE(mst.ExcludedCourse, 'N'), '0', 'N'), '1', 'Y') 'ExcludedCourse',
           mst.SCH_SCHEDULE_NAME,
           mst.ScheduleIsActive,
           mst.MST_ENROLLMENT_TOTAL,
           mst.RosterCount,
           mst.AddCount,
           mst.DropCount
    FROM #ods_sections
        JOIN
        (
            SELECT SchoolId,
                   LocalCourseCode,
                   SectionIdentifier,
                   CourseTitle,
                   CourseCode
            FROM #ods_sections EXCEPT
            SELECT SchoolId,
                   LocalCourseCode,
                   SectionIdentifier,
                   CourseTitle,
                   CourseCode
            FROM #aspen_sections a
            WHERE COALESCE(a.ExcludedSection, 0) + COALESCE(a.ExcludedCourse, 0) = 0 -- neither MST nor CRS excluded
                  AND a.CourseType = 'Class'
                  AND a.ScheduleIsActive = 'Y'
        ) x
            ON x.SchoolId = #ods_sections.SchoolId
               AND x.CourseCode = #ods_sections.CourseCode
               AND x.LocalCourseCode = #ods_sections.LocalCourseCode
               AND x.SectionIdentifier = #ods_sections.SectionIdentifier
        LEFT JOIN
        (
            SELECT DPI_OID,
                   DPI_OBJ_OID_01,
                   DPI_OBJ_ID_15,
                   DPI_SRC_STATUS,
                   DPI_DST_STATUS
            FROM #dpi_data
        ) dpi
            ON dpi.DPI_OBJ_ID_15 = #ods_sections.SectionID15 COLLATE SQL_Latin1_General_CP1_CS_AS
        LEFT JOIN
        (
            SELECT MST_OID,
                   ExcludedSection,
                   ExcludedCourse,
                   SCH_SCHEDULE_NAME,
                   ScheduleIsActive,
                   MST_ENROLLMENT_TOTAL,
                   RosterCount,
                   AddCount,
                   DropCount
            FROM #aspen_sections
        ) mst
            ON dpi.DPI_OBJ_OID_01 = mst.MST_OID
    ORDER BY dpi.DPI_SRC_STATUS,
             dpi.DPI_DST_STATUS,
             REPLACE(REPLACE(COALESCE(mst.ExcludedSection, 'N'), '0', 'N'), '1', 'Y') DESC,
             mst.MST_OID,
             #ods_sections.SchoolId,
             #ods_sections.LocalCourseCode,
             #ods_sections.SectionIdentifier;



    /* :: REMOVE TEMP TABLES :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
    IF OBJECT_ID('tempdb..#aspen_sections', 'U') IS NOT NULL
    BEGIN
        DROP TABLE #aspen_sections;
    END;

    IF OBJECT_ID('tempdb..#ods_sections', 'U') IS NOT NULL
    BEGIN
        DROP TABLE #ods_sections;
    END;

    IF OBJECT_ID('tempdb..#dpi_data', 'U') IS NOT NULL
    BEGIN
        DROP TABLE #dpi_data;
    END;

END;
GO
