IF OBJECT_ID ('dbo.vw_ma_haigo_recipe_04', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_haigo_recipe_04]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 原料残秤量(計画変更)
 イベント要件 2-1 配合レシピマスタ.マークコードを取得するためのもの*/
CREATE VIEW [dbo].[vw_ma_haigo_recipe_04]
AS

SELECT
	tRcp.cd_mark
	,tRcp.cd_haigo
	,tRcp.no_kotei
	,tRcp.kbn_hin
	,tRcp.cd_hinmei
	,tRcp.no_tonyu
	,tMk.mark
	,tNm.dt_from
	,tNm.flg_mishiyo AS mei_flg_mishiyo
FROM dbo.ma_haigo_recipe tRcp 
INNER JOIN dbo.ma_mark tMk 
ON tRcp.cd_mark = tMk.cd_mark 
INNER JOIN dbo.ma_haigo_mei tNm 
ON tRcp.cd_haigo = tNm.cd_haigo 
AND tRcp.no_han = tNm.no_han 
AND tRcp.wt_haigo = tNm.wt_haigo
GO
