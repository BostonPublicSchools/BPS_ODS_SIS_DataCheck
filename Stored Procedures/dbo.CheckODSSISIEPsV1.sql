SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		P. Bryce Avery
-- Create date: 2020-02-03
-- Description:	Compares staff between ODS and SIS
-- =============================================
CREATE  PROCEDURE [dbo].[CheckODSSISIEPsV1]
AS
BEGIN

    SET NOCOUNT ON;

	select st.StudentUniqueId as LocalStudentId, sseae.ProgramName as Program,
		   'ODS' as RecordsFoundIn
	from [dbo].[Mybps_StudentSpecialEducationProgramAssociationExtension] sseae
	inner join [dbo].[Edfi_Student] st ON sseae.StudentUSI = st.StudentUSI
	where GETDATE() between sseae.[BeginDate] and  coalesce(sseae.[IEPExitDate],GETDATE()) 
	except
	select st.STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AS as LocalStudentId, 
	       IEP_PROGRAM COLLATE SQL_Latin1_General_CP1_CI_AS as Program,
		   'ODS' as RecordsFoundIn
	from [BPSDATA-03].ExtractAspen.dbo.V_IEP_DATA v_iep
	   inner join [BPSDATA-03].ExtractAspen.dbo.V_STUDENT st on v_iep.IEP_STD_OID = cast(st.STD_OID as nvarchar(max))
	where  GETDATE() between v_iep.IEP_START_DATE and   coalesce(v_iep.IEP_EXIT_DATE,GETDATE()) 
    and v_iep.IEP_STATUS = 1
	
	Union All

	select st.STD_ID_LOCAL COLLATE SQL_Latin1_General_CP1_CI_AS as LocalStudentId, 
	       IEP_PROGRAM COLLATE SQL_Latin1_General_CP1_CI_AS as Program,
		   'SIS' as RecordsFoundIn
	from [BPSDATA-03].ExtractAspen.dbo.V_IEP_DATA v_iep
	   inner join [BPSDATA-03].ExtractAspen.dbo.V_STUDENT st on v_iep.IEP_STD_OID = cast(st.STD_OID as nvarchar(max))
	where  GETDATE() between v_iep.IEP_START_DATE and   coalesce(v_iep.IEP_EXIT_DATE,GETDATE()) 
	and v_iep.IEP_STATUS = 1
	except
	select st.StudentUniqueId as LocalStudentId, sseae.ProgramName as Program,
		   'SIS' as RecordsFoundIn
	from [dbo].[Mybps_StudentSpecialEducationProgramAssociationExtension] sseae
	inner join [dbo].[Edfi_Student] st ON sseae.StudentUSI = st.StudentUSI
	where GETDATE() between sseae.[BeginDate] and  coalesce(sseae.[IEPExitDate],GETDATE())     
	order by RecordsFoundIn
	

END;

GO
