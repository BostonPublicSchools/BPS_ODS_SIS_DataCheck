SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-------------------------------------------------------------------------
----Ragha  09/28/2022   IEPUniqueIDNotInSync
-------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[IEPUniqueIDNotInSync]
AS
BEGIN
SELECT stu.iepUniqueId,
       stu.studentUniqueId,
       stu.iepBeginDate,
       stu.iepEndDate,
       stu.ProgramEdOrgId,
       stu.educationOrganizationId,
       CASE
           WHEN stu.dateSigned IS NULL THEN
               stu.iepBeginDate
           WHEN stu.dateSigned > stu.iepBeginDate THEN
               stu.dateSigned
           WHEN stu.iepBeginDate > stu.dateSigned THEN
               stu.iepBeginDate
           WHEN stu.dateSigned = stu.iepBeginDate THEN
               stu.dateSigned
       END AS dateSigned
FROM dbo.StudentIEPRefv1 stu
WHERE LoadDate =
(
    SELECT MAX(LoadDate)
    FROM dbo.StudentIEPRefv1 ref
    WHERE stu.studentUniqueId = ref.studentUniqueId
          AND stu.iepUniqueId = ref.iepUniqueId
)
EXCEPT
SELECT SourceSystemId,
       stu.StudentUniqueId,
       spe.IEPBeginDate,
       spe.IEPEndDate,
       exs.ProgramEducationOrganizationId,
       exs.EducationOrganizationId,
       spe.BeginDate
FROM s3v5ys_EdFi_BPS_ProdYS_Ods_2023.mybps.StudentSpecialEducationProgramAssociationExtension exs
    JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.Student stu
        ON stu.StudentUSI = exs.StudentUSI
    JOIN s3v5ys_EdFi_BPS_ProdYS_Ods_2023.edfi.StudentSpecialEducationProgramAssociation spe
        ON spe.BeginDate = exs.BeginDate
           AND spe.EducationOrganizationId = exs.EducationOrganizationId
           AND spe.ProgramEducationOrganizationId = exs.ProgramEducationOrganizationId
           AND spe.ProgramName = exs.ProgramName
           AND spe.ProgramTypeDescriptorId = exs.ProgramTypeDescriptorId
           AND spe.StudentUSI = exs.StudentUSI
WHERE exs.ProgramName <> '504 Plan';
END;
GO
