SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

------------------------------------------------------------------------------
-- Author:		Ragha
-- Create date: 2020-05-01
-- Description:	StudentAddress without an assigned EducationOrganizationId
-------------------------------------------------------------------------------
CREATE   PROCEDURE [dbo].[CheckStudentAddrWithNULLEduOrgIDV1]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT s.StudentUniqueId,
           c.EducationOrganizationId,
           COUNT(*),
		   'ODS' as RecordsFoundIn 
    FROM Edfi_StudentEducationOrganizationAssociationAddress b
        INNER JOIN Edfi_Student s
            ON s.StudentUSI = b.StudentUSI
        LEFT JOIN Edfi_StudentEducationOrganizationAssociation c
            ON b.StudentUSI = c.StudentUSI
    WHERE c.EducationOrganizationId IS NULL
    GROUP BY s.StudentUniqueId,
             c.EducationOrganizationId;

END;
GO
