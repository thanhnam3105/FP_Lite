IF OBJECT_ID ('dbo.vw_ma_haigo_recipe_02', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_haigo_recipe_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_haigo_recipe_02] as
SELECT
	cd_haigo
	,no_han
FROM dbo.ma_haigo_recipe
GROUP BY
	cd_haigo
	,no_han
GO
