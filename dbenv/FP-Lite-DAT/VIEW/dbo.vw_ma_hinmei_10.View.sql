IF OBJECT_ID ('dbo.vw_ma_hinmei_10', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_hinmei_10]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_hinmei_10] as

SELECT
	hin.cd_hinmei AS cd_hinmei
	,hin.nm_hinmei_ja AS nm_hinmei_ja
	,hin.nm_hinmei_en AS nm_hinmei_en
	,hin.nm_hinmei_zh AS nm_hinmei_zh
	,hin.nm_hinmei_vi AS nm_hinmei_vi
	,hin.nm_nisugata_hyoji AS nm_nisugata_hyoji
	,hin.cd_tani_nonyu AS cd_tani_nonyu
	,hin.flg_mishiyo AS flg_mishiyo_hin
	,COALESCE(hin.tan_nonyu, 0) AS tan_nonyu
	,COALESCE(hin.su_iri, 0) AS su_iri
	,COALESCE(hin.wt_ko, 0) AS wt_ko
	,COALESCE(hin.tan_ko, 0) AS tan_ko
	,COALESCE(hin.su_hachu_lot_size, 0) AS su_hachu_lot_size
	,COALESCE(hin.dd_leadtime, 0) AS dd_leadtime
	,tani.nm_tani AS nm_tani
	,tani.cd_tani AS cd_tani
	,tani.flg_mishiyo AS flg_mishiyo_tani
	,tani_hasu.cd_tani AS cd_tani_hasu
	,tani_hasu.nm_tani AS nm_tani_hasu
FROM
	ma_hinmei hin

LEFT OUTER JOIN ma_tani tani
ON tani.cd_tani = hin.cd_tani_nonyu
AND tani.flg_mishiyo = hin.flg_mishiyo
LEFT OUTER JOIN ma_tani tani_hasu
ON tani_hasu.cd_tani = hin.cd_tani_nonyu_hasu
AND tani_hasu.flg_mishiyo = hin.flg_mishiyo
GO
