IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'udf_ReplaceTabooChar') AND xtype IN (N'FN', N'IF', N'TF')) 
DROP FUNCTION [dbo].[udf_ReplaceTabooChar]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,endo.y>
-- Create date: <Create Date, 2015.02.19,>
-- Description:	‹Ö‘¥•¶Žš‚Ì’uŠ·
-- =============================================
CREATE FUNCTION [dbo].[udf_ReplaceTabooChar]
	(
        @str NVARCHAR(200)
	)
RETURNS NVARCHAR(200)
AS
	BEGIN
        DECLARE @ret NVARCHAR(200)
        if @str is null or @str = ''
        begin
			set @ret = @str
		end
		else begin
			set @ret = replace(@str,'"','')
			set @ret = replace(@ret,'''','')
			set @ret = replace(@ret,'{','(')
			set @ret = replace(@ret,'}',')')
        end
	RETURN @ret

	END
GO
