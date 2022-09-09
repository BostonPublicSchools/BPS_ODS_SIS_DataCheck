SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author: Ragha
-- Create date: 2020-10-27
-- Description: Compare Staff School Association Between ODS and DW
-- =============================================
CREATE PROCEDURE [dbo].[CheckODSDWStaffSchoolAssociationV1]
AS
BEGIN
    SELECT ex.StaffUniqueId,
           ex.EducationOrganizationId,
           IdentificationCode PSFTDepartmentCode,
           sch DWEducationOrganizationId,
		   'ODS' as RecordsFoundIn
    FROM
    (
        SELECT c.StaffUniqueId,
               a.EducationOrganizationId
        FROM Edfi_EducationOrganization a
            INNER JOIN Edfi_StaffEducationOrganizationAssignmentAssociation b
                ON b.EducationOrganizationId = a.EducationOrganizationId
            INNER JOIN Edfi_Staff c
                ON c.StaffUSI = b.StaffUSI
        WHERE a.Discriminator IN ( 'edfi.School' )
              AND b.EndDate IS NULL
        EXCEPT
        SELECT DISTINCT
               userid,
               sch
        FROM BPSGRANARY02.BPSDW.dbo.UserSecurity
    ) ex
        INNER JOIN Edfi_EducationOrganizationIdentificationCode eoic
            ON eoic.EducationOrganizationId = ex.EducationOrganizationId
               AND eoic.EducationOrganizationIdentificationSystemDescriptorId = 852
        INNER JOIN BPSGRANARY02.BPSDW.dbo.UserSecurity
            ON ex.StaffUniqueId = userid;

END;
GO
