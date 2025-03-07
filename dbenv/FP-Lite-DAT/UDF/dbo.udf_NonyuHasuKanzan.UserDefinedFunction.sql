IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'udf_NonyuHasuKanzan') AND xtype IN (N'FN', N'IF', N'TF')) 
DROP FUNCTION [dbo].[udf_NonyuHasuKanzan]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date, 2015.02.19,>
-- Last Update: 2015.02.14 tsujita.s
-- Description:	納入端数を換算して納入数と足す
-- =============================================
CREATE FUNCTION [dbo].[udf_NonyuHasuKanzan]
	(
        @cd_tani1 VARCHAR(2)
        ,@cd_tani2 VARCHAR(2)
        ,@su_nonyu DECIMAL(9, 2)
        ,@su_nonyu_hasu DECIMAL(9, 2)
        ,@kg VARCHAR(2)
        ,@li VARCHAR(2)
	)
RETURNS DECIMAL(9, 2)
AS
	BEGIN
        DECLARE @ret DECIMAL(9, 2) = 0.00

		-- 単位がKgまたはLの場合は、端数を正規数に加算する
		IF COALESCE(@cd_tani1, @cd_tani2) = @kg
			OR COALESCE(@cd_tani1, @cd_tani2) = @li
		BEGIN
			SET @ret = @su_nonyu + (CEILING((@su_nonyu_hasu / 1000) * 1000) / 1000)
		END
		ELSE BEGIN
			SET @ret = @su_nonyu
		END

	RETURN @ret

	END
GO
