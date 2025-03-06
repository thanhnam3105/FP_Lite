IF OBJECT_ID ('dbo.vw_ma_sap_bom_denso_pool', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_sap_bom_denso_pool]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_sap_bom_denso_pool]
AS

    WITH cte_pool AS
    (
		SELECT
			pl.dt_denso
			,pl.kbn_denso_SAP
			,pl.cd_seihin
			,COALESCE(seihin.nm_hinmei_ja, '') AS nm_seihin_ja
			,COALESCE(seihin.nm_hinmei_en, '') AS nm_seihin_en
			,COALESCE(seihin.nm_hinmei_zh, '') AS nm_seihin_zh
			,COALESCE(seihin.nm_hinmei_vi, '') AS nm_seihin_vi
			,CONVERT(datetime, CONVERT(varchar, pl.dt_from) + ' 10:00:00', 112) dt_from
			,pl.su_kihon
			,pl.cd_hinmei
			,COALESCE(hin.nm_hinmei_ja, '') AS nm_hinmei_ja
			,COALESCE(hin.nm_hinmei_en, '') AS nm_hinmei_en
			,COALESCE(hin.nm_hinmei_zh, '') AS nm_hinmei_zh
			,COALESCE(hin.nm_hinmei_vi, '') AS nm_hinmei_vi
			,pl.su_hinmoku AS su_hinmoku
			,pl.cd_tani
			,mt.nm_tani
			,pl.su_kaiso
			,pl.cd_haigo
			,pl.no_kotei
			,pl.no_tonyu
		FROM ma_sap_bom_denso_pool pl
		LEFT JOIN ma_hinmei seihin
			ON seihin.cd_hinmei = pl.cd_seihin
		LEFT JOIN ma_hinmei hin
			ON hin.cd_hinmei = pl.cd_hinmei
		LEFT JOIN ma_sap_tani_henkan msth
			ON pl.cd_tani = msth.cd_tani_henkan
		LEFT JOIN ma_tani mt
			ON msth.cd_tani = mt.cd_tani
	)
	SELECT
		cte.dt_denso
		,cte.kbn_denso_SAP
		,cte.cd_seihin
		,cte.nm_seihin_ja
		,cte.nm_seihin_en
		,cte.nm_seihin_zh
		,cte.nm_seihin_vi
		,cte.dt_from
		,cte.su_kihon
		,cte.cd_hinmei
		,cte.nm_hinmei_ja
		,cte.nm_hinmei_en
		,cte.nm_hinmei_zh
		,cte.nm_hinmei_vi
		,cte.su_hinmoku
		,cte.cd_tani
		,cte.nm_tani
		,cte.su_kaiso
		,cte.cd_haigo
		,COALESCE(haigo.nm_haigo_ja, yuko_haigo.nm_haigo_ja, '') AS nm_haigo_ja
		,COALESCE(haigo.nm_haigo_en, yuko_haigo.nm_haigo_en, '') AS nm_haigo_en
		,COALESCE(haigo.nm_haigo_zh, yuko_haigo.nm_haigo_zh, '') AS nm_haigo_zh
		,COALESCE(haigo.nm_haigo_vi, yuko_haigo.nm_haigo_vi, '') AS nm_haigo_vi
		,cte.no_kotei
		,cte.no_tonyu
	FROM
		cte_pool cte
	LEFT JOIN ma_haigo_mei haigo
		ON cte.cd_haigo = haigo.cd_haigo
		AND cte.dt_from = haigo.dt_from
	-- 有効開始日で取得できなかったとき用
	LEFT JOIN (
		SELECT
			cd_haigo
			,MAX(no_han) AS no_han
		FROM ma_haigo_mei
		GROUP BY cd_haigo
	) yuko
		ON cte.cd_haigo = yuko.cd_haigo
	LEFT JOIN (
		SELECT
			cd_haigo
			,no_han
			,nm_haigo_ja
			,nm_haigo_en
			,nm_haigo_zh
			,nm_haigo_vi
		FROM ma_haigo_mei
	) yuko_haigo
	ON yuko_haigo.cd_haigo = yuko.cd_haigo
	AND yuko_haigo.no_han = yuko.no_han
GO
