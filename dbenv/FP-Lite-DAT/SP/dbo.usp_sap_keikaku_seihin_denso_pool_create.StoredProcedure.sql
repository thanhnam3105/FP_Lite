IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_keikaku_seihin_denso_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_keikaku_seihin_denso_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：製造計画抽出POOLテーブル取込処理
ファイル名	：usp_sap_keikaku_seihin_denso_pool_create
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.08 ADMAX endo.y
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_keikaku_seihin_denso_pool_create] 
AS
BEGIN
	--製造計画抽出POOLテーブルから1年以上前のデータを削除
	DELETE
	FROM tr_sap_keikaku_seihin_denso_pool
	WHERE dt_denso < (SELECT DATEADD(month,-18,GETUTCDATE()))
	
	--送信対象のデータを製造計画抽出POOLテーブルに格納
	INSERT INTO tr_sap_keikaku_seihin_denso_pool (
		kbn_denso_SAP
		,no_lot_seihin
		,dt_seizo
		,cd_kojo
		,cd_hinmei
		,su_seizo_keikaku
		,cd_tani_SAP
		,dt_denso
	)
	SELECT
		kbn_denso_SAP
		,no_lot_seihin
		,dt_seizo
		,cd_kojo
		,cd_hinmei
		,COALESCE(su_seizo_keikaku,0)
		,cd_tani_SAP
		,GETUTCDATE()
	FROM tr_sap_keikaku_seihin_denso
END
GO
