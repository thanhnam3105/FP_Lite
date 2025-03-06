IF OBJECT_ID ('dbo.vw_ma_konyu_02', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_konyu_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_konyu_02]
AS

select
	ko.cd_hinmei AS cd_hinmei
	,hin.nm_hinmei_ja AS nm_hinmei_ja
	,hin.nm_hinmei_en AS nm_hinmei_en
	,hin.nm_hinmei_zh AS nm_hinmei_zh
	,hin.nm_hinmei_vi AS nm_hinmei_vi
	,hin.kbn_hin AS kbn_hin
	,ko.no_juni_yusen AS no_juni_yusen
	,ko.cd_torihiki AS cd_torihiki
	,tori1.nm_torihiki AS nm_torihiki
	,ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
	,tani.nm_tani AS tani_nonyu
	,ko.cd_tani_nonyu AS cd_tani_nonyu
	,ko.tan_nonyu AS tan_nonyu
	,ko.tan_nonyu_new AS tan_nonyu_new
	,ko.dt_tanka_new AS dt_tanka_new
	,ko.su_hachu_lot_size AS su_hachu_lot_size
	,ko.wt_nonyu AS wt_nonyu
	,ko.su_iri AS su_iri
	,ko.su_leadtime AS su_leadtime
	,ko.cd_torihiki2 AS cd_torihiki2
	,tori2.nm_torihiki AS nm_torihiki2
	,ko.flg_mishiyo AS flg_mishiyo
	,ko.ts AS ts
	,tani_hasu.nm_tani AS tani_nonyu_hasu
	,ko.cd_tani_nonyu_hasu AS cd_tani_nonyu_hasu

FROM ma_konyu ko

LEFT JOIN ma_torihiki tori1
ON tori1.cd_torihiki = ko.cd_torihiki

LEFT JOIN ma_torihiki tori2
ON tori2.cd_torihiki = ko.cd_torihiki2

LEFT JOIN ma_tani tani
ON tani.cd_tani = ko.cd_tani_nonyu

LEFT JOIN ma_tani tani_hasu
ON tani_hasu.cd_tani = ko.cd_tani_nonyu_hasu

LEFT JOIN ma_hinmei hin
ON hin.cd_hinmei = ko.cd_hinmei
GO
