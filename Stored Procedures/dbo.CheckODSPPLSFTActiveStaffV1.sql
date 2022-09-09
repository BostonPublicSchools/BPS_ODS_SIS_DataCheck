SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



------------------------------------------------------------------------------
-- Author:Ragha
-- Create date: 2020-06-29
-- Description:	Compare Active Staff between Peoplesoft and ODS
-------------------------------------------------------------------------------
CREATE     PROCEDURE [dbo].[CheckODSPPLSFTActiveStaffV1]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        SELECT DISTINCT
               StaffUniqueId,
			   'ODS' as RecordsFoundIn
        FROM [BPS_ODS_SIS_DataCheck].[dbo].[ActiveStaff_EdfiOds_V34] act
        WHERE act.assnEnddate IS NULL
		AND PositionTitle NOT LIKE '%Stipend%'
		
        EXCEPT
        SELECT DISTINCT
               a.ID,
			  'ODS' as RecordsFoundIn
        FROM [BPS_ODS_SIS_DataCheck].[dbo].[ActiveStaff_PPLSFT] a
		JOIN Edfi_Staff s
		on RTRIM(LTRIM(convert(varchar(50), a.ID))) = s.StaffUniqueId
        WHERE Status IN ( 'L', 'A', 'U', 'P' )
		AND Job_Title NOT LIKE '%Stipend%'
		
    ) a
    UNION
    SELECT *
    FROM
    (
        SELECT DISTINCT
               a.ID,
			   'ODS' as RecordsFoundIn
        FROM [BPS_ODS_SIS_DataCheck].[dbo].[ActiveStaff_PPLSFT] a
		JOIN Edfi_Staff s
		on RTRIM(LTRIM(convert(varchar(50), a.ID))) = s.StaffUniqueId
        WHERE Status IN ( 'L', 'A', 'U', 'P' )
		AND Job_Title NOT LIKE '%Stipend%'
		
        EXCEPT
        SELECT DISTINCT
               StaffUniqueId,
			  'ODS' as RecordsFoundIn
        FROM [BPS_ODS_SIS_DataCheck].[dbo].[ActiveStaff_EdfiOds_v34] act
        WHERE assnEnddate IS NULL
		AND PositionTitle NOT LIKE '%Stipend%'
		
    ) b;

END;
GO
