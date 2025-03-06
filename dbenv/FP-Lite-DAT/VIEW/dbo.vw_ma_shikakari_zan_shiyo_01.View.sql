IF OBJECT_ID ('dbo.vw_ma_shikakari_zan_shiyo_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_shikakari_zan_shiyo_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_shikakari_zan_shiyo_01] AS

SELECT
	shikakarizan.cd_hinmei
	,shikakarizan.no_juni_hyoji
	,shikakarizan.cd_seihin
	,shikakarizan.flg_mishiyo AS flg_mishiyo_shikakarizan
	,shikakarizan.cd_create
	,shikakarizan.dt_create
	,shikakarizan.cd_update
	,shikakarizan.dt_update
	,shikakarizan.ts
	,hinmei.nm_hinmei_ja
	,hinmei.nm_hinmei_en
	,hinmei.nm_hinmei_zh
	,hinmei.nm_hinmei_vi
	,hinmei.nm_hinmei_ryaku
	,hinmei.nm_nisugata_hyoji
	,hinmei.flg_mishiyo AS flg_mishiyo_hinmei
FROM ma_shikakari_zan_shiyo shikakarizan
LEFT OUTER JOIN ma_hinmei hinmei
ON shikakarizan.cd_seihin = hinmei.cd_hinmei







GO
