IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeihinJissekiTrace_select_03') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeihinJissekiTrace_select_03]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能			：製品実績トレース画面　検索（投入トランに存在する場合）
ファイル名	：usp_SeihinJissekiTrace_select_03
入力引数		：@no_lot_seihin, @no_seq, @lang
出力引数		：	
戻り値		：
作成日		：2016.03.29  Khang
更新日      ：2019.02.25  BRC takaki.r ニアショア作業依頼No.502
*****************************************************/
CREATE PROCEDURE [dbo].[usp_SeihinJissekiTrace_select_03](
	@no_lot_seihin				VARCHAR(14)			--製品ロット番号
	,@no_seq					DECIMAL(8,0)		--シーケンス番号
	,@lang						VARCHAR(10)			--設定言語
)
AS

BEGIN
	SELECT DISTINCT
		ANBUN.no_lot_shikakari
		,ANBUN.no_lot_seihin
		--,NIUKEHIN.dt_niuke_genshizai
		,CASE
			WHEN NIUKEHIN.dt_niuke_genshizai IS NULL THEN NISUGATA.dt_niuke_genshizai
			ELSE NIUKEHIN.dt_niuke_genshizai
		END AS dt_niuke_genshizai
		,CASE 
			WHEN NIUKEHIN.cd_genshizai IS NULL THEN TONYUHIN.cd_genshizai
			ELSE NIUKEHIN.cd_genshizai
		END AS cd_genshizai
		,CASE 
			WHEN NIUKEHIN.cd_genshizai IS NULL THEN TONYUHIN.nm_genshizai
			ELSE NIUKEHIN.nm_genshizai
		END AS nm_genshizai
		--,NIUKEHIN.no_lot_genshizai
		--,NIUKEHIN.dt_kigen_genshizai
		--,NIUKEHIN.no_nohinsho_genshizai
		,CASE
			WHEN NIUKEHIN.no_lot_genshizai IS NOT NULL THEN NIUKEHIN.no_lot_genshizai
			WHEN NISUGATA.no_lot_genshizai IS NOT NULL THEN NISUGATA.no_lot_genshizai
			WHEN LOT.no_lot IS NOT NULL THEN LOT.no_lot
			ELSE TONYUHIN.no_lot
		END AS no_lot_genshizai
		,CASE
			WHEN NIUKEHIN.dt_kigen_genshizai IS NOT NULL THEN NIUKEHIN.dt_kigen_genshizai
			WHEN NISUGATA.dt_kigen_genshizai IS NOT NULL THEN NISUGATA.dt_kigen_genshizai
			WHEN LOT.dt_shomi IS NOT NULL THEN LOT.dt_shomi
			ELSE TONYUHIN.dt_shomi
		END AS dt_kigen_genshizai
		,CASE
			WHEN NIUKEHIN.no_nohinsho_genshizai IS NULL THEN NISUGATA.no_nohinsho_genshizai
			ELSE NIUKEHIN.no_nohinsho_genshizai
		END AS no_nohinsho_genshizai
	FROM 
	(
		SELECT 
			no_lot_shikakari
			,no_lot_seihin
		FROM tr_sap_shiyo_yojitsu_anbun 
		WHERE no_lot_seihin = @no_lot_seihin
	) ANBUN

	INNER JOIN
	(
		SELECT
			TONYU.no_lot_seihin
			,TONYU.no_kotei
			,TONYU.no_tonyu
			,TONYU.dt_shori
			,TONYU.su_ko_label
			,TONYU.su_kai
			,TONYU.cd_hinmei AS cd_genshizai
			,CASE @lang 
				WHEN 'ja' THEN 
					CASE 
						WHEN HIN_GENSHIZAI.nm_hinmei_ja IS NULL OR LEN(HIN_GENSHIZAI.nm_hinmei_ja) = 0 THEN HIN_GENSHIZAI.nm_hinmei_ryaku
						ELSE HIN_GENSHIZAI.nm_hinmei_ja
					END
				WHEN 'en' THEN
					CASE 
						WHEN HIN_GENSHIZAI.nm_hinmei_en IS NULL OR LEN(HIN_GENSHIZAI.nm_hinmei_en) = 0 THEN HIN_GENSHIZAI.nm_hinmei_ryaku
						ELSE HIN_GENSHIZAI.nm_hinmei_en
					END
				WHEN 'zh' THEN
					CASE 
						WHEN HIN_GENSHIZAI.nm_hinmei_zh IS NULL OR LEN(HIN_GENSHIZAI.nm_hinmei_zh) = 0 THEN HIN_GENSHIZAI.nm_hinmei_ryaku
						ELSE HIN_GENSHIZAI.nm_hinmei_zh
					END
				WHEN 'vi' THEN
					CASE 
						WHEN HIN_GENSHIZAI.nm_hinmei_vi IS NULL OR LEN(HIN_GENSHIZAI.nm_hinmei_vi) = 0 THEN HIN_GENSHIZAI.nm_hinmei_ryaku
						ELSE HIN_GENSHIZAI.nm_hinmei_vi
					END
			END AS nm_genshizai
			,TONYU.cd_line
			,TONYU.kbn_seikihasu
			,TONYU.no_lot
			,TONYU.dt_shomi
		FROM tr_tonyu TONYU		

		LEFT OUTER JOIN 
		(
			SELECT
				cd_hinmei
				,nm_hinmei_ja
				,nm_hinmei_en
				,nm_hinmei_zh
				,nm_hinmei_vi
				,nm_hinmei_ryaku
			FROM ma_hinmei
		) HIN_GENSHIZAI
		ON TONYU.cd_hinmei = HIN_GENSHIZAI.cd_hinmei

		WHERE TONYU.cd_hinmei IN
		(
			SELECT
				cd_hinmei
			FROM ma_hinmei
		)
	) TONYUHIN
	ON TONYUHIN.no_lot_seihin = ANBUN.no_lot_shikakari

	LEFT OUTER JOIN tr_kowake KOWAKE
	ON TONYUHIN.no_lot_seihin = KOWAKE.no_lot_seihin
	AND TONYUHIN.no_kotei = KOWAKE.no_kotei
	AND TONYUHIN.no_tonyu = KOWAKE.no_tonyu
	AND TONYUHIN.dt_shori = KOWAKE.dt_tonyu	
	AND TONYUHIN.su_ko_label = KOWAKE.su_ko		
	AND TONYUHIN.su_kai = KOWAKE.su_kai
	AND TONYUHIN.cd_genshizai = KOWAKE.cd_hinmei
	AND TONYUHIN.cd_line = KOWAKE.cd_line
	AND TONYUHIN.kbn_seikihasu = KOWAKE.kbn_seikihasu

	LEFT OUTER JOIN tr_lot LOT
	ON LOT.no_lot_jisseki = KOWAKE.no_lot_kowake

	LEFT OUTER JOIN 
	(
		SELECT 
			NIUKE.no_niuke
			,NIUKE.cd_hinmei AS cd_genshizai
			,CASE @lang 
				WHEN 'ja' THEN 
					CASE 
						WHEN HIN_GENSHIZAI.nm_hinmei_ja IS NULL OR LEN(HIN_GENSHIZAI.nm_hinmei_ja) = 0 THEN HIN_GENSHIZAI.nm_hinmei_ryaku
						ELSE HIN_GENSHIZAI.nm_hinmei_ja
					END
				WHEN 'en' THEN
					CASE 
						WHEN HIN_GENSHIZAI.nm_hinmei_en IS NULL OR LEN(HIN_GENSHIZAI.nm_hinmei_en) = 0 THEN HIN_GENSHIZAI.nm_hinmei_ryaku
						ELSE HIN_GENSHIZAI.nm_hinmei_en
					END
				WHEN 'zh' THEN
					CASE 
						WHEN HIN_GENSHIZAI.nm_hinmei_zh IS NULL OR LEN(HIN_GENSHIZAI.nm_hinmei_zh) = 0 THEN HIN_GENSHIZAI.nm_hinmei_ryaku
						ELSE HIN_GENSHIZAI.nm_hinmei_zh
					END
				WHEN 'vi' THEN
					CASE 
						WHEN HIN_GENSHIZAI.nm_hinmei_vi IS NULL OR LEN(HIN_GENSHIZAI.nm_hinmei_vi) = 0 THEN HIN_GENSHIZAI.nm_hinmei_ryaku
						ELSE HIN_GENSHIZAI.nm_hinmei_vi
					END
			END AS nm_genshizai
			,NIUKE.no_lot AS no_lot_genshizai
			,NIUKE.dt_niuke AS dt_niuke_genshizai
			,NIUKE.dt_kigen AS dt_kigen_genshizai
			,NIUKE.dt_seizo AS dt_seizo_genshizai
			,NIUKE.no_nohinsho AS no_nohinsho_genshizai
		FROM
		(
			SELECT
				no_niuke
				,cd_hinmei
				,no_lot
				,dt_niuke
				,dt_kigen
				,dt_seizo
				,no_nohinsho
			FROM tr_niuke
			WHERE no_niuke IN (
				SELECT 
					MAX(niuke_max.no_niuke) AS no_niuke
				FROM tr_niuke niuke_max
				GROUP BY niuke_max.cd_hinmei, niuke_max.dt_seizo, niuke_max.dt_kigen, niuke_max.no_lot
			)
			AND no_seq = @no_seq
		) NIUKE

		LEFT OUTER JOIN 
		(
			SELECT
				cd_hinmei
				,nm_hinmei_ja
				,nm_hinmei_en
				,nm_hinmei_zh
				,nm_hinmei_vi
				,nm_hinmei_ryaku
			FROM ma_hinmei
		) HIN_GENSHIZAI
		ON NIUKE.cd_hinmei = HIN_GENSHIZAI.cd_hinmei
	) NIUKEHIN
	ON LOT.no_lot = NIUKEHIN.no_lot_genshizai
	AND LOT.dt_shomi = NIUKEHIN.dt_kigen_genshizai
	
	LEFT JOIN (
		SELECT 
			TN.cd_hinmei AS cd_hinmei
			,TN.no_lot AS no_lot_genshizai
			,TN.dt_niuke AS dt_niuke_genshizai
			,TN.dt_kigen AS dt_kigen_genshizai
			,TN.no_nohinsho AS no_nohinsho_genshizai
		FROM tr_niuke TN
		WHERE no_niuke IN (
			SELECT 
				MAX(niuke.no_niuke) AS no_niuke
			FROM tr_niuke niuke
			GROUP BY niuke.cd_hinmei, niuke.dt_seizo, niuke.dt_kigen, niuke.no_lot
		)
		AND TN.no_seq = @no_seq
	) NISUGATA
	ON	TONYUHIN.cd_genshizai = NISUGATA.cd_hinmei
	AND TONYUHIN.no_lot = NISUGATA.no_lot_genshizai	
END

GO