IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_bom_master_denso_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_bom_master_denso_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：納入実績伝送POOLテーブル作成処理
ファイル名	：[usp_sap_bom_master_denso_pool_create]
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.23 tsujita.s
更新日      ：2015.02.17 tsujita.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_bom_master_denso_pool_create] 
AS
BEGIN
	SET NOCOUNT ON

	-- 送信テーブル保存処理：送信POOLテーブルから1年より前のデータを削除
	DELETE ma_sap_bom_denso_pool
	WHERE dt_denso < DATEADD(month, -18, CONVERT(VARCHAR, GETUTCDATE(), 111))

	-- 送信テーブル保存処理：送信抽出テーブルから送信POOLテーブルにINSERT
	INSERT INTO ma_sap_bom_denso_pool (
		kbn_denso_SAP
		,cd_seihin
		--,no_han
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
		,dt_denso
	)
	SELECT 
		kbn_denso_SAP
		,cd_seihin
		--,no_han
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
		,GETUTCDATE() AS dt_denso
	FROM ma_sap_bom_denso

END
GO
