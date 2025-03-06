IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_hinmei_jushin_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_hinmei_jushin_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：品名マスタ受信POOLテーブル作成処理
ファイル名	：[usp_sap_hinmei_jushin_pool_create]
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.22 endo.y
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_hinmei_jushin_pool_create] 
AS
BEGIN

	-- 受信テーブル削除処理：品名マスタ受信POOLテーブルから1年より前のデータを削除
	DELETE tr_sap_hinmei_jushin_pool
	WHERE dt_create < DATEADD(year, -1, CONVERT(VARCHAR, GETUTCDATE(), 111))

	-- 受信POOLテーブル保存処理：品名マスタ受信テーブルから品名マスタ受信POOLテーブルにINSERT
	INSERT INTO tr_sap_hinmei_jushin_pool (
			 kbn_denso_SAP
			,cd_hinmei
			,kbn_hin
			,flg_mishiyo
			,nm_hinmei_ja
			,nm_hinmei_en
			,nm_hinmei_zh
			,nm_hinmei_vi
			,dt_jushin
			,dt_create
	)
		SELECT 
			 kbn_denso_SAP
			,cd_hinmei
			,kbn_hin
			,flg_mishiyo
			,nm_hinmei_ja
			,nm_hinmei_en
			,nm_hinmei_zh
			,nm_hinmei_vi
			,dt_jushin
			,GETUTCDATE() AS dt_create
		FROM tr_sap_hinmei_jushin

END
GO
