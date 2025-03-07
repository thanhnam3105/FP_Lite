IF OBJECT_ID ('dbo.vw_ma_futai_kettei_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_futai_kettei_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_futai_kettei_01] as

SELECT
	ma_futai_kettei.kbn_jotai
	, ma_futai_kettei.cd_hinmei as cd_hinmei
	, ma_futai_kettei.cd_futai
	, ma_futai_kettei.wt_kowake
	, ma_futai_kettei.cd_tani
	, ma_futai_kettei.flg_mishiyo
	, ma_futai_kettei.dt_create
	, ma_futai_kettei.cd_create
	, ma_futai_kettei.dt_update
	, ma_futai_kettei.cd_update
	, ma_futai_kettei.ts
	, ma_tani.nm_tani
	, ma_futai.nm_futai
FROM
ma_futai_kettei
LEFT OUTER JOIN ma_hinmei
ON ma_futai_kettei.cd_hinmei = ma_hinmei.cd_hinmei
LEFT OUTER JOIN ma_futai
ON ma_futai_kettei.cd_futai = ma_futai.cd_futai
LEFT OUTER JOIN ma_tani
ON ma_futai_kettei.cd_tani = ma_tani.cd_tani
GO
