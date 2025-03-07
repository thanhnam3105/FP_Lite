IF OBJECT_ID ('dbo.vw_ma_hinmei_06', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_hinmei_06]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_hinmei_06] as

SELECT
		sa.cd_sagyo AS cd_hinmei
		,kbn.nm_kbn_hin AS nm_kbn_hin
		,sa.nm_sagyo AS nm_hinmei_ja
		,sa.nm_sagyo AS nm_hinmei_en
		,sa.nm_sagyo AS nm_hinmei_zh
		,sa.nm_sagyo AS nm_hinmei_vi
		,sa.mark AS nm_naiyo
		,kbn.kbn_hin AS kbn_hin
		,sa.flg_mishiyo AS flg_mishiyo
		,'' AS cd_bunrui
	FROM (
		select cd_sagyo,nm_sagyo,mark,flg_mishiyo
		from ma_sagyo
		left join ma_mark mm
		on ma_sagyo.cd_mark = mm.cd_mark
	) AS sa 
	,ma_kbn_hin kbn
GO
