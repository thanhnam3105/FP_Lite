IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_hinmei_jushin_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_hinmei_jushin_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：品名マスタ更新処理
ファイル名	：usp_sap_hinmei_jushin_create
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.21 endo.y
更新日		：2018.01.30 motojima.m
		：2022.12.07 echigo.r
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_hinmei_jushin_update] 
	@kbnCreate		SMALLINT
	,@kbnUpdate		SMALLINT
	,@kbnDelete		SMALLINT
	,@flgshiyo		SMALLINT
	,@cdTantoSAP	VARCHAR(10)
	,@initTaniShiyo	VARCHAR(10)
	,@initBudomari	DECIMAL(5,2)
	,@initHiju		DECIMAL(6,4)
	,@kbnKanzan		VARCHAR(10)
	,@initIrisu		DECIMAL(5,0)
	,@initKo		DECIMAL(12,6)

AS
BEGIN
SET ARITHABORT ON
	-- 変数リスト
	DECLARE @kbn_literal		VARCHAR(100)		--品名マスタ受信時の納入単位/納入単位（端数）の単位設定機能
	SET @kbn_literal = 1

	IF OBJECT_ID('tempdb..#sap_hinmei_info') IS NOT NULL
	BEGIN
		DROP TABLE #sap_hinmei_info
	END
	--伝送日時が最新(最終的な更新区分を判別するため)のデータを格納する一時テーブルの作成
	CREATE TABLE #sap_hinmei_info(
		kbn_denso_SAP	SMALLINT
		,cd_hinmei		VARCHAR(14)
		,kbn_hin		SMALLINT
		,flg_mishiyo	SMALLINT
		,nm_hinmei_ja	NVARCHAR(50)
		--,nm_hinmei_en	VARCHAR(50)
		,nm_hinmei_en	NVARCHAR(50)
		,nm_hinmei_zh	NVARCHAR(50)
		,nm_hinmei_vi	NVARCHAR(50)
		,dt_jushin		DATETIME
	)
	--一時テーブルにデータ格納
	INSERT INTO #sap_hinmei_info (
		kbn_denso_SAP
		,cd_hinmei
		,kbn_hin
		,flg_mishiyo
		,nm_hinmei_ja
		,nm_hinmei_en
		,nm_hinmei_zh
		,nm_hinmei_vi
		,dt_jushin
	)
	SELECT 
		tshj.kbn_denso_SAP
		,tshj.cd_hinmei
		,tshj.kbn_hin
		,tshj.flg_mishiyo
		,dbo.udf_ReplaceTabooChar(tshj.nm_hinmei_ja)
		,dbo.udf_ReplaceTabooChar(tshj.nm_hinmei_en)
		,dbo.udf_ReplaceTabooChar(tshj.nm_hinmei_zh)
		,dbo.udf_ReplaceTabooChar(tshj.nm_hinmei_vi)
		,tshj.dt_jushin	
	FROM tr_sap_hinmei_jushin tshj
	INNER JOIN 
	(SELECT 
		tj.cd_hinmei
		,MAX(kbn_denso_SAP) kbn_denso_SAP
		,tj.dt_jushin
		FROM tr_sap_hinmei_jushin tj
		INNER JOIN 
			(SELECT 
				MAX(dt_jushin) dt_jushin
				,cd_hinmei
			FROM tr_sap_hinmei_jushin
			GROUP BY cd_hinmei
			) hizuke
		ON hizuke.cd_hinmei = tj.cd_hinmei
			AND hizuke.dt_jushin = tj.dt_jushin
		GROUP BY tj.cd_hinmei,tj.dt_jushin
	) maxkbn
	ON maxkbn.cd_hinmei = tshj.cd_hinmei
		AND maxkbn.kbn_denso_SAP = tshj.kbn_denso_SAP
		AND maxkbn.dt_jushin = tshj.dt_jushin
		
	--追加
	INSERT INTO ma_hinmei (
		cd_hinmei
		,nm_hinmei_ja
		,nm_hinmei_en
		,nm_hinmei_zh
		,nm_hinmei_vi
		,cd_tani_shiyo
		,ritsu_budomari
		,ritsu_hiju
		,kbn_kanzan
		,flg_mishiyo
		,dt_create
		,cd_create
		,dt_update
		,cd_update
		,kbn_hin
		,su_iri
		,wt_ko
		,cd_tani_nonyu
		,cd_bunrui
		,cd_tani_nonyu_hasu
	)
	SELECT 
		th.cd_hinmei
		,th.nm_hinmei_ja
		,th.nm_hinmei_en
		,th.nm_hinmei_zh
		,th.nm_hinmei_vi
		,@initTaniShiyo
		,@initBudomari
		,@initHiju
		,@kbnKanzan
		,th.flg_mishiyo
		,GETUTCDATE()
		,@cdTantoSAP
		,GETUTCDATE()
		,@cdTantoSAP
		,th.kbn_hin
		,@initIrisu
		,@initKo
		,ISNULL(ml.cd_literal,(SELECT TOP 1(cd_tani) FROM ma_tani WHERE flg_mishiyo = @flgshiyo) )
		,(SELECT TOP 1(cd_bunrui) FROM ma_bunrui WHERE kbn_hin = th.kbn_hin and flg_mishiyo = @flgshiyo)
		,ISNULL(ml.cd_literal,(SELECT TOP 1(cd_tani) FROM ma_tani WHERE flg_mishiyo = @flgshiyo) )
	FROM #sap_hinmei_info th
	LEFT JOIN ma_hinmei mh
		ON th.cd_hinmei = mh.cd_hinmei
	LEFT JOIN 
		(
		SELECT 
			kbn_literal
			,cd_key
			,CAST(cd_literal AS int) as cd_literal
			,flg_mishiyo
		FROM ma_literal ml
		WHERE kbn_literal = @kbn_literal
			and flg_mishiyo = @flgshiyo
		) ml
		ON ml.cd_key  = th.kbn_hin
	WHERE mh.cd_hinmei IS NULL
		AND th.kbn_denso_SAP <> @kbnDelete
		
	
	--更新
	UPDATE ma_hinmei
		SET nm_hinmei_ja = th.nm_hinmei_ja
			,nm_hinmei_en = th.nm_hinmei_en
			,nm_hinmei_zh = th.nm_hinmei_zh
			,nm_hinmei_vi = th.nm_hinmei_vi
			-- ,flg_mishiyo = th.flg_mishiyo
			,dt_update = GETUTCDATE()
			,cd_update = @cdTantoSAP
			,kbn_hin = th.kbn_hin
	FROM ma_hinmei mh
	LEFT JOIN #sap_hinmei_info th
		ON th.cd_hinmei = mh.cd_hinmei
	WHERE th.cd_hinmei = mh.cd_hinmei
		AND th.kbn_denso_SAP <> @kbnDelete
		AND th.cd_hinmei IS NOT NULL

	--削除
	DELETE mh
	FROM ma_hinmei mh
	LEFT JOIN #sap_hinmei_info th
		ON th.cd_hinmei = mh.cd_hinmei
	WHERE th.cd_hinmei = mh.cd_hinmei
		AND th.kbn_denso_SAP = @kbnDelete

END



GO
