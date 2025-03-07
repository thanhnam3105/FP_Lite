IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LineMaster_Mishiyo_chk') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LineMaster_Mishiyo_chk]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,nakamura.r>
-- Create date: <Create Date,,2013.07.24>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_LineMaster_Mishiyo_chk]
	@cd_line varchar(10)
	,@status int output
	,@table	varchar(1000) output
AS
BEGIN

	DECLARE 
		@errno int
		,@str_table varchar(20)

	SET @table = ''
	SET @str_table = ''

	DECLARE cur_invalidation CURSOR FOR
	SELECT
		str_table
	FROM
		(

			SELECT top 1
				'ma_seizo_line' AS str_table
			FROM ma_seizo_line
			WHERE 
				cd_line = @cd_line
			AND
				flg_mishiyo = 0
			
		) chk


	SET @errno = @@error
	IF @errno <> 0
	BEGIN
		SET @status = 99
		RETURN
	END

	OPEN cur_invalidation

	FETCH NEXT FROM cur_invalidation
	INTO @str_table

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @table = ''
		BEGIN
			SET @table = @str_table
		END
		ELSE BEGIN
			SET @table = @table + ',' + @str_table
		END

		FETCH NEXT FROM cur_invalidation
		INTO @str_table
	END
	CLOSE cur_invalidation
	DEALLOCATE cur_invalidation

	SET @errno = @@error
	IF @errno <> 0
	BEGIN
		CLOSE cur_invalidation
		DEALLOCATE cur_invalidation
		SET @status = 99
		RETURN
	END

	IF ISNULL(@table,'') = '' BEGIN
		SET @status = 0		--変更可
	END
	ELSE IF ISNULL(@table,'') <> '' BEGIN
		SET @status = 1		--変更不可（製造ラインマスタで使用）
	END
	ELSE BEGIN
		SET @status = 99	--エラー
	END
END
GO
