IF OBJECT_ID ('dbo.vw_su_keikaku_shikakari_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_su_keikaku_shikakari_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_su_keikaku_shikakari_01]
AS
SELECT
	ISNULL(sks.cd_shikakari_hin, '') AS cd_shikakari_hin
	,ISNULL(mh.nm_hinmei_ja, '') AS nm_hinmei_ja
	,ISNULL(mh.nm_hinmei_en, '') AS nm_hinmei_en
	,ISNULL(mh.nm_hinmei_zh, '') AS nm_hinmei_zh
	,ISNULL(mh.nm_hinmei_vi, '') AS nm_hinmei_vi
	,ISNULL(mkh.nm_hokan_kbn, '') AS nm_hokan_kbn
	,ISNULL(mh.dd_kaifugo_shomi, 0) AS dd_kaifugo_shomi
	,ISNULL(mh.dd_shomi, 0) AS dd_shomi
	,ISNULL(sks.no_lot_shikakari, '') AS no_lot_shikakari
	,ISNULL(mh.kbn_hin, 0) AS kbn_hin
	,ISNULL(mh.flg_mishiyo, '') AS flg_mishiyo
FROM dbo.su_keikaku_shikakari sks
LEFT OUTER JOIN dbo.ma_hinmei mh
ON mh.cd_hinmei = sks.cd_shikakari_hin
LEFT OUTER JOIN dbo.ma_kbn_hokan mkh
ON mkh.cd_hokan_kbn = mh.kbn_hokan
GO
