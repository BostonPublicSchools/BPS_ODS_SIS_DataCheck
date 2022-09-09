SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author: Ragha
-- Create date: 2020-11-05
-- Description: Compare Staff Staff Assignment Between ODS and Peoplesoft
-- =============================================
CREATE PROCEDURE [dbo].[CheckODSPPLSFTStaffAssignmentEndDate]
AS
BEGIN
SELECT a.StaffUSI,
       a.StaffClassificationDescriptorId,
       a.PositionTitle,
       a.BeginDate
FROM EDFISQL01.s3v5_Edfi_BPS_Production_Ods.edfi.StaffEducationOrganizationAssignmentAssociation a
    JOIN EDFISQL01.s3v5_Edfi_BPS_Production_Ods.edfi.StaffEducationOrganizationAssignmentAssociation b
        ON a.StaffUSI = b.StaffUSI
           AND a.StaffClassificationDescriptorId = b.StaffClassificationDescriptorId
           AND a.PositionTitle = b.PositionTitle
           AND a.BeginDate = b.BeginDate
WHERE (
          a.EndDate IS NULL
          OR b.EndDate IS NULL
      )
GROUP BY a.StaffUSI,
         a.StaffClassificationDescriptorId,
         a.PositionTitle,
         a.BeginDate
HAVING COUNT(*) > 1

END ;
GO
