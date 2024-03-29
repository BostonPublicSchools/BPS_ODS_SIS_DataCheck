USE [BPSDataCheck]
GO
/****** Object:  StoredProcedure [dbo].[_Update_Configuration_Yearly]    Script Date: 2/23/2024 3:04:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[_Update_Configuration_Yearly]
    @ods_db_name    NVARCHAR(max) = null -- name of ODS to be the source of the Synonyms
  , @school_year_id NVARCHAR(max) = null -- school represented as {startingYear}-{endingYear} (eg. 2023-2024)
as
begin
    set nocount on ;
    --checking if we need to update the DB name
    if @ods_db_name is not null
       and len(@ods_db_name) > 0
    begin

        --all synonyms are in dbo.Edfi_Synonyms
        --sql to build dynamic sql command
        declare @sql_cmd NVARCHAR(max) ;
        --actual name of the synonym. This will be the name used inside all the SPs
        declare @edfi_syn_name NVARCHAR(max) ;
        --this the actual name of the edfi table needed
        declare @edfi_db_object NVARCHAR(max) ;
        declare @table_names TABLE (id INT not null identity(1, 1) primary key, syn_name NVARCHAR(max) not null, edfi_db_object NVARCHAR(max) not null) ;
        declare @total_records INT ;
        declare @seq_number INT = 1 ;
        insert into @table_names (syn_name, edfi_db_object)
        select edfi_syn_name
             , edfi_db_object
        from [dbo].[_Config_Edfi_Synonyms] ;
        set @total_records = @@ROWCOUNT ;
        while (@seq_number <= @total_records)
        begin
            select @edfi_syn_name = syn_name
                 , @edfi_db_object = edfi_db_object
            from @table_names
            where id = @seq_number ;
            set @sql_cmd
                = N'
                            DROP SYNONYM IF EXISTS [' + @edfi_syn_name
                  + N']
                            CREATE SYNONYM [' + @edfi_syn_name + N'] FOR [' + @ods_db_name + N'].' + @edfi_db_object ;
            print (@sql_cmd) ;
            execute (@sql_cmd) ;
            set @seq_number = @seq_number + 1 ;
        end ;
    end ;
    --checking if we need to update the aspen school year
    if @school_year_id is not null
       and len(@school_year_id) > 0
    begin
        update [dbo].[_Config_Aspen_Filters]
        set SchoolYearId = ctx.CTX_CONTEXT_ID
          , SchoolYear = ctx.CTX_SCHOOL_YEAR
          , StartDate = ctx.CTX_START_DATE
        from [ASPENDBCLOUD].[aspen_ma_boston].dbo.DISTRICT_SCHOOL_YEAR_CONTEXT ctx
        where ctx.CTX_CONTEXT_ID = @school_year_id ;
    end ;
end ;

