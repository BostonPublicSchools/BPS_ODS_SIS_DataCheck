USE [BPS_ODS_SIS_DataCheck]
GO
/****** Object:  StoredProcedure [dbo].[CheckODSSISStudentEducationOrganizationAssoc]    Script Date: 8/14/2020 5:14:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ragha
-- Create date: 2020-03-10
-- Description:	Compare StudentEducationOrganizationAssociation Between ODS and SIS
-- =============================================
CREATE PROCEDURE [dbo].[CheckODSSISStudentEducationOrganizationAssoc]
AS
BEGIN

SELECT a.*
FROM 
(SELECT DISTINCT 
std.StudentUniqueId,
seo.EducationOrganizationId 
FROM EdFi_BPS_Production_Ods.edfi.StudentEducationOrganizationAssociation seo 
INNER JOIN EdFi_BPS_Production_Ods.edfi.Student std ON std.StudentUSI = seo.StudentUSI
LEFT JOIN EdFi_BPS_Production_Ods.edfi.StudentSchoolAssociation ssa ON ssa.StudentUSI = std.StudentUSI
WHERE ExitWithdrawDate IS NULL
except
SELECT DISTINCT
STD.STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AS AS StudentNo,
SUBSTRING(ORG.ORG_ID,3,7) COLLATE SQL_Latin1_General_CP1_CI_AS AS EducationOrganizationId
FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT STD 
INNER JOIN [BPSDATA-03].ExtractAspen.dbo.ORGANIZATION ORG ON STD.STD_ORG_OID_1= ORG.ORG_OID 
WHERE STD.STD_ENROLLMENT_STATUS='Active'
)a
union
SELECT b.* FROM
(SELECT DISTINCT
STD.STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AS AS StudentNo,
SUBSTRING(ORG.ORG_ID,3,7) COLLATE SQL_Latin1_General_CP1_CI_AS AS EducationOrganizationId
FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT STD 
INNER JOIN [BPSDATA-03].ExtractAspen.dbo.ORGANIZATION ORG ON STD.STD_ORG_OID_1= ORG.ORG_OID 
WHERE STD.STD_ENROLLMENT_STATUS='Active'
EXCEPT
SELECT DISTINCT 
std.StudentUniqueId,
seo.EducationOrganizationId 
FROM EdFi_BPS_Production_Ods.edfi.Student std
left JOIN EdFi_BPS_Production_Ods.edfi.StudentEducationOrganizationAssociation seo ON std.StudentUSI = seo.StudentUSI
LEFT JOIN EdFi_BPS_Production_Ods.edfi.StudentSchoolAssociation ssa ON ssa.StudentUSI = seo.StudentUSI
WHERE ExitWithdrawDate IS NULL
)b

END