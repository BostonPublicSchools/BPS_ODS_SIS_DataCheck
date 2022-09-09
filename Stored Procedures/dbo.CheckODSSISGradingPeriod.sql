SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CheckODSSISGradingPeriod]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT School_ID,
           Grade_Term,
           StartDate,
           'Not in ODS'
    FROM
    (
        SELECT DISTINCT
               SCL.SKL_SCHOOL_ID COLLATE SQL_Latin1_General_CP1_CI_AS AS School_ID,
               rcd.RCD_FIELDD_001 COLLATE SQL_Latin1_General_CP1_CI_AS AS Grade_Term,
               GTD.GTA_START_DATE AS StartDate
        FROM [BPSDATA-03].ExtractAspen.dbo.GRADE_TERM_DATE AS GTD
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.SCHOOL AS SCL
                ON GTD.GTA_SKL_OID = SCL.SKL_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.GRADE_TERM AS GT
                ON GT.GTM_OID = GTD.GTA_GTM_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.GRADE_TERM_DEFINITION AS GTDF
                ON GT.GTM_GTF_OID = GTDF.GTF_OID
            /* DATA_FIELD contains the DB Field name */
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.DATA_FIELD fld
                ON fld.FLD_DATABASE_NAME = 'GTM_GRADE_TERM_ID'
            /* DATA_FIELD_CONFIG contains data dictionary info about the field, including linked reference table */
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.DATA_FIELD_CONFIG fdd
                ON fdd.FDD_FLD_OID = fld.FLD_OID
            /* pull data for related ref table */
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.REF_TABLE rtb
                ON rtb.RTB_OID = fdd.FDD_RTB_OID
            /* ref codes for related ref table and limited to the specific field and value desired */
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.REF_CODE rcd
                ON rtb.RTB_OID = rcd.RCD_RTB_OID
                   AND rcd.RCD_CODE = GTM_GRADE_TERM_ID
            /* limit to current year without needing CTX_OID */
            JOIN [BPSDATA-03].ExtractAspen.dbo.DISTRICT_SCHOOL_YEAR_CONTEXT ctx
                ON ctx.CTX_OID = SCL.SKL_CTX_OID_CURRENT
                   AND ctx.CTX_OID = GTD.GTA_CTX_OID
        -- WHERE GTD.GTA_CTX_OID = 'CTX0000037jdTY'
        WHERE COALESCE(TRY_CAST(SCL.SKL_SCHOOL_ID AS INT), -1) > 0 -- School ID is numeric
        GROUP BY SCL.SKL_SCHOOL_ID,
                 rcd.RCD_FIELDD_001,
                 GTA_START_DATE
        EXCEPT
        SELECT DISTINCT
               CAST(gp.SchoolId AS VARCHAR(20)) AS School_ID,
               d.[Description] AS Grade_Term,
               gp.BeginDate AS StartDate
        FROM s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.GradingPeriod gp
            INNER JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.Descriptor d
                ON d.DescriptorId = gp.GradingPeriodDescriptorId
            INNER JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.EducationOrganization eo
                ON eo.EducationOrganizationId = gp.SchoolId
        -- INNER JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.StudentSchoolAssociation ssc
        --     ON ssc.SchoolId = gp.SchoolId
        -- WHERE ssc.SchoolYear = 2019
        GROUP BY gp.SchoolId,
                 [Description],
                 gp.BeginDate
    ) a
    UNION
    SELECT School_ID,
           Grade_Term,
           StartDate,
           'Not in SIS'
    FROM
    (
        SELECT DISTINCT
               CAST(gp.SchoolId AS VARCHAR(20)) AS School_ID,
               --eo.NameOfInstitution School_Name,
               --'Active in ODS' InDB,
               d.[Description] AS Grade_Term,
               gp.BeginDate AS StartDate
        FROM s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.GradingPeriod gp
            INNER JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.Descriptor d
                ON d.DescriptorId = gp.GradingPeriodDescriptorId
            INNER JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.EducationOrganization eo
                ON eo.EducationOrganizationId = gp.SchoolId
            INNER JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.StudentSchoolAssociation ssc
                ON ssc.SchoolId = gp.SchoolId
        --WHERE ssc.SchoolYear = 2019  
        GROUP BY gp.SchoolId,
                 [Description],
                 gp.BeginDate
        EXCEPT
        SELECT DISTINCT
               SCL.SKL_SCHOOL_ID COLLATE SQL_Latin1_General_CP1_CI_AS AS Schoold_ID,
               rcd.RCD_FIELDD_001 COLLATE SQL_Latin1_General_CP1_CI_AS AS Grade_Term,
               GTD.GTA_START_DATE AS StartDate
        FROM [BPSDATA-03].ExtractAspen.dbo.GRADE_TERM_DATE AS GTD
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.SCHOOL AS SCL
                ON GTD.GTA_SKL_OID = SCL.SKL_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.GRADE_TERM AS GT
                ON GT.GTM_OID = GTD.GTA_GTM_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.GRADE_TERM_DEFINITION AS GTDF
                ON GT.GTM_GTF_OID = GTDF.GTF_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.DATA_PUBLISH_IMAGE AS PUB
                ON PUB.DPI_OBJ_OID_01 = GTD.GTA_OID
            /* DATA_FIELD contains the DB Field name */
            JOIN [BPSDATA-03].ExtractAspen.dbo.DATA_FIELD fld
                ON fld.FLD_DATABASE_NAME = 'GTM_GRADE_TERM_ID'
            /* DATA_FIELD_CONFIG contains data dictionary info about the field, including linked reference table */
            JOIN [BPSDATA-03].ExtractAspen.dbo.DATA_FIELD_CONFIG fdd
                ON fdd.FDD_FLD_OID = fld.FLD_OID
            /* pull data for related ref table */
            JOIN [BPSDATA-03].ExtractAspen.dbo.REF_TABLE rtb
                ON rtb.RTB_OID = fdd.FDD_RTB_OID
            /* 
ref codes for related ref table
and limited to the specific field and value desired
 */
            JOIN [BPSDATA-03].ExtractAspen.dbo.REF_CODE rcd
                ON rtb.RTB_OID = rcd.RCD_RTB_OID
                   AND rcd.RCD_CODE = GTM_GRADE_TERM_ID
        --WHERE
        --GTD.GTA_CTX_OID = 'CTX0000037jdTY'
        GROUP BY SCL.SKL_SCHOOL_ID,
                 GTM_GRADE_TERM_ID,
                 GTA_START_DATE,
                 rcd.RCD_FIELDD_001
    ) b;
END;
GO
