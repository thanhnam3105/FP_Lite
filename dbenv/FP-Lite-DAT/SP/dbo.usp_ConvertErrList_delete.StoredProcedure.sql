IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ConvertErrList_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ConvertErrList_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：コンバートエラーリスト　選択されたデータを削除　
ファイル名	：usp_ConvertErrList_delete
入力引数	：@bhtid, @dt_niuke, @tm_niuke
              , @cd_hinmei_maker, @cd_maker
出力引数	：	
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2013.07.17 ADMAX tsunezumi.t
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_ConvertErrList_delete]
	@bhtid				VARCHAR(2)
	, @dt_niuke			DATETIME
	, @tm_niuke			VARCHAR(5)
	, @cd_hinmei_maker	VARCHAR(14)
	, @cd_maker			VARCHAR(20)
AS
BEGIN

-- 荷受ラベルエラートラン 削除
	DELETE	tr_niuke_err
	WHERE	bhtid            = @bhtid 
	AND		dt_niuke         = @dt_niuke
	AND		tm_niuke         = @tm_niuke
	AND		cd_hinmei_maker  = @cd_hinmei_maker
	AND		cd_maker         = @cd_maker
END
GO
