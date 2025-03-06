IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_chosei_zaiko_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_chosei_zaiko_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：前回調整在庫送信対象テーブル作成処理
ファイル名	：[usp_sap_chosei_zaiko_denso_taisho_zen_create]
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.28 endo.y
更新日      ：2015.07.16 kobayashi.y 按分調整考慮
更新日      ：2015.09.24 taira.s 納品書番号、返品理由を追加
更新日      ：2015.09.29 taira.s 取引先コードを追加
更新日　　　：2022.11.01 echigo.r 返品メモではなく、備考内容をSAPに伝送
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_chosei_zaiko_denso_taisho_zen_create] 
AS
BEGIN
	-- 前回送信対象テーブル作成：前回送信対象テーブルをtrancate
	TRUNCATE TABLE tr_sap_chosei_zaiko_denso_taisho_zen

	-- 前回送信対象テーブル作成：送信対象テーブルを前回送信対象テーブルにINSERT
	INSERT INTO tr_sap_chosei_zaiko_denso_taisho_zen (
			no_seq
			,cd_hinmei
			,dt_hizuke
			,cd_riyu
			,su_chosei
			,dt_update
			,cd_update
			,cd_genka_center
			,cd_soko
			,cd_torihiki
			,biko
			,no_nohinsho
	)
		SELECT
			no_seq
			,cd_hinmei
			,dt_hizuke
			,cd_riyu
			,su_chosei
			,dt_update
			,cd_update
			,cd_genka_center
			,cd_soko
			,cd_torihiki
			,biko
			,no_nohinsho
		FROM
			tr_sap_chosei_zaiko_denso_taisho


	-- 按分調整前回テーブル作成：按分調整前回テーブルをtrancate
	TRUNCATE TABLE tr_sap_chosei_anbun_zen

	-- 按分調整前回テーブル作成：按分調整テーブルを按分調整前回テーブルにINSERT
	INSERT INTO tr_sap_chosei_anbun_zen (
			no_seq
			,no_seq_anbun
			,no_lot_shikakari
			,cd_hinmei
			,dt_hizuke
			,cd_riyu
			,su_chosei
			,cd_genka_center
			,cd_soko
	)
		SELECT
			no_seq
			,no_seq_anbun
			,no_lot_shikakari
			,cd_hinmei
			,dt_hizuke
			,cd_riyu
			,su_chosei
			,cd_genka_center
			,cd_soko
		FROM
			tr_sap_chosei_anbun
END
GO
