IF OBJECT_ID ('dbo.vw_ma_genka_center_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_genka_center_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 調整入力：明細/原価発生部署、ブランクなし
*/
CREATE VIEW [dbo].[vw_ma_genka_center_01]
AS
	--SELECT
	--	'' AS cd_genka_center
	--	,'' AS nm_genka_center
	--	,0 AS flg_mishiyo
	--UNION ALL
	SELECT
		cd_genka_center
		,nm_genka_center
		,flg_mishiyo
	FROM
		ma_genka_center
GO
