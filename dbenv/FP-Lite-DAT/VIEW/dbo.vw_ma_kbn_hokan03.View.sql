IF OBJECT_ID ('dbo.vw_ma_kbn_hokan03', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_kbn_hokan03]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_kbn_hokan03]
AS

SELECT
	dbo.ma_hinmei.cd_hinmei
	,hokan1.nm_hokan_kbn
FROM dbo.ma_hinmei
INNER JOIN dbo.ma_kbn_hokan AS hokan1
	ON dbo.ma_hinmei.kbn_hokan = hokan1.cd_hokan_kbn
GO
