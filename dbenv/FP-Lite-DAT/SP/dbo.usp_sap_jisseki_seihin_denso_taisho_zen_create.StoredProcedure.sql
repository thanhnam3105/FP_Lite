IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_seihin_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_seihin_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：前回製品実績送信対象テーブル作成処理
ファイル名	：[[usp_sap_jisseki_seihin_denso_taisho_zen_create]]
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.07 kaneko.m
更新日      ：2015.03.06 tsujita.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_seihin_denso_taisho_zen_create] 
AS
BEGIN
	-- 前回送信対象テーブル作成：前回送信対象テーブルをtrancate
	TRUNCATE TABLE tr_sap_jisseki_seihin_denso_taisho_zen

	-- 前回送信対象テーブル作成：送信対象テーブルを前回送信対象テーブルにINSERT
	INSERT INTO tr_sap_jisseki_seihin_denso_taisho_zen (
		no_lot_seihin
		,dt_seizo
		,cd_shokuba
		,cd_line
		,cd_hinmei
		,su_seizo_yotei
		,su_seizo_jisseki
		,flg_jisseki
		,kbn_denso
		,flg_denso
		,dt_update
		,su_batch_keikaku
		,su_batch_jisseki
		,dt_shomi
		,no_lot_hyoji
	)
		SELECT
			no_lot_seihin
			,dt_seizo
			,cd_shokuba
			,cd_line
			,cd_hinmei
			,su_seizo_yotei
			,su_seizo_jisseki
			,flg_jisseki
			,kbn_denso
			,flg_denso
			,dt_update
			,su_batch_keikaku
			,su_batch_jisseki
			,dt_shomi
			,no_lot_hyoji
		FROM
			tr_sap_jisseki_seihin_denso_taisho
END
GO
