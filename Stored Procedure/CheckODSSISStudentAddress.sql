USE [BPS_ODS_SIS_DataCheck]
GO
/****** Object:  StoredProcedure [dbo].[CheckODSSISStudentAddress]    Script Date: 8/14/2020 5:14:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------------------------------------------------------------------------------
-- Author:		Ragha
-- Create date: 2020-05-29
-- Description:	SIS vs ODS StudentAddress Compare
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[CheckODSSISStudentAddress]
AS
BEGIN
    SET NOCOUNT ON;
IF OBJECT_ID('tempdb.dbo.#tempaspen', 'U') IS NOT NULL
    DROP TABLE #tempaspen;
IF OBJECT_ID('tempdb.dbo.#tempods', 'U') IS NOT NULL
    DROP TABLE #tempods;

SELECT * 
INTO #tempaspen
FROM (SELECT 
s.STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ID_LOCAL,
CASE WHEN LEN(s.STD_ADRS_VIEW) >0
THEN REVERSE(RIGHT(REVERSE(s.STD_ADRS_VIEW), LEN(s.STD_ADRS_VIEW) - CHARINDEX(' ', REVERSE(s.STD_ADRS_VIEW)))) END 
COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ADRS_VIEW ,
RIGHT(s.STD_ADRS_VIEW, CHARINDEX(' ', REVERSE(s.STD_ADRS_VIEW)) - 1) COLLATE SQL_Latin1_General_CP1_CI_AI AS zip
FROM [BPSDATA-03].ExtractAspen.dbo.V_STUDENT s WITH (NOLOCK)
INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_STUDENT_ENROLLMENT e WITH (NOLOCK) ON s.STD_OID = ENR_STD_OID
INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK) ON SKL_OID = ENR_SKL_OID
INNER JOIN [BPSDATA-03].ExtractAspen. dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH ( NOLOCK ) ON SKL_CTX_OID_CURRENT = CTX_OID
WHERE isnull(s.STD_ADRS_VIEW,'') <> ''
AND s.STD_ENROLLMENT_STATUS = 'Active'
AND (CTX_SCHOOL_YEAR =2020 OR CTX_CONTEXT_ID = '2019-2020')
)aa

SELECT * 
INTO #tempods
FROM (
SELECT distinct 
a.StudentUniqueId,
B.StreetNumberName,
b.PostalCode
FROM EdFi_BPS_Production_Ods.edfi.student a WITH (NOLOCK)
INNER JOIN EdFi_BPS_Production_Ods.edfi.StudentAddress b WITH (NOLOCK) ON a.StudentUSI = b.StudentUSI
INNER JOIN EdFi_BPS_Production_Ods.edfi.StudentSchoolAssociation eo WITH (NOLOCK) ON eo.StudentUSI = a.StudentUSI
WHERE eo.ExitWithdrawDate IS NULL
AND ISNULL(b.StreetNumberName,'') <> ''
AND b.AddressTypeId = 8
AND eo.SchoolYear=2020
) bb


SELECT RTRIM(LTRIM(STD_ID_LOCAL)) COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ID_LOCAL,
RTRIM(LTRIM(STD_ADRS_VIEW)) COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ADRS_VIEW,
RTRIM(LTRIM(zip)) COLLATE SQL_Latin1_General_CP1_CI_AI AS zip
FROM #tempaspen
--WHERE RTRIM(LTRIM(STD_ID_LOCAL)) COLLATE SQL_Latin1_General_CP1_CI_AI=203350
EXCEPT
SELECT RTRIM(LTRIM(StudentUniqueId)) AS StudentUniqueId,
RTRIM(LTRIM(StreetNumberName)) AS StreetNumberName ,
RTRIM(LTRIM(PostalCode)) AS PostalCode
from #tempods
--WHERE RTRIM(LTRIM(StudentUniqueId)) = 203350
UNION 
SELECT RTRIM(LTRIM(StudentUniqueId)) AS StudentUniqueId,
RTRIM(LTRIM(StreetNumberName)) AS StreetNumberName ,
RTRIM(LTRIM(PostalCode)) AS PostalCode
from #tempods
EXCEPT
SELECT RTRIM(LTRIM(STD_ID_LOCAL)) COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ID_LOCAL,
RTRIM(LTRIM(STD_ADRS_VIEW)) COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ADRS_VIEW,
RTRIM(LTRIM(zip)) COLLATE SQL_Latin1_General_CP1_CI_AI AS zip
FROM #tempaspen

END
;
