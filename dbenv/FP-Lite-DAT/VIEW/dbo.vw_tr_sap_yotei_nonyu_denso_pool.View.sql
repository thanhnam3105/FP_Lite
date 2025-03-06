IF OBJECT_ID ('dbo.vw_tr_sap_yotei_nonyu_denso_pool', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_sap_yotei_nonyu_denso_pool]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_sap_yotei_nonyu_denso_pool]
AS
	SELECT 
		pl.dt_denso
		,convert(datetime, convert(varchar, pl.dt_nonyu) + ' 10:00:00', 112) AS 'dt_nonyu'
		,pl.kbn_denso_SAP
		,pl.no_nonyu
		,pl.cd_hinmei
		,mh.nm_hinmei_ja
		,mh.nm_hinmei_en
		,mh.nm_hinmei_zh
		,mh.nm_hinmei_vi
		,pl.cd_torihiki
		,tori.nm_torihiki
		,pl.su_nonyu
		,mt.cd_tani
		,mt.nm_tani
		,pl.kbn_nyuko
	FROM
		tr_sap_yotei_nonyu_denso_pool pl
	-- 品名マスタ
	LEFT JOIN ma_hinmei mh
	ON mh.cd_hinmei = pl.cd_hinmei
	-- 取引先マスタ
	LEFT JOIN ma_torihiki tori
	ON pl.cd_torihiki = tori.cd_torihiki
	-- 単位変換マスタ
	LEFT JOIN ma_sap_tani_henkan msth
	ON pl.cd_tani_SAP = msth.cd_tani_henkan
	-- 単位マスタ
	LEFT JOIN ma_tani mt
	ON msth.cd_tani = mt.cd_tani
GO
