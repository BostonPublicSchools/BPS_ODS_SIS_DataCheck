SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author: Ragha
-- Create date: 2020-10-27
-- Description: Compare Staff School Association Between ODS and DW
-- =============================================
CREATE PROCEDURE [dbo].[CheckODSDWStaffSchoolAssociation]
AS
BEGIN
    SELECT ex.StaffUniqueId,
           ex.EducationOrganizationId,
           IdentificationCode,
           sch DWEducationOrganizationId
    FROM
    (
        SELECT c.StaffUniqueId,
               a.EducationOrganizationId
        FROM EDFISQL01.s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.EducationOrganization a
            INNER JOIN EDFISQL01.s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.StaffEducationOrganizationAssignmentAssociation b
                ON b.EducationOrganizationId = a.EducationOrganizationId
            INNER JOIN EDFISQL01.s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.Staff c
                ON c.StaffUSI = b.StaffUSI
        WHERE a.Discriminator IN ( 'edfi.School' )
              AND b.EndDate IS NULL
        EXCEPT
        SELECT DISTINCT
               userid,
               sch
        FROM BPSGRANARY02.BPSDW.dbo.UserSecurity
    ) ex
        INNER JOIN EDFISQL01.s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.EducationOrganizationIdentificationCode
            ON EducationOrganizationIdentificationCode.EducationOrganizationId = ex.EducationOrganizationId
               AND s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.EducationOrganizationIdentificationCode.EducationOrganizationIdentificationSystemDescriptorId = 852
        INNER JOIN BPSGRANARY02.BPSDW.dbo.UserSecurity
            ON ex.StaffUniqueId = userid;

END;
GO
