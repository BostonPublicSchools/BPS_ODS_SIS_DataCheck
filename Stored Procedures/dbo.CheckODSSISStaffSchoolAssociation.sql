SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author: Ragha Y
-- Create date: 2021-04-07
-- Description: Compares staffchoolAssociation between ODS and SIS
-- =============================================
CREATE PROCEDURE [dbo].[CheckODSSISStaffSchoolAssociation]
AS
BEGIN
    SET NOCOUNT ON;
SELECT DISTINCT
       B.StaffUniqueId,
       A.SchoolId,
       A.SchoolYear
FROM s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.StaffSchoolAssociation A
    INNER JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.Staff B
        ON B.StaffUSI = A.StaffUSI
WHERE A.SchoolYear IS NOT NULL
      --AND A.SchoolYear = 2021
      AND A.SchoolId <> 9035
EXCEPT
SELECT DISTINCT
       CASE
           WHEN ISNUMERIC(STF_ID_LOCAL) = 1 THEN
               a.STF_ID_LOCAL
       END COLLATE SQL_Latin1_General_CP1_CI_AS StaffLocalID,
       CASE
           WHEN ISNUMERIC(C.SKL_SCHOOL_ID) = 1 THEN
               C.SKL_SCHOOL_ID
       END COLLATE SQL_Latin1_General_CP1_CI_AS SchoolID,
       d.CTX_SCHOOL_YEAR
FROM [BPSDATA-03].ExtractAspen.dbo.STAFF a
    INNER JOIN [BPSDATA-03].ExtractAspen.dbo.SCHOOL C
        ON a.STF_SKL_OID = C.SKL_OID
    --LEFT JOIN [BPSDATA-03].ExtractAspen.dbo.STAFF_SCHOOL b 
    -- ON b.SFS_STF_OID = a.STF_OID 
    LEFT JOIN [BPSDATA-03].ExtractAspen.dbo.DISTRICT_SCHOOL_YEAR_CONTEXT d
        ON SKL_CTX_OID_CURRENT = CTX_OID
WHERE CTX_CONTEXT_ID = '2022-2023'
UNION ALL
SELECT DISTINCT
       CASE
           WHEN ISNUMERIC(STF_ID_LOCAL) = 1 THEN
               a.STF_ID_LOCAL
       END COLLATE SQL_Latin1_General_CP1_CI_AS StaffLocalID,
       CASE
           WHEN ISNUMERIC(C.SKL_SCHOOL_ID) = 1 THEN
               C.SKL_SCHOOL_ID
       END COLLATE SQL_Latin1_General_CP1_CI_AS SchoolID,
       d.CTX_SCHOOL_YEAR
FROM [BPSDATA-03].ExtractAspen.dbo.STAFF a
    INNER JOIN [BPSDATA-03].ExtractAspen.dbo.SCHOOL C
        ON a.STF_SKL_OID = C.SKL_OID
    --LEFT JOIN [BPSDATA-03].ExtractAspen.dbo.STAFF_SCHOOL b 
    -- ON b.SFS_STF_OID = a.STF_OID 
    LEFT JOIN [BPSDATA-03].ExtractAspen.dbo.DISTRICT_SCHOOL_YEAR_CONTEXT d
        ON SKL_CTX_OID_CURRENT = CTX_OID
WHERE CTX_CONTEXT_ID = '2022-2023'
EXCEPT
SELECT DISTINCT
       B.StaffUniqueId,
       A.SchoolId,
       A.SchoolYear
FROM s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.StaffSchoolAssociation A
    INNER JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.Staff B
        ON B.StaffUSI = A.StaffUSI
WHERE A.SchoolYear IS NOT NULL
      --AND A.SchoolYear = 2021
      AND A.SchoolId <> 9035;

END
GO
