IF OBJECT_ID ('dbo.vw_ma_sagyo_mark_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_sagyo_mark_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
機能		：配合レシピ画面用作業指示・マークビュー
ビュー名	：vw_ma_sagyo_mark_01
入力引数	：
備考		：
作成日		：2013.07.01 okada.k
更新日		：
************************************************************/
CREATE VIEW [dbo].[vw_ma_sagyo_mark_01] as
SELECT
	sagyo.cd_sagyo AS cd_hinmei
	,sagyo.nm_sagyo AS nm_hinmei_ja
	,sagyo.nm_sagyo AS nm_hinmei_en
	,sagyo.nm_sagyo AS nm_hinmei_zh
	,sagyo.nm_sagyo AS nm_hinmei_vi
	,sagyo.cd_mark AS cd_mark
	,mark.nm_mark AS nm_mark
	,mark.mark AS mark
	,sagyo.flg_mishiyo AS flg_mishiyo
FROM dbo.ma_sagyo sagyo
INNER JOIN dbo.ma_mark mark
ON sagyo.cd_mark = mark.cd_mark
GO
