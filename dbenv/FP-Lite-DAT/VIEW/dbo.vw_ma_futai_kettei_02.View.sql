IF OBJECT_ID ('dbo.vw_ma_futai_kettei_02', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_futai_kettei_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_futai_kettei_02]
AS
SELECT
    mf.cd_hinmei,
    mkh.nm_kbn_hin,
    mh.nm_hinmei_ja AS nm_hinmei_ja,
    mh.nm_hinmei_en AS nm_hinmei_en,
    mh.nm_hinmei_zh AS nm_hinmei_zh,
	mh.nm_hinmei_vi AS nm_hinmei_vi,
    mh.nm_nisugata_hyoji AS nm_nisugata,
    mf.kbn_jotai,
    mf.flg_mishiyo,
    mh.kbn_hin
FROM
dbo.ma_futai_kettei mf
INNER JOIN dbo.ma_hinmei mh
ON mf.cd_hinmei = mh.cd_hinmei
INNER JOIN dbo.ma_kbn_hin mkh
ON mh.kbn_hin = mkh.kbn_hin

UNION

SELECT
    mf.cd_hinmei,
    mkh.nm_kbn_hin,
    mh.nm_haigo_ja AS nm_hinmei_ja,
    mh.nm_haigo_en AS nm_hinmei_en,
    mh.nm_haigo_zh AS nm_hinmei_zh,
	mh.nm_haigo_vi AS nm_hinmei_vi,
    CAST(mh.wt_kihon AS VARCHAR) AS nm_nisugata,
    mf.kbn_jotai,
    mf.flg_mishiyo,
    mf.kbn_hin
FROM
dbo.ma_futai_kettei mf
INNER JOIN dbo.ma_haigo_mei mh
ON mf.cd_hinmei = mh.cd_haigo
INNER JOIN dbo.ma_kbn_hin mkh
ON mf.kbn_hin = mkh.kbn_hin
GO
