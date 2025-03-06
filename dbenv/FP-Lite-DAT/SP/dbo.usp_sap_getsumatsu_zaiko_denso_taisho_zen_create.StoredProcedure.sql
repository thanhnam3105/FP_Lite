IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_getsumatsu_zaiko_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_getsumatsu_zaiko_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：月末在庫送信前回対象テーブル作成処理
ファイル名	：[usp_sap_getsumatsu_zaiko_denso_taisho_zen_create]
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.28 endo.y
更新日      ：2018.08.07 kanehira.d 月末在庫抽出テーブルと月末在庫送信対象テーブルをトランケートする。
更新日      ：2018.12.13 motojima 対象テーブルをTRUNCATEからDELETEに変更。
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_getsumatsu_zaiko_denso_taisho_zen_create] 
AS
BEGIN
/*
	-- 前回送信対象テーブル作成：前回送信対象テーブルをクリア
	DELETE tr_sap_getsumatsu_zaiko_denso_taisho_zen

	-- 前回送信対象テーブル作成：送信対象テーブルを前回送信対象テーブルにINSERT
	INSERT INTO tr_sap_getsumatsu_zaiko_denso_taisho_zen (
		cd_hinmei
		,dt_tanaoroshi
		,cd_kojo
		,hokan_basho
		,su_tanaoroshi
		,cd_tani
		,dt_update
		,kbn_zaiko
	)
	SELECT
		cd_hinmei
		,dt_tanaoroshi
		,cd_kojo
		,hokan_basho
		,su_tanaoroshi
		,cd_tani
		,dt_update
		,kbn_zaiko
	FROM
		tr_sap_getsumatsu_zaiko_denso_taisho
*/
	
	-- 月末在庫送信対象テーブル、月末在庫抽出テーブルを削除	
/*
	TRUNCATE TABLE tr_sap_getsumatsu_zaiko_denso_taisho
	
	TRUNCATE TABLE tr_sap_getsumatsu_zaiko_denso
*/
	DELETE tr_sap_getsumatsu_zaiko_denso_taisho
	DELETE tr_sap_getsumatsu_zaiko_denso

END
GO
