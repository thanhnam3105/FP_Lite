IF OBJECT_ID ('dbo.vw_tr_sap_shiyo_yojitsu_anbun_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_sap_shiyo_yojitsu_anbun_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************					
機能		：製造実績選択・初期表示の検索ビュー			
ビュー名	：vw_tr_sap_shiyo_yojitsu_anbun_01				
備考		：			
作成日		：2015.06.25 ADMAX tsujita.s			
更新日		：2017.01.16 yokota			
************************************************************/					
CREATE VIEW [dbo].[vw_tr_sap_shiyo_yojitsu_anbun_01]					
AS					
					
	SELECT				
		anbun.kbn_shiyo_jisseki_anbun			
		,anbun.kbn_shiyo_jisseki_anbun AS 'con_kbn_shiyo_jisseki_anbun'			
		,anbun.dt_shiyo_shikakari			
		,hin.kbn_hin			
		,hkbn.nm_kbn_hin			
		,seihin.cd_hinmei			
		,hin.nm_hinmei_ja			
		,hin.nm_hinmei_en			
		,hin.nm_hinmei_zh
		,hin.nm_hinmei_vi
		,hin.nm_hinmei_ryaku			
		,hin.flg_mishiyo AS 'flg_mishiyo_hin'			
		,anbun.no_lot_seihin			
		,anbun.no_lot_seihin AS 'con_no_lot_seihin'			
		,anbun.no_lot_shikakari			
		--,anbun.su_shiyo_shikakari			
		,CEILING(anbun.su_shiyo_shikakari*1000)/1000 AS 'su_shiyo_shikakari'
		,anbun.cd_riyu			
		,riyu.nm_riyu			
		,riyu.kbn_bunrui_riyu			
		,anbun.cd_genka_center			
		,genka.nm_genka_center			
		,genka.flg_mishiyo AS 'flg_mishiyo_genka'			
		,anbun.cd_soko			
		,soko.nm_soko			
		,soko.flg_mishiyo AS 'flg_mishiyo_soko'			
		,anbun.kbn_jotai_denso			
		,anbun.kbn_jotai_denso AS 'kbn_denso'			
		,anbun.no_seq			
		,anbun.ts			
		,hin.flg_testitem			
	FROM				
		tr_sap_shiyo_yojitsu_anbun anbun			
					
	LEFT JOIN tr_keikaku_seihin seihin				
	ON anbun.no_lot_seihin = seihin.no_lot_seihin				
					
	LEFT JOIN ma_hinmei hin				
	ON seihin.cd_hinmei = hin.cd_hinmei				
					
	LEFT JOIN ma_kbn_hin hkbn				
	ON hin.kbn_hin = hkbn.kbn_hin				
					
	LEFT JOIN ma_riyu riyu				
	ON anbun.cd_riyu = riyu.cd_riyu				
					
	LEFT JOIN ma_genka_center genka				
	ON anbun.cd_genka_center = genka.cd_genka_center				
					
	LEFT JOIN ma_soko soko				
	ON anbun.cd_soko = soko.cd_soko
GO
