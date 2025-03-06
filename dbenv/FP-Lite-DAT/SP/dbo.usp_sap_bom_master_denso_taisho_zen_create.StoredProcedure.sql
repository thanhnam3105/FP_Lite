IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_bom_master_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_bom_master_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：BOMマスタ送信前回対象テーブル作成処理
ファイル名	：[usp_sap_bom_master_denso_taisho_zen_create]
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.23 tsujita.s
更新日      ：2015.01.27 tsujita.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_bom_master_denso_taisho_zen_create] 
AS
BEGIN
	-- 前回送信対象テーブル作成：前回送信対象テーブルをクリア
	DELETE ma_sap_bom_denso_taisho_zen

	-- 前回送信対象テーブル作成：送信対象テーブルを前回送信対象テーブルにINSERT
	INSERT INTO ma_sap_bom_denso_taisho_zen (
		cd_seihin
		,no_han
		,cd_kojo
		,dt_from
		,su_kihon
		,cd_hinmei
		,su_hinmoku
		,cd_tani
		,su_kaiso
		,cd_haigo
		,no_kotei
		,no_tonyu
		,flg_mishiyo
	)
	SELECT
		cd_seihin
		,no_han
		,cd_kojo
		,dt_from
		,su_kihon
		,cd_hinmei
		,su_hinmoku
		,cd_tani
		,su_kaiso
		,cd_haigo
		,no_kotei
		,no_tonyu
		,flg_mishiyo
	FROM
		ma_sap_bom_denso_taisho
END
GO
