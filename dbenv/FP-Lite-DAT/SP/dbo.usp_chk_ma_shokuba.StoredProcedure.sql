IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_chk_ma_shokuba') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_chk_ma_shokuba]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,komaki.h>
-- Create date: <Create Date,,2013.06.19>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[usp_chk_ma_shokuba]
	@cd_shokuba varchar(10)
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
				'ma_line'	as str_table
			FROM ma_line
			WHERE cd_shokuba = @cd_shokuba
			
			UNION		
				
			SELECT top 1 
				'ma_setsubi'		as str_table
			FROM ma_setsubi
			WHERE cd_shokuba = @cd_shokuba
						
			UNION		
			
			SELECT top 1 
				'ma_panel'	as str_table
			FROM ma_panel
			WHERE cd_shokuba = @cd_shokuba
						
			UNION		
			
			SELECT top 1 
				'tr_keikaku_seihin'		as str_table
			FROM tr_keikaku_seihin
			WHERE cd_shokuba = @cd_shokuba
						
			UNION		
			
			SELECT top 1 
				'tr_tonyu' 		as str_table
			FROM tr_tonyu
			WHERE cd_shokuba = @cd_shokuba
						
			UNION		
			
			SELECT top 1 
				'tr_tonyu_jokyo'	as str_table
			FROM tr_tonyu_jokyo
			WHERE cd_shokuba = @cd_shokuba
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
		SET @status = 0		--削除可
	END
	ELSE IF ISNULL(@table,'') <> '' BEGIN
		SET @status = 1		--削除不可（整合性エラー）
	END
	ELSE BEGIN
		SET @status = 99	--エラー
	END

END
GO
