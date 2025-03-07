IF OBJECT_ID ('dbo.vw_ma_hinmei_02', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_hinmei_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_hinmei_02] as

SELECT
	hin.cd_hinmei AS cd_hinmei
	,kbn.kbn_hin AS kbn_hin
	,kbn.nm_kbn_hin AS nm_kbn_hin
	,hin.nm_hinmei_ja AS nm_hinmei_ja
	,hin.nm_hinmei_en AS nm_hinmei_en
	,hin.nm_hinmei_zh AS nm_hinmei_zh
	,hin.nm_hinmei_vi AS nm_hinmei_vi
	,hin.nm_nisugata_hyoji AS nm_nisugata
	,ISNULL(hin.ritsu_hiju, 0) AS ritsu_hiju
	,hin.ritsu_budomari AS ritsu_budomari
	,tani.nm_tani AS nm_tani
	,tani.cd_tani AS cd_tani
	,hin.flg_mishiyo AS flg_mishiyo_hin
	,tani.flg_mishiyo AS flg_mishiyo_tani
FROM ma_hinmei hin

-- 品区分マスタ
LEFT OUTER JOIN ma_kbn_hin kbn
ON hin.kbn_hin = kbn.kbn_hin

-- 単位マスタ：換算区分で結合
LEFT OUTER JOIN ma_tani tani
ON tani.cd_tani = hin.kbn_kanzan
GO
