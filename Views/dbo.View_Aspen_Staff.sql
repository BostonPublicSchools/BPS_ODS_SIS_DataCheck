SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[View_Aspen_Staff]
AS
SELECT
    stf.STF_OID
    , stf.STF_ID_LOCAL [EmployeeID]
    , stf.STF_ID_STATE [MEPID]
    , stf.STF_NAME_VIEW [Name]
    , stf.STF_STATUS [EmplStatus]
    , stf.STF_HIRE_DATE [HireDate]
    , stf.STF_EXITTERM_DATE [ExitTermDate]
    , skl.SKL_SCHOOL_ID [Main_SklId]
FROM [BPSDATA-03].[ExtractAspen].[dbo].V_STAFF stf
LEFT JOIN [BPSDATA-03].[ExtractAspen].[dbo].V_SCHOOL skl
    ON skl.SKL_OID = stf.STF_SKL_OID
-- WHERE (
--         STF_STATUS = 'Active'
--         OR COALESCE(stf.STF_EXITTERM_DATE, '') = ''
--         );
GO
