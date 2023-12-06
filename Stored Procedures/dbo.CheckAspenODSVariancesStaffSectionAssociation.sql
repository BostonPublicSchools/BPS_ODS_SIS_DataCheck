SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
    =============================================
    Author:			Marco Martinez
    Create date:	09/27/2023
    Description:	StaffSectionAssociation mismatches between DPI & Schedule Master Teacher
    =============================================
*/
CREATE PROCEDURE [dbo].[CheckAspenODSVariancesStaffSectionAssociation]
AS
BEGIN
    --SET NOCOUNT ON added to prevent extra result sets from
    --interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @Year AS INT;
    DECLARE @Zone AS VARCHAR(10);

    SELECT @Year = CTX_SCHOOL_YEAR,
           @Zone = 'ODS-' + CAST(CTX_SCHOOL_YEAR AS VARCHAR)
    FROM ASPENDBCLOUD.aspen_ma_boston.dbo.DISTRICT_SCHOOL_YEAR_CONTEXT
        JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.ORGANIZATION
            ON CTX_OID = ORG_CTX_OID_CURRENT
               AND ORG_ORG_OID_PARENT IS NULL;


    WITH cteStaffODS
    AS (SELECT DISTINCT
               [StaffUniqueId] COLLATE DATABASE_DEFAULT AS StaffId
        FROM [EDFISQL01].[s3v5ys_EdFi_BPS_ProdYS_Ods_2024].[edfi].[Staff]),
         DPI_SectionCount
    AS (SELECT dpi.DPI_OBJ_ID_02 AS 'SchoolId',
               dpi.DPI_OBJ_ID_01 AS 'StaffID',
               COUNT(1) AS 'SectionsInODS'
        FROM ASPENDBCLOUD.aspen_ma_boston.dbo.DATA_PUBLISH_IMAGE dpi
        WHERE dpi.DPI_TYPE = 'EdFi'
              AND dpi.DPI_ENTITY_TYPE = 'StaffSectionAssociation'
              AND dpi.DPI_ZONE = @Zone
              AND dpi.DPI_YEAR = @Year
              AND dpi.DPI_SRC_STATUS = 'Uploaded'
        GROUP BY dpi.DPI_OBJ_ID_02,
                 dpi.DPI_OBJ_ID_01),
         MST_Count
    AS (SELECT stf.STF_OID,
               stf.STF_ID_LOCAL AS 'StaffID',
               stf.STF_NAME_VIEW AS 'StaffName',
               stf.STF_STAFF_TYPE AS 'StaffType',
               skl.SKL_SCHOOL_ID AS 'SchoolId',
               skl.SKL_SCHOOL_NAME AS 'SchoolName',
               COUNT(DISTINCT mtc.MTC_MST_OID) AS 'SectionsScheduled'
        FROM ASPENDBCLOUD.aspen_ma_boston.dbo.SCHEDULE_MASTER_TEACHER mtc
            JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.SCHEDULE_MASTER mst
                ON mst.MST_OID = mtc.MTC_MST_OID
                   AND COALESCE(MST_FIELDA_005, '0') = '0' --  DOE EXCLUDE MST
            --AND COALESCE(MTC_FIELDA_002, '0') = '0' --  DOE EXCLUDE MTC
            JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.COURSE_SCHOOL csk
                ON csk.CSK_OID = mst.MST_CSK_OID
            JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.COURSE crs
                ON crs.CRS_OID = csk.CSK_CRS_OID
                   AND COALESCE(CRS_FIELDA_002, '0') = '0' --  DOE EXCLUDE CRS)
                   AND CRS_MASTER_TYPE = 'Class' -- only "Class" is publishable
            JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.SCHEDULE sch
                ON mst.MST_SCH_OID = sch.SCH_OID
            JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.SCHOOL_SCHEDULE_CONTEXT skx
                ON skx.SKX_SCH_OID_ACTIVE = sch.SCH_OID
            JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.SCHOOL skl
                ON skx.SKX_SKL_OID = skl.SKL_OID
                   AND COALESCE(TRY_CAST(skl.SKL_SCHOOL_ID AS INT), -1) > 0 -- School ID is numeric
            JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.DISTRICT_SCHOOL_YEAR_CONTEXT ctx
                ON ctx.CTX_OID = skx.SKX_CTX_OID
            JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.ORGANIZATION org
                ON ctx.CTX_OID = org.ORG_CTX_OID_CURRENT
                   AND org.ORG_ORG_OID_PARENT IS NULL
            JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.STAFF stf
                ON stf.STF_OID = mtc.MTC_STF_OID
        WHERE stf.STF_ID_LOCAL IS NOT NULL
        GROUP BY stf.STF_OID,
                 stf.STF_ID_LOCAL,
                 stf.STF_NAME_VIEW,
                 stf.STF_STAFF_TYPE,
                 skl.SKL_SCHOOL_ID,
                 skl.SKL_SCHOOL_NAME)
    SELECT mst.SchoolId,
           mst.SchoolName,
           mst.StaffId,
           mst.StaffName,
           mst.StaffType,
           mst.SectionsScheduled,
           ISNULL(dpi.SectionsInODS, 0) SectionsInODS,
           mst.SectionsScheduled - ISNULL(dpi.SectionsInODS, 0) AS 'variance'
    FROM MST_Count mst
        LEFT JOIN DPI_SectionCount dpi
            ON mst.StaffId = dpi.StaffId
               AND mst.SchoolId = dpi.SchoolId
        LEFT JOIN cteStaffODS
            ON mst.StaffId = cteStaffODS.StaffId
    WHERE ISNULL(dpi.SectionsInODS, 0) <> mst.SectionsScheduled
          AND cteStaffODS.StaffId IS NOT NULL
    ORDER BY mst.SchoolId,
             mst.SchoolName,
             variance DESC,
             mst.StaffName;

END;
GO
