IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_torihiki_jushin_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_torihiki_jushin_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：取引先マスタ更新処理
ファイル名	：usp_sap_torihiki_jushin_update
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.22 endo.y
更新日      ：2016.12.13 motojima.m 中文対応
更新日      ：2017.01.05 BRC.inoue.k
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_torihiki_jushin_update] 
	@kbnCreate			SMALLINT
	,@kbnUpdate			SMALLINT
	,@kbnDelete			SMALLINT
	,@cdTantoSAP		VARCHAR(10)
	,@initKbnKeishiki	SMALLINT
	,@initKbnKeisho		SMALLINT
	,@initFlgPikking	SMALLINT
	,@initFlgShiyo		SMALLINT
AS
BEGIN
	IF OBJECT_ID('tempdb..#sap_torihiki_info') IS NOT NULL
	BEGIN
		DROP TABLE #sap_torihiki_info
	END
	--伝送日時が最新(最終的な更新区分を判別するため)のデータを格納する一時テーブルの作成
	CREATE TABLE #sap_torihiki_info(
		kbn_denso_SAP			SMALLINT
		,kbn_torihiki			SMALLINT
		--,nm_torihiki			VARCHAR(50)
		,nm_torihiki			NVARCHAR(50)
		,cd_torihiki			VARCHAR(13)
		--,nm_torihiki_ryaku	VARCHAR(50)
		,nm_torihiki_ryaku		NVARCHAR(50)
		,no_yubin				VARCHAR(10)
		--,nm_jusho				VARCHAR(100)
		,nm_jusho				NVARCHAR(100)
		,no_tel					VARCHAR(20)
		,no_fax					VARCHAR(20)
		,e_mail					VARCHAR(50)
		,flg_mishiyo			SMALLINT
		,dt_jushin				DATETIME
	)
	--一時テーブルにデータ格納
	INSERT INTO #sap_torihiki_info (
		kbn_denso_SAP
		,kbn_torihiki
		,nm_torihiki
		,cd_torihiki
		,nm_torihiki_ryaku
		,no_yubin
		,nm_jusho
		,no_tel
		,no_fax
		,e_mail
		,flg_mishiyo
		,dt_jushin
	)
	SELECT
		tstj.kbn_denso_SAP
		,tstj.kbn_torihiki
		,dbo.udf_ReplaceTabooChar(tstj.nm_torihiki)
		,tstj.cd_torihiki
		,dbo.udf_ReplaceTabooChar(tstj.nm_torihiki_ryaku)
		,dbo.udf_ReplaceTabooChar(tstj.no_yubin)
		,dbo.udf_ReplaceTabooChar(tstj.nm_jusho)
		,dbo.udf_ReplaceTabooChar(tstj.no_tel)
		,dbo.udf_ReplaceTabooChar(tstj.no_fax)
		,dbo.udf_ReplaceTabooChar(tstj.e_mail)
		,tstj.flg_mishiyo
		,tstj.dt_jushin
	FROM tr_sap_torihiki_jushin tstj
	INNER JOIN 
	(SELECT 
		tj.cd_torihiki
		,MAX(kbn_denso_SAP) kbn_denso_SAP
		,tj.dt_jushin
		FROM tr_sap_torihiki_jushin tj
		INNER JOIN (
			SELECT 
				MAX(dt_jushin) dt_jushin
				,cd_torihiki
			FROM tr_sap_torihiki_jushin
			GROUP BY cd_torihiki
		)hizuke
		ON hizuke.cd_torihiki = tj.cd_torihiki
			AND hizuke.dt_jushin = tj.dt_jushin
		GROUP BY tj.cd_torihiki,tj.dt_jushin
	) maxkbn
	ON maxkbn.cd_torihiki = tstj.cd_torihiki
		AND maxkbn.kbn_denso_SAP = tstj.kbn_denso_SAP
		AND maxkbn.dt_jushin = tstj.dt_jushin

	--追加
	INSERT INTO ma_torihiki (
		kbn_torihiki
		,nm_torihiki
		,cd_torihiki
		,nm_torihiki_ryaku
		,no_yubin
		,nm_jusho
		,no_tel
		,no_fax
		,e_mail
		,kbn_keishiki_nonyusho
		,kbn_keisho_nonyusho
		,flg_pikking
		,flg_mishiyo
		,dt_create
		,cd_create
		,dt_update
		,cd_update
	)
	SELECT 
		tt.kbn_torihiki
		,tt.nm_torihiki
		--,tt.cd_torihiki
		,UPPER (tt.cd_torihiki)
		,tt.nm_torihiki_ryaku
		,tt.no_yubin
		,tt.nm_jusho
		,tt.no_tel
		,tt.no_fax
		,tt.e_mail
		,@initKbnKeishiki
		,@initKbnKeisho
		,@initFlgPikking
		,@initFlgShiyo
		,GETUTCDATE()
		,@cdTantoSAP
		,GETUTCDATE()
		,@cdTantoSAP
	FROM #sap_torihiki_info tt
	LEFT JOIN ma_torihiki mt
		ON tt.cd_torihiki = mt.cd_torihiki
	WHERE mt.cd_torihiki IS NULL
		AND tt.kbn_denso_SAP <> @kbnDelete
	
	--更新
	UPDATE ma_torihiki
		SET kbn_torihiki = tt.kbn_torihiki
			,nm_torihiki = tt.nm_torihiki
			,nm_torihiki_ryaku = tt.nm_torihiki_ryaku
			,no_yubin = tt.no_yubin
			,nm_jusho = tt.nm_jusho
			,no_tel = tt.no_tel
			,no_fax = tt.no_fax
			,e_mail = tt.e_mail
			,flg_mishiyo = tt.flg_mishiyo
			,dt_update = GETUTCDATE()
			,cd_update = @cdTantoSAP
	FROM ma_torihiki mt
	LEFT JOIN #sap_torihiki_info tt
		ON tt.cd_torihiki = mt.cd_torihiki
	WHERE tt.cd_torihiki = mt.cd_torihiki
		AND tt.kbn_denso_SAP <> @kbnDelete
		AND tt.cd_torihiki IS NOT NULL

	--削除
	DELETE mt
	FROM ma_torihiki mt
	LEFT JOIN #sap_torihiki_info tt
		ON tt.cd_torihiki = mt.cd_torihiki
	WHERE tt.cd_torihiki = mt.cd_torihiki
		AND tt.kbn_denso_SAP = @kbnDelete

END
GO
