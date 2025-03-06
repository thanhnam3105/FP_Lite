IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_shiyo_denso_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：使用実績伝送POOLテーブル作成処理
ファイル名	：[usp_sap_jisseki_shiyo_denso_pool_create]
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.07.15 kaneko.m
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_pool_create] 
AS
BEGIN

	-- 送信テーブル保存処理：送信POOLテーブルから1年より前のデータを削除
	DELETE tr_sap_jisseki_shiyo_denso_pool
	WHERE dt_denso < DATEADD(month, -18, CONVERT(VARCHAR, GETUTCDATE(), 111))

	-- 送信テーブル保存処理：送信抽出テーブルから送信POOLテーブルにINSERT
	INSERT INTO tr_sap_jisseki_shiyo_denso_pool (
		kbn_denso_SAP
		,no_seq
		,no_lot_seihin
		,dt_shiyo
		,cd_kojo
		,cd_hinmei
		,su_shiyo
		,cd_tani_SAP
		,type_ido
		,hokan_basho
		,dt_denso
	)
		SELECT 
			kbn_denso_SAP
			,no_seq
			,no_lot_seihin
			,dt_shiyo
			,cd_kojo
			,cd_hinmei
			,su_shiyo
			,cd_tani_SAP
			,type_ido
			,hokan_basho
			,GETUTCDATE() AS dt_denso
		FROM tr_sap_jisseki_shiyo_denso

END

GO
