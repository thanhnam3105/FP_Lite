IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_nonyu_denso_taisho_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_nonyu_denso_taisho_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：納入実績送信対象テーブル作成処理
ファイル名	：usp_sap_jisseki_nonyu_denso_taisho_create
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.19 endo.y
更新日      ：2015.08.19 taira.s 納品書番号、税関書類No.を追加
更新日      ：2015.09.29 taira.s 納入番号の取得元を納入トランの納入予定番号に変更
更新日      ：2015.10.07 ADMAX taira.s 品名マスタ.テスト品=1のデータを取り込まないように修正
更新日      ：2016.01.04 Hirai.a 条件の日付を60日に統一
更新日      ：2017.07.21 BRC Kurimoto.m [KPMサポートNo.23] 更新時に実績値0のデータが伝送されないように修正
更新日      ：2018.03.12 BRC cho.k 荷受完了フラグを他の実績データと分離して伝送するように修正 
更新日		：2018.10.26 BRC kanehira.d 荷受場所コードではなく倉庫コードを取得するように修正
更新日      ：2018.11.26 BRC kanehira 使用単位がLB以外の環境でも納入実績の計算処理がされるように修正
更新日      ：2019.08.02 nakamura.r 数量を小数点以下３桁まで許容
更新日      ：2020.08.26 BRC nojima 明細削除実行時に納入実績が残っているデータを確定データとして伝送するように修正
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_nonyu_denso_taisho_create] 
	@kbnCreate smallint
	,@kbnUpdate smallint
	,@kbnDelete smallint
	,@flgKakutei smallint
	,@flgJisseki smallint
	,@kbnJikagen smallint
	,@kbnTani	smallint
	,@kbnTaniSyonin	smallint
	,@kbnTaniLB	smallint
	,@kbnTaniShiyo	smallint
	,@flgShiyo	smallint
	,@cdTaniKg	varchar(2)
	,@cdTaniL	varchar(2)
AS
BEGIN
	DECLARE @kinoLB SMALLINT
	SELECT @kinoLB = kbn_kino_naiyo
	FROM cn_kino_sentaku
	WHERE kbn_kino = @kbnTani
	
	--機能選択．納入実績承認区分を取得
	DECLARE @kinoSyonin SMALLINT
	SELECT @kinoSyonin = kbn_kino_naiyo
	FROM cn_kino_sentaku
	WHERE kbn_kino = @kbnTaniSyonin
	
	-- 納入実績送信対象テーブルの削除
	TRUNCATE TABLE tr_sap_jisseki_nonyu_denso_taisho
	
	--コピー条件用日付（システム日時 - 60日）
	DECLARE @dateTaisho DATETIME = DATEADD(DD,-60,getutcdate())
	
	-- 荷受・納入予実トランの実績データ(正規)を納入実績送信対象テーブルに追加
	INSERT INTO tr_sap_jisseki_nonyu_denso_taisho (
		no_nonyu
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
		,no_nohinsho
		,no_zeikan_shorui
	)
	SELECT 
		SUBSTRING(tno.no_nonyu_yotei,4,14) no_nonyu
		,SUBSTRING(tni.no_niuke,4,14) + '1' AS no_niuke
		,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
		--,tni.cd_niuke_basho
		,mks.cd_soko_kbn AS cd_niuke_basho
		,tni.dt_nonyu
		,tni.cd_hinmei
		--,tni.su_nonyu_jitsu
		--,CASE WHEN mk.cd_tani_nonyu = mk.cd_tani_nonyu_hasu THEN
		,CASE WHEN COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = COALESCE(mk.cd_tani_nonyu_hasu,mh.cd_tani_nonyu_hasu) THEN
				--CASE WHEN  @kinoLB = @kbnTaniLB AND (COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniKg OR COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniL) 
				CASE WHEN COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniKg OR COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniL
					THEN ROUND(tni.su_nonyu_jitsu_hasu / 1000,3,1) + tni.su_nonyu_jitsu
				ELSE   tni.su_nonyu_jitsu_hasu + tni.su_nonyu_jitsu
				END
		 ELSE tni.su_nonyu_jitsu END AS su_nonyu_jitsu
		,tni.cd_torihiki
		--,mk.cd_tani_nonyu
		,COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu)
		,tni.kbn_nyuko
		,COALESCE(tn2.flg_kakutei,0)
		,ISNULL(tni.no_nohinsho,'')
		,ISNULL(tni.no_zeikan_shorui,'')
	FROM tr_niuke tni
	LEFT JOIN tr_nonyu tno
		--ON tno.dt_nonyu = tni.dt_niuke
		--AND tno.cd_hinmei = tni.cd_hinmei
		--AND tno.cd_torihiki = tni.cd_torihiki
		--AND tno.kbn_nyuko = tni.kbn_nyuko
		ON tno.no_nonyu = tni.no_nonyu
		AND tni.no_seq = 1
		AND tno.flg_yojitsu = @flgJisseki
		AND CASE WHEN @kinoSyonin = @kbnTaniShiyo THEN tni.flg_shonin ELSE @kbnTaniShiyo END = @kbnTaniShiyo
	LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = tni.cd_hinmei
	LEFT JOIN (
				SELECT 
					cd_hinmei
					,cd_torihiki
					,kbn_nyuko
					,MAX(no_niuke) no_niuke
					,flg_kakutei
				FROM tr_niuke
				WHERE flg_kakutei = @flgKakutei
				AND no_seq = 1
				GROUP BY cd_hinmei,cd_torihiki,kbn_nyuko,flg_kakutei,dt_niuke,no_nonyu
			) tn2
		ON tn2.no_niuke = tni.no_niuke
	LEFT JOIN ma_konyu mk
		ON tni.cd_hinmei = mk.cd_hinmei
			AND tni.cd_torihiki = mk.cd_torihiki
			--AND mk.flg_mishiyo = @flgShiyo
	LEFT JOIN ma_kbn_soko mks
		ON mh.kbn_hin = mks.kbn_hin
	WHERE tni.no_nonyu = tno.no_nonyu
		AND tno.flg_yojitsu = @flgJisseki
		AND tni.no_seq = 1
		AND tni.dt_nonyu > @dateTaisho
		AND ISNULL(mh.flg_testitem, 0) <> 1

	-- 荷受・納入予実トランの実績データ(端数)を納入実績送信対象テーブルに追加
	INSERT INTO tr_sap_jisseki_nonyu_denso_taisho (
		no_nonyu
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
		,no_nohinsho
		,no_zeikan_shorui
	)
	SELECT
		SUBSTRING(tno.no_nonyu_yotei,4,14) no_nonyu
		,SUBSTRING(tni.no_niuke,4,14) + '2' AS no_niuke
		,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
		--,tni.cd_niuke_basho
		,mks.cd_soko_kbn AS cd_niuke_basho
		,tni.dt_nonyu
		,tni.cd_hinmei
		--,tni.su_nonyu_jitsu_hasu
		--,CASE WHEN  @kinoLB = @kbnTaniLB AND (COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniKg OR COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniL) 
		,CASE WHEN COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniKg OR COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniL
				THEN ROUND(tni.su_nonyu_jitsu_hasu / 1000,2,1)
			  ELSE   tni.su_nonyu_jitsu_hasu
		 END AS su_nonyu_jitsu_hasu
		,tni.cd_torihiki
		,COALESCE(mk.cd_tani_nonyu_hasu,mh.cd_tani_nonyu_hasu,'') AS cd_tani_nonyu_hasu
		,tni.kbn_nyuko
		,COALESCE(tn2.flg_kakutei,0)
		,tni.no_nohinsho
		,tni.no_zeikan_shorui
	FROM tr_niuke tni
	LEFT JOIN tr_nonyu tno
		--ON tno.dt_nonyu = tni.dt_niuke
		--AND tno.cd_hinmei = tni.cd_hinmei
		--AND tno.cd_torihiki = tni.cd_torihiki
		--AND tno.kbn_nyuko = tni.kbn_nyuko
		ON tno.no_nonyu = tni.no_nonyu
		AND tno.flg_yojitsu = @flgJisseki
		AND CASE WHEN @kinoSyonin = @kbnTaniShiyo THEN tni.flg_shonin ELSE @kbnTaniShiyo END = @kbnTaniShiyo
	LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = tni.cd_hinmei
	LEFT JOIN (
				SELECT
					cd_hinmei
					,cd_torihiki
					,kbn_nyuko
					,MAX(no_niuke) no_niuke
					,flg_kakutei
				FROM tr_niuke
				WHERE flg_kakutei = @flgKakutei
					AND no_seq = 1
				GROUP BY cd_hinmei,cd_torihiki,kbn_nyuko,flg_kakutei,dt_niuke,no_nonyu
			) tn2
		ON tn2.no_niuke = tni.no_niuke
	LEFT JOIN ma_konyu mk
		ON tni.cd_hinmei = mk.cd_hinmei
			AND tni.cd_torihiki = mk.cd_torihiki
			--AND mk.flg_mishiyo = @flgShiyo
	LEFT JOIN tr_sap_jisseki_nonyu_denso_taisho_zen zen
		ON zen.no_nonyu = SUBSTRING(tno.no_nonyu,4,14)
			AND zen.no_niuke = SUBSTRING(tni.no_niuke,4,14) + '2'
	LEFT JOIN ma_kbn_soko mks
		ON mh.kbn_hin = mks.kbn_hin
	WHERE tni.no_nonyu = tno.no_nonyu
		AND tni.no_seq = 1
		AND tno.flg_yojitsu = @flgJisseki
		AND (zen.su_nonyu_jitsu is null 
			or (zen.su_nonyu_jitsu != 0
				--AND CASE WHEN  @kinoLB = @kbnTaniLB AND (mk.cd_tani_nonyu = @cdTaniKg OR mk.cd_tani_nonyu = @cdTaniL) 
				--AND CASE WHEN  @kinoLB = @kbnTaniLB AND (COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniKg OR COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniL) 
				AND CASE WHEN COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniKg OR COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniL
					THEN ROUND(tni.su_nonyu_jitsu_hasu / 1000,2,1)
					ELSE   tni.su_nonyu_jitsu_hasu
					END != 0))
		AND mk.cd_tani_nonyu <> mk.cd_tani_nonyu_hasu
		AND tni.dt_nonyu > @dateTaisho
		AND ISNULL(mh.flg_testitem, 0) <> 1
		
	-- 送信データ抽出：納入実績抽出テーブルのTRUNCATE
	TRUNCATE TABLE tr_sap_jisseki_nonyu_denso
	
	--前回データから3か月前を削除
	DELETE tr_sap_jisseki_nonyu_denso_taisho_zen
	WHERE dt_nonyu <= @dateTaisho
	
	-- 送信データ抽出：納入実績抽出テーブルへのINSERT
	INSERT INTO tr_sap_jisseki_nonyu_denso (
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
		,no_nohinsho
		,no_zeikan_shorui
	)
	--新規追加データ
	SELECT
		@kbnCreate
		,taisho.no_nonyu
		,taisho.no_niuke
		,taisho.cd_kojo
		,taisho.cd_niuke_basho
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,taisho.dt_nonyu,112)) AS dt_nonyu
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,taisho.su_nonyu_jitsu
		,taisho.cd_torihiki
		,mst.cd_tani_henkan
		,taisho.kbn_nyuko
		,9 AS flg_kakutei
		,taisho.no_nohinsho
		,taisho.no_zeikan_shorui
	FROM tr_sap_jisseki_nonyu_denso_taisho taisho
	LEFT JOIN tr_sap_jisseki_nonyu_denso_taisho_zen zen
		ON zen.no_nonyu = taisho.no_nonyu
			AND zen.no_niuke = taisho.no_niuke
			AND zen.cd_hinmei = taisho.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = taisho.cd_tani_nonyu
	LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = taisho.cd_hinmei
	WHERE taisho.su_nonyu_jitsu <> 0
		AND zen.no_nonyu IS NULL
		AND mh.kbn_hin <> @kbnJikagen
	
	UNION ALL
	
	--更新データ(赤)
	SELECT
		@kbnDelete
		,zen.no_nonyu
		,zen.no_niuke
		,zen.cd_kojo
		,zen.cd_niuke_basho
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,zen.dt_nonyu,112)) AS dt_nonyu
		,UPPER(zen.cd_hinmei) AS cd_hinmei
		,zen.su_nonyu_jitsu
		,zen.cd_torihiki
		,mst.cd_tani_henkan
		,zen.kbn_nyuko
		,9 AS flg_kakutei
		,zen.no_nohinsho
		,zen.no_zeikan_shorui
	FROM tr_sap_jisseki_nonyu_denso_taisho taisho
	INNER JOIN tr_sap_jisseki_nonyu_denso_taisho_zen zen
		ON zen.no_nonyu = taisho.no_nonyu
			AND zen.no_niuke = taisho.no_niuke
			AND zen.cd_hinmei = taisho.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = taisho.cd_tani_nonyu
	LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = zen.cd_hinmei
	WHERE (taisho.dt_nonyu <> zen.dt_nonyu
		OR taisho.su_nonyu_jitsu <> zen.su_nonyu_jitsu
		--OR taisho.flg_kakutei <> zen.flg_kakutei
		OR taisho.no_nohinsho <> zen.no_nohinsho
		OR taisho.no_zeikan_shorui <> zen.no_zeikan_shorui)
		AND zen.su_nonyu_jitsu <> 0
		AND mh.kbn_hin <> @kbnJikagen
	
	UNION ALL
	
	--更新データ(黒)
	SELECT
		@kbnCreate
		,taisho.no_nonyu
		,taisho.no_niuke
		,taisho.cd_kojo
		,taisho.cd_niuke_basho
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,taisho.dt_nonyu,112)) AS dt_nonyu
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,taisho.su_nonyu_jitsu
		,taisho.cd_torihiki
		,mst.cd_tani_henkan
		,taisho.kbn_nyuko
		,9 AS flg_kakutei
		,taisho.no_nohinsho
		,taisho.no_zeikan_shorui
	FROM tr_sap_jisseki_nonyu_denso_taisho taisho
	INNER JOIN tr_sap_jisseki_nonyu_denso_taisho_zen zen
		ON zen.no_nonyu = taisho.no_nonyu
			AND zen.no_niuke = taisho.no_niuke
			AND zen.cd_hinmei = taisho.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = taisho.cd_tani_nonyu
	LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = taisho.cd_hinmei
	WHERE (taisho.dt_nonyu <> zen.dt_nonyu
		OR taisho.su_nonyu_jitsu <> zen.su_nonyu_jitsu
		--OR taisho.flg_kakutei <> zen.flg_kakutei
		OR taisho.no_nohinsho <> zen.no_nohinsho
		OR taisho.no_zeikan_shorui <> zen.no_zeikan_shorui)
		AND taisho.su_nonyu_jitsu <> 0
		AND mh.kbn_hin <> @kbnJikagen
	
	UNION ALL
	
	--削除データ
	SELECT
		@kbnDelete
		,zen.no_nonyu
		,zen.no_niuke
		,zen.cd_kojo
		,zen.cd_niuke_basho
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,zen.dt_nonyu,112)) AS dt_nonyu
		,UPPER(zen.cd_hinmei) AS cd_hinmei
		,zen.su_nonyu_jitsu
		,zen.cd_torihiki
		,mst.cd_tani_henkan
		,zen.kbn_nyuko
		,9 AS flg_kakutei
		,zen.no_nohinsho
		,zen.no_zeikan_shorui
	FROM tr_sap_jisseki_nonyu_denso_taisho_zen zen
	LEFT JOIN tr_sap_jisseki_nonyu_denso_taisho taisho
		ON taisho.no_nonyu = zen.no_nonyu
			AND taisho.no_niuke = zen.no_niuke
			AND taisho.cd_hinmei = zen.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = zen.cd_tani_nonyu
	LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = zen.cd_hinmei
	WHERE zen.su_nonyu_jitsu <> 0
		AND taisho.no_nonyu IS NULL
		AND mh.kbn_hin <> @kbnJikagen
		
	UNION ALL
		
	-- 確定フラグ
	SELECT DISTINCT
		@kbnUpdate
		,taisho.no_nonyu AS no_nonyu
		,'0' AS no_niuke
		,taisho.cd_kojo AS cd_kojo
		,taisho.cd_niuke_basho AS cd_niuke_basho
		,NULL AS dt_nonyu
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,0 AS su_nonyu_jitsu
		,taisho.cd_torihiki
		,'' AS cd_tani_nonyu
		,NULL AS kbn_nyuko
		,taisho.flg_kakutei
		,'' AS no_nohinsho
		,'' AS no_zeikan_shorui
	FROM (
		SELECT
			no_nonyu
			, cd_kojo
			, cd_niuke_basho
			, cd_hinmei
			, cd_torihiki
			, MAX(flg_kakutei) AS flg_kakutei
		FROM tr_sap_jisseki_nonyu_denso_taisho
		WHERE su_nonyu_jitsu <> 0
		GROUP BY no_nonyu, cd_kojo, cd_niuke_basho, cd_hinmei, cd_torihiki
		) taisho
	LEFT OUTER JOIN (
		SELECT
			no_nonyu
			, cd_kojo
			, cd_niuke_basho
			, cd_hinmei
			, cd_torihiki
			, MAX(flg_kakutei) AS flg_kakutei
		FROM tr_sap_jisseki_nonyu_denso_taisho_zen
		WHERE su_nonyu_jitsu <> 0
		GROUP BY no_nonyu, cd_kojo, cd_niuke_basho, cd_hinmei, cd_torihiki
	) zen
		ON zen.no_nonyu = taisho.no_nonyu
	   AND zen.cd_hinmei = taisho.cd_hinmei
	   AND zen.cd_kojo = taisho.cd_kojo
	   AND zen.cd_niuke_basho = taisho.cd_niuke_basho
	LEFT JOIN ma_hinmei mh
		ON taisho.cd_hinmei = mh.cd_hinmei
	WHERE  (zen.no_nonyu IS NULL
	     OR taisho.flg_kakutei <> zen.flg_kakutei)
		AND mh.kbn_hin <> @kbnJikagen
	
	--20190417確定フラグが変わっていない更新データの確定フラグも送るように修正
	INSERT INTO tr_sap_jisseki_nonyu_denso (
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
		,no_nohinsho
		,no_zeikan_shorui
	)
	SELECT DISTINCT
		@kbnUpdate
		,taisho.no_nonyu AS no_nonyu
		,'0' AS no_niuke
		,taisho.cd_kojo AS cd_kojo
		,taisho.cd_niuke_basho AS cd_niuke_basho
		,NULL AS dt_nonyu
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,0 AS su_nonyu_jitsu
		,taisho.cd_torihiki
		,'' AS cd_tani_nonyu
		,NULL AS kbn_nyuko
		,taisho.flg_kakutei
		,'' AS no_nohinsho
		,'' AS no_zeikan_shorui
	FROM (
		SELECT
			no_nonyu
			, cd_kojo
			, cd_niuke_basho
			, cd_hinmei
			, cd_torihiki
			, MAX(flg_kakutei) AS flg_kakutei
		FROM tr_sap_jisseki_nonyu_denso_taisho
		WHERE su_nonyu_jitsu <> 0
		GROUP BY no_nonyu, cd_kojo, cd_niuke_basho, cd_hinmei, cd_torihiki
		) taisho
	INNER JOIN tr_sap_jisseki_nonyu_denso denso
		ON taisho.no_nonyu = denso.no_nonyu
		AND denso.kbn_denso_SAP <> @kbnDelete
		AND denso.su_nonyu_jitsu <> 0 --フラグのみのデータか判定
	LEFT JOIN tr_sap_jisseki_nonyu_denso denso_flg
		ON taisho.no_nonyu = denso_flg.no_nonyu
		AND denso_flg.su_nonyu_jitsu = 0
	LEFT JOIN ma_hinmei mh
		ON taisho.cd_hinmei = mh.cd_hinmei
	WHERE mh.kbn_hin <> @kbnJikagen
		AND denso_flg.no_nonyu IS NULL

	--20200826削除(@kbnDelete)が伝送され、納入実績が残っているデータを確定データとして伝送すように修正		
	INSERT INTO tr_sap_jisseki_nonyu_denso (
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
		,no_nohinsho
		,no_zeikan_shorui
	)
	SELECT
		@kbnUpdate 
		,denso_kbn2.no_nonyu AS no_nonyu
		,'0' AS no_niuke
		,denso_kbn2.cd_kojo
		,denso_kbn2.cd_niuke_basho AS cd_niuke_basho
		,NULL AS dt_nonyu
		,UPPER(denso_kbn2.cd_hinmei) AS cd_hinmei
		,0 AS su_nonyu_jitsu
		,denso_kbn2.cd_torihiki
		,'' AS cd_tani_nonyu
		,NULL AS kbn_nyuko
		,denso_kbn2.flg_kakutei
		,'' AS no_nohinsho
		,'' AS no_zeikan_shorui
	FROM(	
		SELECT DISTINCT
			@kbnUpdate AS kbn_denso_SAP 
			,taisho.no_nonyu AS no_nonyu
			,'0' AS no_niuke
			,taisho.cd_kojo AS cd_kojo
			,taisho.cd_niuke_basho AS cd_niuke_basho
			,NULL AS dt_nonyu
			,UPPER(taisho.cd_hinmei) AS cd_hinmei
			,0 AS su_nonyu_jitsu
			,taisho.cd_torihiki
			,'' AS cd_tani_nonyu
			,NULL AS kbn_nyuko
			,taisho.flg_kakutei
			,'' AS no_nohinsho
			,'' AS no_zeikan_shorui
		FROM (
			SELECT
				no_nonyu
				, cd_kojo
				, cd_niuke_basho
				, cd_hinmei
				, cd_torihiki
				, MAX(flg_kakutei) AS flg_kakutei
			FROM tr_sap_jisseki_nonyu_denso_taisho
			WHERE su_nonyu_jitsu <> 0
			GROUP BY no_nonyu, cd_kojo, cd_niuke_basho, cd_hinmei, cd_torihiki
			) taisho
		INNER JOIN tr_sap_jisseki_nonyu_denso denso--削除区分が伝送されたレコードを結合
			ON taisho.no_nonyu = denso.no_nonyu
			AND denso.kbn_denso_SAP = @kbnDelete 
			AND denso.su_nonyu_jitsu <> 0 
	   )denso_kbn2
	   LEFT JOIN tr_sap_jisseki_nonyu_denso denso--1度確定データが伝送されているデータ以外が確定対象
		ON denso_kbn2.kbn_denso_SAP = denso.kbn_denso_SAP
		AND denso_kbn2.no_nonyu = denso.no_nonyu
	   WHERE denso.no_nonyu IS NULL

END
GO
