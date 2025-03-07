IF OBJECT_ID ('dbo.vw_ma_hinmei_03', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_hinmei_03]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_hinmei_03]
AS
SELECT
	hin.cd_hinmei AS cd_hinmei
	,kbn.nm_kbn_hin AS nm_kbn_hin
	,hin.nm_hinmei_ja AS nm_hinmei_ja
	,hin.nm_hinmei_en AS nm_hinmei_en
	,hin.nm_hinmei_zh AS nm_hinmei_zh
	,hin.nm_hinmei_vi AS nm_hinmei_vi
	,hin.nm_nisugata_hyoji AS nm_naiyo
	,hin.kbn_hin AS kbn_hin
	,hin.flg_mishiyo AS flg_mishiyo
	,hin.cd_niuke_basho AS cd_niuke_basho
	,hin.cd_bunrui AS cd_bunrui
FROM ma_hinmei hin
LEFT OUTER JOIN ma_kbn_hin kbn
ON hin.kbn_hin = kbn.kbn_hin
GO
