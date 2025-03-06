IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_torihiki_jushin_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_torihiki_jushin_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：取引先マスタ受信POOLテーブル作成処理
ファイル名	：[usp_sap_torihiki_jushin_pool_create]
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.22 endo.y
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_torihiki_jushin_pool_create] 
AS
BEGIN

	-- 受信テーブル削除処理：取引先マスタ受信POOLテーブルから1年より前のデータを削除
	DELETE tr_sap_torihiki_jushin_pool
	WHERE dt_create < DATEADD(year, -1, CONVERT(VARCHAR, GETUTCDATE(), 111))

	-- 受信POOLテーブル保存処理：取引先マスタ受信テーブルから取引先マスタ受信POOLテーブルにINSERT
	INSERT INTO tr_sap_torihiki_jushin_pool (
			 kbn_denso_SAP
			,kbn_torihiki
			,nm_torihiki
			,cd_torihiki
			,nm_torihiki_ryaku
			,no_yubin
			,nm_jusho
			,no_tel
			,no_fax
			,e_mail
			,flg_mishiyo
			,dt_jushin
			,dt_create
	)
		SELECT 
			 kbn_denso_SAP
			,kbn_torihiki
			,nm_torihiki
			,cd_torihiki
			,nm_torihiki_ryaku
			,no_yubin
			,nm_jusho
			,no_tel
			,no_fax
			,e_mail
			,flg_mishiyo
			,dt_jushin
			,GETUTCDATE() AS dt_create
		FROM tr_sap_torihiki_jushin

END
GO
