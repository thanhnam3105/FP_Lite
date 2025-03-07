IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_getsumatsu_zaiko_denso_taisho_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_getsumatsu_zaiko_denso_taisho_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：月末在庫送信対象テーブル作成処理
ファイル名	：usp_sap_getsumatsu_zaiko_denso_taisho_create
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.30 tsujita.s
更新日      ：2015.10.07 ADMAX taira.s 品名マスタ.テスト品=1のデータを取り込まないように修正
更新日　　　：2016.01.04 Hirai.a 条件の日付を60日に統一
更新日　　　：2016.05.20 motojima.m
更新日　　　：2018.06.13 tokumoto.k 伝送対象の日付を画面指定日付に修正。前回データ比較廃止。
更新日　　　：2018.08.07 kanehira.d 画面指定日付と棚卸日が等しいデータを月末在庫送信対象テーブルから削除するように修正。
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_getsumatsu_zaiko_denso_taisho_create] 
	@kbnCreate smallint
	,@kbnUpdate smallint
	,@kbnDelete smallint
	,@flg_true smallint
	,@flg_false smallint
	,@kbn_genryo smallint
	,@kbn_shizai smallint
	,@kbn_jikagen smallint
	,@kbn_zaiko smallint
	,@dt_zaiko DATETIME
AS
BEGIN
SET ARITHABORT ON
	-- 変数リスト
	DECLARE @msg				VARCHAR(300)		-- 処理結果メッセージ格納用
	DECLARE @cd_kojo			VARCHAR(13)			-- ログイン情報：工場コード

	-- 工場コードの取得
	SET @cd_kojo = (SELECT TOP 1 cd_kojo FROM ma_kojo)
	
	----コピー条件用日付（システム日時 - 60日）
	--DECLARE @dateTaisho DATETIME = DATEADD(DD,-60,getutcdate())

	-- 検索日付のデータのみクリア
	DELETE tr_sap_getsumatsu_zaiko_denso_taisho
	WHERE dt_tanaoroshi = @dt_zaiko
	
	-- ======================================================
	--  月 末 在 庫 送 信 対 象 テ ー ブ ル の 作 成
	-- ======================================================
	-- 在庫トランのデータを月末在庫送信対象テーブルに追加
	INSERT INTO tr_sap_getsumatsu_zaiko_denso_taisho (
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
		zaiko.cd_hinmei
		,zaiko.dt_hizuke
		,@cd_kojo AS 'cd_kojo'
		,zaiko.cd_soko
		--,zaiko.su_zaiko
		,sum(case when round(convert(decimal(15,6),zaiko.su_zaiko),3) >= 99999999.999999
				or round(convert(decimal(15,6),zaiko.su_zaiko),3) <= -99999999.999999
			then round(convert(decimal(15,6),zaiko.su_zaiko),3,1)
			else round(zaiko.su_zaiko,3)
		end) AS su_zaiko
		,hin.cd_tani_shiyo
		,MAX(zaiko.dt_update) as dt_update
		,@kbn_zaiko
	FROM tr_zaiko zaiko
	INNER JOIN (
		SELECT
			cd_hinmei
			,cd_tani_shiyo
			,flg_testitem
		FROM ma_hinmei
		WHERE kbn_hin = @kbn_genryo
		OR kbn_hin = @kbn_shizai
		OR kbn_hin = @kbn_jikagen
	) hin
	ON zaiko.cd_hinmei = hin.cd_hinmei
	WHERE --zaiko.dt_hizuke > @dateTaisho
		zaiko.dt_hizuke = @dt_zaiko
		AND ISNULL(hin.flg_testitem, 0) <> 1
	GROUP BY 
		zaiko.cd_hinmei
		,zaiko.dt_hizuke
		,zaiko.cd_soko
		,hin.cd_tani_shiyo

		
	-- ======================================================
	--  月 末 在 庫 抽 出 テ ー ブ ル の 作 成
	-- ======================================================
	-- 抽出テーブルをクリア
	DELETE tr_sap_getsumatsu_zaiko_denso
	
	----前回データから3か月前を削除
	--DELETE tr_sap_getsumatsu_zaiko_denso_taisho_zen
	--WHERE dt_tanaoroshi <= @dateTaisho

	-- 月末在庫抽出テーブルへのINSERT
	INSERT INTO tr_sap_getsumatsu_zaiko_denso (
		kbn_denso_SAP
		,cd_hinmei
		,dt_tanaoroshi
		,cd_kojo
		,hokan_basho
		,su_tanaoroshi
		,cd_tani
		,dt_update
		,kbn_zaiko
	)
	-- ////////// 新規追加データ
	SELECT
		@kbnCreate
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_tanaoroshi, 112)) AS 'dt_tanaoroshi'
		,taisho.cd_kojo
		,taisho.hokan_basho
		,taisho.su_tanaoroshi
		,mst.cd_tani_henkan
		,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_update, 112)) AS 'dt_update'
		,taisho.kbn_zaiko
	FROM
		tr_sap_getsumatsu_zaiko_denso_taisho taisho
	--LEFT JOIN tr_sap_getsumatsu_zaiko_denso_taisho_zen zen
	--	ON zen.cd_hinmei = taisho.cd_hinmei
	--	AND zen.dt_tanaoroshi = taisho.dt_tanaoroshi
	--	AND zen.kbn_zaiko = taisho.kbn_zaiko
	--	AND zen.hokan_basho = taisho.hokan_basho
	LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = taisho.cd_tani
	--WHERE
	--	zen.cd_hinmei IS NULL
	
	---- ////////// 更新データ
	--UNION ALL
	--SELECT
	--	@kbnUpdate
	--	,UPPER(taisho.cd_hinmei) AS cd_hinmei
	--	,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_tanaoroshi, 112)) AS 'dt_tanaoroshi'
	--	,taisho.cd_kojo
	--	,taisho.hokan_basho
	--	,taisho.su_tanaoroshi
	--	,mst.cd_tani_henkan
	--	,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_update, 112)) AS 'dt_update'
	--	,taisho.kbn_zaiko
	--FROM
	--	tr_sap_getsumatsu_zaiko_denso_taisho taisho
	--LEFT JOIN tr_sap_getsumatsu_zaiko_denso_taisho_zen zen
	--	ON zen.cd_hinmei = taisho.cd_hinmei
	--	AND zen.dt_tanaoroshi = taisho.dt_tanaoroshi
	--	AND zen.kbn_zaiko = taisho.kbn_zaiko
	--	AND zen.hokan_basho = taisho.hokan_basho
	--LEFT JOIN ma_sap_tani_henkan mst
	--	ON mst.cd_tani = taisho.cd_tani
	--WHERE
	--	taisho.hokan_basho <> zen.hokan_basho
	--	OR taisho.su_tanaoroshi <> zen.su_tanaoroshi
	--	OR taisho.cd_tani <> zen.cd_tani

	---- ////////// 削除データ
	--UNION ALL
	--SELECT
	--	@kbnDelete
	--	,UPPER(zen.cd_hinmei) AS cd_hinmei
	--	,CONVERT(DECIMAL, CONVERT(NVARCHAR, zen.dt_tanaoroshi, 112)) AS 'dt_tanaoroshi'
	--	,zen.cd_kojo
	--	,zen.hokan_basho
	--	,zen.su_tanaoroshi
	--	,mst.cd_tani_henkan
	--	,CONVERT(DECIMAL, CONVERT(NVARCHAR, zen.dt_update, 112)) AS 'dt_update'
	--	,zen.kbn_zaiko
	--FROM
	--	tr_sap_getsumatsu_zaiko_denso_taisho_zen zen
	--LEFT JOIN tr_sap_getsumatsu_zaiko_denso_taisho taisho
	--	ON zen.cd_hinmei = taisho.cd_hinmei
	--	AND zen.dt_tanaoroshi = taisho.dt_tanaoroshi
	--	AND zen.kbn_zaiko = taisho.kbn_zaiko
	--	AND zen.hokan_basho = taisho.hokan_basho
	--LEFT JOIN ma_sap_tani_henkan mst
	--	ON mst.cd_tani = zen.cd_tani
	--WHERE
	--	taisho.cd_hinmei IS NULL

END
GO
