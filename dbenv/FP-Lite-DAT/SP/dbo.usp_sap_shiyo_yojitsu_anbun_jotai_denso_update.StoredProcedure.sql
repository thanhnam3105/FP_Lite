IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_shiyo_yojitsu_anbun_jotai_denso_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_shiyo_yojitsu_anbun_jotai_denso_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：使用予実按分トラン伝送状態更新処理
ファイル名	：usp_sap_shiyo_yojitsu_anbun_jotai_denso_update
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.07.13 kaneko.m
更新日      ：2015.12.22 ADMAX s.shibao 残実績の更新用処理追加
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_shiyo_yojitsu_anbun_jotai_denso_update]
	@kbnShiyoJissekiAnbun	VARCHAR(10)
	,@kbnDensoJotaiBefore	SMALLINT
	,@kbnDensoJotaiAfter	SMALLINT
AS
BEGIN
	IF @kbnShiyoJissekiAnbun = '1'
	UPDATE
		tr_sap_shiyo_yojitsu_anbun
	SET
		kbn_jotai_denso = @kbnDensoJotaiAfter
	WHERE EXISTS (
		SELECT 1 FROM wk_sap_shiyo_yojitsu_anbun_seizo wk
		WHERE
			wk.no_seq = tr_sap_shiyo_yojitsu_anbun.no_seq
			AND wk.no_lot_shikakari = tr_sap_shiyo_yojitsu_anbun.no_lot_shikakari
			AND wk.kbn_shiyo_jisseki_anbun = @kbnShiyoJissekiAnbun
			AND wk.kbn_jotai_denso = @kbnDensoJotaiBefore
	)
	ELSE IF @kbnShiyoJissekiAnbun = '2'
	UPDATE
		tr_sap_shiyo_yojitsu_anbun
	SET
		kbn_jotai_denso = @kbnDensoJotaiAfter
	WHERE EXISTS (
		SELECT 1 FROM wk_sap_shiyo_yojitsu_anbun_chosei wk
		WHERE
			wk.no_seq = tr_sap_shiyo_yojitsu_anbun.no_seq
			AND wk.no_lot_shikakari = tr_sap_shiyo_yojitsu_anbun.no_lot_shikakari
			AND wk.kbn_shiyo_jisseki_anbun = @kbnShiyoJissekiAnbun
			AND wk.kbn_jotai_denso = @kbnDensoJotaiBefore
	)
	ELSE IF @kbnShiyoJissekiAnbun = '3'
	UPDATE
		tr_sap_shiyo_yojitsu_anbun
	SET
		kbn_jotai_denso = @kbnDensoJotaiAfter
	WHERE EXISTS (
		SELECT 1 FROM wk_sap_shiyo_yojitsu_anbun_seizo wk
		WHERE
			wk.no_seq = tr_sap_shiyo_yojitsu_anbun.no_seq
			AND wk.no_lot_shikakari = tr_sap_shiyo_yojitsu_anbun.no_lot_shikakari
			AND wk.kbn_shiyo_jisseki_anbun = @kbnShiyoJissekiAnbun
			AND wk.kbn_jotai_denso = @kbnDensoJotaiBefore
	)

END
GO
