IF OBJECT_ID ('dbo.vw_ma_kbn_hokan01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_kbn_hokan01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_kbn_hokan01]
AS

SELECT
	dbo.ma_hinmei.cd_hinmei
	,dbo.ma_kbn_hokan.nm_hokan_kbn
FROM dbo.ma_hinmei
INNER JOIN dbo.ma_kbn_hokan
ON dbo.ma_hinmei.kbn_kaifugo_hokan = dbo.ma_kbn_hokan.cd_hokan_kbn
GO
