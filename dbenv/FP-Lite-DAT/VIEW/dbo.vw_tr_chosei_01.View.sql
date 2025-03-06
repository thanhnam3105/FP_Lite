IF OBJECT_ID ('dbo.vw_tr_chosei_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_chosei_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_chosei_01] as

SELECT
 tr.dt_hizuke
 ,tr.no_seq
 ,tr.cd_hinmei
 ,ma_gen.nm_hinmei_ja
 ,ma_gen.nm_hinmei_en
 ,ma_gen.nm_hinmei_zh
 ,ma_gen.nm_hinmei_vi
 ,ma_kbn_hin.kbn_hin
 ,ma_kbn_hin.nm_kbn_hin
 ,ma_gen.nm_nisugata_hyoji AS nm_nisugata
 ,ma_tani.nm_tani AS tani_shiyo
 ,tr.su_chosei
 ,tr.su_chosei AS su_chosei_initial
 ,ma_riyu.cd_riyu
 ,ma_riyu.nm_riyu
 ,ma_riyu.kbn_bunrui_riyu
 ,tr.biko
 ,tr.cd_seihin
 ,ma_sei.nm_hinmei_ja AS nm_seihin_ja
 ,ma_sei.nm_hinmei_en AS nm_seihin_en
 ,ma_sei.nm_hinmei_zh AS nm_seihin_zh
 ,ma_sei.nm_hinmei_vi AS nm_seihin_vi
 ,ma_sei.flg_mishiyo
 ,ma_tanto.nm_tanto AS nm_update
 ,tr.cd_update
 ,tr.dt_update
 ,tr.cd_genka_center
 ,gc.nm_genka_center
 ,tr.cd_soko
 ,soko.nm_soko
 ,tr.no_lot_seihin
 ,shikakari.no_seq_shiyo_yojitsu_anbun  AS anbun_no_seq
FROM tr_chosei tr

-- 原資材名用の品名マスタ情報
LEFT JOIN ma_hinmei ma_gen
ON ma_gen.cd_hinmei = tr.cd_hinmei

-- 製品名用の品名マスタ情報
LEFT JOIN ma_hinmei ma_sei
ON ma_sei.cd_hinmei = tr.cd_seihin

LEFT JOIN ma_tani
ON cd_tani = ma_gen.cd_tani_shiyo

LEFT JOIN ma_riyu
ON ma_riyu.cd_riyu = tr.cd_riyu

LEFT JOIN ma_tanto
ON ma_tanto.cd_tanto = tr.cd_update

LEFT JOIN ma_kbn_hin
ON ma_kbn_hin.kbn_hin = ma_gen.kbn_hin

LEFT JOIN ma_soko soko
ON soko.cd_soko = tr.cd_soko

LEFT JOIN ma_genka_center gc
ON gc.cd_genka_center = tr.cd_genka_center

LEFT JOIN tr_shiyo_shikakari_zan shikakari
ON tr.no_seq = shikakari.no_lot AND
shikakari.kbn_shiyo_jisseki_anbun = '2'

LEFT JOIN tr_sap_shiyo_yojitsu_anbun anbun
ON shikakari.no_seq_shiyo_yojitsu_anbun =  anbun.no_seq
GO
