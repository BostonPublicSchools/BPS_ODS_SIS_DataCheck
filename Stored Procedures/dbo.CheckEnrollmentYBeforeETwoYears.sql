SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Marco Martinez
-- Create date:	09/19/2023
-- Description:	Checks multiple open primary enrollments due Y before E records inside the las two school years. 
-- =============================================
CREATE PROCEDURE [dbo].[CheckEnrollmentYBeforeETwoYears]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    WITH ENRY AS 
	(
	SELECT 
		ENR_STD_OID,		
		ENR_ENROLLMENT_TYPE,
		CONVERT(VARCHAR(10),ENR_ENROLLMENT_DATE,120) ENR_ENROLLMENT_DATE,
		ENR_TIMESTAMP,
		ENR_FIELDA_007 ENR_GRADE,
		ENR_SKL_OID,
		ENR_ENROLLMENT_REASON_CODE,	
		LEAD(ENR_ENROLLMENT_TYPE) OVER (PARTITION BY ENR_STD_OID ORDER BY ENR_ENROLLMENT_DATE DESC, ENR_TIMESTAMP DESC) PREVENR_ENROLLMENT_TYPE
	FROM
		ASPENDBCLOUD.aspen_ma_boston.dbo.STUDENT_ENROLLMENT 
	WHERE
		ENR_STD_OID IN (SELECT ENR_STD_OID FROM ASPENDBCLOUD.aspen_ma_boston.dbo.STUDENT_ENROLLMENT WHERE ENR_ENROLLMENT_TYPE = 'Y' GROUP BY ENR_STD_OID)
		AND COALESCE(ENR_FIELDA_028,0) = 0
		AND (ENR_ENROLLMENT_STATUS_CODE = 'Active' OR ENR_ENROLLMENT_STATUS_CODE IS NULL)
	)


	SELECT 	
		STD.STD_ID_LOCAL [Student No],
		STD.STD_NAME_VIEW [Student Name],
		SKL_SCHOOL_ID [SchoolID],
		SKL_SCHOOL_NAME [School],
		STD.STD_ENROLLMENT_STATUS [Type],
		STD.STD_GRADE_LEVEL [Std Grade],
		ENRY.ENR_GRADE AS [Y Grade],
		ENRY.ENR_ENROLLMENT_REASON_CODE [Y Reason],	
		ENRY.ENR_ENROLLMENT_DATE [Y Enrollment Date] 
  
	FROM ENRY
	INNER JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.STUDENT STD 
		ON STD.STD_OID = ENRY.ENR_STD_OID
	INNER JOIN ASPENDBCLOUD.aspen_ma_boston.dbo.SCHOOL WITH (NOLOCK) 
		ON ENR_SKL_OID = SKL_OID AND SKL_SCHOOL_TYPE_CODE != 'Placeholder'
	INNER JOIN 
	(
		SELECT CTX_OID, CTX_CONTEXT_ID, LEAD(CTX_START_DATE) OVER(ORDER BY CTX_SCHOOL_YEAR DESC) PREV_CONTEXT_START_DATE 
		FROM ASPENDBCLOUD.aspen_ma_boston.dbo.DISTRICT_SCHOOL_YEAR_CONTEXT WITH (NOLOCK)
	) SKX  
		ON SKL_CTX_OID_CURRENT = SKX.CTX_OID

	WHERE 1 =1
		AND ENRY.ENR_ENROLLMENT_DATE >= SKX.PREV_CONTEXT_START_DATE
		AND ENRY.ENR_ENROLLMENT_TYPE = 'Y'
		AND ENRY.PREVENR_ENROLLMENT_TYPE = 'W'		
		AND STD.STD_ENROLLMENT_STATUS = 'Active'
	ORDER BY ENRY.ENR_ENROLLMENT_DATE DESC

END;
GO
