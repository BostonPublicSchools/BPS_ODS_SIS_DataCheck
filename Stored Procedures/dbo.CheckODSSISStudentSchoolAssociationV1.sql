SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		KRISHNA
-- Create date: 2020-02-14
-- Description:	Compare Student School Association Between ODS and SIS
-- =============================================
CREATE   PROCEDURE [dbo].[CheckODSSISStudentSchoolAssociationV1]
-- Add the parameters for the stored procedure here
--@Year1 VARCHAR(30)
--@Year VARCHAR(30)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @Year VARCHAR(30);
    --Ragha Y 08-10-2020 Updated to 2021 from 2020'
    --SET @Year = '2021';
    SELECT EO.EducationOrganizationId,
           LOWER(EO.ShortNameOfInstitution), -- Only Short Name Matches with ASPEN Name
           ToalStudents =
           (
               SELECT COUNT(StudentUSI)
               FROM Edfi_StudentSchoolAssociation
               WHERE SchoolId = EO.EducationOrganizationId
                     --AND SchoolYear = @Year
                     AND ExitWithdrawDate IS NULL
           ),
		   'ODS' AS RecordsFoundIn
    FROM Edfi_EducationOrganization AS EO
    WHERE EO.EducationOrganizationId IN ( 1010, 1020, 1030, 1040, 1050, 1053, 1070, 1080, 1103, 1120, 1140, 1162, 1171,
                                          1195, 1200, 1210, 1215, 1230, 1253, 1256, 1260, 1265, 1285, 1291, 1292, 1293,
                                          1294, 1311, 1340, 1410, 1420, 1430, 1440, 1441, 1450, 1460, 1470, 1990, 1991,
                                          2010, 2040, 2140, 2190, 2360, 2450, 4022, 4030, 4031, 4033, 4052, 4053, 4055,
                                          4061, 4062, 4070, 4080, 4081, 4082, 4084, 4100, 4113, 4121, 4123, 4130, 4140,
                                          4151, 4160, 4171, 4173, 4178, 4192, 4193, 4200, 4201, 4210, 4230, 4231, 4240,
                                          4241, 4242, 4250, 4260, 4261, 4270, 4272, 4280, 4283, 4285, 4290, 4291, 4311,
                                          4321, 4322, 4323, 4331, 4345, 4350, 4360, 4361, 4370, 4381, 4390, 4391, 4400,
                                          4410, 4440, 4450, 4460, 4530, 4531, 4541, 4543, 4560, 4561, 4570, 4580, 4590,
                                          4592, 4600, 4610, 4620, 4621, 4630, 4640, 4650, 4661, 4670, 4671, 4680, 4691
                                        )
          AND
          (
              SELECT COUNT(StudentUSI)
              FROM Edfi_StudentSchoolAssociation
              WHERE SchoolId = EO.EducationOrganizationId
                    --AND SchoolYear = @Year
                    AND ExitWithdrawDate IS NULL
          ) > 0
    EXCEPT
    SELECT SKL.SKL_SCHOOL_ID,
           LOWER(SKL.SKL_SCHOOL_NAME) COLLATE SQL_Latin1_General_CP1_CI_AS,
           ToalStudents =
           (
               SELECT COUNT(STD.STD_OID)
               FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT AS STD
               WHERE STD.STD_ENROLLMENT_STATUS = 'Active'
                     AND STD.STD_SKL_OID = SKL.SKL_OID
           ),
		   'ODS' AS RecordsFoundIn
    FROM [BPSDATA-03].ExtractAspen.dbo.SCHOOL AS SKL
    WHERE --SKL_FIELDB_038 = '00350000' AND SKL_ORG_OID_2 = '0002'
        SKL.SKL_SCHOOL_ID IN ( '1010', '1020', '1030', '1040', '1050', '1053', '1070', '1080', '1103', '1120', '1140',
                               '1162', '1171', '1195', '1200', '1210', '1215', '1230', '1253', '1256', '1260', '1265',
                               '1285', '1291', '1292', '1293', '1294', '1311', '1340', '1410', '1420', '1430', '1440',
                               '1441', '1450', '1460', '1470', '1990', '1991', '2010', '2040', '2140', '2190', '2360',
                               '2450', '4022', '4030', '4031', '4033', '4052', '4053', '4055', '4061', '4062', '4070',
                               '4080', '4081', '4082', '4084', '4100', '4113', '4121', '4123', '4130', '4140', '4151',
                               '4160', '4171', '4173', '4178', '4192', '4193', '4200', '4201', '4210', '4230', '4231',
                               '4240', '4241', '4242', '4250', '4260', '4261', '4270', '4272', '4280', '4283', '4285',
                               '4290', '4291', '4311', '4321', '4322', '4323', '4331', '4345', '4350', '4360', '4361',
                               '4370', '4381', '4390', '4391', '4400', '4410', '4440', '4450', '4460', '4530', '4531',
                               '4541', '4543', '4560', '4561', '4570', '4580', '4590', '4592', '4600', '4610', '4620',
                               '4621', '4630', '4640', '4650', '4661', '4670', '4671', '4680', '4691'
                             )
        AND
        (
            SELECT COUNT(STD.STD_OID)
            FROM [BPSDATA-03].ExtractAspen.dbo.STUDENT AS STD
            WHERE STD.STD_ENROLLMENT_STATUS = 'Active'
                  AND STD.STD_SKL_OID = SKL.SKL_OID
        ) > 0;
--ORDER BY SKL.SKL_SCHOOL_ID ASC

END;
GO
