SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		P. Bryce Avery
-- Create date: 2020-02-03
-- Description:	Compares staff between ODS and SIS
-- =============================================
CREATE   PROCEDURE [dbo].[CheckODSSISStaffV1]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
           LOWER(FirstName) FirstName,
           --           LOWER(MiddleName),
           LOWER(LastSurname)LastSurname,
           StaffUniqueId,
           'ODS' as RecordsFoundIn
    FROM EdFi_Staff Staff
        JOIN EdFi_StaffEducationOrganizationAssignmentAssociation
            ON EdFi_StaffEducationOrganizationAssignmentAssociation.StaffUSI = Staff.StaffUSI
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
           'ODS' as RecordsFoundIn
    FROM [BPSDATA-03].ExtractAspen.dbo.STAFF
        JOIN [BPSDATA-03].ExtractAspen.dbo.PERSON
            ON PSN_OID = STF_PSN_OID
    WHERE STF_STATUS IN ( 'Active')--, 'Inactive', 'Paid Leave' )
          AND LEFT(STF_ID_LOCAL, 1) IN ( '0', '1' )
    UNION ALL
    SELECT LOWER(PSN_NAME_FIRST) COLLATE DATABASE_DEFAULT,
           --           LOWER(PSN_NAME_MIDDLE) COLLATE DATABASE_DEFAULT,
           LOWER(PSN_NAME_LAST) COLLATE DATABASE_DEFAULT,
           STF_ID_LOCAL COLLATE DATABASE_DEFAULT,
           'SIS' as RecordsFoundIn
    FROM [BPSDATA-03].ExtractAspen.dbo.STAFF
        JOIN [BPSDATA-03].ExtractAspen.dbo.PERSON
            ON PSN_OID = STF_PSN_OID
    WHERE STF_STATUS IN ( 'Active')--, 'Inactive', 'Paid Leave' )
          AND LEFT(STF_ID_LOCAL, 1) IN ( '0', '1' )
    EXCEPT
    SELECT DISTINCT
           LOWER(FirstName)FirstName,
           --           LOWER(MiddleName),
           LOWER(LastSurname)LastSurname,
           StaffUniqueId,
           'SIS' as RecordsFoundIn
    FROM EdFi_Staff Staff
        JOIN Edfi_StaffEducationOrganizationAssignmentAssociation
            ON Edfi_StaffEducationOrganizationAssignmentAssociation.StaffUSI = Staff.StaffUSI
               --AND
               --(
               --    EndDate > '2011-01-01'
               --    OR EndDate IS NULL
               --)
    WHERE LEFT(StaffUniqueId, 1) IN ( '0', '1' )
	AND EndDate IS NULL
	ORDER BY RecordsFoundIn;

END;
GO
