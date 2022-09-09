SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

------------------------------------------------------------------------------
-- Author:		Ragha
-- Create date: 2020-05-01
-- Description:	StudentTelephone without an assigned EducationOrganizationId
-------------------------------------------------------------------------------
CREATE   PROCEDURE [dbo].[CheckStudentTelephoneWithNULLEduOrgIDV1]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT b.StudentUSI,
           c.EducationOrganizationId,
           COUNT(*)
    FROM Edfi_StudentEducationOrganizationAssociationTelephone b
        LEFT JOIN Edfi_StudentEducationOrganizationAssociation c
            ON b.StudentUSI = c.StudentUSI
    WHERE c.EducationOrganizationId IS NULL
    GROUP BY b.StudentUSI,
             c.EducationOrganizationId;

END;
GO
