IF OBJECT_ID ('dbo.vw_ma_haigo_mei_02', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_haigo_mei_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_haigo_mei_02]
AS
SELECT            
	yuko.cd_haigo
	, hai.nm_haigo_ja
	, hai.nm_haigo_en
	, hai.nm_haigo_zh
	, hai.nm_haigo_vi
	, hai.no_han
	, hai.dt_from
	, hai.flg_mishiyo
FROM              
	(
		SELECT
			cd_haigo
			, MAX(dt_from) AS dt_from
        FROM	dbo.ma_haigo_mei
        GROUP BY	cd_haigo
    ) AS yuko
RIGHT OUTER JOIN dbo.ma_haigo_mei AS hai 
ON yuko.cd_haigo = hai.cd_haigo 
AND yuko.dt_from = hai.dt_from
GO
