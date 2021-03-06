USE [BPS_ODS_SIS_DataCheck]
GO
/****** Object:  StoredProcedure [dbo].[CheckODSSISStudentIdentificationCode]    Script Date: 8/14/2020 5:16:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------------------------------------------------------------------------------
-- Author:		Ragha
-- Create date: 2020-06-15
-- Description:	Compare SIS Vs ODS StudentIdentificationCode
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[CheckODSSISStudentIdentificationCode]
AS

BEGIN
    SET NOCOUNT ON;

SELECT DISTINCT 
STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AS AS STD_ID_LOCAL,
STD_ID_STATE COLLATE SQL_Latin1_General_CP1_CI_AS AS STD_ID_STATE
FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT s
--INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_STUDENT_ENROLLMENT e WITH (NOLOCK) ON s.STD_OID = e.ENR_STD_OID
INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK) ON SKL_OID = STD_SKL_OID
INNER JOIN [BPSDATA-03].ExtractAspen. dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH ( NOLOCK ) ON SKL_CTX_OID_CURRENT = CTX_OID
--AND ENR_ENROLLMENT_DATE >= CTX_START_DATE
--Ragha Y 08-10-2020 Updated to 2020-2021 from 2019-2020'
WHERE CTX_CONTEXT_ID = '2020-2021'
--AND 
--e.ENR_WITHDATE IS NULL
--AND 
--(COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT),-1) BETWEEN 1000 AND 4800
--   OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT),-1) BETWEEN 9000 AND 9999)
  --AND s.STD_ENROLLMENT_STATUS ='Active'
  AND STD_ID_STATE COLLATE SQL_Latin1_General_CP1_CI_AS IS NOT NULL

EXCEPT
SELECT DISTINCT 
std.StudentUniqueId,
sic.IdentificationCode
FROM EdFi_BPS_Production_Ods.edfi.StudentIdentificationCode sic 
INNER JOIN EdFi_BPS_Production_Ods.edfi.Student std ON std.StudentUSI = sic.StudentUSI 
INNER JOIN EdFi_BPS_Production_Ods.edfi.StudentSchoolAssociation sc ON std.StudentUSI = sc.StudentUSI
WHERE 
sc.ExitWithdrawDate IS NULL
--Ragha Y 08-11-2020 Updated to 2021 from 2020
AND sc.SchoolYear=2021
--AND (sc.SchoolId  BETWEEN 1000 AND 4800
--   OR sc.SchoolId BETWEEN 9000 AND 9999)
AND sic.AssigningOrganizationIdentificationCode ='State'
UNION 
SELECT DISTINCT 
std.StudentUniqueId,
sic.IdentificationCode
FROM EdFi_BPS_Production_Ods.edfi.StudentIdentificationCode sic 
INNER JOIN EdFi_BPS_Production_Ods.edfi.Student std ON std.StudentUSI = sic.StudentUSI 
INNER JOIN EdFi_BPS_Production_Ods.edfi.StudentSchoolAssociation sc ON std.StudentUSI = sc.StudentUSI
WHERE 
sc.ExitWithdrawDate IS NULL
--Ragha Y 08-10-2020 Updated to 2021 from 2020
AND sc.SchoolYear=2021
--AND (sc.SchoolId  BETWEEN 1000 AND 4800
--   OR sc.SchoolId BETWEEN 9000 AND 9999)
AND sic.AssigningOrganizationIdentificationCode ='State'
EXCEPT
SELECT DISTINCT 
STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AS AS STD_ID_LOCAL,
STD_ID_STATE COLLATE SQL_Latin1_General_CP1_CI_AS AS STD_ID_STATE
FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT s
--INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_STUDENT_ENROLLMENT e WITH (NOLOCK) ON s.STD_OID = e.ENR_STD_OID
INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK) ON SKL_OID = STD_SKL_OID
INNER JOIN [BPSDATA-03].ExtractAspen. dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH ( NOLOCK ) ON SKL_CTX_OID_CURRENT = CTX_OID
--AND ENR_ENROLLMENT_DATE >= CTX_START_DATE
--Ragha Y 08-10-2020 Updated to 2020-2021 from 2019-2020'
WHERE CTX_CONTEXT_ID = '2020-2021'--AND 
--e.ENR_WITHDATE IS NULL
--AND 
--(COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT),-1) BETWEEN 1000 AND 4800
--   OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT),-1) BETWEEN 9000 AND 9999)
  --AND s.STD_ENROLLMENT_STATUS ='Active'

  END
  ;