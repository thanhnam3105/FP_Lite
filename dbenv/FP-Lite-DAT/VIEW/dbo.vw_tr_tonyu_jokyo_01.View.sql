IF OBJECT_ID ('dbo.vw_tr_tonyu_jokyo_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_tonyu_jokyo_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_tonyu_jokyo_01]
AS
SELECT
	ISNULL(ttj.dt_seizo, '')					AS dt_seizo
	,ISNULL(ttj.no_kotei, 0)					AS no_kotei
	,ISNULL(ttj.cd_haigo, '')					AS cd_haigo
	,ISNULL(ttj.su_kai, '')						AS su_kai
	,ISNULL(ttj.su_kai_hasu, 0)					AS su_kai_hasu
	,ISNULL(ttj.su_yotei, 0)					AS su_yotei
	,ISNULL(ttj.su_yotei_hasu, 0)				AS su_yotei_hasu
	,ISNULL(ttj.no_tonyu, 0)					AS no_tonyu
	,ISNULL(ttj.no_lot_seihin, '')				AS no_lot_seihin
	,ISNULL(ttj.wt_haigo, 0)					AS wt_haigo
	,ISNULL(ttj.cd_line, '')					AS cd_line
	,ISNULL(ml.nm_line, '')						AS nm_line
	,ISNULL(ttj.cd_shokuba, '')					AS cd_shokuba
	,ISNULL(ttj.cd_panel, '')					AS cd_panel
	,ISNULL(ttj.kbn_seikihasu, '')				AS kbn_seikihasu
	,ISNULL(ttj.kbn_jokyo, '')					AS kbn_jokyo
	,ISNULL(ttj.flg_saikido, '')				AS flg_saikido
	,ISNULL(ttj.su_ko_niuke, '')				AS su_ko_niuke
	,ISNULL(ttj.su_ko, '')						AS su_ko
	,ISNULL(ttj.su_ko_hasu, '')					AS su_ko_hasu
	--,ISNULL(dbo.ma_haigo_mei.nm_haigo_ja, '')	AS nm_haigo_ja
	--,ISNULL(dbo.ma_haigo_mei.nm_haigo_en, '')	AS nm_haigo_en
	--,ISNULL(dbo.ma_haigo_mei.nm_haigo_zh, '')	AS nm_haigo_zh
	,ISNULL(haigo.nm_haigo_ja, '')				AS nm_haigo_ja
	,ISNULL(haigo.nm_haigo_en, '')				AS nm_haigo_en
	,ISNULL(haigo.nm_haigo_zh, '')				AS nm_haigo_zh
	,ISNULL(haigo.nm_haigo_vi, '')				AS nm_haigo_vi
	,ISNULL(ttj.flg_kanryo_tonyu, 0)			AS flg_kanryo_tonyu
FROM dbo.tr_tonyu_jokyo ttj 
LEFT OUTER JOIN dbo.ma_haigo_mei haigo
--ON ttj.cd_haigo = dbo.ma_haigo_mei.cd_haigo
ON ttj.cd_haigo = haigo.cd_haigo
AND haigo.no_han = (SELECT TOP 1 no_han FROM udf_HaigoRecipeYukoHan(ttj.cd_haigo, 0, ttj.dt_seizo)) 
LEFT OUTER JOIN dbo.ma_line ml 
ON ttj.cd_shokuba = ml.cd_shokuba 
AND ttj.cd_line = ml.cd_line
GO
