IF OBJECT_ID ('dbo.vw_ma_haigo_shikakari_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_haigo_shikakari_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
機能		：配合レシピ画面用配合・仕掛品用ビュー
ビュー名	：vw_ma_haigo_shikakari
入力引数	：
備考		：
作成日		：2013.07.01 okada.k
更新日		：
************************************************************/
CREATE VIEW [dbo].[vw_ma_haigo_shikakari_01] as
SELECT
	cd_haigo AS cd_hinmei
	,nm_haigo_ja AS nm_hinmei_ja
	,nm_haigo_en AS nm_hinmei_en
	,nm_haigo_zh AS nm_hinmei_zh
	,nm_haigo_vi AS nm_hinmei_vi
	,no_han AS no_han
	,flg_mishiyo AS flg_mishiyo
FROM dbo.ma_haigo_mei
GO
