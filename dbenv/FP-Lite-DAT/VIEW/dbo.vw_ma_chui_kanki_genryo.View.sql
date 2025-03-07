IF OBJECT_ID ('dbo.vw_ma_chui_kanki_genryo', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_chui_kanki_genryo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_chui_kanki_genryo]
AS

SELECT 
	mckg.cd_chui_kanki
	,mck.nm_chui_kanki
	,mckg.no_juni_yusen
	,mckg.flg_chui_kanki_hyoji
	,mckg.flg_mishiyo
	,mckg.ts
	,mckg.kbn_chui_kanki
	,mckg.cd_hinmei
	,mckg.kbn_hin
FROM ma_chui_kanki_genryo mckg
LEFT OUTER JOIN ma_chui_kanki mck
ON mckg.kbn_chui_kanki = mck.kbn_chui_kanki
AND mckg.cd_chui_kanki = mck.cd_chui_kanki
GO
