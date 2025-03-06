IF OBJECT_ID ('dbo.vw_niuke_HenpinNyuryoku', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_niuke_HenpinNyuryoku]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_niuke_HenpinNyuryoku]
AS
SELECT 
	niuke.cd_niuke_basho,
	niuke.nm_niuke,
	niuke.nm_jusho_1,
	niuke.nm_jusho_2,
	niuke.nm_jusho_3,
	niuke.flg_mishiyo,
	niuke.kbn_niuke_basho
FROM 
	ma_niuke							AS niuke

	INNER JOIN ma_kbn_niuke				AS kbn_niuke
	ON niuke.kbn_niuke_basho = kbn_niuke.kbn_niuke_basho
	AND kbn_niuke.flg_mishiyo = 0
	AND kbn_niuke.flg_henpin = 1 
WHERE 
	niuke.flg_mishiyo = 0


GO


