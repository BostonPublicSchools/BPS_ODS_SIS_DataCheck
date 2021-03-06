USE [BPS_ODS_SIS_DataCheck]
GO
/****** Object:  StoredProcedure [dbo].[CheckODSSISStaffEmploymentStatus]    Script Date: 8/14/2020 5:13:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		P. Bryce Avery
-- Create date: 2020-02-27
-- Description:	Compares staff employment status between ODS and SIS
-- =============================================
CREATE PROCEDURE [dbo].[CheckODSSISStaffEmploymentStatus]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT STF_ID_LOCAL COLLATE DATABASE_DEFAULT,
           'Active in SIS' InDB
    FROM [BPSDATA-03].ExtractAspen.dbo.STAFF
        JOIN [BPSDATA-03].ExtractAspen.dbo.PERSON
            ON PSN_OID = STF_PSN_OID
    WHERE STF_STATUS IN ( 'Active' )
          AND LEFT(STF_ID_LOCAL, 1) IN ( '0', '1' )
    EXCEPT
    SELECT StaffUniqueId,
           'Active in SIS' InDB
    FROM EdFi_BPS_Production_Ods.edfi.Staff
        JOIN EdFi_BPS_Production_Ods.edfi.StaffEducationOrganizationEmploymentAssociation
            ON StaffEducationOrganizationEmploymentAssociation.StaffUSI = Staff.StaffUSI
    WHERE EndDate IS NULL
    UNION
    SELECT StaffUniqueId,
           'Active in ODS' InDB
    FROM EdFi_BPS_Production_Ods.edfi.Staff
        JOIN EdFi_BPS_Production_Ods.edfi.StaffEducationOrganizationEmploymentAssociation
            ON StaffEducationOrganizationEmploymentAssociation.StaffUSI = Staff.StaffUSI
    WHERE EndDate IS NULL
    EXCEPT
    SELECT STF_ID_LOCAL COLLATE DATABASE_DEFAULT,
           'Active in ODS' InDB
    FROM [BPSDATA-03].ExtractAspen.dbo.STAFF
        JOIN [BPSDATA-03].ExtractAspen.dbo.PERSON
            ON PSN_OID = STF_PSN_OID
    WHERE STF_STATUS IN ( 'Active' )
          AND LEFT(STF_ID_LOCAL, 1) IN ( '0', '1' );

END;
