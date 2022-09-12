SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


------------------------------------------------------------------------------
-- Author:Ragha
-- Create date: 2021-07-14
-- Description:	Compare counts for Student tables between ODS2.5 Vs 3
-------------------------------------------------------------------------------
CREATE   PROCEDURE [dbo].[CheckODSSISStudentsnotinsyncV1]
AS
BEGIN
    SET NOCOUNT ON;
SELECT DISTINCT
       STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ID_LOCAL,
	   'SIS' AS RecordsFoundIn
FROM [BPSDATA-03].ExtractAspen.dbo.V_STUDENT s WITH (NOLOCK)
    INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK)
        ON SKL_OID = STD_SKL_OID
		--INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH (NOLOCK)
  --              ON SKL_CTX_OID_CURRENT = CTX_OID
WHERE (
          COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
      BETWEEN 1000 AND 4800
          OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
      BETWEEN 9000 AND 9999
      )
	  --AND
   --           (
   --               CTX_SCHOOL_YEAR = 2021
   --               OR CTX_CONTEXT_ID = '2020-2021'
   --           )
			  
      AND s.STD_ENROLLMENT_STATUS = 'Active'

EXCEPT
SELECT DISTINCT
       StudentUniqueId,
	   'SIS' AS RecordsFoundIn
FROM Edfi_Student s WITH (NOLOCK)
    LEFT JOIN Edfi_StudentSchoolAssociation eo WITH (NOLOCK)
        ON eo.StudentUSI = s.StudentUSI
WHERE eo.ExitWithdrawDate IS NULL
      AND
      (
          SchoolId
      BETWEEN 1000 AND 4800
          OR SchoolId
      BETWEEN 9000 AND 9999
      )
	  --AND eo.SchoolYear = 2021
UNION ALL
SELECT DISTINCT
       StudentUniqueId,
	   'ODS' AS RecordsFoundIn
FROM Edfi_Student s WITH (NOLOCK)
    LEFT JOIN Edfi_StudentSchoolAssociation eo WITH (NOLOCK)
        ON eo.StudentUSI = s.StudentUSI
WHERE eo.ExitWithdrawDate IS NULL
      AND
      (
          SchoolId
      BETWEEN 1000 AND 4800
          OR SchoolId
      BETWEEN 9000 AND 9999
      )
	  --AND eo.SchoolYear = 2021
EXCEPT
SELECT DISTINCT
       STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AI AS STD_ID_LOCAL,
	   'ODS' AS RecordsFoundIn
FROM [BPSDATA-03].ExtractAspen.dbo.V_STUDENT s WITH (NOLOCK)
    INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_SCHOOL WITH (NOLOCK)
        ON SKL_OID = STD_SKL_OID
		--INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT WITH (NOLOCK)
  --              ON SKL_CTX_OID_CURRENT = CTX_OID
WHERE (
          COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
      BETWEEN 1000 AND 4800
          OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
      BETWEEN 9000 AND 9999
      )
	  --AND
   --           (
   --               CTX_SCHOOL_YEAR = 2021
   --               OR CTX_CONTEXT_ID = '2020-2021'
   --           )
			  
     AND s.STD_ENROLLMENT_STATUS = 'Active';
END;
GO
