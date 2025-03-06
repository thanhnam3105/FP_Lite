IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_nonyu_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_nonyu_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：前回納入実績送信対象テーブル作成処理
ファイル名	：[[usp_sap_jisseki_nonyu_denso_taisho_zen_create]]
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.20 endo.y
更新日      ：2015.08.19 taira.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_nonyu_denso_taisho_zen_create] 
AS
BEGIN
	-- 前回送信対象テーブル作成：前回送信対象テーブルをtrancate
	TRUNCATE TABLE tr_sap_jisseki_nonyu_denso_taisho_zen

	-- 前回送信対象テーブル作成：送信対象テーブルを前回送信対象テーブルにINSERT
	INSERT INTO tr_sap_jisseki_nonyu_denso_taisho_zen (
			no_nonyu
			,no_niuke
			,cd_kojo
			,cd_niuke_basho
			,dt_nonyu
			,cd_hinmei
			,su_nonyu_jitsu
			,cd_torihiki
			,cd_tani_nonyu
			,kbn_nyuko
			,flg_kakutei
			,no_nohinsho
			,no_zeikan_shorui
	)
		SELECT
			no_nonyu
			,no_niuke
			,cd_kojo
			,cd_niuke_basho
			,dt_nonyu
			,cd_hinmei
			,su_nonyu_jitsu
			,cd_torihiki
			,cd_tani_nonyu
			,kbn_nyuko
			,flg_kakutei
			,ISNULL(no_nohinsho,'')
			,ISNULL(no_zeikan_shorui,'')
		FROM
			tr_sap_jisseki_nonyu_denso_taisho
END
GO
