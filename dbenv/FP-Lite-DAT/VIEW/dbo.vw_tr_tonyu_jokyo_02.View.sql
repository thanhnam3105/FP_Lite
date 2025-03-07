IF OBJECT_ID ('dbo.vw_tr_tonyu_jokyo_02', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_tonyu_jokyo_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_tonyu_jokyo_02]
AS
SELECT
	ttj.dt_seizo
	,ttj.cd_panel
	,ttj.cd_shokuba
	,ttj.cd_line
	,ttj.kbn_jokyo
	,ttj.dt_yotei_seizo
	,ttj.no_kotei
	,ttj.cd_haigo
	,ttj.nm_haigo
	,ttj.su_kai
	,ttj.su_kai_hasu
	,ttj.su_yotei
	,ttj.su_yotei_hasu
	,ttj.su_ko_niuke
	,ttj.su_ko
	,ttj.su_ko_hasu
	,ttj.no_tonyu
	,ttj.no_lot
	,ttj.flg_fukusu
	,ttj.wt_haigo
	,ttj.no_lot_seihin
	,ttj.kbn_seikihasu
	,ttj.flg_saikido
	,ml.cd_line AS Expr1
	,ml.nm_line
	,ml.cd_shokuba AS Expr2
	,ml.flg_mishiyo
	,ml.dt_create
	,ml.cd_create
	,ml.dt_update
	,ml.cd_update
	,ml.ts
FROM dbo.tr_tonyu_jokyo ttj
LEFT OUTER JOIN dbo.ma_line ml
ON ml.cd_shokuba = ttj.cd_shokuba
AND ml.cd_line = ttj.cd_line
GO
