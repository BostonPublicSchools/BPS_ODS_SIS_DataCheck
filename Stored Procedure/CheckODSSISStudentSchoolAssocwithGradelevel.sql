USE [BPS_ODS_SIS_DataCheck]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

------------------------------------------------------------------------------
-- Author:		Ragha
-- Create date: 2020-07-01
-- Description:	Check SIS vs ODS StudentSchoolAssociation and Gradelevel
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[CheckODSSISStudentSchoolAssocwithGradelevel]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ssc.SchoolId,
           d.CodeValue AS Student_Grade,
           COUNT(StudentUniqueId) Student_Cnt
    FROM s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.Student s WITH (NOLOCK)
        INNER JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.StudentSchoolAssociation ssc WITH (NOLOCK)
            ON ssc.StudentUSI = s.StudentUSI
        INNER JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.Descriptor d WITH (NOLOCK)
            ON d.DescriptorId = ssc.EntryGradeLevelDescriptorId
        INNER JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.GradeLevelDescriptor gd WITH (NOLOCK)
            ON d.DescriptorId = gd.GradeLevelDescriptorId
    WHERE (
              SchoolId
          BETWEEN 1000 AND 4800
              OR SchoolId
          BETWEEN 9000 AND 9999
          )
          --Ragha Y 08-10-2020 Updated to 2021 from 2020
          --AND SchoolYear = 2021
          AND ExitWithdrawDate IS NULL
          AND d.CodeValue IS NOT NULL
    GROUP BY ssc.SchoolId,
             d.CodeValue
    EXCEPT
    SELECT SKL_SCHOOL_ID COLLATE SQL_Latin1_General_CP1_CI_AS AS SKL_SCHOOL_ID,
           RCD_FIELDD_001 COLLATE SQL_Latin1_General_CP1_CI_AS AS Student_Grade,
           COUNT(STD_ID_LOCAL) AS Student_cnt
    FROM
    (
        SELECT DISTINCT
               skl.SKL_SCHOOL_ID,
               RCD_FIELDD_001,
               std.STD_ID_LOCAL
        FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT std WITH (NOLOCK)
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.SCHOOL skl WITH (NOLOCK)
                ON skl.SKL_OID = std.STD_SKL_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT d WITH (NOLOCK)
                ON SKL_CTX_OID_CURRENT = d.CTX_OID
            INNER JOIN [BPSDATA-03].[ExtractAspen].dbo.DATA_FIELD_CONFIG WITH (NOLOCK)
                ON FDD_RTB_OID = 'rtbGradeLevel'
            INNER JOIN [BPSDATA-03].[ExtractAspen].dbo.REF_TABLE WITH (NOLOCK)
                ON RTB_OID = FDD_RTB_OID
            INNER JOIN [BPSDATA-03].[ExtractAspen].dbo.REF_CODE WITH (NOLOCK)
                ON RTB_OID = RCD_RTB_OID
                   AND RCD_CODE = STD_GRADE_LEVEL
        WHERE (
                  COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 1000 AND 4800
                  OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 9000 AND 9999
              )
              AND std.STD_ENROLLMENT_STATUS = 'Active'
              --Ragha Y 08-10-2020 Updated to 2022-2023 from 2019-2020'
              AND CTX_CONTEXT_ID = '2022-2023'
              AND RCD_FIELDD_001 <> 'Ungraded'
              AND RCD_FIELDD_001 IS NOT NULL
    ) a
    GROUP BY SKL_SCHOOL_ID,
             RCD_FIELDD_001
    UNION
    SELECT SKL_SCHOOL_ID COLLATE SQL_Latin1_General_CP1_CI_AS AS SKL_SCHOOL_ID,
           RCD_FIELDD_001 COLLATE SQL_Latin1_General_CP1_CI_AS AS Student_Grade,
           COUNT(STD_ID_LOCAL) AS Student_cnt
    FROM
    (
        SELECT DISTINCT
               skl.SKL_SCHOOL_ID,
               RCD_FIELDD_001,
               std.STD_ID_LOCAL
        FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT std WITH (NOLOCK)
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.SCHOOL skl WITH (NOLOCK)
                ON skl.SKL_OID = std.STD_SKL_OID
            INNER JOIN [BPSDATA-03].ExtractAspen.dbo.V_DISTRICT_SCHOOL_YEAR_CONTEXT d WITH (NOLOCK)
                ON SKL_CTX_OID_CURRENT = d.CTX_OID
            INNER JOIN [BPSDATA-03].[ExtractAspen].dbo.DATA_FIELD_CONFIG WITH (NOLOCK)
                ON FDD_RTB_OID = 'rtbGradeLevel'
            INNER JOIN [BPSDATA-03].[ExtractAspen].dbo.REF_TABLE WITH (NOLOCK)
                ON RTB_OID = FDD_RTB_OID
            INNER JOIN [BPSDATA-03].[ExtractAspen].dbo.REF_CODE WITH (NOLOCK)
                ON RTB_OID = RCD_RTB_OID
                   AND RCD_CODE = STD_GRADE_LEVEL
        WHERE (
                  COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 1000 AND 4800
                  OR COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1)
              BETWEEN 9000 AND 9999
              )
              AND std.STD_ENROLLMENT_STATUS = 'Active'
              --Ragha Y 08-10-2020 Updated to 2022-2023 from 2019-2020'
              AND CTX_CONTEXT_ID = '2022-2023'
              AND RCD_FIELDD_001 <> 'Ungraded'
              AND RCD_FIELDD_001 IS NOT NULL
    ) a
    GROUP BY SKL_SCHOOL_ID,
             RCD_FIELDD_001
    EXCEPT
    SELECT ssc.SchoolId,
           d.CodeValue AS Student_Grade,
           COUNT(StudentUniqueId) Student_Cnt
    FROM s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.Student s WITH (NOLOCK)
        INNER JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.StudentSchoolAssociation ssc WITH (NOLOCK)
            ON ssc.StudentUSI = s.StudentUSI
        INNER JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.Descriptor d WITH (NOLOCK)
            ON d.DescriptorId = ssc.EntryGradeLevelDescriptorId
        INNER JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.GradeLevelDescriptor gd WITH (NOLOCK)
            ON d.DescriptorId = gd.GradeLevelDescriptorId
    WHERE (
              SchoolId
          BETWEEN 1000 AND 4800
              OR SchoolId
          BETWEEN 9000 AND 9999
          )
          --Ragha Y 08-10-2020 Updated to 2021 from 2020
         -- AND SchoolYear = 2021
          AND ExitWithdrawDate IS NULL
          AND d.CodeValue IS NOT NULL
    GROUP BY ssc.SchoolId,
             d.CodeValue;

END;

GO
