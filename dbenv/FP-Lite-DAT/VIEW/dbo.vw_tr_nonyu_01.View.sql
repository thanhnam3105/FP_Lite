IF OBJECT_ID ('dbo.vw_tr_nonyu_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_nonyu_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_nonyu_01] as

SELECT
 tr.flg_yojitsu AS flg_yojitsu
 ,tr.no_nonyu AS no_nonyu
 ,tr.cd_hinmei AS cd_hinmei
 ,ma_hin.nm_hinmei_ja AS nm_hinmei_ja
 ,ma_hin.nm_hinmei_en AS nm_hinmei_en
 ,ma_hin.nm_hinmei_zh AS nm_hinmei_zh
 ,ma_hin.nm_hinmei_vi AS nm_hinmei_vi
 ,ma_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
 ,ma_tan.nm_tani AS nm_tani
 ,ma_bun.nm_bunrui AS nm_bunrui
 ,tr.dt_nonyu AS dt_nonyu
 ,tr.su_nonyu AS su_nonyu
 ,tr.su_nonyu_hasu AS su_nonyu_hasu
 ,tr.cd_torihiki AS cd_torihiki
 ,tr.cd_torihiki2 AS cd_torihiki2
 ,tr.tan_nonyu AS tan_nonyu
 ,tr.kin_kingaku AS kin_kingaku
 ,tr.no_nonyusho AS no_nonyusho
 ,tr.kbn_zei AS kbn_zei
 ,tr.kbn_denso AS kbn_denso
 ,tr.flg_kakutei AS flg_kakutei
 ,tr.dt_seizo AS dt_seizo
 ,(ISNULL(ma_ko.wt_nonyu, 0) * ISNULL(ma_ko.su_iri, 0) * ISNULL(tr.su_nonyu, 0)) AS juryo
FROM tr_nonyu tr

-- 品名マスタ
LEFT JOIN ma_hinmei ma_hin
ON ma_hin.cd_hinmei = tr.cd_hinmei

-- 原資材購入先マスタ
LEFT JOIN ma_konyu ma_ko
ON ma_ko.cd_hinmei = tr.cd_hinmei
AND ma_ko.cd_torihiki = tr.cd_torihiki

-- 単位マスタ
LEFT JOIN ma_tani ma_tan
ON ma_tan.cd_tani = ma_ko.cd_tani_nonyu

-- 分類マスタ
LEFT JOIN ma_bunrui ma_bun
ON ma_bun.cd_bunrui = ma_hin.cd_bunrui
AND ma_bun.kbn_hin = ma_hin.kbn_hin
GO
