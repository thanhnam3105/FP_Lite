IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_soko_info]'))
DROP VIEW [dbo].[vw_soko_info]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_soko_info] as

SELECT
	mh.cd_hinmei
	,mh.kbn_hin
	,mh.nm_hinmei_ja
	,mh.nm_hinmei_en
	,mh.nm_hinmei_zh
	,mh.nm_hinmei_vi
	,mh.nm_hinmei_ryaku
	,mh.cd_niuke_basho
	,mks.cd_soko_kbn AS cd_soko
	,ms.nm_soko
FROM
	ma_hinmei mh
INNER JOIN 
	ma_kbn_soko mks
ON
	mks.kbn_hin = mh.kbn_hin
INNER JOIN
	ma_soko ms
ON
	ms.cd_soko = mks.cd_soko_kbn
WHERE
	mh.flg_mishiyo = 0
	AND ms.flg_mishiyo = 0

GO


