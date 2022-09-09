SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

------------------------------------------------------------------------------
-- Author:		Ragha
-- Create date: 2020-06-11
-- Description:	SIS vs ODS StudentLanguage Compare
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[CheckODSSISStudentLanguage]
AS
BEGIN
    SET NOCOUNT ON;
    IF OBJECT_ID('tempdb.dbo.#tempaspenlan', 'U') IS NOT NULL
        DROP TABLE #tempaspenlan;
    IF OBJECT_ID('tempdb.dbo.#tempodslan', 'U') IS NOT NULL
        DROP TABLE #tempodslan;

    SELECT a.STD_ID_LOCAL,
           a.[Language] AS [Language]
    INTO #tempaspenlan
    FROM
    (
        SELECT STD_ID_LOCAL,
               CASE
                   WHEN STD_FIELDB_004 IS NOT NULL THEN
                       'Native language'
               END AS [Language]
        FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT s
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_STUDENT_ENROLLMENT e WITH (NOLOCK)
                ON s.STD_OID = e.ENR_STD_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK)
                ON SKL_OID = ENR_SKL_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH (NOLOCK)
                ON SKL_CTX_OID_CURRENT = CTX_OID
                   AND ENR_ENROLLMENT_DATE >= CTX_START_DATE
        --Ragha Y 08-10-2020 Updated to 2020-2021 from 2019-2020'
        WHERE CTX_CONTEXT_ID = '2020-2021'
              AND e.ENR_WITHDATE IS NULL
              AND
              (
                  COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 1000 AND 4800
                  OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 9000 AND 9999
              )
              AND s.STD_ENROLLMENT_STATUS = 'Active'
        --and STD_ID_LOCAL= '346125'
        UNION
        SELECT STD_ID_LOCAL,
               CASE
                   WHEN STD_HOME_LANGUAGE_CODE IS NOT NULL THEN
                       'Home language'
               END AS [Language]
        FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT s
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_STUDENT_ENROLLMENT e WITH (NOLOCK)
                ON s.STD_OID = e.ENR_STD_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK)
                ON SKL_OID = ENR_SKL_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH (NOLOCK)
                ON SKL_CTX_OID_CURRENT = CTX_OID
                   AND ENR_ENROLLMENT_DATE >= CTX_START_DATE
        --Ragha Y 08-10-2020 Updated to 2020-2021 from 2019-2020'
        WHERE CTX_CONTEXT_ID = '2020-2021'
              AND e.ENR_WITHDATE IS NULL
              AND
              (
                  COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 1000 AND 4800
                  OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 9000 AND 9999
              )
              AND s.STD_ENROLLMENT_STATUS = 'Active'
        --and STD_ID_LOCAL= '346125'
        UNION
        SELECT STD_ID_LOCAL,
               CASE
                   WHEN STD_FIELDB_002 IS NOT NULL THEN
                       'Other language proficiency'
               END AS [Language]
        FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT s
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_STUDENT_ENROLLMENT e WITH (NOLOCK)
                ON s.STD_OID = e.ENR_STD_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK)
                ON SKL_OID = ENR_SKL_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH (NOLOCK)
                ON SKL_CTX_OID_CURRENT = CTX_OID
                   AND ENR_ENROLLMENT_DATE >= CTX_START_DATE
        --Ragha Y 08-10-2020 Updated to 2020-2021 from 2019-2020'
        WHERE CTX_CONTEXT_ID = '2020-2021'
              AND e.ENR_WITHDATE IS NULL
              AND
              (
                  COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 1000 AND 4800
                  OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 9000 AND 9999
              )
              AND s.STD_ENROLLMENT_STATUS = 'Active'
        --and STD_ID_LOCAL= '346125'
        UNION
        SELECT STD_ID_LOCAL,
               CASE
                   WHEN STD_FIELDB_003 IS NOT NULL THEN
                       'Other'
               END AS [Language]
        FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT s
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_STUDENT_ENROLLMENT e WITH (NOLOCK)
                ON s.STD_OID = e.ENR_STD_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK)
                ON SKL_OID = ENR_SKL_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH (NOLOCK)
                ON SKL_CTX_OID_CURRENT = CTX_OID
                   AND ENR_ENROLLMENT_DATE >= CTX_START_DATE
        --Ragha Y 08-10-2020 Updated to 2020-2021 from 2019-2020'
        WHERE CTX_CONTEXT_ID = '2020-2021'
              AND e.ENR_WITHDATE IS NULL
              AND
              (
                  COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 1000 AND 4800
                  OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 9000 AND 9999
              )
              AND s.STD_ENROLLMENT_STATUS = 'Active'
        --and STD_ID_LOCAL= '346125'
        UNION
        SELECT STD_ID_LOCAL,
               CASE
                   WHEN STD_FIELDB_001 IS NOT NULL THEN
                       'Correspondence language'
               END AS [Language]
        FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT s
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_STUDENT_ENROLLMENT e WITH (NOLOCK)
                ON s.STD_OID = e.ENR_STD_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK)
                ON SKL_OID = ENR_SKL_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH (NOLOCK)
                ON SKL_CTX_OID_CURRENT = CTX_OID
                   AND ENR_ENROLLMENT_DATE >= CTX_START_DATE
        --Ragha Y 08-10-2020 Updated to 2020-2021 from 2019-2020'
        WHERE CTX_CONTEXT_ID = '2020-2021'
              AND e.ENR_WITHDATE IS NULL
              AND
              (
                  COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 1000 AND 4800
                  OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 9000 AND 9999
              )
              AND s.STD_ENROLLMENT_STATUS = 'Active'
        --and STD_ID_LOCAL= '346125'
        UNION
        SELECT STD_ID_LOCAL,
               CASE
                   WHEN STD_FIELDB_062 IS NOT NULL THEN
                       'Spoken language'
               END AS [Language]
        FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT s
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_STUDENT_ENROLLMENT e WITH (NOLOCK)
                ON s.STD_OID = e.ENR_STD_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK)
                ON SKL_OID = ENR_SKL_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH (NOLOCK)
                ON SKL_CTX_OID_CURRENT = CTX_OID
                   AND ENR_ENROLLMENT_DATE >= CTX_START_DATE
        --Ragha Y 08-10-2020 Updated to 2020-2021 from 2019-2020'
        WHERE CTX_CONTEXT_ID = '2020-2021'
              AND e.ENR_WITHDATE IS NULL
              AND
              (
                  COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 1000 AND 4800
                  OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 9000 AND 9999
              )
              AND s.STD_ENROLLMENT_STATUS = 'Active'
    --and STD_ID_LOCAL= '346125'
    ) a;

    SELECT DISTINCT
           Student.StudentUniqueId,
           CASE
               WHEN Descriptor.CodeValue IS NOT NULL THEN
                   Descriptor.CodeValue
           END AS [language]
    INTO #tempodslan
    FROM s3v5_EdFi_BPS_Production_Ods.edfi.Student
        JOIN s3v5_EdFi_BPS_Production_Ods.edfi.StudentEducationOrganizationAssociation
            ON StudentEducationOrganizationAssociation.StudentUSI = Student.StudentUSI
        JOIN s3v5_EdFi_BPS_Production_Ods.edfi.StudentEducationOrganizationAssociationLanguage
            ON StudentEducationOrganizationAssociationLanguage.EducationOrganizationId = StudentEducationOrganizationAssociation.EducationOrganizationId
               AND StudentEducationOrganizationAssociationLanguage.StudentUSI = StudentEducationOrganizationAssociation.StudentUSI
        JOIN s3v5_EdFi_BPS_Production_Ods.edfi.LanguageDescriptor
            ON LanguageDescriptor.LanguageDescriptorId = StudentEducationOrganizationAssociationLanguage.LanguageDescriptorId
        JOIN s3v5_EdFi_BPS_Production_Ods.edfi.Descriptor
            ON Descriptor.DescriptorId = LanguageDescriptor.LanguageDescriptorId
        JOIN s3v5_EdFi_BPS_Production_Ods.edfi.StudentSchoolAssociation sc
            ON sc.StudentUSI = Student.StudentUSI
    WHERE sc.ExitWithdrawDate IS NULL
          --Ragha Y 08-10-2020 Updated to 2021 from 2020
          AND sc.SchoolYear = 2021
          AND
          (
              sc.SchoolId
          BETWEEN 1000 AND 4800
              OR SchoolId
          BETWEEN 9000 AND 9999
          )
    --and a.StudentUniqueId = '346125'
    ;

    SELECT DISTINCT
           STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AS AS STD_ID_LOCAL,
           Language COLLATE SQL_Latin1_General_CP1_CI_AS AS Language
    FROM #tempaspenlan
    WHERE Language COLLATE SQL_Latin1_General_CP1_CI_AS IS NOT NULL
    EXCEPT
    SELECT DISTINCT
           StudentUniqueId,
           [language]
    FROM #tempodslan;


END;
GO
