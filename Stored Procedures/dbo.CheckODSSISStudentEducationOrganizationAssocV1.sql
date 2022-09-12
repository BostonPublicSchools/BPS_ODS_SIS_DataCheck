SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ragha
-- Create date: 2020-03-10
-- Description:	Compare StudentEducationOrganizationAssociation Between ODS and SIS
-- =============================================
CREATE   PROCEDURE [dbo].[CheckODSSISStudentEducationOrganizationAssocV1]
AS
BEGIN

    SELECT a.*
    FROM
    (
        SELECT DISTINCT
               std.StudentUniqueId,
               seo.EducationOrganizationId,
			   'ODS' as RecordsFoundIn
        FROM Edfi_Student std
            INNER JOIN Edfi_StudentEducationOrganizationAssociation seo
                ON std.StudentUSI = seo.StudentUSI
            INNER JOIN Edfi_StudentSchoolAssociation ssa
                ON ssa.StudentUSI = seo.StudentUSI
        WHERE ExitWithdrawDate IS NULL
        EXCEPT
        SELECT DISTINCT
               STD.STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AS AS StudentNo,
               SUBSTRING(ORG.ORG_ID, 3, 7) COLLATE SQL_Latin1_General_CP1_CI_AS AS EducationOrganizationId,
			   'ODS' as RecordsFoundIn
        FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT STD
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.ORGANIZATION ORG
                ON STD.STD_ORG_OID_1 = ORG.ORG_OID
        WHERE STD.STD_ENROLLMENT_STATUS = 'Active'
    ) a
    UNION ALL
    SELECT b.*
    FROM
    (
        SELECT DISTINCT
               STD.STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AS AS StudentNo,
               SUBSTRING(ORG.ORG_ID, 3, 7) COLLATE SQL_Latin1_General_CP1_CI_AS AS EducationOrganizationId,
			   'SIS' as RecordsFoundIn
        FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT STD
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.ORGANIZATION ORG
                ON STD.STD_ORG_OID_1 = ORG.ORG_OID
        WHERE STD.STD_ENROLLMENT_STATUS = 'Active'
        EXCEPT
        SELECT DISTINCT
               std.StudentUniqueId,
               seo.EducationOrganizationId,
			   'SIS' as RecordsFoundIn
        FROM Edfi_Student std
            INNER JOIN Edfi_StudentEducationOrganizationAssociation seo
                ON std.StudentUSI = seo.StudentUSI
            INNER JOIN Edfi_StudentSchoolAssociation ssa
                ON ssa.StudentUSI = seo.StudentUSI
        WHERE ExitWithdrawDate IS NULL
    ) b;

END;
GO
