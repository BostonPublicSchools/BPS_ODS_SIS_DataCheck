SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-------------------------------------------------------------------------
-- Author:		Ragha
-- Create date: 2020-06-25
-- Description:	Compare active students are in sync between SIS and ODS 
---------------------------------------------------------------------------
CREATE   PROCEDURE [dbo].[CheckODSSISStudentSchoolStatusV1]
AS
BEGIN
	declare @current_year nvarchar(20) = (select top 1 SchoolYear from dbo._Config_Aspen_Filters)
    SELECT eo.EducationOrganizationId,
           LOWER(eo.ShortNameOfInstitution) ShortNameOfInstitution,
           s.StudentUniqueId
    FROM Edfi_Student s WITH (NOLOCK)
        JOIN Edfi_StudentSchoolAssociation ssa WITH (NOLOCK)
            ON s.StudentUSI = ssa.StudentUSI
        JOIN Edfi_EducationOrganization eo WITH (NOLOCK)
            ON ssa.SchoolId = eo.EducationOrganizationId
    WHERE (
              SchoolId
          BETWEEN 1000 AND 4800
              OR SchoolId
          BETWEEN 9000 AND 9999
          )
         -- AND SchoolYear = '2020'
          AND ExitWithdrawDate IS NULL
    EXCEPT
    SELECT s.SKL_SCHOOL_ID,
           LOWER(s.SKL_SCHOOL_NAME) COLLATE SQL_Latin1_General_CP1_CI_AS SKL_SCHOOL_NAME,
           a.STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AS STD_ID_LOCAL
    FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT a WITH (NOLOCK)
        JOIN [BPSDATA-03].ExtractAspen.dbo.SCHOOL s WITH (NOLOCK)
            ON s.SKL_OID = a.STD_SKL_OID
        JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT d WITH (NOLOCK)
            ON SKL_CTX_OID_CURRENT = d.CTX_OID
    WHERE (
              COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
          BETWEEN 1000 AND 4800
              OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
          BETWEEN 9000 AND 9999
          )
          AND a.STD_ENROLLMENT_STATUS = 'Active'
          --Ragha Y 08-10-2020 Updated to 2020-2021 from 2019-2020'
          AND CTX_CONTEXT_ID =@current_year
    UNION
    SELECT s.SKL_SCHOOL_ID,
           LOWER(s.SKL_SCHOOL_NAME) COLLATE SQL_Latin1_General_CP1_CI_AS SKL_SCHOOL_NAME,
           a.STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AS STD_ID_LOCAL
    FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT a WITH (NOLOCK)
        JOIN [BPSDATA-03].ExtractAspen.dbo.SCHOOL s WITH (NOLOCK)
            ON s.SKL_OID = a.STD_SKL_OID
        JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT d WITH (NOLOCK)
            ON SKL_CTX_OID_CURRENT = d.CTX_OID
    WHERE (
              COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
          BETWEEN 1000 AND 4800
              OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
          BETWEEN 9000 AND 9999
          )
          AND a.STD_ENROLLMENT_STATUS = 'Active'
          --Ragha Y 08-10-2020 Updated to 2020-2021 from 2019-2020'
          AND CTX_CONTEXT_ID = @current_year
    EXCEPT
    SELECT EO.EducationOrganizationId,
           LOWER(EO.ShortNameOfInstitution),
           s.StudentUniqueId
    FROM Edfi_Student s
        JOIN Edfi_StudentSchoolAssociation ssa
            ON s.StudentUSI = ssa.StudentUSI
        JOIN Edfi_EducationOrganization AS EO
            ON ssa.SchoolId = EO.EducationOrganizationId
    WHERE (
              SchoolId
          BETWEEN 1000 AND 4800
              OR SchoolId
          BETWEEN 9000 AND 9999
          )
         -- AND SchoolYear = '2020'
          AND ExitWithdrawDate IS NULL;
END;
GO
