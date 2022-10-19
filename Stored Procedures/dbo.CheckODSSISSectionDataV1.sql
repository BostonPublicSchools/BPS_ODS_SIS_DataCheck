SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


---------------------------------------------------------------------------
---- Author:		Ragha
---- Create date: 2020-05-04
---- Description:	Compare Section Data in EDFI not Matching 
----WITH Student and Master Schedule in ASPEN 
-----------------------------------------------------------------------------
CREATE procedure [dbo].[CheckODSSISSectionDataV1]
as
begin

	select CAST(SC.SchoolId as VARCHAR(20)) as SchoolId
			, CO.LocalCourseCode collate database_default as LocalCourseCode
			, SC.SectionIdentifier collate database_default as SectionIdentifier
			, CS.CourseTitle collate database_default as CourseTitle
			, CO.CourseCode collate database_default as CourseCode
			, 'N' as exclSec
			, 'N' as exclCrs
			, 'ODS' as issueFoundIN
	from EdFi_Section as SC
		join EdFi_CourseOffering as CO
			on CO.LocalCourseCode = SC.LocalCourseCode
				and CO.SchoolId = SC.SchoolId
				and CO.SchoolYear = SC.SchoolYear
				and CO.SessionName = SC.SessionName
		inner join EdFi_Course as CS
			on CS.EducationOrganizationId = CO.EducationOrganizationId
				and CS.CourseCode = CO.CourseCode
	except
	select distinct skl.SKL_SCHOOL_ID as SchoolId
			, csk.CSK_COURSE_NUMBER + '-' + COALESCE(trm.TRM_TERM_CODE,'TRM missing') as LocalCourseCode
			, mst.MST_SECTION_NUMBER collate database_default as SectionIdentifier
			, crs.CRS_SHORT_DESCRIPTION collate database_default as CourseTitle
			, crs.CRS_COURSE_NUMBER as CourseCode
			, case when COALESCE(MST_FIELDA_005,'0') = '1' then 'Y' else 'N' end as 'DOE EXCLUDE MST'
			, case when COALESCE(CRS_FIELDA_002,'0') = '1' then 'Y' else 'N' end as 'DOE EXCLUDE CRS'
			, 'ODS' as IssueFoundIN
	from [BPSDATA-03].ExtractAspen.dbo.SCHEDULE_MASTER mst
		left join [BPSDATA-03].ExtractAspen.dbo.SCHEDULE_TERM trm
			on trm.TRM_OID = mst.MST_TRM_OID
		join [BPSDATA-03].ExtractAspen.dbo.COURSE_SCHOOL csk
			on csk.CSK_OID = mst.MST_CSK_OID
		join [BPSDATA-03].ExtractAspen.dbo.SCHOOL skl
			on skl.SKL_OID = csk.CSK_SKL_OID
		join [BPSDATA-03].ExtractAspen.dbo.COURSE crs
			on crs.CRS_OID = csk.CSK_CRS_OID
				and skl.SKL_CTX_OID_CURRENT = crs.CRS_CTX_OID
				and crs.CRS_MASTER_TYPE = 'Class' -- only publishable course type
				and COALESCE(CRS_FIELDA_002, '0') = '0' -- DOE EXCLUDE CRS
		join [BPSDATA-03].ExtractAspen.dbo.DISTRICT_SCHOOL_YEAR_CONTEXT ctx
			on ctx.CTX_OID = skl.SKL_CTX_OID_CURRENT
		left join
		(
			select RCD_CODE
				, RCD_CODE_SYSTEM
				, RCD_CODE_EDFI
			from [BPSDATA-03].ExtractAspen.dbo.REF_TABLE
				join [BPSDATA-03].ExtractAspen.dbo.REF_CODE
					on RTB_OID = RCD_RTB_OID
						and COALESCE(RCD_DISABLED_IND, '0') = '0'
			where RTB_OID = 'rtbSchTermCode'
		) refCode
			on trm.TRM_TERM_CODE = refCode.RCD_CODE
	where COALESCE(TRY_CAST(skl.SKL_SCHOOL_ID as INT),-1) > 0  -- schoolId is numeric
		and skl.SKL_SCHOOL_NAME not like 'Summer%'
		-- exclude sections w/out enrolled students because this is either stale or changing data
		--and COALESCE(mst.MST_ENROLLMENT_TOTAL,0) <> 0

	union
	
	select distinct skl.SKL_SCHOOL_ID as SchoolId
			, csk.CSK_COURSE_NUMBER + '-' + COALESCE(trm.TRM_TERM_CODE,'TRM missing') as LocalCourseCode
			, mst.MST_SECTION_NUMBER collate database_default as SectionIdentifier
			, crs.CRS_SHORT_DESCRIPTION collate database_default as CourseTitle
			, crs.CRS_COURSE_NUMBER as CourseCode
			, case when COALESCE(MST_FIELDA_005,'0') = '1' then 'Y' else 'N' end as exclSec
			, case when COALESCE(CRS_FIELDA_002,'0') = '1' then 'Y' else 'N' end as exclCrs
			, 'Aspen' as IssueFoundIN
	from [BPSDATA-03].ExtractAspen.dbo.SCHEDULE_MASTER mst
		left join [BPSDATA-03].ExtractAspen.dbo.SCHEDULE_TERM trm
			on trm.TRM_OID = mst.MST_TRM_OID
		join [BPSDATA-03].ExtractAspen.dbo.COURSE_SCHOOL csk
			on csk.CSK_OID = mst.MST_CSK_OID
		join [BPSDATA-03].ExtractAspen.dbo.SCHOOL skl
			on skl.SKL_OID = csk.CSK_SKL_OID
		join [BPSDATA-03].ExtractAspen.dbo.COURSE crs
			on crs.CRS_OID = csk.CSK_CRS_OID
				and skl.SKL_CTX_OID_CURRENT = crs.CRS_CTX_OID
				and crs.CRS_MASTER_TYPE = 'Class' -- only publishable course type
				and COALESCE(CRS_FIELDA_002, '0') = '0' -- DOE EXCLUDE CRS
		join [BPSDATA-03].ExtractAspen.dbo.DISTRICT_SCHOOL_YEAR_CONTEXT ctx
			on ctx.CTX_OID = skl.SKL_CTX_OID_CURRENT
		left join
		(
			select RCD_CODE
				, RCD_CODE_SYSTEM
				, RCD_CODE_EDFI
			from [BPSDATA-03].ExtractAspen.dbo.REF_TABLE
				join [BPSDATA-03].ExtractAspen.dbo.REF_CODE
					on RTB_OID = RCD_RTB_OID
						and COALESCE(RCD_DISABLED_IND, '0') = '0'
			where RTB_OID = 'rtbSchTermCode'
		) refCode
			on trm.TRM_TERM_CODE = refCode.RCD_CODE
	where COALESCE(TRY_CAST(skl.SKL_SCHOOL_ID as INT),-1) > 0  -- schoolId is numeric
		and skl.SKL_SCHOOL_NAME not like 'Summer%'
		-- exclude sections w/out enrolled students because this is either stale or changing data
		and COALESCE(mst.MST_ENROLLMENT_TOTAL,0) <> 0
		--debugging: 
		--and trm.TRM_OID is not null
		--and coalesce(MST_FIELDA_005, '0') = '0' -- DOE EXCLUDE MST
	except
	select CAST(SC.SchoolId as VARCHAR(20)) as SchoolId
			, CO.LocalCourseCode collate database_default as LocalCourseCode
			, SC.SectionIdentifier collate database_default as SectionIdentifier
			, CS.CourseTitle collate database_default as CourseTitle
			, CO.CourseCode collate database_default as CourseCode
			, 'N' as exclSec
			, 'N' as exclCrs
			, 'Aspen' as IssueFoundIN
	from EdFi_Section as SC
		join EdFi_CourseOffering as CO
			on CO.LocalCourseCode = SC.LocalCourseCode
				and CO.SchoolId = SC.SchoolId
				and CO.SchoolYear = SC.SchoolYear
				and CO.SessionName = SC.SessionName
		inner join EdFi_Course as CS
			on CS.EducationOrganizationId = CO.EducationOrganizationId
				and CS.CourseCode = CO.CourseCode
	order by issueFoundIN desc
		, SchoolId
		, exclCrs
		, CourseCode
		, SectionIdentifier

end;



GO
