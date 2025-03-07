IF OBJECT_ID ('dbo.vw_ma_haigo_mei_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_haigo_mei_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
機能		：配合名マスタ用ビュー
ビュー名	：vw_ma_haigo_mei
入力引数	：
備考		：
作成日		：2013.09.09 okada.k
更新日		：
************************************************************/
CREATE VIEW [dbo].[vw_ma_haigo_mei_01] as
SELECT
	ISNULL(haigo.cd_haigo,'')			AS cd_haigo
	,haigo.nm_haigo_ja					AS nm_haigo_ja
	,haigo.nm_haigo_en					AS nm_haigo_en
	,haigo.nm_haigo_zh					AS nm_haigo_zh
	,haigo.nm_haigo_vi					AS nm_haigo_vi
	,haigo.nm_haigo_ryaku				AS nm_haigo_ryaku
	,haigo.ritsu_budomari				AS ritsu_budomari
	,ISNULL(haigo.wt_kihon,0)			AS wt_kihon
	,haigo.ritsu_kihon					AS ritsu_kihon
	,ISNULL(haigo.flg_gassan_shikomi,0)	AS flg_gassan_shikomi
	,haigo.wt_saidai_shikomi			AS wt_saidai_shikomi
	,ISNULL(haigo.no_han,0)				AS no_han
	,ISNULL(haigo.wt_haigo,0)			AS wt_haigo
	,haigo.wt_haigo_gokei				AS wt_haigo_gokei
	,haigo.biko							AS biko
	,haigo.no_seiho						AS no_seiho
	,ISNULL(haigo.cd_tanto_seizo,'')	AS cd_tanto_seizo
	,ISNULL(tanto_seizo.nm_tanto,'')	AS nm_tanto_seizo
	,haigo.dt_seizo_koshin				AS dt_seizo_koshin
	,ISNULL(haigo.cd_tanto_hinkan,'')	AS cd_tanto_hinkan
	,ISNULL(tanto_hinkan.nm_tanto,'')	AS nm_tanto_hinkan
	,haigo.dt_hinkan_koshin				AS dt_hinkan_koshin
	,haigo.dt_from						AS dt_from
	,ISNULL(haigo.kbn_kanzan,'0')		AS kbn_kanzan
	,ISNULL(tani.nm_tani,'')			AS nm_tani_shiyo
	,ISNULL(haigo.ritsu_hiju, 0)		AS ritsu_hiju
	,ISNULL(haigo.flg_shorihin,0)		AS flg_shorihin
	,ISNULL(haigo.flg_tanto_hinkan,0)	AS flg_tanto_hinkan
	,ISNULL(haigo.flg_tanto_seizo,0)	AS flg_tanto_seizo
	,ISNULL(haigo.kbn_shiagari,0)		AS kbn_shiagari
	,haigo.cd_bunrui					AS cd_bunrui
	,ISNULL(haigo.flg_mishiyo,0)		AS flg_mishiyo
	,haigo.wt_kowake					AS wt_kowake
	,haigo.su_kowake					AS su_kowake
	,haigo.ts							AS ts
	,ISNULL(bunrui.kbn_hin, 5)			AS kbn_hin
	,bunrui.nm_bunrui					AS nm_bunrui
	,ISNULL(haigo.cd_create,'')			AS cd_create
	,toroku.nm_tanto					AS nm_create
	,ISNULL(haigo.dt_create,'') AS dt_create
	,ISNULL(haigo.cd_update,'')			AS cd_update
	,koshin.nm_tanto					AS nm_update
	,ISNULL(haigo.dt_update,'') AS dt_update
	,ISNULL(haigo.flg_tenkai,0)			AS flg_tenkai
	,haigo.dd_shomi			AS dd_shomi
	,haigo.kbn_hokan			AS kbn_hokan
FROM dbo.ma_haigo_mei haigo

LEFT JOIN dbo.ma_tani tani
ON haigo.kbn_kanzan = tani.cd_tani

LEFT JOIN dbo.ma_tanto toroku
ON haigo.cd_create = toroku.cd_tanto
LEFT JOIN dbo.ma_tanto koshin
ON haigo.cd_update = koshin.cd_tanto
LEFT JOIN dbo.ma_tanto tanto_seizo
ON haigo.cd_tanto_seizo = tanto_seizo.cd_tanto
LEFT JOIN dbo.ma_tanto tanto_hinkan
ON haigo.cd_tanto_hinkan = tanto_hinkan.cd_tanto
LEFT JOIN dbo.ma_bunrui bunrui	
ON haigo.cd_bunrui = bunrui.cd_bunrui
GO
