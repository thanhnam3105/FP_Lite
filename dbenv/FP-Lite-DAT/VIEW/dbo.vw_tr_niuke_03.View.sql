IF OBJECT_ID ('dbo.vw_tr_niuke_03', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_niuke_03]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_niuke_03]
AS
SELECT                  t_niu.dt_niuke AS dt_niuke, ISNULL(ma_niu.nm_niuke, '') AS nm_niuke, ISNULL(ma_niu.cd_niuke_basho, '') AS cd_niuke_basho, 
                                  t_niu.cd_hinmei AS cd_hinmei, ISNULL(ma_hin.nm_hinmei_ja, '') AS nm_hinmei, ISNULL(ma_hin.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji, 
                                  ISNULL(ma_tori.nm_torihiki, '') AS nm_torihiki, ISNULL(ma_tori.cd_torihiki, '') AS cd_torihiki, ISNULL(t_niu.tm_nonyu_yotei, '') AS tm_nonyu_yotei, 
                                  ISNULL(t_niu.su_nonyu_yotei, 0) AS su_nonyu_yotei, ISNULL(t_niu.su_nonyu_yotei_hasu, 0) AS su_nonyu_yotei_hasu, ISNULL(t_niu.tm_nonyu_jitsu, '') 
                                  AS tm_nonyu_jitsu, ISNULL(t_niu.su_nonyu_jitsu, 0) AS su_nonyu_jitsu, ISNULL(t_niu.su_nonyu_jitsu_hasu, 0) AS su_nonyu_hasuu_jitsu, 
                                  ISNULL(ma_hkn.nm_hokan_kbn, '') AS nm_hokan_kbn, t_niu.kbn_nyushukko AS kbn_nyushukko
FROM                     tr_niuke AS t_niu LEFT OUTER JOIN
                                  ma_niuke AS ma_niu ON t_niu.cd_niuke_basho = ma_niu.cd_niuke_basho AND ma_niu.flg_mishiyo = 0 LEFT OUTER JOIN
                                  ma_hinmei AS ma_hin ON t_niu.cd_hinmei = ma_hin.cd_hinmei AND ma_hin.flg_mishiyo = 0 LEFT OUTER JOIN
                                  ma_kbn_hokan AS ma_hkn ON t_niu.cd_niuke_basho = ma_hkn.cd_hokan_kbn AND ma_hkn.flg_mishiyo = 0 LEFT OUTER JOIN
                                  ma_torihiki AS ma_tori ON t_niu.cd_torihiki = ma_tori.cd_torihiki AND ma_tori.flg_mishiyo = 0
WHERE                   t_niu.dt_niuke IS NOT NULL
UNION ALL
SELECT                  t_nyu.dt_nonyu AS dt_niuke, ISNULL(ma_niu.nm_niuke, '') AS nm_niuke, ISNULL(ma_niu.cd_niuke_basho, '') AS cd_niuke, 
                                  t_nyu.cd_hinmei AS cd_hinmei, ISNULL(ma_hin.nm_hinmei_ja, '') AS nm_hinmei, ISNULL(ma_hin.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji, 
                                  ISNULL(ma_tori.nm_torihiki, '') AS nm_torihiki, ISNULL(ma_tori.cd_torihiki, '') AS cd_torihiki, '00:00' AS tm_nonyu_yotei, ISNULL(CONVERT(VARCHAR, 
                                  t_nyu.su_nonyu), 0) AS su_nonyu_yotei, '0' AS su_nonyu_yotei_hasu, '' AS tm_nonyu_jitsu, 0 AS su_nonyu_jitsu, 0 AS su_nonyu_hasuu_jitsu, 
                                  ISNULL(ma_hkn.nm_hokan_kbn, '') AS nm_hokan_kbn, '1' AS kbn_nyushukko
FROM                     tr_nonyu AS t_nyu LEFT OUTER JOIN
                                  ma_hinmei AS ma_hin ON t_nyu.cd_hinmei = ma_hin.cd_hinmei AND ma_hin.flg_mishiyo = 0 LEFT OUTER JOIN
                                  ma_niuke AS ma_niu ON t_nyu.cd_hinmei = ma_niu.cd_niuke_basho AND ma_niu.flg_mishiyo = 0 LEFT OUTER JOIN
                                  ma_kbn_hokan AS ma_hkn ON t_nyu.cd_hinmei = ma_hkn.cd_hokan_kbn AND ma_hkn.flg_mishiyo = 0 LEFT OUTER JOIN
                                  ma_torihiki AS ma_tori ON t_nyu.cd_torihiki = ma_tori.cd_torihiki AND ma_tori.flg_mishiyo = 0
WHERE                   NOT EXISTS
                                      (SELECT                  *
                                            FROM                     tr_niuke AS t_niu
                                            WHERE                   t_niu.cd_hinmei = t_nyu.cd_hinmei AND t_niu.cd_torihiki = t_nyu.cd_torihiki AND t_niu.dt_niuke = t_nyu.dt_nonyu)
GO
