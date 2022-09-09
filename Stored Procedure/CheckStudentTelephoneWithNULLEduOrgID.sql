USE [BPS_ODS_SIS_DataCheck];
GO
/****** Object:  StoredProcedure [dbo].[CheckStudentTelephoneWithNULLEduOrgID]    Script Date: 8/14/2020 5:52:41 PM ******/
;
GO
;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------
-- Author:		Ragha
-- Create date: 2020-05-01
-- Description:	StudentTelephone without an assigned EducationOrganizationId
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[CheckStudentTelephoneWithNULLEduOrgID]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT b.StudentUSI,
           c.EducationOrganizationId,
           COUNT(*)
    FROM [s3v5ys_EdFi_BPS_ProdYS_Ods_2023].[edfi].[StudentEducationOrganizationAssociationTelephone] b
        LEFT JOIN [s3v5ys_EdFi_BPS_ProdYS_Ods_2023].[edfi].[StudentEducationOrganizationAssociation] c
            ON b.StudentUSI = c.StudentUSI
    WHERE c.EducationOrganizationId IS NULL
    GROUP BY b.StudentUSI,
             c.EducationOrganizationId;

END;
GO
