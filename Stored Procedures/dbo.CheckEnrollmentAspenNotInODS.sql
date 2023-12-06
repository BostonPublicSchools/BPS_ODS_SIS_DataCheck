SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
    =============================================
    Author:		Tim Reed
    Create date:	11/4/2022
    Description:	DataChecker comparison of enrollment in Aspen vs the ODS
    =============================================
*/
create procedure [dbo].[CheckEnrollmentAspenNotInODS]
as
begin
   --SET NOCOUNT ON added to prevent extra result sets from
   --interfering with SELECT statements.
  set nocount on
;

  /* :: remove old temp tables :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
  if object_id('tempdb..#ods_enrollment') is not null
  begin
    drop table #ods_enrollment
    ;
  end
  ;

  if object_id('tempdb..#aspen_enrollment') is not null
  begin
    drop table #aspen_enrollment
    ;
  end
  ;


  /* :: create temp tables :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
if object_id('tempdb..#ods_enrollment') is null
begin
  create table #ods_enrollment
    (
      SchoolId   INT
    , SchoolName VARCHAR(250)
    , StudentID  VARCHAR(20)
    --, sklCount   SMALLINT
    )
  ;
end
;

if object_id('tempdb..#aspen_enrollment') is null
begin
  create table #aspen_enrollment
    (
      SchoolId   INT
    , SchoolName VARCHAR(250)
    , StudentID  VARCHAR(20)
    --, sklCount   SMALLINT
    )
  ;
end
;


  /* :: gather ODS enrollment ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
  insert into #ods_enrollment (SchoolId, SchoolName, StudentID)--, sklCount)
  select eo.EducationOrganizationId as 'SchoolId'
       , eo.ShortNameOfInstitution as 'SchoolName' -- Only Short Name Matches with ASPEN Name
       , s.StudentUniqueId as 'StudentID'
  from EDFISQL01.s3v5ys_EdFi_BPS_ProdYS_Ods_2024.edfi.StudentSchoolAssociation as ssa
    join EDFISQL01.s3v5ys_EdFi_BPS_ProdYS_Ods_2024.edfi.Student s
      on s.StudentUSI = ssa.StudentUSI
    join EDFISQL01.s3v5ys_EdFi_BPS_ProdYS_Ods_2024.edfi.EducationOrganization as eo
      on ssa.SchoolId = eo.EducationOrganizationId
    -- limit to BPS schools with current year EdOrgNetwork associations
    join EDFISQL01.s3v5ys_EdFi_BPS_ProdYS_Ods_2024.edfi.EducationOrganizationNetworkAssociation eona
      on eona.MemberEducationOrganizationId = eo.EducationOrganizationId
         and eona.BeginDate >= (select top 1 StartDate from EDFISQL01.BPS_ODS_SIS_DataCheck.dbo._Config_Aspen_Filters)
  where
    ssa.SchoolYear = (select top 1 SchoolYear from EDFISQL01.BPS_ODS_SIS_DataCheck.dbo._Config_Aspen_Filters)
    and ssa.ExitWithdrawDate is null
    and datediff(hour, convert(DATETIME, s.BirthDate), getdate()) / 8766 <= 21
    -- For Aspen, this is functionally redundant with null ExitWithdrawDate, but it clarifies
    and ssa.PrimarySchool = 1
  ;

  /* :: gather Aspen enrollment ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
  insert into #aspen_enrollment (SchoolId, SchoolName, StudentID)--, sklCount)
  select skl.SKL_SCHOOL_ID collate database_default as 'SchoolId'
       , skl.SKL_SCHOOL_NAME collate database_default as 'SchoolName'
       , std.STD_ID_LOCAL collate database_default as 'StudentID'
  from ASPENDBCLOUD.aspen_ma_boston.dbo.STUDENT std
    -- for DOB
    join ASPENDBCLOUD.aspen_ma_boston.dbo.PERSON psn
      on psn.PSN_OID = std.STD_PSN_OID
    join ASPENDBCLOUD.aspen_ma_boston.dbo.SCHOOL as skl
      on skl.SKL_OID = std.STD_SKL_OID
         and coalesce(try_cast(skl.SKL_SCHOOL_ID as INT), -1) > 0
  where
    -- limit to only schools eligible for the ODS (have numeric School Id's)
    std.STD_ENROLLMENT_STATUS = 'Active'
    and datediff(hour, convert(DATETIME, psn.PSN_DOB), getdate()) / 8766 <= 21 -- LIMIT BY AGE
  ;

/* :: student enrollment in Aspen not in ODS :::::::::::::::::::::::::::::::::::::::::::::::::::: */
  select x.StudentID
       , x.SchoolId
       , #aspen_enrollment.SchoolName
       , count(1) over (partition by x.SchoolId) as 'schoolStudentCount'
       , 'Aspen' 'dataSource'
       , x.StudentID + '-' + convert(VARCHAR(10), x.SchoolId) 'Aspen ID1-ID2'
  from (
    select StudentID
         , SchoolId
    from #aspen_enrollment a
    where
      exists (select distinct SchoolId from #ods_enrollment where a.SchoolId = SchoolId)
    except
    select StudentID
         , SchoolId
    from #ods_enrollment
  ) as x
  left join #aspen_enrollment on #aspen_enrollment.StudentID = x.StudentID
    and #aspen_enrollment.SchoolId = x.SchoolId
  order by
    schoolStudentCount desc
  , SchoolId
  , StudentID
  ;

  /* :: remove temp tables :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
  if object_id('tempdb..#ods_enrollment') is not null
  begin
    drop table #ods_enrollment
    ;
  end
  ;

  if object_id('tempdb..#aspen_enrollment') is not null
  begin
    drop table #aspen_enrollment
    ;
  end
  ;

end
;
GO
