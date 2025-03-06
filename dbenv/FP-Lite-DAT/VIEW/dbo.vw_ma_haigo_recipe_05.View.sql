IF OBJECT_ID ('dbo.vw_ma_haigo_recipe_05', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_haigo_recipe_05]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_haigo_recipe_05]
AS
SELECT
	mhr.no_seq
	,mhr.cd_haigo
	,mhr.no_han
	,mhr.wt_haigo
	,mhr.no_kotei
	,mhr.no_tonyu
	,mhr.kbn_hin
	,mhr.cd_hinmei
	,mhr.nm_hinmei
	,mhr.cd_mark
	,mhr.wt_kihon
	,mhr.wt_shikomi
	,mhr.wt_nisugata
	,mhr.su_nisugata
	,mhr.wt_kowake
	,mhr.su_kowake
	,mhr.cd_futai
	,mhr.ritsu_hiju
	,mhr.ritsu_budomari
	,mhr.dt_create
	,mhr.cd_create
	,mhr.dt_update
	,mhr.cd_update
	,mhr.su_settei
	,mhr.su_settei_max
	,mhr.su_settei_min
	,mhr.ts
	,mm.cd_mark AS Expr1
	,mm.nm_mark
	,mm.mark
	,mm.kbn_shubetsu
	,mm.cd_tani_shiyo
	,mm.flg_label
	,mm.flg_lot
	,mm.kbn_nyuryoku_haigojyuryo
	,mm.kbn_nyuryoku_nisugatajyuryo
	,mm.kbn_nyuryoku_nisugatasu
	,mm.kbn_nyuryoku_kowakejyuryo
	,mm.kbn_nyuryoku_kowakesu
	,mm.kbn_nyuryoku_hiju
	,mm.kbn_nyuryoku_budomari
	,mm.kbn_nyuryoku_futai
	,mm.dt_update AS Expr2
	,mm.ts AS Expr3
	,mhm.cd_haigo AS Expr4
	,mhm.nm_haigo_ja
	,mhm.nm_haigo_en
	,mhm.nm_haigo_zh
	,mhm.nm_haigo_vi
	,mhm.nm_haigo_ryaku
	,mhm.ritsu_budomari AS Expr5
	,mhm.wt_kihon AS Expr6
	,mhm.ritsu_kihon
	,mhm.flg_gassan_shikomi
	,mhm.wt_saidai_shikomi
	,mhm.no_han AS Expr7
	,mhm.wt_haigo AS Expr8
	,mhm.wt_haigo_gokei
	,mhm.biko
	,mhm.no_seiho
	,mhm.cd_tanto_seizo
	,mhm.dt_seizo_koshin
	,mhm.cd_tanto_hinkan
	,mhm.dt_hinkan_koshin
	,mhm.dt_from
	,mhm.kbn_kanzan
	,mhm.ritsu_hiju AS Expr9
	,mhm.flg_shorihin
	,mhm.flg_tanto_hinkan
	,mhm.flg_tanto_seizo
	,mhm.kbn_shiagari
	,mhm.cd_bunrui
	,mhm.flg_mishiyo
	,mhm.dt_create AS Expr10
	,mhm.cd_create AS Expr11
	,mhm.dt_update AS Expr12
	,mhm.cd_update AS Expr13
	,mhm.wt_kowake AS Expr14
	,mhm.su_kowake AS Expr15
	,mhm.ts AS Expr16
	,mhm.flg_tenkai
	,mhr.flg_kowake_systemgai
FROM dbo.ma_haigo_recipe mhr
INNER JOIN dbo.ma_mark mm
ON mm.cd_mark = mhr.cd_mark
INNER JOIN dbo.ma_haigo_mei mhm
ON mhm.cd_haigo = mhr.cd_haigo
AND mhm.no_han = mhr.no_han
AND mhm.wt_haigo = mhr.wt_haigo



GO
