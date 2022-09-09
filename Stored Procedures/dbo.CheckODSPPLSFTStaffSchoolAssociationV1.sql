SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ragha Y
-- Create date: 2021-04-09
-- Description:	Compares staffchoolAssociation between ODS and PeopleSoft
-- =============================================
CREATE   PROCEDURE [dbo].[CheckODSPPLSFTStaffSchoolAssociationV1]
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
    LEFT JOIN Edfi_EducationOrganizationIdentificationCode b
        ON a.Deptid = b.IdentificationCode
    JOIN Edfi_Staff c
        ON a.Id = c.StaffUniqueId
WHERE a.Status <> 'R';


SELECT StaffUniqueId,
       EducationOrganizationId,
       SchoolYear,
	   'ODS' as RecordsFoundIn
FROM #temp1
WHERE SchoolYear = 2022
      AND LEN(EducationOrganizationId) < 6      
EXCEPT
SELECT DISTINCT
       B.StaffUniqueId,
       A.SchoolId,
       A.SchoolYear,
	   'ODS' as RecordsFoundIn
FROM Edfi_StaffSchoolAssociation A
    INNER JOIN Edfi_Staff B
        ON B.StaffUSI = A.StaffUSI
WHERE A.SchoolYear IS NOT NULL
      AND A.SchoolId <> 9035
;

END
GO
