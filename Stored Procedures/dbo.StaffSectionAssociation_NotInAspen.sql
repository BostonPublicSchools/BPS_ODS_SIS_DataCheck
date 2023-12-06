SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
    =============================================
    Author:			Marco Martinez
    Create date:	10/24/2023
    Description:	Section by Staff and School in ODS and NOT in Aspen
    =============================================
*/
CREATE PROCEDURE [dbo].[StaffSectionAssociation_NotInAspen]
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


    WITH cteTermCodes
    AS (
       /*
			The System field is used to "normalize" session names to a 
			common value that won't change over time. Session names are
			not Descriptors. Normalization is necessary because schools 
			customize and change term names causing problems for entities 
			where SessionName is a key field.
		*/
       SELECT RCD_CODE,
              RCD_CODE_SYSTEM
       FROM ASPENDBCLOUD.aspen_ma_boston.dbo.REF_CODE
       WHERE RCD_RTB_OID = 'rtbSchTermCode'),
         cteMTC
    AS   -- relabeled to clarify (this really is MTC-related)
    (SELECT STF_ID_LOCAL AS 'StaffID',
            STF_NAME_VIEW AS 'StaffName',
            STF_STAFF_TYPE AS 'StaffType',
            SKL_SCHOOL_NAME AS 'SchoolName',
            SKL_SCHOOL_ID AS 'SchoolId',
            CTX_SCHOOL_YEAR AS 'SchoolYear',
            cteTermCodes.RCD_CODE_SYSTEM AS 'SessionName',
            CONCAT(CRS_COURSE_NUMBER, '-', mstTRM.TRM_TERM_CODE) AS 'LocalCourseCode',
            MST_SECTION_NUMBER AS 'SectionNumber',
            -- grouped columns by table/topic
            MTC_TEACHER_ROLE AS 'TeacherRole',
            MTC_OID,
            mtcTRM.TRM_OID AS 'mtcTRM_OID',
            mtcTRM.TRM_TERM_NAME AS 'mtcTRM_Name',
            mtcTRM.TRM_TERM_CODE AS 'mtcTRM_Code',
            cteTermCodes_mtcTRM.RCD_CODE_SYSTEM AS 'mtcTRM_SessionName',
            MST_OID,
            mstTRM.TRM_OID AS 'mstTRM_OID',
            mstTRM.TRM_TERM_NAME AS 'mstTRM_Name',
            mstTRM.TRM_TERM_CODE AS 'mstTRM_Code',
            cteTermCodes.RCD_CODE_SYSTEM AS 'mstTRM_SessionName',
            CONCAT(
                      SKL_SCHOOL_ID,
                      CTX_SCHOOL_YEAR,
                      cteTermCodes.RCD_CODE_SYSTEM,
                      CONCAT(CRS_COURSE_NUMBER, '-', mstTRM.TRM_TERM_CODE),
                      MST_SECTION_NUMBER
                  ) AS 'DPI ID1+ID2+ID3+ID4+ID5'
     FROM ASPENDBCLOUD.aspen_ma_boston.dbo.SCHEDULE_MASTER_TEACHER

         -- get only publishable sections & courses
         JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.SCHEDULE_MASTER
             ON MST_OID = MTC_MST_OID
                AND COALESCE(MST_FIELDA_005, '0') = '0' --  DOE EXCLUDE MST
                --AND COALESCE(MTC_FIELDA_002, '0') = '0' --  DOE EXCLUDE MTC
         JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.COURSE_SCHOOL
             ON CSK_OID = MST_CSK_OID
         JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.COURSE
             ON CRS_OID = CSK_CRS_OID
                AND COALESCE(CRS_FIELDA_002, '0') = '0' --  DOE EXCLUDE CRS
                AND CRS_MASTER_TYPE = 'Class' -- only "Class" is publishable

         -- get only records in current year active schedules
         JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.SCHEDULE
             ON MST_SCH_OID = SCH_OID

         -- check for Schedule Term on MST records
         -- set to left join to catch missing Section Scheule Term
         LEFT JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.SCHEDULE_TERM mstTRM
             ON MST_TRM_OID = mstTRM.TRM_OID
         LEFT JOIN cteTermCodes
             ON mstTRM.TRM_TERM_CODE = cteTermCodes.RCD_CODE

         -- check for Schedule Term on MTC records
         LEFT JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.SCHEDULE_TERM mtcTRM
             ON MTC_TRM_OID = mtcTRM.TRM_OID
         LEFT JOIN cteTermCodes cteTermCodes_mtcTRM
             ON mtcTRM.TRM_TERM_CODE = cteTermCodes_mtcTRM.RCD_CODE

         -- limit to cuurent year active schcedules
         JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.SCHOOL_SCHEDULE_CONTEXT
             ON SKX_SCH_OID_ACTIVE = SCH_OID
         JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.SCHOOL
             ON SKX_SKL_OID = SKL_OID
                AND COALESCE(TRY_CAST(SKL_SCHOOL_ID AS INT), -1) > 0 -- School ID is numeric
         JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.DISTRICT_SCHOOL_YEAR_CONTEXT
             ON CTX_OID = SKX_CTX_OID
         JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.ORGANIZATION
             ON CTX_OID = ORG_CTX_OID_CURRENT
                AND ORG_ORG_OID_PARENT IS NULL

         -- get staff-related info (perhaps move to top of joins?)
         JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.STAFF
             ON STF_OID = MTC_STF_OID
     WHERE STF_ID_LOCAL IS NOT NULL),
         cteDPI
    AS (SELECT skl.SKL_SCHOOL_ID AS 'SchoolId',
               skl.SKL_SCHOOL_NAME AS 'SchoolName',
               stf.STF_ID_LOCAL AS 'StaffID',
               stf.STF_NAME_VIEW AS 'StaffName',
               DPI_OBJ_OID_03 AS 'MST_OID',
			   DPI_OBJ_OID_01 AS 'MTC_OID',
               DPI_OBJ_ID_03 AS 'SchoolYear',
               DPI_OBJ_ID_04 AS 'SessionName',
               DPI_OBJ_ID_05 AS 'LocalCourseCode',
               DPI_OBJ_ID_06 AS 'SectionNumber',
			   DPI_OBJ_ID_15 AS 'StaffSectionAssociationId'
        FROM ASPENDBCLOUD.aspen_ma_boston.dbo.DATA_PUBLISH_IMAGE
            JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.STAFF stf
                ON stf.STF_ID_LOCAL = DPI_OBJ_ID_01
            JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.SCHOOL skl
                ON skl.SKL_SCHOOL_ID = DPI_OBJ_ID_02
        WHERE DPI_TYPE = 'EdFi'
              AND DPI_ENTITY_TYPE = 'StaffSectionAssociation'
              AND DPI_ZONE = @Zone
              AND DPI_YEAR = @Year
              AND DPI_SRC_STATUS = 'Uploaded')
    SELECT cteDPI.SchoolId,
           cteDPI.SchoolName,
           cteDPI.StaffId,
           cteDPI.StaffName,
           cteDPI.MST_OID,
		   cteDPI.MTC_OID,
           cteDPI.SchoolYear,
           cteDPI.SessionName,
           cteDPI.LocalCourseCode,
           cteDPI.SectionNumber,
		   LOWER(REPLACE(CONVERT(CHAR(36),cteDPI.StaffSectionAssociationId),'-','')) StaffSectionAssociationId
    FROM cteDPI
        LEFT JOIN cteMTC
            ON cteMTC.StaffId = cteDPI.StaffId
               AND cteMTC.SchoolId = cteDPI.SchoolId
               AND cteMTC.SchoolYear = cteDPI.SchoolYear
               AND cteMTC.SessionName = cteDPI.SessionName
               AND cteMTC.LocalCourseCode = cteDPI.LocalCourseCode
               AND cteMTC.SectionNumber = cteDPI.SectionNumber
    WHERE cteMTC.MTC_OID IS NULL;


END;
GO
