IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_batch_old_data_del') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_batch_old_data_del]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：過去データ削除処理
ファイル名	：usp_batch_old_data_del
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
備考		：対象テーブルの過去データを削除する
作成日		：2021.07.07 echigo.r
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_batch_old_data_del]
AS

	-- *******************************
	-- 変数定義
	-- *******************************
	DECLARE 	@table_name		varchar(50)	--テーブル名
			,@column_name	varchar(20)	--カラム名
			,@column_style	varchar(30)	--カラム形式
			,@date_part		varchar(5) 	--期間単位
			,@date_number	varchar(5)	--期間
			,@max_rec		varchar(10)	--最大処理件数
			,@str_where 		varchar(100)
			,@str_sql 		varchar(8000)
			,@errcode		int		--エラーコード

	-- *******************************
	-- ①対象テーブル、条件の取得
	-- *******************************
	-- カーソル定義
	DECLARE 	cur_tbl CURSOR FOR
	SELECT 	table_name		--テーブル名
			,column_name		--カラム名
			,column_style		--カラム形式
			,date_part		--期間単位
			,convert(varchar,date_number)	--期間
			,convert(varchar,max_rec)		--最大処理件数
	FROM 		ma_batch_old_data_del	--過去データ削除管理マスタ
	WHERE 	flg_shori = 1		--処理フラグ=1のみ対象
	ORDER BY 	no_shori		--処理番号順

	SET @errcode = @@error
	IF @errcode <> 0
	BEGIN
		RETURN @errcode
	END

	--カーソルを開く
	OPEN 		cur_tbl
	
	--フェッチする
	FETCH NEXT FROM cur_tbl
	INTO 		@table_name		--テーブル名
			,@column_name	--カラム名
			,@column_style	--カラム形式
			,@date_part		--期間単位
			,@date_number	--期間
			,@max_rec		--最大処理件数

	-- *******************************
	-- ②一テーブルずつ処理
	-- *******************************
	--カーソルの終わりまで
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @str_where = CASE @column_style 
						WHEN 'YYYY/MM/DD' 
							THEN @column_name + ' < convert(varchar(10), dateadd(' + @date_part + ', -' + @date_number + ', getdate()), 111)'
						WHEN 'YYYYMMDD' 
							THEN @column_name + ' < convert(varchar(8), dateadd(' + @date_part + ', -' + @date_number + ', getdate()), 112)'
						WHEN 'YYYYMM'
							THEN @column_name + ' < left(convert(varchar(8), dateadd(' + @date_part + ', -' + @date_number + ', getdate()), 112), 6)'
						END

		SET @errcode = @@error
		IF @errcode <> 0
		BEGIN
			--カーソルを閉じる
			CLOSE 	cur_tbl
			DEALLOCATE cur_tbl
			RETURN @errcode
		END

		--削除用SQL作成
		SET @str_sql = 'DECLARE @count bigint'
		SET @str_sql = @str_sql + ' SELECT @count=COUNT(*) FROM ' + @table_name + ' WHERE ' + @str_where	--削除対象件数取得
		SET @str_sql = @str_sql + ' PRINT ''' + @table_name +  ''''						--対象テーブル名を記録
		SET @str_sql = @str_sql + ' WHILE @count>0'							--削除対象件数が0件になるまで
		SET @str_sql = @str_sql + ' BEGIN '
		SET @str_sql = @str_sql + ' PRINT ''START '' + convert(varchar,getdate(),121)' 		--時刻を記録
		SET @str_sql = @str_sql + ' 		BEGIN TRANSACTION '					--トランザクション開始(最大処理件数ずつあえてコミット)
		SET @str_sql = @str_sql + ' 		DELETE TOP(' + @max_rec + ')'				--最大処理件数ずつ削除
		SET @str_sql = @str_sql + ' 		FROM ' + @table_name + ' WHERE ' + @str_where		--テーブル、条件を指定
		SET @str_sql = @str_sql + ' 		IF @@error <> 0 BEGIN'					--エラー発生時
		SET @str_sql = @str_sql + ' 			ROLLBACK TRANSACTION'				--ロールバック
		SET @str_sql = @str_sql + ' 			PRINT ''エラー発生'''					
		SET @str_sql = @str_sql + ' 			BREAK'						--処理を抜ける(次のテーブルは処理する)
		SET @str_sql = @str_sql + ' 		END'
		SET @str_sql = @str_sql + ' 		COMMIT TRANSACTION '					--コミット
		SET @str_sql = @str_sql + ' 		SELECT @count=COUNT(*) FROM ' + @table_name + ' WHERE ' + @str_where	--削除対象件数取得
		SET @str_sql = @str_sql + ' PRINT ''END    '' + convert(varchar,getdate(),121)' 			--時刻を記録
		SET @str_sql = @str_sql + ' END'

		--削除実行
		EXECUTE (@str_sql)

		SET @errcode = @@error
		IF @errcode <> 0
		BEGIN
			--カーソルを閉じる
			CLOSE 	cur_tbl
			DEALLOCATE cur_tbl
			RETURN @errcode
		END

		--フェッチする
		FETCH NEXT FROM cur_tbl
		INTO 		@table_name		--テーブル名
				,@column_name	--カラム名
				,@column_style	--カラム形式
				,@date_part		--期間単位
				,@date_number	--期間
				,@max_rec		--最大処理件数

	END

	--カーソルを閉じる
	CLOSE 	cur_tbl
	DEALLOCATE cur_tbl
		
	SET @errcode = @@error
	IF @errcode <> 0
	BEGIN
		RETURN @errcode
	END

	

GO


