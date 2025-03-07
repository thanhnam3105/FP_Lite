IF OBJECT_ID ('dbo.vw_ma_hinmei_05', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_hinmei_05]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_hinmei_05]
AS
SELECT
	hai.cd_haigo AS cd_hinmei
	,kbn.nm_kbn_hin AS nm_kbn_hin
	,hai.nm_haigo_ja AS nm_hinmei_ja
	,hai.nm_haigo_en AS nm_hinmei_en
	,hai.nm_haigo_zh AS nm_hinmei_zh
	,hai.nm_haigo_vi AS nm_hinmei_vi
	,CAST(hai.wt_kihon AS VARCHAR) AS nm_naiyo
	,kbn.kbn_hin AS kbn_hin
	,hai.flg_mishiyo AS flg_mishiyo
FROM (select * from ma_haigo_mei where no_han = 1) hai
,ma_kbn_hin kbn
GO
