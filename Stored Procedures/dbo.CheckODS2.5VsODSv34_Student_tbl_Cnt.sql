SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

------------------------------------------------------------------------------
-- Author:Ragha
-- Create date: 2020-07-10
-- Description:	Compare counts for Student tables between ODS2.5 Vs 3
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[CheckODS2.5VsODSv34_Student_tbl_Cnt]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SUM(val) AS Std_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUniqueId) AS val
        FROM EdFi_BPS_Production_Ods.edfi.Student
        UNION ALL
        SELECT -COUNT(StudentUniqueId) AS v34_Sudent_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.Student
    ) sub;

    SELECT SUM(val) AS Std_AcademicRcd_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentAcademicRecord
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentAcademicRecord
    ) sub;

    SELECT SUM(val) AS Std_AcademicRcdHnr_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentAcademicRecordAcademicHonor
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentAcademicRecordAcademicHonor
    ) sub;

    SELECT SUM(val) AS Std_AcademicRcdClsRnk_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentAcademicRecordClassRanking
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentAcademicRecordClassRanking
    ) sub;

    SELECT SUM(val) AS Std_AcademicRcdRecog_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentAcademicRecordRecognition
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentAcademicRecordRecognition
    ) sub;

    SELECT SUM(val) AS Std_AcademicRcdRptCd_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentAcademicRecordReportCard
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentAcademicRecordReportCard
    ) sub;

    SELECT SUM(val) AS Std_Assesment_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentAssessment
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentAssessment
    ) sub;

    SELECT SUM(val) AS Std_Assesmentitem_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentAssessmentItem
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentAssessmentItem
    ) sub;

    SELECT SUM(val) AS Std_AssesmentPerf_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentAssessmentPerformanceLevel
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentAssessmentPerformanceLevel
    ) sub;

    SELECT SUM(val) AS Std_AssesmentScrResult_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentAssessmentScoreResult
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentAssessmentScoreResult
    ) sub;



    SELECT SUM(val) AS Std_ObjAssesment_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentAssessmentStudentObjectiveAssessment
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentAssessmentStudentObjectiveAssessment
    ) sub;


    SELECT SUM(val) AS Std_ObjAssesmentPerfResults_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentAssessmentStudentObjectiveAssessmentPerformanceLevel
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentAssessmentStudentObjectiveAssessmentPerformanceLevel
    ) sub;

    SELECT SUM(val) AS Std_AssesmentStdObjAssessmentScrResult_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentAssessmentStudentObjectiveAssessmentScoreResult
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentAssessmentStudentObjectiveAssessmentScoreResult
    ) sub;


    SELECT SUM(val) AS Std_ChrDesc_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentCharacteristicDescriptorId) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentCharacteristicDescriptor
        UNION ALL
        SELECT -COUNT(StudentCharacteristicDescriptorId) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentCharacteristicDescriptor
    ) sub;

    SELECT SUM(val) AS Std_ChortAssoc_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentCohortAssociation
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentCohortAssociation
    ) sub;


    SELECT SUM(val) AS Std_ChortAssocSec_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentCohortAssociationSection
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentCohortAssociationSection
    ) sub;


    SELECT SUM(val) AS Std_CTEProgAssoc_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentCTEProgramAssociation
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentCTEProgramAssociation
    ) sub;


    SELECT SUM(val) AS Std_CTEProgAssocTEProg_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentCTEProgramAssociationCTEProgram
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentCTEProgramAssociationCTEProgram
    ) sub;


    SELECT SUM(val) AS Std_DiscIncAssoc_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentDisciplineIncidentAssociation
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentDisciplineIncidentAssociation
    ) sub;


    SELECT SUM(val) AS Std_DiscIncAssocBehavior_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentDisciplineIncidentAssociationBehavior
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentDisciplineIncidentAssociationBehavior
    ) sub;


    SELECT SUM(val) AS Std_EduOrgAssoc_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentEducationOrganizationAssociation
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentEducationOrganizationAssociation
    ) sub;



    SELECT SUM(val) AS Std_ProgAssocService_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentProgramAssociationService
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentProgramAssociationService
    ) sub;

    SELECT SUM(val) AS Std_SchAssoc_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentSchoolAssociation
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentSchoolAssociation
    ) sub;


    SELECT SUM(val) AS Std_SchAssocEduPlan_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentSchoolAssociationEducationPlan
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentSchoolAssociationEducationPlan
    ) sub;


    SELECT SUM(val) AS Std_SchAttendanceEvent_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentSchoolAttendanceEvent
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentSchoolAttendanceEvent
    ) sub;


    SELECT SUM(val) AS Std_SpeclEduPgmAssocSerProv_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentSpecialEducationProgramAssociationServiceProvider
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentSpecialEducationProgramAssociationServiceProvider
    ) sub;


    SELECT SUM(val) AS Std_Visa_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentVisa
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentVisa
    ) sub;


    SELECT SUM(val) AS Std_ReportCardStdCompetencyObj_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.ReportCardStudentCompetencyObjective
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.ReportCardStudentCompetencyObjective
    ) sub;


    SELECT SUM(val) AS Std_ReportCardStdLearningObj_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.ReportCardStudentLearningObjective
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.ReportCardStudentLearningObjective
    ) sub;


    SELECT SUM(val) AS Std_CompObj_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentCompetencyObjective
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentCompetencyObjective
    ) sub;


    SELECT SUM(val) AS Std_GradebookEntry_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentGradebookEntry
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentGradebookEntry
    ) sub;


    SELECT SUM(val) AS Std_IdentificationDocument_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentIdentificationDocument
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentIdentificationDocument
    ) sub;


    SELECT SUM(val) AS Std_IdentifSysDescriptor_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentIdentificationSystemDescriptorId) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentIdentificationSystemDescriptor
        UNION ALL
        SELECT -COUNT(StudentIdentificationSystemDescriptorId) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentIdentificationSystemDescriptor
    ) sub;


    SELECT SUM(val) AS Std_InterventionAssoc_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentInterventionAssociation
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentInterventionAssociation
    ) sub;


    SELECT SUM(val) AS Std_InterventionAssocInterventionEffectiveness_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentInterventionAssociationInterventionEffectiveness
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentInterventionAssociationInterventionEffectiveness
    ) sub;

    SELECT SUM(val) AS Std_InterventionAttendanceEvent_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentInterventionAttendanceEvent
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentInterventionAttendanceEvent
    ) sub;


    SELECT SUM(val) AS Std_LearningObjective_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentLearningObjective
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentLearningObjective
    ) sub;


    SELECT SUM(val) AS Std_MigrantEducationProgramAssoc_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentMigrantEducationProgramAssociation
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentMigrantEducationProgramAssociation
    ) sub;


    SELECT SUM(val) AS Std_OtherName_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentOtherName
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentOtherName
    ) sub;

    SELECT SUM(val) AS Std_ParentAssociation_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentParentAssociation
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentParentAssociation
    ) sub;


    SELECT SUM(val) AS Std_ProgramAssoc_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentProgramAssociation
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentProgramAssociation
    ) sub;


    SELECT SUM(val) AS Std_ProgramAttendanceEvent_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentProgramAttendanceEvent
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentProgramAttendanceEvent
    ) sub;


    SELECT SUM(val) AS Std_SectionAssociation_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentSectionAssociation
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentSectionAssociation
    ) sub;


    SELECT SUM(val) AS Std_SectionAttendanceEvent_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentSectionAttendanceEvent
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentSectionAttendanceEvent
    ) sub;


    SELECT SUM(val) AS Std_SpecialEducationProgramAssociation_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentSpecialEducationProgramAssociation
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentSpecialEducationProgramAssociation
    ) sub;


    SELECT SUM(val) AS Std_TitleIPartAProgramAssociation_Cnt_Diff
    FROM
    (
        SELECT COUNT(StudentUSI) AS val
        FROM EdFi_BPS_Production_Ods.edfi.StudentTitleIPartAProgramAssociation
        UNION ALL
        SELECT -COUNT(StudentUSI) AS v34_cnt
        FROM v34_EdFi_BPS_Production_ODS.edfi.StudentTitleIPartAProgramAssociation
    ) sub;
END;
GO
