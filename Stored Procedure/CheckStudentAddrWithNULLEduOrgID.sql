USE [BPS_ODS_SIS_DataCheck];
GO
/****** Object:  StoredProcedure [dbo].[CheckStudentAddrWithNULLEduOrgID]    Script Date: 8/14/2020 5:50:16 PM ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
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
           COUNT(*)
    FROM [EdFi_BPS_Production_Ods].[edfi].[StudentAddress] b
        INNER JOIN EdFi_BPS_Production_Ods.edfi.Student s
            ON s.StudentUSI = b.StudentUSI
        LEFT JOIN [EdFi_BPS_Production_Ods].[edfi].[StudentEducationOrganizationAssociation] c
            ON b.StudentUSI = c.StudentUSI
    WHERE c.EducationOrganizationId IS NULL
    GROUP BY s.StudentUniqueId,
             c.EducationOrganizationId;

END;