SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










CREATE   VIEW [dbo].[ActiveStaff_EdfiOds_V34]
AS
SELECT DISTINCT stf.StaffUniqueId,
       stfEdOrgEmp.StaffUSI,
       stfEdOrgEmp.EmploymentStatusDescriptorId,
       stfEdOrgEmp.EndDate AS EmpEnddate,
       stfEdOrgEmp.HireDate,
	   saa.PositionTitle,
	   saa.EndDate AS assnEnddate
FROM Edfi_Staff stf
    INNER JOIN Edfi_StaffEducationOrganizationEmploymentAssociation stfEdOrgEmp
        ON stf.StaffUSI = stfEdOrgEmp.StaffUSI
    LEFT JOIN Edfi_StaffEducationOrganizationAssignmentAssociation saa
        ON saa.StaffUSI = stf.StaffUSI
WHERE stfEdOrgEmp.EducationOrganizationId = '350000'
;
GO
