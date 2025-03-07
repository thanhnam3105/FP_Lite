IF OBJECT_ID ('dbo.vw_ma_hinmei_09', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_hinmei_09]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_hinmei_09] as

SELECT
	 hin.cd_hinmei AS cd_hinmei
	 ,konyu.cd_torihiki AS cd_torihiki
	 ,hin.cd_niuke_basho AS cd_niuke_basho
	 ,hin.nm_hinmei_ja AS nm_hinmei_ja
	 ,hin.nm_hinmei_en AS nm_hinmei_en
	 ,hin.nm_hinmei_zh AS nm_hinmei_zh
	 ,hin.nm_hinmei_vi AS nm_hinmei_vi
	 ,bunrui.cd_bunrui AS cd_bunrui
	 ,bunrui.nm_bunrui AS nm_bunrui
	 ,tan_nonyu.nm_tani AS nonyu_tani
	 ,tan_shiyo.nm_tani AS shiyo_tani
	 ,konyu.nm_nisugata_hyoji AS nm_nisugata_hyoji
FROM
	ma_hinmei hin

LEFT JOIN ma_bunrui bunrui
ON bunrui.cd_bunrui = hin.cd_bunrui
AND bunrui.kbn_hin = hin.kbn_hin

LEFT JOIN (
	SELECT cd_hinmei
		,MIN(no_juni_yusen) AS no_juni_yusen
	FROM ma_konyu ma
	GROUP BY cd_hinmei
) yusen
ON yusen.cd_hinmei = hin.cd_hinmei

LEFT JOIN ma_konyu konyu
ON konyu.cd_hinmei = yusen.cd_hinmei
AND konyu.no_juni_yusen = yusen.no_juni_yusen

LEFT JOIN ma_tani tan_nonyu
ON tan_nonyu.cd_tani = konyu.cd_tani_nonyu

LEFT JOIN ma_tani tan_shiyo
ON tan_shiyo.cd_tani = hin.cd_tani_shiyo
GO
