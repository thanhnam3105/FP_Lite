IF OBJECT_ID ('dbo.vw_ma_kbn_hokan02', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_kbn_hokan02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_kbn_hokan02]
AS

SELECT
	mhm.cd_haigo
	,mkh.nm_hokan_kbn
	,mhm.no_han
FROM ma_haigo_mei mhm
INNER JOIN dbo.ma_kbn_hokan mkh
ON mhm.kbn_hokan = mkh.cd_hokan_kbn
GO
