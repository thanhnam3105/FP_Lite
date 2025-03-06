IF OBJECT_ID ('dbo.vw_tr_keikaku_seihin_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_keikaku_seihin_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_keikaku_seihin_01]
AS
	SELECT DISTINCT
		seihin.no_lot_seihin
		, seihin.dt_seizo
		, seihin.cd_shokuba
		, seihin.cd_line
		, seihin.cd_hinmei
		, seihin.su_seizo_yotei
		, COALESCE(seihin.su_seizo_jisseki, seihin.su_seizo_yotei) AS su_seizo_jisseki
		, seihin.flg_jisseki
		, seihin.kbn_denso
		, seihin.flg_denso
		, seihin.dt_update
		, hin.nm_hinmei_ja
		, hin.nm_hinmei_en
		, hin.nm_hinmei_zh
		, hin.nm_hinmei_vi
		, '' AS nm_hinmei
		, shoku.nm_shokuba
		, line.nm_line
		, hin.flg_mishiyo AS flg_mishiyo_hinmei
		, line.flg_mishiyo AS flg_mishiyo_line
		--, DATEADD(dd, hin.dd_shomi - 1, seihin.dt_seizo) AS dd_shomi_kigen
		, seihin.dt_shomi AS dt_shomi
		, seizoLine.flg_mishiyo AS flg_mishiyo_seizo_line
		, seizoLine.kbn_master
		, seihin.su_batch_jisseki
		, hin.wt_ko
		, hin.su_iri
		, hin.flg_mishiyo
		, hin.dd_shomi
		--, hin.cd_haigo
		 -- 倍率
		,CASE WHEN hin.cd_haigo IS NOT NULL
		 THEN (SELECT TOP 1 ritsu_kihon
		       FROM udf_HaigoRecipeYukoHan(hin.cd_haigo, hin.flg_mishiyo, seihin.dt_seizo))
		 ELSE NULL END AS ritsu_kihon
		 -- 合計配合重量
		,CASE WHEN hin.cd_haigo IS NOT NULL
		 THEN (SELECT TOP 1 wt_haigo_gokei
		       FROM udf_HaigoRecipeYukoHan(hin.cd_haigo, hin.flg_mishiyo, seihin.dt_seizo))
		 ELSE 0 END AS wt_haigo_gokei
		 -- 歩留
		,CASE WHEN hin.cd_haigo IS NOT NULL
		 THEN (SELECT TOP 1 ritsu_budomari_mei
		       FROM udf_HaigoRecipeYukoHan(hin.cd_haigo, hin.flg_mishiyo, seihin.dt_seizo))
		 ELSE NULL END AS haigo_budomari
		,seihin.no_lot_hyoji
		,CASE
			WHEN uchiwake.no_lot_seihin IS NOT NULL THEN '1'
			ELSE NULL
		END AS 'flg_uchiwake'

	FROM
		dbo.tr_keikaku_seihin AS seihin

	LEFT OUTER JOIN dbo.ma_hinmei AS hin
	ON seihin.cd_hinmei = hin.cd_hinmei

	LEFT OUTER JOIN dbo.ma_line AS line
	ON seihin.cd_line = line.cd_line

	LEFT OUTER JOIN dbo.ma_shokuba AS shoku
	ON seihin.cd_shokuba = shoku.cd_shokuba

	LEFT OUTER JOIN dbo.ma_seizo_line AS seizoLine
	ON seihin.cd_hinmei = seizoLine.cd_haigo
	AND line.cd_line = seizoLine.cd_line

	LEFT OUTER JOIN
	(
		-- 内訳の抽出
		SELECT
			shikakariZanMst.cd_seihin
			,anbun.no_lot_seihin
		FROM dbo.ma_shikakari_zan_shiyo shikakariZanMst

		LEFT OUTER JOIN dbo.ma_hinmei zanHin
		ON shikakariZanMst.cd_hinmei = zanHin.cd_hinmei

		LEFT OUTER JOIN dbo.su_keikaku_shikakari summary
		ON zanHin.cd_haigo = summary.cd_shikakari_hin

		INNER JOIN dbo.tr_sap_shiyo_yojitsu_anbun anbun
		ON summary.no_lot_shikakari = anbun.no_lot_shikakari
		AND anbun.kbn_shiyo_jisseki_anbun = '3'

	) uchiwake
	ON seihin.cd_hinmei = uchiwake.cd_seihin

GO
