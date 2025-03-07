IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'udf_SplitCommaValue') AND xtype IN (N'FN', N'IF', N'TF')) 
DROP FUNCTION [dbo].[udf_SplitCommaValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[udf_SplitCommaValue]
(
    @String varchar(max)
)
returns @SplittedValues table
(
    Id varchar(50) primary key
)
as
begin
    declare @SplitLength int, @Delimiter varchar(5)
    
    set @Delimiter = ','
    
    while len(@String) > 0
    begin 
        select @SplitLength = (case charindex(@Delimiter,@String) when 0 then
            len(@String) else charindex(@Delimiter,@String) -1 end)
 
        insert into @SplittedValues
        select substring(@String,1,@SplitLength) 
    
        select @String = (case (len(@String) - @SplitLength) when 0 then  ''
            else right(@String, len(@String) - @SplitLength - 1) end)
    end 
return  
end
GO
