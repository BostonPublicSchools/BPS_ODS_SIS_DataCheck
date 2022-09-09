SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










CREATE   VIEW [dbo].[ActiveStaff_EdfiOds_V34_BackUp]
AS
SELECT DISTINCT stf.StaffUniqueId,
       stfEdOrgEmp.StaffUSI,
       stfEdOrgEmp.EmploymentStatusDescriptorId,
       stfEdOrgEmp.EndDate AS EmpEnddate,
       stfEdOrgEmp.HireDate,
	   saa.PositionTitle,
	   saa.EndDate AS assnEnddate
FROM v34_EdFi_BPS_Production_Ods.edfi.Staff stf
    INNER JOIN v34_EdFi_BPS_Production_Ods.edfi.StaffEducationOrganizationEmploymentAssociation stfEdOrgEmp
        ON stf.StaffUSI = stfEdOrgEmp.StaffUSI
    LEFT JOIN v34_EdFi_BPS_Production_Ods.edfi.StaffEducationOrganizationAssignmentAssociation saa
        ON saa.StaffUSI = stf.StaffUSI
WHERE stfEdOrgEmp.EducationOrganizationId = '350000'
;
GO
