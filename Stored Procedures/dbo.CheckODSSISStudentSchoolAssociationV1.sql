SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Create date: 2020-02-14
-- Modified: 2022-10-17
-- Description: Compare Student School Association Between ODS and SIS
-- =============================================
CREATE procedure [dbo].[CheckODSSISStudentSchoolAssociationV1]
as
begin
  -- SET NOCOUNT ON added to prevent extra result sets from
  -- interfering with SELECT statements.
set nocount on
;
declare @Year VARCHAR(30)
;
declare @startDate DATE
;
select @Year = SchoolYear
     , @startDate = startDate
from (
  select SchoolYear
       , dateadd(year, -1, try_cast(cast(SchoolYear as VARCHAR(4)) + '-07-01' as DATE)) as 'startDate'
  from edfi_SchoolYearType
  where CurrentSchoolYear = 1
) y
;

select *
from (
  select ods.SchoolId
       , ods.SchoolName
       , ods.TotalStudents as 'ODS EnrollCount'
       , aspen.TotalStudents as 'Aspen EnrollCount'
       -- determine which system has larger enrollment count
       , case
           when ods.TotalStudents - aspen.TotalStudents > 0 then
             'ODS'
           else
             'Aspen'
         end 'System'
       -- display the difference between systems
       , case
           when ods.TotalStudents - aspen.TotalStudents > 0 then
             ods.TotalStudents - aspen.TotalStudents
           else
             aspen.TotalStudents - ods.TotalStudents
         end 'Over by'
  from
  /* get current-year ODS enrollment from BPS schools with current-year network associations */
  (
    select eo.EducationOrganizationId as 'SchoolId'
         , eo.ShortNameOfInstitution as 'SchoolName' -- Only Short Name Matches with ASPEN Name
         , TotalStudents = (
             select count(StudentUSI)
             from EdFi_StudentSchoolAssociation
             where
               SchoolId = eo.EducationOrganizationId
               and SchoolYear = @Year
               and ExitWithdrawDate is null
               and CreateDate < format(getdate(),'yyyy-MM-dd')
               and PrimarySchool = 1 -- For Aspen, this is functionally redundant with null ExitWithdrawDate, but it clarifies
           )
         , 'ODS' as 'RecordsFoundIn'
    from EdFi_EducationOrganization as eo
      -- limit to BPS schools with current year EdOrgNetwork associations
      join edfi_EducationOrganizationNetworkAssociation eona
        on eona.MemberEducationOrganizationId = eo.EducationOrganizationId
           and eona.BeginDate >= @startDate
  ) as ods

    /* get enrollment counts for Aspen schools that are eligible for publishing to the ODS (have numeric school ids) */
    left join (
      select skl.SKL_SCHOOL_ID as 'SchoolId'
           , skl.SKL_SCHOOL_NAME as 'SchoolName'
           , TotalStudents = (
               select count(std.STD_OID)
               from [BPSDATA-03].ExtractAspen.dbo.STUDENT as std
               where
                 std.STD_ENROLLMENT_STATUS = 'Active'
                 and std.STD_SKL_OID = skl.SKL_OID
             )
           , 'Aspen' as RecordsFoundIn
      from [BPSDATA-03].ExtractAspen.dbo.SCHOOL as skl
      where
        -- limit to only schools eligible for the ODS (have numeric School Id's)
        coalesce(try_cast(skl.SKL_SCHOOL_ID as INT), -1) > 0 -- between 1000 and 4700
    ) as aspen
      on ods.SchoolId = aspen.SchoolId
  where ods.TotalStudents <> aspen.TotalStudents
) x
order by
  x.System desc
, x.[Over by] desc
, x.SchoolId
;


end
;
GO
