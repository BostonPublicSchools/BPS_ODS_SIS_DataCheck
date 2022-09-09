SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



------------------------------------------------------------------------------
-- Author:		Ragha
-- Create date: 2020-06-03
-- Description:	SIS vs ODS Compare Student Email 
-------------------------------------------------------------------------------
CREATE     PROCEDURE [dbo].[CheckODSSISStudentEmailV1]
AS
BEGIN
	declare @current_year nvarchar(20) = (select top 1 SchoolYear from dbo._Config_Aspen_Filters)
    SET NOCOUNT ON;
    IF OBJECT_ID('tempdb.dbo.#tempaspen', 'U') IS NOT NULL
        DROP TABLE #tempaspen;
    IF OBJECT_ID('tempdb.dbo.#tempods', 'U') IS NOT NULL
        DROP TABLE #tempods;

    SELECT DISTINCT
           a.StudentUniqueId,
           b.ElectronicMailAddress
    INTO #tempods
    FROM Edfi_Student a
        INNER JOIN Edfi_StudentEducationOrganizationAssociation seo
            ON a.StudentUSI = seo.StudentUSI
        INNER JOIN Edfi_StudentEducationOrganizationAssociationElectronicMail b
            ON a.StudentUSI = b.StudentUSI
        LEFT JOIN Edfi_StudentSchoolAssociation eo WITH (NOLOCK)
            ON eo.StudentUSI = a.StudentUSI
    WHERE eo.ExitWithdrawDate IS NULL
          AND b.ElectronicMailAddress IS NOT NULL
          AND b.ElectronicMailAddress NOT LIKE CAST(a.StudentUSI AS VARCHAR(10)) + '@%'
		 -- AND eo.SchoolYear = 2022
		  AND
          (
              SchoolId
          BETWEEN 1000 AND 4800
              OR SchoolId
          BETWEEN 9000 AND 9999
          );


    SELECT *
    INTO #tempaspen
    FROM
    (
        SELECT DISTINCT
               s.STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ID_LOCAL,
               p.PSN_EMAIL_01 COLLATE SQL_Latin1_General_CP1_CI_AI AS EMAILID,
               s.STD_ENROLLMENT_STATUS
        FROM [BPSDATA-03].ExtractAspen.dbo.V_STUDENT s WITH (NOLOCK)
            INNER JOIN [BPSDATA-03].ExtractAspen.[dbo].[V_PERSON] p WITH (NOLOCK)
                ON s.STD_PSN_OID = p.PSN_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK)
                ON SKL_OID = STD_SKL_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH (NOLOCK)
                ON SKL_CTX_OID_CURRENT = CTX_OID
        --Ragha Y 08-10-2020 Updated to 2020-2021 from 2019-2020
        WHERE CTX_CONTEXT_ID = @current_year
              AND (ISNULL(p.PSN_EMAIL_01, '') <> '')
			     AND
          (
              COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
          BETWEEN 1000 AND 4800
              OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
          BETWEEN 9000 AND 9999
          )

        --UNION
        --SELECT DISTINCT
        --       s.STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ID_LOCAL,
        --       p.PSN_EMAIL_02 COLLATE SQL_Latin1_General_CP1_CI_AI AS PSN_EMAIL_02,
        --       s.STD_ENROLLMENT_STATUS
        --FROM [BPSDATA-03].ExtractAspen.dbo.V_STUDENT s WITH (NOLOCK)
        --    INNER JOIN [BPSDATA-03].ExtractAspen.[dbo].[V_PERSON] p WITH (NOLOCK)
        --        ON s.STD_PSN_OID = p.PSN_OID
        --    INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK)
        --        ON SKL_OID = STD_SKL_OID
        --    INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH (NOLOCK)
        --        ON SKL_CTX_OID_CURRENT = CTX_OID
        ----Ragha Y 08-10-2020 Updated to 2020-2021 from 2019-2020
        --WHERE CTX_CONTEXT_ID = '2020-2021'
        --      AND (ISNULL(p.PSN_EMAIL_02, '') <> '')
    ) a;

    SELECT *
    FROM
    (
        SELECT DISTINCT
               STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ID_LOCAL,
               EMAILID COLLATE SQL_Latin1_General_CP1_CI_AI AS EMAILID
        FROM #tempaspen
        WHERE EMAILID NOT LIKE CAST(STD_ID_LOCAL AS VARCHAR(10)) + '@%'
              AND EMAILID IS NOT NULL
              AND STD_ENROLLMENT_STATUS = 'Active'
        EXCEPT
        SELECT DISTINCT
               StudentUniqueId,
               ElectronicMailAddress
        FROM #tempods
    ) aa
    UNION
    SELECT *
    FROM
    (
        SELECT DISTINCT
               StudentUniqueId,
               ElectronicMailAddress
        FROM #tempods
        EXCEPT
        SELECT DISTINCT
               STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ID_LOCAL,
               EMAILID COLLATE SQL_Latin1_General_CP1_CI_AI AS EMAILID
        FROM #tempaspen
    ) bb;
END;
GO
