IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_getsumatsu_zaiko_denso_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_getsumatsu_zaiko_denso_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：月末在庫伝送POOLテーブル作成処理
ファイル名	：[usp_sap_getsumatsu_zaiko_denso_pool_create]
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.30 tsujita.s
更新日		：2021.05.17 BRC.saito #1205対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_getsumatsu_zaiko_denso_pool_create] 
AS
BEGIN
	-- バッチコントロールマスタ更新(起動)
	UPDATE ma_batch_control
	SET flg_shori = 1
		,dt_start = GETUTCDATE()
	WHERE id_jobnet = 'GETSUMATSU_ZAIKO'
	AND flg_shori = 0

	-- 送信テーブル保存処理：送信POOLテーブルから1年より前のデータを削除
	DELETE tr_sap_getsumatsu_zaiko_denso_pool
	WHERE dt_denso < DATEADD(month, -18, CONVERT(VARCHAR, GETUTCDATE(), 111))

	-- 送信テーブル保存処理：送信抽出テーブルから送信POOLテーブルにINSERT
	INSERT INTO tr_sap_getsumatsu_zaiko_denso_pool (
		kbn_denso_SAP
		,cd_hinmei
		,dt_tanaoroshi
		,cd_kojo
		,hokan_basho
		,su_tanaoroshi
		,cd_tani
		,dt_update
		,kbn_zaiko
		,dt_denso
	)
	SELECT 
		 kbn_denso_SAP
		,cd_hinmei
		,dt_tanaoroshi
		,cd_kojo
		,hokan_basho
		,su_tanaoroshi
		,cd_tani
		,dt_update
		,kbn_zaiko
		,GETUTCDATE() AS dt_denso
	FROM tr_sap_getsumatsu_zaiko_denso

END
GO
