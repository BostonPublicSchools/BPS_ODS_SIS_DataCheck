USE [BPS_ODS_SIS_DataCheck]
GO
/****** Object:  StoredProcedure [dbo].[CheckODSSISStudentRace]    Script Date: 8/14/2020 5:36:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------------------------------------------------------------------------------
-- Author:		Ragha
-- Create date: 2020-06-19
-- Description:	SIS vs ODS Compare Student Race 
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[CheckODSSISStudentRace]
AS
BEGIN
    SET NOCOUNT ON;


SELECT STD_ID_LOCAL COLLATE  SQL_Latin1_General_CP1_CI_AS  AS STD_ID_LOCAL
    --, RAC_RACE_CODE
    , RCD_FIELDD_001 COLLATE  SQL_Latin1_General_CP1_CI_AS AS AspenRace
    --, RCD_CODE_EDFI [Ed-Fi 3 Code]
FROM [BPSDATA-03].ExtractAspen.dbo.PERSON
JOIN [BPSDATA-03].ExtractAspen.dbo.STUDENT
    ON PSN_OID = STD_PSN_OID
JOIN [BPSDATA-03].ExtractAspen.dbo.PERSON_RACE
    ON PSN_OID = RAC_PSN_OID
JOIN [BPSDATA-03].ExtractAspen.dbo.DATA_FIELD_CONFIG
    ON FDD_FLD_OID = 'racRaceCode'
JOIN [BPSDATA-03].ExtractAspen.dbo.REF_TABLE
    ON RTB_OID = FDD_RTB_OID
JOIN [BPSDATA-03].ExtractAspen.dbo.REF_CODE
    ON RTB_OID = RCD_RTB_OID
        AND RCD_CODE = RAC_RACE_CODE
WHERE 
--PSN_RACE_VIEW IN ('African American'
--,'AMIND'
--,'ASIAN'
--,'Asian'
--,'Asian, Black'
--,'Asian, Black, Native American'
--,'Asian, Black, Native American, Pacific Islander'
--,'Asian, Black, Native American, Pacific Islander, White'
--,'Asian, Black, Native American, White'
--,'Asian, Black, Other, White'
--,'Asian, Black, Pacific Islander'
--,'Asian, Black, Pacific Islander, White'
--,'Asian, Black, White'
--,'Asian, Mixed'
--,'Asian, Mixed, White'
--,'Asian, Native American'
--,'Asian, Native American, Pacific Islander'
--,'Asian, Native American, Pacific Islander, White'
--,'Asian, Native American, White'
--,'Asian, Other'
--,'Asian, Other, White'
--,'Asian, Pacific Islander'
--,'Asian, Pacific Islander, White'
--,'Asian, White'
--,'Asian,Native American'
--,'Black'
--,'Black, Native American'
--,'Black, Native American, Pacific Islander'
--,'Black, Native American, Pacific Islander, White'
--,'Black, Native American, White'
--,'Black, Other'
--,'Black, Pacific Islander'
--,'Black, Pacific Islander, White'
--,'Black, White'
--,'Caucasian'
--,'HISPA'
--,'Mixed or Other, White'
--,'Nat. Amer.'
--,'Native American'
--,'Native American, Pacific Islander'
--,'Native American, Pacific Islander, White'
--,'Native American, White'
--,'Native American,Asian'
--,'NSPEC'
--,'Other'
--,'Other, White'
--,'Pacific Islander'
--,'Pacific Islander, White'
--,'race'
--,'RACES'
--,'White')
------------------------------------------------------------------------------------------
--('Asian', 'Black', 'Pacific Islander', 'White','Black', 'Black, Native American'
--                       , 'Black, White','Native American','Black, White','Asian, White','Native American, White'
--					   ,'Black, Native American, White','Asian, Black, Native American, Pacific Islander, White'
--					   ,'Asian, Black','Asian, Pacific Islander, White','Pacific Islander, White','Asian, Black, Pacific Islander'
--					   ,'Black, Pacific Islander','Black, Native American, Pacific Islander, White')
--AND 
STD_ENROLLMENT_STATUS in ('Active','Inactive')
EXCEPT
SELECT DISTINCT StudentUniqueId,
rt.CodeValue AS ODSRace
FROM EdFi_BPS_Production_Ods.edfi.Student s
INNER JOIN EdFi_BPS_Production_Ods.edfi.StudentRace sr ON s.StudentUSI = sr.StudentUSI
INNER JOIN EdFi_BPS_Production_Ods.edfi.RaceType rt ON rt.RaceTypeId = sr.RaceTypeId
INNER JOIN EdFi_BPS_Production_Ods.EDFI.StudentSchoolAssociation ssc ON s.StudentUSI = ssc.StudentUSI
WHERE ssc.ExitWithdrawDate IS NULL
AND s.StudentUniqueId NOT IN ('258973','380941','412394','412394','412394','425168','425739','425741','426308','426321','435322')

UNION

SELECT DISTINCT StudentUniqueId,
rt.CodeValue AS ODSRace
FROM EdFi_BPS_Production_Ods.edfi.Student s
INNER JOIN EdFi_BPS_Production_Ods.edfi.StudentRace sr ON s.StudentUSI = sr.StudentUSI
INNER JOIN EdFi_BPS_Production_Ods.edfi.RaceType rt ON rt.RaceTypeId = sr.RaceTypeId
INNER JOIN EdFi_BPS_Production_Ods.EDFI.StudentSchoolAssociation ssc ON s.StudentUSI = ssc.StudentUSI
WHERE ssc.ExitWithdrawDate IS NULL
AND s.StudentUniqueId NOT IN ('258973','380941','412394','412394','412394','425168','425739','425741','426308','426321','435322')
EXCEPT
SELECT STD_ID_LOCAL COLLATE  SQL_Latin1_General_CP1_CI_AS  AS STD_ID_LOCAL
    --, RAC_RACE_CODE
    , RCD_FIELDD_001 COLLATE  SQL_Latin1_General_CP1_CI_AS AS AspenRace
    --, RCD_CODE_EDFI [Ed-Fi 3 Code]
FROM [BPSDATA-03].ExtractAspen.dbo.PERSON
JOIN [BPSDATA-03].ExtractAspen.dbo.STUDENT
    ON PSN_OID = STD_PSN_OID
JOIN [BPSDATA-03].ExtractAspen.dbo.PERSON_RACE
    ON PSN_OID = RAC_PSN_OID
JOIN [BPSDATA-03].ExtractAspen.dbo.DATA_FIELD_CONFIG
    ON FDD_FLD_OID = 'racRaceCode'
JOIN [BPSDATA-03].ExtractAspen.dbo.REF_TABLE
    ON RTB_OID = FDD_RTB_OID
JOIN [BPSDATA-03].ExtractAspen.dbo.REF_CODE
    ON RTB_OID = RCD_RTB_OID
        AND RCD_CODE = RAC_RACE_CODE
WHERE 
--PSN_RACE_VIEW IN ('African American'
--,'AMIND'
--,'ASIAN'
--,'Asian'
--,'Asian, Black'
--,'Asian, Black, Native American'
--,'Asian, Black, Native American, Pacific Islander'
--,'Asian, Black, Native American, Pacific Islander, White'
--,'Asian, Black, Native American, White'
--,'Asian, Black, Other, White'
--,'Asian, Black, Pacific Islander'
--,'Asian, Black, Pacific Islander, White'
--,'Asian, Black, White'
--,'Asian, Mixed'
--,'Asian, Mixed, White'
--,'Asian, Native American'
--,'Asian, Native American, Pacific Islander'
--,'Asian, Native American, Pacific Islander, White'
--,'Asian, Native American, White'
--,'Asian, Other'
--,'Asian, Other, White'
--,'Asian, Pacific Islander'
--,'Asian, Pacific Islander, White'
--,'Asian, White'
--,'Asian,Native American'
--,'Black'
--,'Black, Native American'
--,'Black, Native American, Pacific Islander'
--,'Black, Native American, Pacific Islander, White'
--,'Black, Native American, White'
--,'Black, Other'
--,'Black, Pacific Islander'
--,'Black, Pacific Islander, White'
--,'Black, White'
--,'Caucasian'
--,'HISPA'
--,'Mixed or Other, White'
--,'Nat. Amer.'
--,'Native American'
--,'Native American, Pacific Islander'
--,'Native American, Pacific Islander, White'
--,'Native American, White'
--,'Native American,Asian'
--,'NSPEC'
--,'Other'
--,'Other, White'
--,'Pacific Islander'
--,'Pacific Islander, White'
--,'race'
--,'RACES'
--,'White'
--)
--('Asian', 'Black', 'Pacific Islander', 'White','Black', 'Black, Native American'
--                       , 'Black, White','Native American','Black, White','Asian, White','Native American, White'
--					   ,'Black, Native American, White','Asian, Black, Native American, Pacific Islander, White'
--					   ,'Asian, Black','Asian, Pacific Islander, White','Pacific Islander, White','Asian, Black, Pacific Islander'
--					   ,'Black, Pacific Islander','Black, Native American, Pacific Islander, White')
--AND 
STD_ENROLLMENT_STATUS IN('Active','Inactive','Graduate','Registered')

END;