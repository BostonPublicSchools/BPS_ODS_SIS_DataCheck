SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
    =============================================
    Author:			Marco Martinez
    Create date:	10/16/2023
    Description:	Section by Staff and School in Aspen and NOT in ODS
    =============================================
*/
CREATE PROCEDURE [dbo].[StaffSectionAssociation_NotInODS]
AS
BEGIN
    --SET NOCOUNT ON added to prevent extra result sets from
    --interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @Year AS INT;
    DECLARE @Zone AS VARCHAR(10);

    SELECT @Year = CTX_SCHOOL_YEAR,
           @Zone = 'ODS-' + CAST(CTX_SCHOOL_YEAR AS VARCHAR)
    FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.DISTRICT_SCHOOL_YEAR_CONTEXT
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.ORGANIZATION
            ON CTX_OID = ORG_CTX_OID_CURRENT
               AND ORG_ORG_OID_PARENT IS NULL;



    IF OBJECT_ID('tempdb..#cteStaffODS') IS NOT NULL
    BEGIN
        DROP TABLE #cteStaffODS;
    END;

    IF OBJECT_ID('tempdb..#cteTermCodes') IS NOT NULL
    BEGIN
        DROP TABLE #cteTermCodes;
    END;


    IF OBJECT_ID('tempdb..#cteTeacherRoles') IS NOT NULL
    BEGIN
        DROP TABLE #cteTeacherRoles;
    END;

    IF OBJECT_ID('tempdb..#cteMTC') IS NOT NULL
    BEGIN
        DROP TABLE #cteMTC;
    END;

    IF OBJECT_ID('tempdb..#cteDPI') IS NOT NULL
    BEGIN
        DROP TABLE #cteDPI;
    END;




    SELECT DISTINCT
           [StaffUniqueId] COLLATE DATABASE_DEFAULT AS StaffId
    INTO #cteStaffODS
    FROM [EDFISQL01].[s3v5ys_EdFi_BPS_ProdYS_Ods_2024].[edfi].[Staff];


    /*
		The System field is used to "normalize" session names to a 
		common value that won't change over time. Session names are
		not Descriptors. Normalization is necessary because schools 
		customize and change term names causing problems for entities 
		where SessionName is a key field.
	*/
    --INSERT INTO #cteTermCodes
    SELECT RCD_CODE,
           RCD_CODE_SYSTEM
    INTO #cteTermCodes
    FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.REF_CODE
    WHERE RCD_RTB_OID = 'rtbSchTermCode';



    /*
		Teacher role sets the ClassroomPositionDescriptor, 
		so we must evaluate for that
	*/
    SELECT RCD_CODE,
           RCD_CODE_EDFI
    INTO #cteTeacherRoles
    FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.REF_CODE
    WHERE RCD_RTB_OID = 'rtbTeacherRole';





    -- relabeled to clarify (this really is MTC-related)
    SELECT STF_ID_LOCAL COLLATE DATABASE_DEFAULT AS 'StaffID',
           STF_NAME_VIEW AS 'StaffName',
           STF_STAFF_TYPE AS 'StaffType',
           SKL_SCHOOL_NAME AS 'SchoolName',
           SKL_SCHOOL_ID AS 'SchoolId',
           CTX_SCHOOL_YEAR AS 'SchoolYear',
           cteTermCodes.RCD_CODE_SYSTEM AS 'SessionName',
           CONCAT(CRS_COURSE_NUMBER, '-', mstTRM.TRM_TERM_CODE) AS 'LocalCourseCode',
           MST_SECTION_NUMBER AS 'SectionNumber',
           -- grouped columns by table/topic
           MTC_TEACHER_ROLE AS 'TeacherRole',
           MTC_OID,
           mtcTRM.TRM_OID AS 'mtcTRM_OID',
           mtcTRM.TRM_TERM_NAME AS 'mtcTRM_Name',
           mtcTRM.TRM_TERM_CODE AS 'mtcTRM_Code',
           cteTermCodes_mtcTRM.RCD_CODE_SYSTEM AS 'mtcTRM_SessionName',
           MST_OID,
           mstTRM.TRM_OID AS 'mstTRM_OID',
           mstTRM.TRM_TERM_NAME AS 'mstTRM_Name',
           mstTRM.TRM_TERM_CODE AS 'mstTRM_Code',
           cteTermCodes.RCD_CODE_SYSTEM AS 'mstTRM_SessionName',
           CONCAT(
                     STF_ID_LOCAL,
                     SKL_SCHOOL_ID,
                     CTX_SCHOOL_YEAR,
                     cteTermCodes.RCD_CODE_SYSTEM,
                     CONCAT(CRS_COURSE_NUMBER, '-', mstTRM.TRM_TERM_CODE),
                     MST_SECTION_NUMBER
                 ) AS 'DPI ID1+ID2+ID3+ID4+ID5+ID6',
           CASE
               WHEN COALESCE(STF_FIELDA_045, '0') = '1' THEN
                   'Y'
               ELSE
                   'N'
           END AS 'ExcludeStaff?',
           STF_STATUS,
           CASE USR_LOGIN_STATUS
               WHEN '0' THEN
                   'Enabled'
               WHEN '1' THEN
                   'Disabled' -- 'Disabled but allow re-enable from password recovery'
               WHEN '2' THEN
                   'Disabled' -- 'Disabled and locked'
           END AS 'USR_LOGIN_STATUS'
    INTO #cteMTC
    FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHEDULE_MASTER_TEACHER

        -- get only publishable sections & courses
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHEDULE_MASTER
            ON MST_OID = MTC_MST_OID
               AND COALESCE(MST_FIELDA_005, '0') = '0' --  DOE EXCLUDE MST
               AND COALESCE(MTC_FIELDA_002, '0') = '0' --  DOE EXCLUDE MTC
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.COURSE_SCHOOL
            ON CSK_OID = MST_CSK_OID
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.COURSE
            ON CRS_OID = CSK_CRS_OID
               AND COALESCE(CRS_FIELDA_002, '0') = '0' --  DOE EXCLUDE CRS
               AND CRS_MASTER_TYPE = 'Class' -- only "Class" is publishable

        -- get only records in current year active schedules
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHEDULE
            ON MST_SCH_OID = SCH_OID

        -- check for Schedule Term on MST records
        -- set to left join to catch missing Section Scheule Term
        LEFT JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHEDULE_TERM mstTRM
            ON MST_TRM_OID = mstTRM.TRM_OID
        LEFT JOIN #cteTermCodes cteTermCodes
            ON mstTRM.TRM_TERM_CODE = cteTermCodes.RCD_CODE

        -- check for Schedule Term on MTC records
        LEFT JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHEDULE_TERM mtcTRM
            ON MTC_TRM_OID = mtcTRM.TRM_OID
        LEFT JOIN #cteTermCodes cteTermCodes_mtcTRM
            ON mtcTRM.TRM_TERM_CODE = cteTermCodes_mtcTRM.RCD_CODE

        -- limit to cuurent year active schcedules
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHOOL_SCHEDULE_CONTEXT
            ON SKX_SCH_OID_ACTIVE = SCH_OID
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHOOL
            ON SKX_SKL_OID = SKL_OID
               AND COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1) > 0 -- School ID is numeric
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.DISTRICT_SCHOOL_YEAR_CONTEXT
            ON CTX_OID = SKX_CTX_OID
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.ORGANIZATION
            ON CTX_OID = ORG_CTX_OID_CURRENT
               AND ORG_ORG_OID_PARENT IS NULL

        -- get staff-related info
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.STAFF
            ON STF_OID = MTC_STF_OID
        --AND STF_STATUS = 'Active' -- Exclude Inactive staff - no need to publish. Schedule data quality tracker should catch.
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.USER_INFO
            ON USR_PSN_OID = STF_PSN_OID
    --AND USR_LOGIN_STATUS = 0	-- Can also exclude AD inactive staff like this (ex Leonard, Maryanna)
    WHERE STF_ID_LOCAL IS NOT NULL;













    SELECT DPI_OBJ_ID_02 AS 'SchoolId',
           DPI_OBJ_ID_01 AS 'StaffID',
           DPI_OBJ_OID_03 AS 'MST_OID',
           DPI_OBJ_ID_03 AS 'SchoolYear',
           DPI_OBJ_ID_04 AS 'SessionName',
           DPI_OBJ_ID_05 AS 'LocalCourseCode',
           DPI_OBJ_ID_06 AS 'SectionNumber'
    INTO #cteDPI
    FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.DATA_PUBLISH_IMAGE
    WHERE DPI_TYPE = 'EdFi'
          AND DPI_ENTITY_TYPE = 'StaffSectionAssociation'
          AND DPI_ZONE = @Zone
          AND DPI_YEAR = @Year
          AND DPI_SRC_STATUS = 'Uploaded';







    SELECT A.staffName,
           A.StaffType,
           A.SchoolName,
           A.STF_STATUS,
           A.USR_LOGIN_STATUS,
           A.StaffID,
           A.SchoolId,
           A.SchoolYear,
           A.SessionName,
           A.LocalCourseCode,
           A.SectionNumber,
           A.TeacherRole,
           A.DPI_SRC_STATUS,
           A.DPI_DST_STATUS,
           --A.[PROBLEM ODS],
           A.[PROBLEM SIS],
           A.STATUS,
           A.NOTES,
           A.MTC_OID,
           A.mtcTRM_OID,
           A.mtcTRM_Name,
           A.mtcTRM_Code,
           A.mtcTRM_SessionName,
           A.MST_OID,
           A.mstTRM_OID,
           A.mstTRM_Name,
           A.mstTRM_Code,
           A.mstTRM_SessionName,
           A.[DPI ID1+ID2+ID3+ID4+ID5+ID6]
    FROM
    (
        SELECT cteMTC.StaffName,
               cteMTC.StaffType,
               cteMTC.SchoolName,
               cteMTC.STF_STATUS,
               cteMTC.USR_LOGIN_STATUS,
               -- columns ordered as DPI ID 1 to ID 6
               cteMTC.StaffID,
               cteMTC.SchoolId,
               cteMTC.SchoolYear,
               cteMTC.SessionName,
               cteMTC.LocalCourseCode,
               cteMTC.SectionNumber,
               cteMTC.TeacherRole,
               dpi.DPI_SRC_STATUS,
               dpi.DPI_DST_STATUS,
               CASE
                   WHEN cteStaffODS.StaffId IS NULL THEN
                       'Staff NOT in ODS'
                   ELSE
                       ''
               END AS 'PROBLEM ODS',
               CASE
                   WHEN cteMTC.mstTRM_OID IS NULL THEN
                       'Section Term is Missing'
                   WHEN cteMTC.mtcTRM_OID IS NULL THEN
                       'Teacher Term is Missing'
                   WHEN cteMTC.mstTRM_OID <> cteMTC.mtcTRM_OID THEN
                       'Teacher Term <> Section Term'
                   WHEN COALESCE(cteMTC.TeacherRole, '') = '' THEN
                       'Teacher Role is Missing'
                   WHEN
                   (
                       SELECT COALESCE(RCD_CODE_EDFI, '')
                       FROM #cteTeacherRoles cteTeacherRoles
                       WHERE RCD_CODE = cteMTC.TeacherRole
                   ) = '' THEN
                       'Teacher Role is Invalid'
                   WHEN cteMTC.[ExcludeStaff?] = 'Y' THEN
                       'Staff record is Excluded'
                   -- don't add "?" (avoid visual clutter) if staff is not in ODS
                   WHEN cteStaffODS.StaffId IS NULL THEN
                       ''
                   ELSE
                       '?'
               END AS 'PROBLEM SIS',
               '' AS 'STATUS',
               '' AS 'NOTES',
               -- MTC detail for analysis
               --, '::' ':=:' -- divider
               cteMTC.MTC_OID,
               cteMTC.mtcTRM_OID,
               cteMTC.mtcTRM_Name,
               cteMTC.mtcTRM_Code,
               cteMTC.mtcTRM_SessionName,
               -- MST detail for analysis
               --, '::' ':=:' -- divider
               cteMTC.MST_OID,
               cteMTC.mstTRM_OID,
               cteMTC.mstTRM_Name,
               cteMTC.mstTRM_Code,
               cteMTC.mstTRM_SessionName,
               -- DPI string for lookup
               --, '::' ':=:' -- divider
               cteMTC.[DPI ID1+ID2+ID3+ID4+ID5+ID6]
        FROM #cteMTC cteMTC
            LEFT JOIN #cteDPI cteDPI
                ON cteMTC.StaffID = cteDPI.StaffID COLLATE DATABASE_DEFAULT
                   AND cteMTC.SchoolId = cteDPI.SchoolId
                   AND cteMTC.SchoolYear = cteDPI.SchoolYear
                   AND cteMTC.SessionName = cteDPI.SessionName
                   AND cteMTC.LocalCourseCode = cteDPI.LocalCourseCode
                   AND cteMTC.SectionNumber = cteDPI.SectionNumber
            LEFT JOIN #cteStaffODS cteStaffODS
                ON cteMTC.StaffID = cteStaffODS.StaffId

            -- Include info on data attempted to be published.
            -- This could potentially produce multiple rows per MTC_OID
            -- but that would also be a data QA issue.
            LEFT JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.DATA_PUBLISH_IMAGE dpi
                ON dpi.DPI_TYPE = 'EdFi'
                   AND dpi.DPI_ENTITY_TYPE = 'StaffSectionAssociation'
                   AND dpi.DPI_YEAR = @Year
                   AND dpi.DPI_ZONE = @Zone
                   AND dpi.DPI_SRC_STATUS = 'Ready for Upload'
                   AND dpi.DPI_OBJ_OID_01 = cteMTC.MTC_OID
        WHERE cteDPI.MST_OID IS NULL
    ) A
    WHERE A.[PROBLEM ODS] = ''
    ORDER BY A.StaffID,
             A.SchoolId,
             A.LocalCourseCode;


END;
GO
