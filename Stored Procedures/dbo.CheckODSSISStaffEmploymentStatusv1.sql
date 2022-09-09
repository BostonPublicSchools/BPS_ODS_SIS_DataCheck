SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		P. Bryce Avery
-- Create date: 2020-02-27
-- Description:	Compares staff employment status between ODS and SIS
-- =============================================
CREATE   PROCEDURE [dbo].[CheckODSSISStaffEmploymentStatusv1]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT STF_ID_LOCAL COLLATE DATABASE_DEFAULT,
           'SIS' as RecordsFoundIn
    FROM [BPSDATA-03].ExtractAspen.dbo.STAFF
        JOIN [BPSDATA-03].ExtractAspen.dbo.PERSON
            ON PSN_OID = STF_PSN_OID
    WHERE STF_STATUS IN ( 'Active' )
          AND LEFT(STF_ID_LOCAL, 1) IN ( '0', '1' )
    EXCEPT
    SELECT StaffUniqueId,
            'SIS' as RecordsFoundIn
    FROM Edfi_Staff Staff
        JOIN Edfi_StaffEducationOrganizationEmploymentAssociation seoea
            ON seoea.StaffUSI = Staff.StaffUSI
    WHERE EndDate IS NULL
    UNION ALL
    SELECT StaffUniqueId,
            'ODS' as RecordsFoundIn
    FROM Edfi_Staff Staff
        JOIN Edfi_StaffEducationOrganizationEmploymentAssociation seoea
            ON seoea.StaffUSI = Staff.StaffUSI
    WHERE EndDate IS NULL
    EXCEPT
    SELECT STF_ID_LOCAL COLLATE DATABASE_DEFAULT,
           'ODS' as RecordsFoundIn
    FROM [BPSDATA-03].ExtractAspen.dbo.STAFF
        JOIN [BPSDATA-03].ExtractAspen.dbo.PERSON
            ON PSN_OID = STF_PSN_OID
    WHERE STF_STATUS IN ( 'Active' )
          AND LEFT(STF_ID_LOCAL, 1) IN ( '0', '1' )
ORDER BY RecordsFoundIn
END;
GO
