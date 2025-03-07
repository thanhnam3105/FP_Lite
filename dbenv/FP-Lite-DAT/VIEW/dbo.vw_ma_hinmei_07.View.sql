IF OBJECT_ID ('dbo.vw_ma_hinmei_07', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_hinmei_07]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_hinmei_07]
AS

SELECT
	hin.cd_hinmei
	, hin.nm_hinmei_ja
	, hin.nm_hinmei_en
	, hin.nm_hinmei_zh
	, hin.nm_hinmei_vi
	, hin.nm_nisugata_hyoji
	, CAST(hin.su_hachu_lot_size AS VARCHAR) + ' ' + konyu_tani.nm_tani AS su_hachu_lot_size
	, hin.cd_tani_shiyo
	, hin.dd_leadtime
	, hin.su_zaiko_min
	, hin.kbn_kanzan
	, konyu.cd_torihiki
	, tori.nm_torihiki
	, hin.flg_mishiyo AS hin_flg_mishiyo
	, konyu_tani.flg_mishiyo AS konyu_tani_flg_mishiyo
	, konyu.flg_mishiyo AS konyu_flg_mishiyo
	, tori.flg_mishiyo AS tori_flg_mishiyo
	, hin.kbn_hin
FROM
	dbo.ma_hinmei AS hin

LEFT OUTER JOIN dbo.ma_konyu AS konyu
ON hin.cd_hinmei = konyu.cd_hinmei
AND konyu.no_juni_yusen = (SELECT MIN(no_juni_yusen) AS Expr1
                           FROM dbo.ma_konyu AS k
                           WHERE (cd_hinmei = konyu.cd_hinmei)
                           AND (flg_mishiyo = konyu.flg_mishiyo)
                          )

LEFT OUTER JOIN dbo.ma_tani AS konyu_tani
ON konyu.cd_tani_nonyu = konyu_tani.cd_tani

LEFT OUTER JOIN dbo.ma_torihiki AS tori
ON konyu.cd_torihiki = tori.cd_torihiki
GO
