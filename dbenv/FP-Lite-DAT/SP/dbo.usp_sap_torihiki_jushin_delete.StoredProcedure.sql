IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_torihiki_jushin_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_torihiki_jushin_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：取引先マスタ受信テーブル削除処理
ファイル名	：[usp_sap_torihiki_jushin_delete]
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.22 endo.y
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_torihiki_jushin_delete] 
AS
BEGIN

	-- 取引先マスタ受信テーブルの削除
	TRUNCATE TABLE tr_sap_torihiki_jushin

END
GO
