IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_seihin_denso_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_seihin_denso_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：製品実績伝送POOLテーブル作成処理
ファイル名	：[usp_sap_jisseki_seihin_denso_pool_create]
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.07 kaneko.m
更新日      ：2015.03.06 tsujita.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_seihin_denso_pool_create] 
AS
BEGIN

	-- 送信テーブル保存処理：送信POOLテーブルから1年より前のデータを削除
	DELETE tr_sap_jisseki_seihin_denso_pool
	WHERE dt_denso < DATEADD(month, -18, CONVERT(VARCHAR, GETUTCDATE(), 111))

	-- 送信テーブル保存処理：送信抽出テーブルから送信POOLテーブルにINSERT
	INSERT INTO tr_sap_jisseki_seihin_denso_pool (
		 kbn_denso_SAP
		,no_lot_seihin
		,dt_seizo
		,dt_shomi
		,cd_kojo
		,cd_hinmei
		,su_seizo_jisseki
		,cd_tani_SAP
		,dt_denso
		,no_lot_hyoji
	)
		SELECT 
			kbn_denso_SAP
			,no_lot_seihin
			,dt_seizo
			,dt_shomi
			,cd_kojo
			,cd_hinmei
			,su_seizo_jisseki
			,cd_tani_SAP
			,GETUTCDATE() AS dt_denso
			,no_lot_hyoji
		FROM tr_sap_jisseki_seihin_denso

END
GO
