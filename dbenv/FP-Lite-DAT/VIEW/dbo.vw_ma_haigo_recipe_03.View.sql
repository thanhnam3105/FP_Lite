IF OBJECT_ID ('dbo.vw_ma_haigo_recipe_03', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_haigo_recipe_03]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_haigo_recipe_03]
AS
SELECT                  TOP (100) PERCENT no_kotei
FROM                     dbo.ma_haigo_recipe
GROUP BY          no_kotei
ORDER BY          no_kotei asc
GO
