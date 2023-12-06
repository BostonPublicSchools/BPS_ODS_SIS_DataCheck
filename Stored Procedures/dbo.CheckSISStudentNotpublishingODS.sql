SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-----------------------------------------------------------------------
--Marco  11/15/2023  Data Checker for Student records not publishing to the ODS
-----------------------------------------------------------------------
CREATE PROCEDURE [dbo].[CheckSISStudentNotpublishingODS]
AS
BEGIN

    DECLARE @Year AS INT;
    DECLARE @Zone AS VARCHAR(10);

    SELECT @Year = CTX_SCHOOL_YEAR,
           @Zone = 'ODS-' + CAST(CTX_SCHOOL_YEAR AS VARCHAR)
    FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.DISTRICT_SCHOOL_YEAR_CONTEXT
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.ORGANIZATION
            ON CTX_OID = ORG_CTX_OID_CURRENT
               AND ORG_ORG_OID_PARENT IS NULL;


    SELECT dpi.DPI_OBJ_ID_01 'ID1',
           dpi.DPI_ENTITY_TYPE,
           dpi.DPI_SRC_STATUS 'SrcStatus',
           dpi.DPI_DST_STATUS 'DstStatus',
           CASE
               WHEN CHARINDEX('method=DELETE,', dpi.DPI_DST_MESSAGE) > 0 THEN
                   SUBSTRING(
                                dpi.DPI_DST_MESSAGE,
                                0,
                                CHARINDEX('method=DELETE', dpi.DPI_DST_MESSAGE) + LEN('method=DELETE')
                            )
               WHEN CHARINDEX('message": ', dpi.DPI_DST_MESSAGE) > 0 THEN
                   SUBSTRING(
                                dpi.DPI_DST_MESSAGE,
                                CHARINDEX('message": "', dpi.DPI_DST_MESSAGE) + LEN('message": "'),
                                LEN(dpi.DPI_DST_MESSAGE) - CHARINDEX('message": "', dpi.DPI_DST_MESSAGE)
                                - LEN('message": "') - LEN('" }') + 1
                            )
               ELSE
                   dpi.DPI_DST_MESSAGE
           END 'DstMessageError',
           std.STD_ENROLLMENT_STATUS,
           skl.SKL_SCHOOL_ID,
           skl.SKL_SCHOOL_NAME,
           FORMAT(
                     DATEADD(
                                SECOND,
                                (dpi.DPI_CREATE_TIME / 1000) - DATEDIFF(SECOND, GETDATE(), GETUTCDATE()),
                                '1970-01-01 00:00:00'
                            ),
                     'yyyy-MM-dd HH:mm:ss'
                 ) + '.' + RIGHT(dpi.DPI_CREATE_TIME, 3) 'CreateTime',
           FORMAT(
                     DATEADD(
                                SECOND,
                                (dpi.DPI_MODIFY_TIME / 1000) - DATEDIFF(SECOND, GETDATE(), GETUTCDATE()),
                                '1970-01-01 00:00:00'
                            ),
                     'yyyy-MM-dd HH:mm:ss'
                 ) + '.' + RIGHT(dpi.DPI_MODIFY_TIME, 3) 'ModifyTime',
           FORMAT(
                     DATEADD(
                                SECOND,
                                (dpi.DPI_DELIVER_TIME / 1000) - DATEDIFF(SECOND, GETDATE(), GETUTCDATE()),
                                '1970-01-01 00:00:00'
                            ),
                     'yyyy-MM-dd HH:mm:ss'
                 ) + '.' + RIGHT(dpi.DPI_DELIVER_TIME, 3) 'DeliverTime',
           dpi.DPI_OID 'DPI_OID',
           dpi.DPI_ZONE 'Zone',
           dpi.DPI_YEAR 'Year',
           dpi.DPI_OBJ_OID_01
    FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.DATA_PUBLISH_IMAGE dpi
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.STUDENT std
            ON std.STD_OID = dpi.DPI_OBJ_OID_01
        JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHOOL skl
            ON skl.SKL_OID = std.STD_SKL_OID
        JOIN
        (
            SELECT dpiSEOA.DPI_OID,
                   std.STD_OID,
                   std.STD_ID_LOCAL,
                   skl.SKL_SCHOOL_ID,
                   dpiSEOA.DPI_CREATE_TIME
            FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.DATA_PUBLISH_IMAGE dpiSEOA
                JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.STUDENT std
                    ON std.STD_OID = dpiSEOA.DPI_OBJ_OID_01
                JOIN [ASPENDBCLOUD].[aspen_ma_boston].dbo.SCHOOL skl
                    ON skl.SKL_OID = std.STD_SKL_OID
            WHERE dpiSEOA.DPI_TYPE = 'EdFi'
                  AND dpiSEOA.DPI_ENTITY_TYPE = 'StudentEducationOrganizationAssociation'
                  -- find StudentEducationOrganizationAssociation with API access violation errors (occurs when enrollment is missing)
                  AND dpiSEOA.DPI_SRC_STATUS = 'Ready for Upload' --not in ('Deleted', 'Error')
                  AND dpiSEOA.DPI_DST_STATUS = 'Error: 403'
                  AND EXISTS
            (
                -- find students with enrollment that has been uploaded (or could be uploaded)
                SELECT DISTINCT
                       dpiSSA.DPI_OBJ_OID_01
                FROM [ASPENDBCLOUD].[aspen_ma_boston].dbo.DATA_PUBLISH_IMAGE dpiSSA
                WHERE dpiSSA.DPI_TYPE = 'EdFi'
                      AND dpiSSA.DPI_ENTITY_TYPE = 'StudentSchoolAssociation'
                      AND dpiSSA.DPI_SRC_STATUS NOT IN ( 'Deleted', 'Error' )
                      AND dpiSEOA.DPI_OBJ_OID_01 = dpiSSA.DPI_OBJ_OID_01
            )
        ) x
            ON x.DPI_OID = dpi.DPI_OID
    WHERE dpi.DPI_YEAR = @Year
          AND dpi.DPI_ZONE = @Zone
          AND
          (
              (
                  COALESCE(TRY_CAST(x.SKL_SCHOOL_ID AS INT), -1)
          BETWEEN 1000 AND 4780
                  -- limit to BPS records created BEFORE today (adjusted for UTC)
                  -- because there is a pattern of errors that often resolve on the following school day
                  -- after Chris Costigan assigns a BPS email address to the student
                  AND DATEADD(DAY, 0, CONVERT(DATE, GETDATE())) > FORMAT(
                                                                            DATEADD(
                                                                                       SECOND,
                                                                                       (x.DPI_CREATE_TIME / 1000)
                                                                                       - DATEDIFF(
                                                                                                     SECOND,
                                                                                                     GETDATE(),
                                                                                                     GETUTCDATE()
                                                                                                 ),
                                                                                       '1970-01-01 00:00:00'
                                                                                   ),
                                                                            'yyyy-MM-dd HH:mm:ss'
                                                                        ) + '.' + RIGHT(x.DPI_CREATE_TIME, 3)
              )
              OR COALESCE(TRY_CAST(x.SKL_SCHOOL_ID AS INT), -1) NOT
          BETWEEN 1000 AND 478
          )
    ORDER BY SrcStatus DESC,
             ID1;

END;
GO
