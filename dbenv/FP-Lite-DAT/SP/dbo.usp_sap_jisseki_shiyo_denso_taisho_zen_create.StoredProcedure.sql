IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_shiyo_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：前回使用実績送信対象テーブル作成処理
ファイル名	：[usp_sap_jisseki_shiyo_denso_taisho_zen_create]
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.07.15 kaneko.m
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_taisho_zen_create] 
AS
BEGIN
	-- 前回送信対象テーブル作成：前回送信対象テーブルをtrancate
	TRUNCATE TABLE tr_sap_jisseki_shiyo_denso_taisho_zen

	-- 前回送信対象テーブル作成：送信対象テーブルを前回送信対象テーブルにINSERT
	INSERT INTO tr_sap_jisseki_shiyo_denso_taisho_zen (
		no_seq
		,flg_yojitsu
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,no_lot_shikakari
		,su_shiyo
		,data_key_tr_shikakari
	)
		SELECT
			no_seq
			,flg_yojitsu
			,cd_hinmei
			,dt_shiyo
			,no_lot_seihin
			,no_lot_shikakari
			,su_shiyo
			,data_key_tr_shikakari
		FROM
			tr_sap_jisseki_shiyo_denso_taisho
END

GO
