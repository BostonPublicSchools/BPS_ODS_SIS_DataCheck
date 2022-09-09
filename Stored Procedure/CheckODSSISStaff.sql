USE [BPS_ODS_SIS_DataCheck]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		P. Bryce Avery
-- Create date: 2020-02-03
-- Description:	Compares staff between ODS and SIS
-- =============================================
CREATE PROCEDURE [dbo].[CheckODSSISStaff]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
           LOWER(FirstName),
           --           LOWER(MiddleName),
           LOWER(LastSurname),
           StaffUniqueId,
           'In ODS' InDB
    FROM s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.Staff
        JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.StaffEducationOrganizationAssignmentAssociation
            ON StaffEducationOrganizationAssignmentAssociation.StaffUSI = Staff.StaffUSI
               --AND
               --(
               --    EndDate > '2011-01-01'
               --    OR EndDate IS NULL
               --)
    WHERE LEFT(StaffUniqueId, 1) IN ( '0', '1' )
	AND EndDate IS NULL
    EXCEPT
    SELECT LOWER(PSN_NAME_FIRST) COLLATE DATABASE_DEFAULT,
           --           LOWER(PSN_NAME_MIDDLE) COLLATE DATABASE_DEFAULT,
           LOWER(PSN_NAME_LAST) COLLATE DATABASE_DEFAULT,
           STF_ID_LOCAL COLLATE DATABASE_DEFAULT,
           'In ODS' InDB
    FROM [BPSDATA-03].ExtractAspen.dbo.STAFF
        JOIN [BPSDATA-03].ExtractAspen.dbo.PERSON
            ON PSN_OID = STF_PSN_OID
    WHERE STF_STATUS IN ( 'Active')--, 'Inactive', 'Paid Leave' )
          AND LEFT(STF_ID_LOCAL, 1) IN ( '0', '1' )
    UNION
    SELECT LOWER(PSN_NAME_FIRST) COLLATE DATABASE_DEFAULT,
           --           LOWER(PSN_NAME_MIDDLE) COLLATE DATABASE_DEFAULT,
           LOWER(PSN_NAME_LAST) COLLATE DATABASE_DEFAULT,
           STF_ID_LOCAL COLLATE DATABASE_DEFAULT,
           'In Aspen' InDB
    FROM [BPSDATA-03].ExtractAspen.dbo.STAFF
        JOIN [BPSDATA-03].ExtractAspen.dbo.PERSON
            ON PSN_OID = STF_PSN_OID
    WHERE STF_STATUS IN ( 'Active')--, 'Inactive', 'Paid Leave' )
          AND LEFT(STF_ID_LOCAL, 1) IN ( '0', '1' )
    EXCEPT
    SELECT DISTINCT
           LOWER(FirstName),
           --           LOWER(MiddleName),
           LOWER(LastSurname),
           StaffUniqueId,
           'In Aspen' InDB
    FROM s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.Staff
        JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.StaffEducationOrganizationAssignmentAssociation
            ON StaffEducationOrganizationAssignmentAssociation.StaffUSI = Staff.StaffUSI
               --AND
               --(
               --    EndDate > '2011-01-01'
               --    OR EndDate IS NULL
               --)
    WHERE LEFT(StaffUniqueId, 1) IN ( '0', '1' )
	AND EndDate IS NULL;

END;
GO
