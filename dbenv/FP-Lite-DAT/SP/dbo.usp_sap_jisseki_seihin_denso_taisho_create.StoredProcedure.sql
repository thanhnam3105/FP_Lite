IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_seihin_denso_taisho_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_seihin_denso_taisho_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：製品実績送信対象テーブル作成処理
ファイル名	：usp_sap_jisseki_seihin_denso_taisho_create
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.07 kaneko.m
更新日      ：2015.10.07 ADMAX taira.s 品名マスタ.テスト品=1のデータを取り込まないように修正
更新日      ：2015.12.01 ADMAX kakuta.y 実績データの判断をフラグに統一。送信対象絞り込み時にフラグで絞るので、それ以降の処理でフラグをみないように修正。
更新日　　　：2016.01.04 Hirai.a 条件の日付を60日に統一
更新日　　　：2024.02.05 Echigo.r 工場コード識別条件追加（TN工場追加対応）
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_seihin_denso_taisho_create] 
	@createFlag smallint
	,@updateFlag smallint
	,@deleteFlag smallint
	,@kbnJikagen smallint
	,@flgJisseki smallint
AS
BEGIN

	-- 工場コードの取得
	DECLARE @cd_kojo VARCHAR(13)
	SET @cd_kojo = (SELECT TOP 1 cd_kojo FROM ma_kojo)

	--コピー条件用日付（システム日時 - 60日）
	DECLARE @dateTaisho DATETIME = DATEADD(DD,-60,getutcdate())

	-- 取込処理：製品実績送信対象 テーブルをtrancate
	TRUNCATE TABLE tr_sap_jisseki_seihin_denso_taisho

	-- 取込処理：製品計画トランを製品実績送信対象テーブルにINSERT
	INSERT INTO tr_sap_jisseki_seihin_denso_taisho (
		no_lot_seihin
		,dt_seizo
		,cd_shokuba
		,cd_line
		,cd_hinmei
		,su_seizo_yotei
		,su_seizo_jisseki
		,flg_jisseki
		,kbn_denso
		,flg_denso
		,dt_update
		,su_batch_keikaku
		,su_batch_jisseki
		,dt_shomi
		,no_lot_hyoji
	)
		 SELECT
				no_lot_seihin
			   ,dt_seizo
			   ,cd_shokuba
			   ,cd_line
			   ,tks.cd_hinmei
			   ,su_seizo_yotei
			   ,su_seizo_jisseki
			   ,flg_jisseki
			   ,kbn_denso
			   ,flg_denso
			   ,tks.dt_update
			   ,su_batch_keikaku
			   ,su_batch_jisseki
			   ,dt_shomi
			   ,no_lot_hyoji
		 FROM tr_keikaku_seihin tks
		 LEFT JOIN ma_hinmei mh
		    ON tks.cd_hinmei = mh.cd_hinmei
		 WHERE
			tks.flg_jisseki = @flgJisseki
			AND tks.dt_seizo > @dateTaisho
			AND ISNULL(mh.flg_testitem, 0) <> 1

	-- 送信データ抽出：製品実績抽出テーブルのTRUNCATE
	TRUNCATE TABLE tr_sap_jisseki_seihin_denso
	
	--前回データから3か月前を削除
	DELETE tr_sap_jisseki_seihin_denso_taisho_zen
	WHERE dt_seizo <= @dateTaisho

	-- 送信データ抽出：製品実績抽出テーブルへのINSERT
	INSERT INTO tr_sap_jisseki_seihin_denso (
		kbn_denso_SAP
		,no_lot_seihin
		,dt_seizo
		,dt_shomi
		,cd_kojo
		,cd_hinmei
		,su_seizo_jisseki
		,cd_tani_SAP
		,no_lot_hyoji
	)
		-- 送信データ抽出：新規データ抽出
		SELECT
			@createFlag AS kbn_denso_SAP
			,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
				SUBSTRING(taisho.no_lot_seihin, 4, 10) AS no_lot_seihin
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_seizo, 112)) AS dt_seizo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_shomi, 112)) AS dt_shomi
			,@cd_kojo AS cd_kojo
			,UPPER(taisho.cd_hinmei) AS cd_hinmei
			,taisho.su_seizo_jisseki
			,mst.cd_tani_henkan
			,taisho.no_lot_hyoji
		FROM tr_sap_jisseki_seihin_denso_taisho taisho
		LEFT JOIN tr_sap_jisseki_seihin_denso_taisho_zen zen
			ON taisho.no_lot_seihin = zen.no_lot_seihin
			AND taisho.flg_jisseki = zen.flg_jisseki
		LEFT JOIN ma_hinmei mh
			ON taisho.cd_hinmei = mh.cd_hinmei
		LEFT JOIN ma_sap_tani_henkan mst
			ON mh.cd_tani_nonyu = mst.cd_tani
		WHERE zen.no_lot_seihin is null

		-- 送信データ抽出：更新データ抽出（赤）
		UNION ALL
		SELECT
			@deleteFlag AS kbn_denso_SAP
			,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
				SUBSTRING(zen.no_lot_seihin, 4, 10) AS no_lot_seihin
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, zen.dt_seizo, 112)) AS dt_seizo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, zen.dt_shomi, 112)) AS dt_shomi
			,@cd_kojo AS cd_kojo
			,UPPER(zen.cd_hinmei) AS cd_hinmei
			,zen.su_seizo_jisseki
			,mst.cd_tani_henkan
			,zen.no_lot_hyoji
		FROM tr_sap_jisseki_seihin_denso_taisho taisho
		INNER JOIN tr_sap_jisseki_seihin_denso_taisho_zen zen
			ON taisho.no_lot_seihin = zen.no_lot_seihin
			AND taisho.flg_jisseki = zen.flg_jisseki
		LEFT JOIN ma_hinmei mh
			ON taisho.cd_hinmei = mh.cd_hinmei
		LEFT JOIN ma_sap_tani_henkan mst
			ON mh.cd_tani_nonyu = mst.cd_tani
		WHERE (taisho.su_seizo_jisseki <> zen.su_seizo_jisseki 
				OR taisho.dt_shomi <> zen.dt_shomi
				OR COALESCE(taisho.no_lot_hyoji, '') <> COALESCE(zen.no_lot_hyoji, ''))

		-- 送信データ抽出：更新データ抽出（黒）
		UNION ALL
		SELECT
			@createFlag AS kbn_denso_SAP
			,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
				SUBSTRING(taisho.no_lot_seihin, 4, 10) AS no_lot_seihin
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_seizo, 112)) AS dt_seizo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_shomi, 112)) AS dt_shomi
			,@cd_kojo AS cd_kojo
			,UPPER(taisho.cd_hinmei) AS cd_hinmei
			,taisho.su_seizo_jisseki
			,mst.cd_tani_henkan
			,taisho.no_lot_hyoji
		FROM tr_sap_jisseki_seihin_denso_taisho taisho
		INNER JOIN tr_sap_jisseki_seihin_denso_taisho_zen zen
			ON taisho.no_lot_seihin = zen.no_lot_seihin
			AND taisho.flg_jisseki = zen.flg_jisseki
		LEFT JOIN ma_hinmei mh
			ON taisho.cd_hinmei = mh.cd_hinmei
		LEFT JOIN ma_sap_tani_henkan mst
			ON mh.cd_tani_nonyu = mst.cd_tani
		WHERE (taisho.su_seizo_jisseki <> zen.su_seizo_jisseki
				OR taisho.dt_shomi <> zen.dt_shomi
				OR COALESCE(taisho.no_lot_hyoji, '') <> COALESCE(zen.no_lot_hyoji, ''))

		-- 送信データ抽出：削除データ抽出
		UNION ALL
		SELECT
			@deleteFlag AS kbn_denso_SAP
			,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
				SUBSTRING(zen.no_lot_seihin, 4, 10) AS no_lot_seihin
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, zen.dt_seizo, 112)) AS dt_seizo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, zen.dt_shomi, 112)) AS dt_shomi
			,@cd_kojo AS cd_kojo
			,UPPER(zen.cd_hinmei) AS cd_hinmei
			,zen.su_seizo_jisseki
			,mst.cd_tani_henkan
			,zen.no_lot_hyoji
		FROM tr_sap_jisseki_seihin_denso_taisho_zen zen
		LEFT JOIN tr_sap_jisseki_seihin_denso_taisho taisho
			ON zen.no_lot_seihin = taisho.no_lot_seihin
			AND zen.flg_jisseki = taisho.flg_jisseki
		LEFT JOIN ma_hinmei mh
			ON zen.cd_hinmei = mh.cd_hinmei
		LEFT JOIN ma_sap_tani_henkan mst
			ON mh.cd_tani_nonyu = mst.cd_tani
		WHERE taisho.no_lot_seihin is null
			AND zen.flg_jisseki = @flgJisseki
END

GO
