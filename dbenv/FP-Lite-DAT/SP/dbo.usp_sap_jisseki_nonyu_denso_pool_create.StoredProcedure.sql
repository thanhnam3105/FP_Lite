IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_nonyu_denso_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_nonyu_denso_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：納入実績伝送POOLテーブル作成処理
ファイル名	：[usp_sap_jisseki_nonyu_denso_pool_create]
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.20 endo.y
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_nonyu_denso_pool_create] 
AS
BEGIN

	-- 送信テーブル保存処理：送信POOLテーブルから1年より前のデータを削除
	DELETE tr_sap_jisseki_nonyu_denso_pool
	WHERE dt_denso < DATEADD(month, -18, CONVERT(VARCHAR, GETUTCDATE(), 111))

	-- 送信テーブル保存処理：送信抽出テーブルから送信POOLテーブルにINSERT
	INSERT INTO tr_sap_jisseki_nonyu_denso_pool (
			 kbn_denso_SAP
			,no_nonyu
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
			,dt_denso
			,no_nohinsho
			,no_zeikan_shorui
	)
		SELECT 
			 kbn_denso_SAP
			,no_nonyu
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
			,GETUTCDATE() AS dt_denso
			,no_nohinsho
			,no_zeikan_shorui
		FROM tr_sap_jisseki_nonyu_denso

END
GO
