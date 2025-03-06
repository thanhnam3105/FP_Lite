IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_keikaku_seihin_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_keikaku_seihin_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：製品計画送信前回対象テーブル取込処理
ファイル名	：usp_sap_keikaku_seihin_denso_taisho_zen_create
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.08 ADMAX endo.y
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_keikaku_seihin_denso_taisho_zen_create] 
	--@hoge1 smallint
	--,@hoge2 smallint
	--,@hoge3 smallint
AS
BEGIN
	-- 製品計画送信前回対象テーブルの削除
	TRUNCATE TABLE tr_sap_keikaku_seihin_denso_taisho_zen

	-- 製品計画送信対象テーブルのデータを製品計画送信前回対象テーブルにコピー
	INSERT INTO tr_sap_keikaku_seihin_denso_taisho_zen (
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
	FROM tr_sap_keikaku_seihin_denso_taisho
END
GO
