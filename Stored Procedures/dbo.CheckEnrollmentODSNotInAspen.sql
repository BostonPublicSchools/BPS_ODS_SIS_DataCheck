SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Tim Reed
-- Create date:	11/4/2022
-- Description:	DataChecker comparison of enrollment in Aspen vs the ODS
--      Moved to BPSDATA-03 and references updated based on server move
-- =============================================
CREATE PROCEDURE [dbo].[CheckEnrollmentODSNotInAspen]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    /* :: remove old temp tables :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
    IF OBJECT_ID('tempdb..#ods_enrollment') IS NOT NULL
    BEGIN
        DROP TABLE #ods_enrollment;
    END;

    IF OBJECT_ID('tempdb..#aspen_enrollment') IS NOT NULL
    BEGIN
        DROP TABLE #aspen_enrollment;
    END;


    /* :: create temp tables :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
    IF OBJECT_ID('tempdb..#ods_enrollment') IS NULL
    BEGIN
        CREATE TABLE #ods_enrollment
        (
            SchoolId INT,
            SchoolName VARCHAR(250),
            StudentID VARCHAR(20),
            sklCount SMALLINT,
            ID15 VARCHAR(38)
        );
    END;

    IF OBJECT_ID('tempdb..#aspen_enrollment') IS NULL
    BEGIN
        CREATE TABLE #aspen_enrollment
        (
            SchoolId INT,
            SchoolName VARCHAR(250),
            StudentID VARCHAR(20),
            sklCount SMALLINT
        );
    END;


    /* :: gather ODS enrollment ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
    INSERT INTO #ods_enrollment
    (
        SchoolId,
        SchoolName,
        StudentID,
        sklCount,
        ID15
    )
    SELECT eo.EducationOrganizationId AS 'SchoolId',
           eo.ShortNameOfInstitution AS 'SchoolName', -- Only Short Name Matches with ASPEN Name
           s.StudentUniqueId AS 'StudentID',
           COUNT(1) OVER (PARTITION BY ssa.SchoolId) 'sklCount',
           LOWER(REPLACE(CONVERT(CHAR(36), ssa.Id), '-', ''))
    FROM EDFISQL01.s3v5ys_EdFi_BPS_ProdYS_Ods_2024.edfi.StudentSchoolAssociation AS ssa WITH (NOLOCK)
        JOIN EDFISQL01.s3v5ys_EdFi_BPS_ProdYS_Ods_2024.edfi.Student s WITH (NOLOCK)
            ON s.StudentUSI = ssa.StudentUSI
        JOIN EDFISQL01.s3v5ys_EdFi_BPS_ProdYS_Ods_2024.edfi.EducationOrganization AS eo WITH (NOLOCK)
            ON ssa.SchoolId = eo.EducationOrganizationId
        -- limit to BPS schools with current year EdOrgNetwork associations
        JOIN EDFISQL01.s3v5ys_EdFi_BPS_ProdYS_Ods_2024.edfi.EducationOrganizationNetworkAssociation eona WITH (NOLOCK)
            ON eona.MemberEducationOrganizationId = eo.EducationOrganizationId
               AND eona.BeginDate >=
               (
                   SELECT TOP 1 StartDate FROM EDFISQL01.BPS_ODS_SIS_DataCheck.dbo._Config_Aspen_Filters
               )
    WHERE ssa.SchoolYear =
    (
        SELECT TOP 1 SchoolYear FROM EDFISQL01.BPS_ODS_SIS_DataCheck.dbo._Config_Aspen_Filters
    )
          AND ssa.ExitWithdrawDate IS NULL
          AND DATEDIFF(HOUR, CONVERT(DATETIME, s.BirthDate), GETDATE()) / 8766 <= 21
          -- For Aspen, this is functionally redundant with null ExitWithdrawDate, but it clarifies
          AND ssa.PrimarySchool = 1;

    /* :: gather Aspen enrollment ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
    INSERT INTO #aspen_enrollment
    (
        SchoolId,
        SchoolName,
        StudentID,
        sklCount
    )
    SELECT skl.SKL_SCHOOL_ID COLLATE DATABASE_DEFAULT AS 'SchoolId',
           skl.SKL_SCHOOL_NAME COLLATE DATABASE_DEFAULT AS 'SchoolName',
           std.STD_ID_LOCAL COLLATE DATABASE_DEFAULT AS 'StudentID',
           COUNT(1) OVER (PARTITION BY std.STD_SKL_OID) AS 'sklCount'
    FROM ASPENDBCLOUD.aspen_ma_boston.dbo.STUDENT std WITH (NOLOCK)
        -- for DOB
        JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.PERSON psn WITH (NOLOCK)
            ON psn.PSN_OID = std.STD_PSN_OID
        JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.SCHOOL AS skl WITH (NOLOCK)
            ON skl.SKL_OID = std.STD_SKL_OID
               AND COALESCE(TRY_CAST(skl.SKL_SCHOOL_ID AS INT), -1) > 0
    WHERE
        -- limit to only schools eligible for the ODS (have numeric School Id's)
        std.STD_ENROLLMENT_STATUS = 'Active'
        AND DATEDIFF(HOUR, CONVERT(DATETIME, psn.PSN_DOB), GETDATE()) / 8766 <= 21 -- LIMIT BY AGE
    ;

    /* :: student enrollment in ODS not in Aspen :::::::::::::::::::::::::::::::::::::::::::::::::::: */
    SELECT x.StudentID,
           x.SchoolId,
           #ods_enrollment.SchoolName,
           COUNT(1) OVER (PARTITION BY x.SchoolId) AS 'schoolStudentCount',
           'ODS' 'dataSource',
           x.StudentID + '-' + CONVERT(VARCHAR(10), x.SchoolId) 'Aspen ID1-ID2',
           #ods_enrollment.ID15 'Aspen ID15'
    FROM
    (
        SELECT StudentID,
               SchoolId
        FROM #ods_enrollment o
        EXCEPT
        SELECT StudentID,
               SchoolId
        FROM #aspen_enrollment a
        WHERE EXISTS
        (
            SELECT DISTINCT SchoolId FROM #ods_enrollment WHERE a.SchoolId = SchoolId
        )
    ) AS x
        LEFT JOIN #ods_enrollment
            ON #ods_enrollment.StudentID = x.StudentID
               AND #ods_enrollment.SchoolId = x.SchoolId
    ORDER BY schoolStudentCount DESC,
             SchoolId,
             StudentID;

    /* :: remove temp tables :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
    IF OBJECT_ID('tempdb..#ods_enrollment') IS NOT NULL
    BEGIN
        DROP TABLE #ods_enrollment;
    END;

    IF OBJECT_ID('tempdb..#aspen_enrollment') IS NOT NULL
    BEGIN
        DROP TABLE #aspen_enrollment;
    END;


END;
GO
