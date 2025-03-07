IF OBJECT_ID ('dbo.vw_tr_zaiko_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_zaiko_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_zaiko_01] as

SELECT
 zaiko.dt_hizuke AS zaiko_hizuke
 ,k_zaiko.dt_hizuke AS keisan_hizuke
 ,hin.cd_hinmei
 ,hin.nm_hinmei_ja
 ,hin.nm_hinmei_en
 ,hin.nm_hinmei_zh
 ,hin.nm_hinmei_vi
 ,hin.nm_nisugata_hyoji
 ,hin.kbn_hin
 ,ma_kbn_hin.nm_kbn_hin AS nm_hinkbn
 ,hin.cd_tani_nonyu
 ,hin.cd_kura
 ,kura.nm_kura
 ,hin.cd_bunrui
 ,mb.nm_bunrui
 ,tani_nonyu.nm_tani AS tani_nonyu
 ,tani_shiyo.nm_tani AS tani_shiyo
 ,ISNULL(k_zaiko.su_zaiko, 0) AS su_keisan_zaiko
 ,ISNULL(zaiko.su_zaiko, 0) AS su_zaiko
 ,zaiko.dt_jisseki_zaiko
 ,hin.flg_mishiyo
 ,ISNULL(hin.tan_ko, 0) AS tan_ko
 ,ISNULL(hin.su_iri, 0) AS su_iri
 ,ISNULL(hin.wt_ko, 0) AS wt_ko
FROM
 ma_hinmei hin

LEFT JOIN ma_bunrui mb
ON hin.cd_bunrui = mb.cd_bunrui
AND hin.kbn_hin = mb.kbn_hin

LEFT JOIN ma_tani tani_nonyu
ON hin.cd_tani_nonyu = tani_nonyu.cd_tani

LEFT JOIN ma_tani tani_shiyo
ON hin.cd_tani_shiyo = tani_shiyo.cd_tani

LEFT JOIN ma_kura kura
ON hin.cd_kura = kura.cd_kura

LEFT JOIN ma_kbn_hin
ON hin.kbn_hin = ma_kbn_hin.kbn_hin

LEFT JOIN tr_zaiko zaiko
ON hin.cd_hinmei = zaiko.cd_hinmei

LEFT JOIN tr_zaiko_keisan k_zaiko
ON hin.cd_hinmei = k_zaiko.cd_hinmei
AND zaiko.dt_hizuke = k_zaiko.dt_hizuke
GO
