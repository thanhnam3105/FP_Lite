IF OBJECT_ID ('dbo.vw_ma_haigo_recipe_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_haigo_recipe_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能  ：配合レシピ登録画面の検索結果データを返す
作成日  ：
更新日  ：2017.03.07 matsumura.y マークL対応 取得項目にPLC項目番号を追加
 *****************************************************/
CREATE VIEW [dbo].[vw_ma_haigo_recipe_01] as
SELECT
	recipe.no_seq AS no_seq
	,recipe.cd_haigo AS cd_haigo
	,mei.nm_haigo_ryaku AS nm_haigo_ryaku
	,recipe.no_han AS no_han
	,ISNULL(shikakari.no_han,1) AS no_han_shikakari
	,recipe.no_kotei AS no_kotei
	,recipe.wt_haigo AS wt_haigo
	,mei.flg_mishiyo AS flg_mishiyo
	,mei.no_seiho AS no_seiho
	,mei.biko AS biko
	,mei.dt_from AS dt_from
	,recipe.cd_hinmei AS cd_hinmei
	,recipe.nm_hinmei AS nm_hinmei
	,recipe.no_tonyu AS no_tonyu
	,recipe.kbn_hin AS kbn_hin
	,recipe.cd_mark AS cd_mark
	,mark.mark AS mark
	,mark.nm_mark AS nm_mark
	,recipe.wt_shikomi AS wt_shikomi
	,recipe.no_plc_komoku AS no_plc_komoku
	--,CASE
	--	--WHEN hinmei.cd_tani_shiyo is not null THEN hinmei.cd_tani_shiyo
	--	WHEN hinmei.kbn_kanzan is not null THEN hinmei.kbn_kanzan
	--	ELSE shikakari.kbn_kanzan
	--END AS cd_tani_shiyo
	,COALESCE(hinmei.kbn_kanzan, shikakari.kbn_kanzan) AS cd_tani_shiyo
	--,CASE 
	--	WHEN tani.nm_tani is not null THEN tani.nm_tani
	--	ELSE haigoTani.nm_tani
	--END	AS nm_tani_shiyo
	,COALESCE(tani.nm_tani, haigoTani.nm_tani) AS nm_tani_shiyo
	,recipe.wt_nisugata AS wt_nisugata
	,recipe.su_nisugata AS su_nisugata
	,recipe.wt_kowake AS wt_kowake
	,recipe.su_kowake AS su_kowake
	,ISNULL(recipe.flg_kowake_systemgai, 0) AS flg_kowake_systemgai
	,recipe.ritsu_budomari AS ritsu_budomari
	,recipe.ritsu_hiju AS ritsu_hiju
	,recipe.su_settei AS su_settei
	,recipe.su_settei_max AS su_settei_max
	,recipe.su_settei_min AS su_settei_min
	,recipe.cd_futai AS cd_futai
	,futai.nm_futai AS nm_futai
	,recipe.dt_create AS dt_create
	,recipe.cd_create AS cd_create
	,recipe.dt_update AS dt_update
	,recipe.cd_update AS cd_update
	,recipe.ts AS ts
FROM dbo.ma_haigo_recipe recipe

INNER JOIN dbo.ma_haigo_mei mei
ON recipe.cd_haigo = mei.cd_haigo
AND recipe.no_han = mei.no_han

LEFT JOIN 
	(
		SELECT
			cd_haigo 
			,no_han
			,kbn_kanzan
		FROM dbo.ma_haigo_mei
	) shikakari
ON recipe.cd_hinmei = shikakari.cd_haigo

LEFT JOIN dbo.ma_hinmei hinmei
ON recipe.cd_hinmei = hinmei.cd_hinmei
AND recipe.kbn_hin = hinmei.kbn_hin

LEFT JOIN dbo.ma_mark mark
ON recipe.cd_mark = mark.cd_mark

LEFT JOIN ma_tanto seizo
ON mei.cd_tanto_seizo = seizo.cd_tanto

LEFT JOIN ma_tanto hinkan
ON mei.cd_tanto_hinkan = hinkan.cd_tanto

LEFT JOIN ma_tani tani
--ON hinmei.cd_tani_shiyo = tani.cd_tani
ON hinmei.kbn_kanzan = tani.cd_tani

LEFT JOIN ma_tani haigoTani
ON shikakari.kbn_kanzan = haigoTani.cd_tani

LEFT JOIN ma_futai futai
ON recipe.cd_futai = futai.cd_futai
GO
