SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


------------------------------------------------------------------------------
-- Author:		Ragha
-- Create date: 2020-06-15
-- Description:	Compare SIS Vs ODS StudentIdentificationCode
-------------------------------------------------------------------------------
CREATE   PROCEDURE [dbo].[CheckODSSISStudentIdentificationCodeV1]
AS
BEGIN
	DECLARE @current_year NVARCHAR(20) = (SELECT TOP 1 SchoolYear FROM dbo._Config_Aspen_Filters)
    SET NOCOUNT ON;

    SELECT DISTINCT
           STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AS AS STD_ID_LOCAL,
           STD_ID_STATE COLLATE SQL_Latin1_General_CP1_CI_AS AS STD_ID_STATE,
		   'SIS' AS RecordsFoundIn
    FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT s
        --INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_STUDENT_ENROLLMENT e WITH (NOLOCK) ON s.STD_OID = e.ENR_STD_OID
        INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK)
            ON SKL_OID = STD_SKL_OID
        INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH (NOLOCK)
            ON SKL_CTX_OID_CURRENT = CTX_OID
    --AND ENR_ENROLLMENT_DATE >= CTX_START_DATE
    --Ragha Y 08-10-2020 Updated to 2022-2023 from 2019-2020'
    WHERE CTX_CONTEXT_ID = @current_year
          --AND 
          --e.ENR_WITHDATE IS NULL
          --AND 
          --(COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT),-1) BETWEEN 1000 AND 4800
          --   OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT),-1) BETWEEN 9000 AND 9999)
          AND s.STD_ENROLLMENT_STATUS IN ('Active','Registered')
          AND STD_ID_STATE COLLATE SQL_Latin1_General_CP1_CI_AS IS NOT NULL
    EXCEPT
    SELECT DISTINCT
           std.StudentUniqueId,
           sic.IdentificationCode,
		   'SIS' AS RecordsFoundIn
    FROM Edfi_Student std
        INNER JOIN EdFi_StudentEducationOrganizationAssociation seo
            ON std.StudentUSI = seo.StudentUSI
        INNER JOIN Edfi_StudentEducationOrganizationAssociationStudentIdentificationCode sic
            ON sic.StudentUSI = seo.StudentUSI
               AND sic.EducationOrganizationId = seo.EducationOrganizationId
               AND sic.StudentUSI = seo.StudentUSI
        INNER JOIN EdFi_StudentSchoolAssociation sc
            ON std.StudentUSI = sc.StudentUSI
    WHERE sc.ExitWithdrawDate IS NULL
          --Ragha Y 08-11-2020 Updated to 2021 from 2020
         -- AND sc.SchoolYear = 2021
          --AND (sc.SchoolId  BETWEEN 1000 AND 4800
          --   OR sc.SchoolId BETWEEN 9000 AND 9999)
          AND sic.AssigningOrganizationIdentificationCode = 'State'
    UNION ALL
    SELECT DISTINCT
           std.StudentUniqueId,
           sic.IdentificationCode,
		   'ODS' AS RecordsFoundIn
    FROM Edfi_Student std
        INNER JOIN EdFi_StudentEducationOrganizationAssociation seo
            ON std.StudentUSI = seo.StudentUSI
        INNER JOIN Edfi_StudentEducationOrganizationAssociationStudentIdentificationCode sic
            ON sic.StudentUSI = seo.StudentUSI
               AND sic.EducationOrganizationId = seo.EducationOrganizationId
               AND sic.StudentUSI = seo.StudentUSI
        INNER JOIN EdFi_StudentSchoolAssociation sc
            ON std.StudentUSI = sc.StudentUSI
    WHERE sc.ExitWithdrawDate IS NULL
          --Ragha Y 08-11-2020 Updated to 2021 from 2020
         -- AND sc.SchoolYear = 2021
          --AND (sc.SchoolId  BETWEEN 1000 AND 4800
          --   OR sc.SchoolId BETWEEN 9000 AND 9999)
          AND sic.AssigningOrganizationIdentificationCode = 'State'
    EXCEPT
    SELECT DISTINCT
           STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AS AS STD_ID_LOCAL,
           STD_ID_STATE COLLATE SQL_Latin1_General_CP1_CI_AS AS STD_ID_STATE,
		   'ODS' AS RecordsFoundIn
    FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT s
        --INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_STUDENT_ENROLLMENT e WITH (NOLOCK) ON s.STD_OID = e.ENR_STD_OID
        INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK)
            ON SKL_OID = STD_SKL_OID
        INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH (NOLOCK)
            ON SKL_CTX_OID_CURRENT = CTX_OID
    --AND ENR_ENROLLMENT_DATE >= CTX_START_DATE
    --Ragha Y 08-10-2020 Updated to 2022-2023 from 2019-2020'
    WHERE CTX_CONTEXT_ID =@current_year  --AND 
--e.ENR_WITHDATE IS NULL
--AND 
--(COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT),-1) BETWEEN 1000 AND 4800
--   OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT),-1) BETWEEN 9000 AND 9999)
AND s.STD_ENROLLMENT_STATUS IN ('Active','Registered')
ORDER BY RecordsFoundIn;

END;
GO
