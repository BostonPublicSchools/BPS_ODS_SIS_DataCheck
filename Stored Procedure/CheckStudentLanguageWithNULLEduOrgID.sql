USE [BPS_ODS_SIS_DataCheck];
GO
/****** Object:  StoredProcedure [dbo].[CheckStudentLanguageWithNULLEduOrgID]    Script Date: 8/14/2020 5:51:42 PM ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
------------------------------------------------------------------------------
-- Author:		Ragha
-- Create date: 2020-05-01
-- Description:	StudentLanguage without an assigned EducationOrganizationId
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[CheckStudentLanguageWithNULLEduOrgID]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT b.StudentUSI,
           c.EducationOrganizationId,
           COUNT(*)
    FROM [EdFi_BPS_Production_Ods].[edfi].[StudentLanguage] b
        LEFT JOIN [EdFi_BPS_Production_Ods].[edfi].[StudentEducationOrganizationAssociation] c
            ON b.StudentUSI = c.StudentUSI
    WHERE c.EducationOrganizationId IS NULL
    GROUP BY b.StudentUSI,
             c.EducationOrganizationId;

END;