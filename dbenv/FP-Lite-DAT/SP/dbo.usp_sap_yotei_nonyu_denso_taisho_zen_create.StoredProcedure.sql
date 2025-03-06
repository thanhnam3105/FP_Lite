IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_yotei_nonyu_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_yotei_nonyu_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：納入予定送信前回対象テーブル取込処理
ファイル名	：usp_sap_yotei_nonyu_denso_taisho_zen_create
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.08 ADMAX endo.y
更新日      ：2015.06.19 ADMAX tsujita.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_yotei_nonyu_denso_taisho_zen_create] 
AS
BEGIN
	-- 納入予定送信前回対象テーブルの削除
	TRUNCATE TABLE tr_sap_yotei_nonyu_denso_taisho_zen

	-- 納入予定送信対象テーブルのデータを納入予定送信前回対象テーブルにコピー
	INSERT INTO tr_sap_yotei_nonyu_denso_taisho_zen (
		flg_yojitsu
		,no_nonyu
		,dt_nonyu
		,cd_hinmei
		,su_nonyu
		,su_nonyu_hasu
		,cd_torihiki
		,cd_torihiki2
		,tan_nonyu
		,kin_kingaku
		,no_nonyusho
		,kbn_zei
		,kbn_denso
		,flg_kakutei
		,dt_seizo
		,kbn_nyuko
		,cd_tani_shiyo
	)
	SELECT
		flg_yojitsu
		,no_nonyu
		,dt_nonyu
		,cd_hinmei
		,su_nonyu
		,su_nonyu_hasu
		,cd_torihiki
		,cd_torihiki2
		,tan_nonyu
		,kin_kingaku
		,no_nonyusho
		,kbn_zei
		,kbn_denso
		,flg_kakutei
		,dt_seizo
		,kbn_nyuko
		,cd_tani_shiyo
	FROM tr_sap_yotei_nonyu_denso_taisho
END
GO
