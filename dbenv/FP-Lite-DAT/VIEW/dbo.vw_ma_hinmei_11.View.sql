IF OBJECT_ID ('dbo.vw_ma_hinmei_11', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_hinmei_11]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_hinmei_11] as

SELECT
	hin.nm_hinmei_ja
	,hin.nm_hinmei_en
	,hin.nm_hinmei_zh
	,hin.nm_hinmei_vi
	,hin.cd_haigo
	,hin.flg_mishiyo
	,kbnhin.kbn_hin
	,hin.cd_hinmei
	,hin.dd_shomi
	,kbnhin.nm_kbn_hin
FROM dbo.ma_hinmei hin 
LEFT OUTER JOIN dbo.ma_kbn_hin kbnhin
ON hin.kbn_hin = kbnhin.kbn_hin
GO
