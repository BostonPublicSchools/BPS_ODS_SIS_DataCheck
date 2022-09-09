SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


------------------------------------------------------------------------------
-- Author:		Ragha
-- Create date: 2020-05-01
-- Description:	StudentElectronicMail without an assigned EducationOrganizationId
-------------------------------------------------------------------------------
CREATE     PROCEDURE [dbo].[CheckStudentElectronicMailWithNULLEduOrgIDV1]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT b.StudentUSI,
           c.EducationOrganizationId,
           COUNT(*),
		   'ODS' as RecordsFoundIn 
    FROM Edfi_StudentEducationOrganizationAssociationElectronicMail b
        LEFT JOIN Edfi_StudentEducationOrganizationAssociation c
            ON b.StudentUSI = c.StudentUSI
    WHERE c.EducationOrganizationId IS NULL
    GROUP BY b.StudentUSI,
             c.EducationOrganizationId;

END;
GO
