IF OBJECT_ID ('dbo.vw_ma_panel_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_panel_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_panel_01]
AS
SELECT
	mp.cd_panel
	, mp.cd_shokuba
	, ms.nm_shokuba
	, mp.cd_hakari_1
	, mh1.nm_hakari AS nm_hakari_1
	, mp.no_hakari_com_1
	, mp.cd_hakari_2
	, mh2.nm_hakari AS nm_hakari_2
	, mp.no_hakari_com_2
	, mp.su_hakari
	, mp.wt_kirikae_hakari
	, tani.nm_tani
	, mp.no_com_reader
	, mp.flg_mishiyo
	, mp.dt_create
	, mp.dt_update
	, mp.ts
FROM
	dbo.ma_panel AS mp
LEFT OUTER JOIN dbo.ma_hakari AS mh1
ON mh1.cd_hakari = mp.cd_hakari_1
AND mh1.flg_mishiyo = 0

LEFT OUTER JOIN dbo.ma_hakari AS mh2
ON mh2.cd_hakari = mp.cd_hakari_2
AND mh2.flg_mishiyo = 0

LEFT OUTER JOIN dbo.ma_shokuba AS ms
ON ms.cd_shokuba = mp.cd_shokuba
AND ms.flg_mishiyo = 0

LEFT OUTER JOIN dbo.ma_tani AS tani
ON mh1.cd_tani = tani.cd_tani
AND tani.flg_mishiyo = 0
GO
