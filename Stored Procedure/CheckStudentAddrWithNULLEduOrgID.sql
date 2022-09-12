USE [BPS_ODS_SIS_DataCheck];
GO
/****** Object:  StoredProcedure [dbo].[CheckStudentAddrWithNULLEduOrgID]    Script Date: 8/14/2020 5:50:16 PM ******/
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
-- Description:	StudentAddress without an assigned EducationOrganizationId
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[CheckStudentAddrWithNULLEduOrgID]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT s.StudentUniqueId,
           c.EducationOrganizationId,
           COUNT(*),
		   'ODS' as RecordsFoundIn 
    FROM [s3v5ys_EdFi_BPS_ProdYS_Ods_2023].[edfi].[StudentEducationOrganizationAssociationAddress] b
        INNER JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.Student s
            ON s.StudentUSI = b.StudentUSI
        LEFT JOIN [s3v5ys_EdFi_BPS_ProdYS_Ods_2023].[edfi].[StudentEducationOrganizationAssociation] c
            ON b.StudentUSI = c.StudentUSI
    WHERE c.EducationOrganizationId IS NULL
    GROUP BY s.StudentUniqueId,
             c.EducationOrganizationId;

END;
GO
