IF OBJECT_ID ('dbo.vw_tr_sap_keikaku_seihin_denso_pool', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_sap_keikaku_seihin_denso_pool]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_sap_keikaku_seihin_denso_pool]
AS
	SELECT 
		tsksdp.dt_denso
		,tsksdp.kbn_denso_SAP
		,convert(datetime,convert(varchar,tsksdp.dt_seizo)+ ' 10:00:00',112) dt_seizo
		,tsksdp.cd_hinmei
		,mh.nm_hinmei_ja
		,mh.nm_hinmei_en
		,mh.nm_hinmei_zh
		,mh.nm_hinmei_vi
		,tsksdp.no_lot_seihin
		,tsksdp.su_seizo_keikaku
		,mt.cd_tani
		,mt.nm_tani
	FROM tr_sap_keikaku_seihin_denso_pool tsksdp
	LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = tsksdp.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan msth
		ON tsksdp.cd_tani_SAP = msth.cd_tani_henkan
	LEFT JOIN ma_tani mt
		ON msth.cd_tani = mt.cd_tani
GO
