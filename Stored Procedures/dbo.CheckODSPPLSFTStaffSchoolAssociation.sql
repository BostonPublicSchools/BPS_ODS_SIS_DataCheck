SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ragha Y
-- Create date: 2021-04-09
-- Description:	Compares staffchoolAssociation between ODS and PeopleSoft
-- =============================================
CREATE PROCEDURE [dbo].[CheckODSPPLSFTStaffSchoolAssociation]
AS
BEGIN
    SET NOCOUNT ON;
SELECT b.EducationOrganizationId,
       c.StaffUSI,
       c.StaffUniqueId,
       CASE
           WHEN a.Status IN ( 'A', 'L', 'U', 'P' ) THEN
               2021
           WHEN a.Status IN ( 'T', 'R', 'D' )
                AND DATEPART(MONTH, Eff_Date) > 6 THEN
               YEAR(DATEADD(YEAR, 1, (Eff_Date)))
           WHEN a.Status IN ( 'T', 'R', 'D' )
                AND DATEPART(MONTH, Eff_Date) <= 6 THEN
               YEAR(Eff_Date)
       END AS SchoolYear,
       a.*
INTO #temp1
FROM EDFISQL01.BPS_ODS_SIS_DataCheck.dbo.staffassignment_load a
    LEFT JOIN EDFISQL01.s3v5_Edfi_BPS_Production_ODS.edfi.EducationOrganizationIdentificationCode b
        ON a.Deptid = b.IdentificationCode
    JOIN EDFISQL01.v34_Edfi_BPS_Production_ODS.edfi.Staff c
        ON a.Id = c.StaffUniqueId
WHERE a.Status <> 'R';


SELECT StaffUniqueId,
       EducationOrganizationId,
       SchoolYear
FROM #temp1
WHERE SchoolYear = 2022
      AND LEN(EducationOrganizationId) < 6      
EXCEPT
SELECT DISTINCT
       B.StaffUniqueId,
       A.SchoolId,
       A.SchoolYear
FROM EDFISQL01.Edfi_BPS_Production_Ods.edfi.StaffSchoolAssociation A
    INNER JOIN EDFISQL01.Edfi_BPS_Production_Ods.edfi.Staff B
        ON B.StaffUSI = A.StaffUSI
WHERE A.SchoolYear IS NOT NULL
      AND A.SchoolYear = 2022
      AND A.SchoolId <> 9035
;

END
GO
