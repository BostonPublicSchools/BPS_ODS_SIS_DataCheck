SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[_Update_Configuration_Yearly]
    @ods_db_name nvarchar(max)= NULL,
	@school_year nvarchar(max)= NULL
AS
BEGIN
    SET NOCOUNT ON
	--checking if we need to update the DB name
	IF @ods_db_name IS NOT NULL AND LEN(@ods_db_name) > 0
		begin
			
			--all synonyms are in dbo.Edfi_Synonyms
			--sql to build dynamic sql command
			declare @sql_cmd nvarchar(max)
			--actual name of the synonym. This will be the name used inside all the SPs
			declare @edfi_syn_name nvarchar(max)
			--this the actual name of the edfi table needed
			declare @edfi_db_object nvarchar(max)
			declare @table_names table (id int not null identity(1,1) primary key,
										syn_name nvarchar(max) not null,
										edfi_db_object nvarchar(max) not null)
			declare @total_records int
			declare @seq_number int = 1
			insert into @table_names (syn_name,edfi_db_object)
			select edfi_syn_name, edfi_db_object
			from [dbo].[_Config_Edfi_Synonyms]
			set @total_records = @@ROWCOUNT
			while (@seq_number <= @total_records)
				begin
				   select @edfi_syn_name = syn_name, @edfi_db_object = edfi_db_object from @table_names where id = @seq_number
				   set @sql_cmd = '
							DROP SYNONYM IF EXISTS ['+ @edfi_syn_name +']
							CREATE SYNONYM ['+ @edfi_syn_name +'] FOR ['+@ods_db_name+'].' + @edfi_db_object
					 print (@sql_cmd)
 					 execute(@sql_cmd)
				  set @seq_number = @seq_number + 1;
				end
		end 
    --checking if we need to update the aspen school year
	IF @school_year IS NOT NULL AND LEN(@school_year) > 0
		BEGIN
		  UPDATE [dbo].[_Config_Aspen_Filters]
		  SET SchoolYear=@school_year;
		END
END
GO
