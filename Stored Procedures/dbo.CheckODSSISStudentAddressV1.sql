SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--------------------------------------------------------------------------------
---- Author:		Ragha
---- Create date: 2020-05-29
---- Description:	SIS vs ODS StudentAddress Compare
---------------------------------------------------------------------------------
CREATE   PROCEDURE [dbo].[CheckODSSISStudentAddressV1]
AS
BEGIN
declare @current_year nvarchar(20) = (select top 1 SchoolYear from dbo._Config_Aspen_Filters)
    SET NOCOUNT ON;
    IF OBJECT_ID('tempdb.dbo.#tempaspen', 'U') IS NOT NULL
        DROP TABLE #tempaspen;
    IF OBJECT_ID('tempdb.dbo.#tempods', 'U') IS NOT NULL
        DROP TABLE #tempods;

    SELECT *
    INTO #tempaspen
    FROM
    (
        SELECT s.STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ID_LOCAL,
               CASE
                   WHEN LEN(s.STD_ADRS_VIEW) > 0 THEN
                       REVERSE(RIGHT(REVERSE(s.STD_ADRS_VIEW), LEN(s.STD_ADRS_VIEW)
                                                               - CHARINDEX(' ', REVERSE(s.STD_ADRS_VIEW)))
                              )
               END COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ADRS_VIEW,
               RIGHT(s.STD_ADRS_VIEW, CHARINDEX(' ', REVERSE(s.STD_ADRS_VIEW)) - 1)COLLATE SQL_Latin1_General_CP1_CI_AI AS zip,
			   'SIS' as RecordsFoundIn
        FROM [BPSDATA-03].ExtractAspen.dbo.V_STUDENT s WITH (NOLOCK)
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_STUDENT_ENROLLMENT e WITH (NOLOCK)
                ON s.STD_OID = ENR_STD_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK)
                ON SKL_OID = ENR_SKL_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH (NOLOCK)
                ON SKL_CTX_OID_CURRENT = CTX_OID
        WHERE ISNULL(s.STD_ADRS_VIEW, '') <> ''
              AND s.STD_ENROLLMENT_STATUS = 'Active'
              AND
              (
                  CTX_SCHOOL_YEAR = 2023
                  OR CTX_CONTEXT_ID = @current_year
              )
    ) aa;

    SELECT *
    INTO #tempods
    FROM
    (
        SELECT DISTINCT
               a.StudentUniqueId,
               StreetNumberName,
               PostalCode,
			   'ODS' as RecordsFoundIn
        FROM Edfi_Student a WITH (NOLOCK)
            INNER JOIN Edfi_StudentEducationOrganizationAssociation seo WITH (NOLOCK)
                ON a.StudentUSI = seo.StudentUSI
				INNER JOIN Edfi_StudentEducationOrganizationAssociationAddress seoa WITH (NOLOCK)
				ON seoa.EducationOrganizationId = seo.EducationOrganizationId AND seoa.StudentUSI = seo.StudentUSI
            --INNER JOIN s3v5_EdFi_BPS_Production_Ods.edfi.EducationOrganizationAddress b WITH (NOLOCK)
            --    ON seo.EducationOrganizationId = b.EducationOrganizationId
            INNER JOIN Edfi_StudentSchoolAssociation eo WITH (NOLOCK)
                ON eo.StudentUSI = a.StudentUSI
        WHERE eo.ExitWithdrawDate IS NULL
              AND ISNULL(StreetNumberName, '') <> ''
              --AND b.AddressTypeId = 8
              --AND eo.SchoolYear = 2023
    ) bb;


    SELECT RTRIM(LTRIM(STD_ID_LOCAL)) COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ID_LOCAL,
           RTRIM(LTRIM(STD_ADRS_VIEW)) COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ADRS_VIEW,
           RTRIM(LTRIM(zip)) COLLATE SQL_Latin1_General_CP1_CI_AI AS ZIP,
		   'SIS' as RecordsFoundIn
    FROM #tempaspen
    --WHERE RTRIM(LTRIM(STD_ID_LOCAL)) COLLATE SQL_Latin1_General_CP1_CI_AI=203350
    EXCEPT
    SELECT RTRIM(LTRIM(StudentUniqueId)) AS StudentUniqueId,
           RTRIM(LTRIM(StreetNumberName)) AS StreetNumberName,
           RTRIM(LTRIM(PostalCode)) AS PostalCode,
		   'SIS' as RecordsFoundIn
    FROM #tempods
    --WHERE RTRIM(LTRIM(StudentUniqueId)) = 203350
    UNION
    SELECT RTRIM(LTRIM(StudentUniqueId)) AS StudentUniqueId,
           RTRIM(LTRIM(StreetNumberName)) AS StreetNumberName,
           RTRIM(LTRIM(PostalCode)) AS PostalCode,
		   'ODS' as RecordsFoundIn
    FROM #tempods
    EXCEPT
    SELECT RTRIM(LTRIM(STD_ID_LOCAL)) COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ID_LOCAL,
           RTRIM(LTRIM(STD_ADRS_VIEW)) COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ADRS_VIEW,
           RTRIM(LTRIM(zip)) COLLATE SQL_Latin1_General_CP1_CI_AI AS ZIP,
		   'ODS' as RecordsFoundIn
    FROM #tempaspen;

END;
GO
