IF OBJECT_ID ('dbo.vw_ma_juryo_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_juryo_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_juryo_01]
AS
SELECT 
 juryo.kbn_jotai AS kbn_jotai
,juryo.kbn_hin AS kbn_hin
,kbn_hin.nm_kbn_hin AS nm_kbn_hin
,juryo.cd_hinmei AS cd_hinmei
,hin.nm_hinmei_ja AS nm_hinmei_ja
,hin.nm_hinmei_en AS nm_hinmei_en
,hin.nm_hinmei_zh AS nm_hinmei_zh
,hin.nm_hinmei_vi AS nm_hinmei_vi
,haigo.nm_haigo_ja AS nm_haigo_ja
,haigo.nm_haigo_en AS nm_haigo_en
,haigo.nm_haigo_zh AS nm_haigo_zh
,haigo.nm_haigo_vi AS nm_haigo_vi
,juryo.wt_kowake AS wt_kowake
,juryo.dt_create AS dt_create
,juryo.cd_create AS cd_create
,juryo.dt_update AS dt_update
,juryo.cd_update AS cd_update
,juryo.ts AS ts
FROM ma_juryo  juryo
LEFT JOIN ma_kbn_hin kbn_hin
ON juryo.kbn_hin = kbn_hin.kbn_hin
LEFT JOIN ma_hinmei hin
ON juryo.cd_hinmei = hin.cd_hinmei
LEFT JOIN ma_haigo_mei haigo
ON juryo.cd_hinmei = haigo.cd_haigo
AND haigo.no_han = 1
GO
