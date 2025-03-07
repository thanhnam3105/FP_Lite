IF OBJECT_ID ('dbo.vw_tr_zan_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_zan_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_zan_01]
AS
SELECT
	--ISNULL((ROW_NUMBER() OVER (ORDER BY hinmei.cd_hinmei ASC)), 0) AS ID
	bunrui.kbn_hin
	,bunrui.cd_bunrui
	,bunrui.nm_bunrui
	,hinmei.cd_hinmei
	,hinmei.nm_hinmei_ja
	,hinmei.nm_hinmei_en
	,hinmei.nm_hinmei_zh
	,hinmei.nm_hinmei_vi
	,tani.nm_tani
	,hinmei.nm_nisugata_hyoji
	,yojitsuSum.flg_yojitsu
	,yojitsuSum.dt_hiduke
	,yojitsuSum.su_shiyo_sum
	,IsNull(zan.wt_shiyo_zan, 0) AS wt_shiyo_zan  
	,yojitsuSum.su_shiyo_sum - IsNull(zan.wt_shiyo_zan, 0) AS qty_hitsuyo
	,torihiki.nm_torihiki_ryaku
	,zan.dt_hizuke AS zan_hiduke
	,yusenKonyu.flg_mishiyo AS konyu_mishiyo
	,tani.flg_mishiyo AS tani_mishiyo
	,torihiki.flg_mishiyo AS torihiki_mishiyo
	,bunrui.flg_mishiyo As bunrui_mishiyo
FROM 
	(
		SELECT 
			shiyo_yojitsu.flg_yojitsu
			,shiyo_yojitsu.cd_hinmei
			,shiyo_yojitsu.dt_shiyo dt_hiduke
			,SUM(shiyo_yojitsu.su_shiyo) su_shiyo_sum
		FROM
			dbo.tr_shiyo_yojitsu shiyo_yojitsu
		GROUP BY
			shiyo_yojitsu.flg_yojitsu
			,shiyo_yojitsu.cd_hinmei
			,shiyo_yojitsu.dt_shiyo
	) AS yojitsuSum
	LEFT OUTER JOIN dbo.tr_zan zan 	 
	ON yojitsuSum.cd_hinmei = zan.cd_hinmei
	AND yojitsuSum.dt_hiduke = zan.dt_hizuke
	LEFT OUTER JOIN dbo.ma_hinmei hinmei
	ON yojitsuSum.cd_hinmei = hinmei.cd_hinmei
	LEFT OUTER JOIN dbo.ma_tani tani
	ON hinmei.cd_tani_shiyo = tani.cd_tani
	LEFT OUTER JOIN dbo.ma_bunrui bunrui
	ON hinmei.kbn_hin = bunrui.kbn_hin
	AND hinmei.cd_bunrui = bunrui.cd_bunrui
	LEFT OUTER JOIN
		( 
			
			SELECT 
				konyu.cd_hinmei
				,konyu.cd_torihiki
				,konyu.no_juni_yusen
				,konyu.flg_mishiyo
			FROM
				dbo.ma_konyu konyu
				INNER JOIN	(
						SELECT 
							yusen.cd_hinmei
							,MIN(yusen.no_juni_yusen) no_yusen
							,yusen.flg_mishiyo
						FROM
							dbo.ma_konyu yusen
						GROUP BY
							cd_hinmei
							,flg_mishiyo		
					) AS yusenJyuni
				ON konyu.cd_hinmei = yusenJyuni.cd_hinmei
				AND konyu.no_juni_yusen = yusenJyuni.no_yusen
		)	AS yusenKonyu
	ON hinmei.cd_hinmei = yusenKonyu.cd_hinmei
	LEFT OUTER JOIN dbo.ma_torihiki torihiki
	ON yusenKonyu.cd_torihiki = torihiki.cd_torihiki
GO
