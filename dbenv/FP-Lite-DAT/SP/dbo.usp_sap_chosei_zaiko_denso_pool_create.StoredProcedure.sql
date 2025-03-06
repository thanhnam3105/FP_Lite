IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_chosei_zaiko_denso_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_chosei_zaiko_denso_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：在庫調整伝送POOLテーブル作成処理
ファイル名	：[usp_sap_chosei_zaiko_denso_pool_create]
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.28 endo.y
更新日      ：2015.09.24 taira.s  納品書番号、返品理由を追加
更新日      ：2015.09.29 taira.s  取引先コードを追加
更新日　　　：2022.11.01 echigo.r 返品メモではなく、備考内容をSAPに伝送
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_chosei_zaiko_denso_pool_create] 
AS
BEGIN

	-- 送信テーブル保存処理：送信POOLテーブルから1年より前のデータを削除
	DELETE tr_sap_chosei_zaiko_denso_pool
	WHERE dt_denso < DATEADD(month, -18, CONVERT(VARCHAR, GETUTCDATE(), 111))

	-- 送信テーブル保存処理：送信抽出テーブルから送信POOLテーブルにINSERT
	INSERT INTO tr_sap_chosei_zaiko_denso_pool (
			 kbn_denso_SAP
			,no_seq
			,cd_hinmei
			,cd_kojo
			,cd_soko
			,cd_riyu
			,su_chosei
			,cd_tani_SAP
			,cd_genka_center
			,dt_denpyo
			,dt_hizuke
			,dt_denso
			,kbn_ido
			,cd_torihiki
			,biko
			,no_nohinsho
	)
		SELECT 
			 kbn_denso_SAP
			,no_seq
			,cd_hinmei
			,cd_kojo
			,cd_soko
			,cd_riyu
			,su_chosei
			,cd_tani_SAP
			,cd_genka_center
			,dt_denpyo
			,dt_hizuke
			,GETUTCDATE() AS dt_denso
			,kbn_ido
			,cd_torihiki
			,biko
			,no_nohinsho
		FROM tr_sap_chosei_zaiko_denso

END
GO
