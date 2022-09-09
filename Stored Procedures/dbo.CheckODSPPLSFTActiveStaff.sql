SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

------------------------------------------------------------------------------
-- Author:Ragha
-- Create date: 2020-06-29
-- Description:	Compare Active Staff between Peoplesoft and ODS
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[CheckODSPPLSFTActiveStaff]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        SELECT DISTINCT
               StaffUniqueId
        FROM [BPS_ODS_SIS_DataCheck].[dbo].[ActiveStaff_EdfiOds_V34] act
        WHERE act.assnEnddate IS NULL
		AND PositionTitle NOT LIKE '%Stipend%'
		
        EXCEPT
        SELECT DISTINCT
               a.ID
        FROM [BPS_ODS_SIS_DataCheck].[dbo].[ActiveStaff_PPLSFT] a
		JOIN s3v5_EdFi_BPS_Production_Ods.edfi.Staff s
		on RTRIM(LTRIM(convert(varchar(50), a.ID))) = s.StaffUniqueId
        WHERE Status IN ( 'L', 'A', 'U', 'P' )
		AND Job_Title NOT LIKE '%Stipend%'
		
    ) a
    UNION
    SELECT *
    FROM
    (
        SELECT DISTINCT
               a.ID
        FROM [BPS_ODS_SIS_DataCheck].[dbo].[ActiveStaff_PPLSFT] a
		JOIN s3v5_EdFi_BPS_Production_Ods.edfi.Staff s
		on RTRIM(LTRIM(convert(varchar(50), a.ID))) = s.StaffUniqueId
        WHERE Status IN ( 'L', 'A', 'U', 'P' )
		AND Job_Title NOT LIKE '%Stipend%'
		
        EXCEPT
        SELECT DISTINCT
               StaffUniqueId
        FROM [BPS_ODS_SIS_DataCheck].[dbo].[ActiveStaff_EdfiOds_v34] act
        WHERE assnEnddate IS NULL
		AND PositionTitle NOT LIKE '%Stipend%'
		
    ) b;

END;
GO
