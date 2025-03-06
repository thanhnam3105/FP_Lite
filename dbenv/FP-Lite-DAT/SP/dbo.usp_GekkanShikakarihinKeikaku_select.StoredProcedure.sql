IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GekkanShikakarihinKeikaku_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GekkanShikakarihinKeikaku_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author,,kobayashi.y>
-- Create date: <Create Date,,2013.11.07>
-- Last Update: <2016.10.13,,BRC.inoue.k>
--				<2024.01.22,TosVN(toan.nt) Support #3423>
-- Description: 月間仕掛品計画の検索処理
-- =============================================
CREATE PROCEDURE [dbo].[usp_GekkanShikakarihinKeikaku_select]
    @cd_shokuba varchar(10)
    ,@dt_hiduke_from datetime
    ,@dt_hiduke_to datetime
    ,@isHinmeiSearch smallint
    ,@cd_hinmei_search varchar(14)
    ,@no_lot_search varchar(14)
    ,@isSelectLotNashi smallint
    ,@isSelectLotOya smallint
    ,@isSelectLotSeihin smallint
    ,@isSelectLotShikakari smallint
    ,@skip decimal(10)
    ,@top decimal(10)
    ,@isExcel smallint
    ,@true smallint
    ,@count int output
WITH RECOMPILE
AS
BEGIN

DECLARE @start decimal(10)
DECLARE @end decimal(10)
	
SET @start = @skip
SET @end = @skip + @top

BEGIN
WITH cte AS
   (
	SELECT 
		ISNULL(shikakari_result.dt_hitsuyo, calendar.dt_hizuke) AS dt_hitsuyo_tukihi
		,ISNULL(shikakari_result.dt_hitsuyo, calendar.dt_hizuke) AS dt_hitsuyo_yobi
		,ISNULL(shikakari_result.dt_hitsuyo, calendar.dt_hizuke) AS dt_hitsuyo_hidden
		,calendar.flg_kyujitsu
		,calendar.flg_shukujitsu
		,shikakari_result.dt_seizo
		,shikakari_result.dt_seizo AS dt_seizo_hidden
		,shikakari_result.nm_haigo_en
		,shikakari_result.nm_haigo_ja
		,shikakari_result.nm_haigo_zh
		,shikakari_result.nm_haigo_vi
		,shikakari_result.cd_shikakari AS cd_hinmei
		,shikakari_result.nm_shikakari_en 
		,shikakari_result.nm_shikakari_ja
		,shikakari_result.nm_shikakari_zh
		,shikakari_result.nm_shikakari_vi
		,shikakari_result.flg_gassan_shikomi
		,shikakari_result.ritsu_kihon
		,shikakari_result.wt_haigo_gokei
		,shikakari_result.cd_tani
		,shikakari_result.nm_tani
       	--,ISNULL(shikakari_result.wt_shikomi_keikaku, 0) AS wt_shikomi_keikaku
		,COALESCE(CEILING(shikakari_result.wt_shikomi_keikaku * 1000)/1000,0.000) AS wt_shikomi_keikaku
		--,shikakari_result.wt_hitsuyo
		,COALESCE(CEILING(shikakari_result.wt_hitsuyo * 1000)/1000,0.000) AS wt_hitsuyo 
		,shikakari_result.nm_line
		,shikakari_result.cd_line
		,shikakari_result.no_lot_seihin
		,shikakari_result.no_lot_shikakari
		,shikakari_result.no_lot_shikakari_oya
		,@cd_shokuba AS cd_shokuba
		,shikakari_result.data_key
		,shikakari_result.data_key_oya
		,shikakari_result.flg_jisseki
		,shikakari_result.flg_shikakari_jisseki
		,shikakari_result.flg_keikaku
		,shikakari_result.flg_label
		,shikakari_result.flg_label_hasu
		,ROW_NUMBER() OVER (ORDER BY 
			calendar.dt_hizuke
			--,shikakari_result.wt_shikomi_keikaku
			,shikakari_result.dt_seizo
			,shikakari_result.cd_line
			,shikakari_result.no_lot_seihin
			,shikakari_result.cd_shikakari
			,shikakari_result.data_key) AS RN 
	FROM ma_calendar calendar
	LEFT OUTER JOIN 
	(
		SELECT
			shikakari_trn.dt_hitsuyo 
			,shikakari_trn.dt_seizo
			,shikakari_trn.cd_hinmei
			,shikakari_oya.nm_haigo_en
			,shikakari_oya.nm_haigo_ja
			,shikakari_oya.nm_haigo_zh
			,shikakari_oya.nm_haigo_vi
			,haigo_for_trn.cd_haigo AS cd_shikakari
			,haigo_for_trn.nm_haigo_en AS nm_shikakari_en 
			,haigo_for_trn.nm_haigo_ja AS nm_shikakari_ja
			,haigo_for_trn.nm_haigo_zh AS nm_shikakari_zh
			,haigo_for_trn.nm_haigo_vi AS nm_shikakari_vi
			,haigo_for_trn.flg_gassan_shikomi
			,haigo_for_trn.ritsu_kihon
			,haigo_for_trn.wt_haigo_gokei
			,haigo_for_trn.cd_tani
			,haigo_for_trn.nm_tani
            ,shikakari_trn.wt_shikomi_keikaku
            ,shikakari_trn.wt_hitsuyo
			,line.nm_line
			,line.cd_line
			,shikakari_trn.no_lot_seihin
			,shikakari_trn.no_lot_shikakari
			,shikakari_trn.no_lot_shikakari_oya
			,shikakari_trn.cd_shokuba
			,shikakari_trn.data_key
			,shikakari_trn.data_key_oya
			,vw.flg_seihin_jisseki	AS flg_jisseki
			,vw.flg_shikakari_jisseki
			,vw.flg_shikomi			AS flg_keikaku
			,vw.flg_label
			,vw.flg_label_hasu
		FROM tr_keikaku_shikakari shikakari_trn
		LEFT OUTER JOIN vw_tr_keikaku_check vw
			ON ISNULL(vw.no_lot_seihin, '') = ISNULL(shikakari_trn.no_lot_seihin,'')
			AND vw.no_lot_shikakari = shikakari_trn.no_lot_shikakari
		LEFT OUTER JOIN 
		(
			SELECT
				oya.cd_shikakari_hin
				,oya.cd_shokuba
				,oya.dt_seizo
				,oya.no_lot_shikakari
				,oya.no_lot_seihin
				,haigo_for_oya.nm_haigo_en
				,haigo_for_oya.nm_haigo_ja
				,haigo_for_oya.nm_haigo_zh
				,haigo_for_oya.nm_haigo_vi
				,haigo_for_oya.nm_tani
				,oya.data_key
			FROM tr_keikaku_shikakari oya
			LEFT OUTER JOIN 
				(
					SELECT 
						haigo_mei.cd_haigo
						,haigo_mei.nm_haigo_en
						,haigo_mei.nm_haigo_ja
						,haigo_mei.nm_haigo_zh
						,haigo_mei.nm_haigo_vi
						,haigo_mei.no_han
						,tani.nm_tani
					FROM ma_haigo_mei haigo_mei
					LEFT OUTER JOIN ma_tani tani
					ON haigo_mei.kbn_kanzan = tani.cd_tani
					--INNER JOIN
					--(
					--	SELECT 
					--		mei.cd_haigo
					--		,MAX(mei.no_han) as no_han
					--	FROM ma_haigo_mei mei
					--	left outer join tr_keikaku_shikakari shika
					--	on mei.cd_haigo = shika.cd_shikakari_hin
					--	and mei.dt_from <= shika.dt_seizo
					--	WHERE mei.flg_mishiyo <> @true
					--	GROUP BY 
					--		mei.cd_haigo
					--) yuko
					--ON haigo_mei.cd_haigo = yuko.cd_haigo
					--AND haigo_mei.no_han = yuko.no_han
				) haigo_for_oya
			ON oya.cd_shikakari_hin = haigo_for_oya.cd_haigo
			AND haigo_for_oya.no_han = (SELECT TOP 1 no_han FROM udf_HaigoRecipeYukoHan(oya.cd_shikakari_hin, 0, oya.dt_seizo))
			WHERE
				oya.dt_hitsuyo BETWEEN @dt_hiduke_from AND @dt_hiduke_to
		) shikakari_oya --仕掛トラン 親
		ON shikakari_trn.no_lot_shikakari_oya = shikakari_oya.no_lot_shikakari
		--AND shikakari_trn.no_lot_seihin = shikakari_oya.no_lot_seihin
		AND shikakari_trn.data_key_oya = shikakari_oya.data_key
		AND (shikakari_trn.no_lot_seihin = shikakari_oya.no_lot_seihin
			OR shikakari_oya.no_lot_seihin IS NULL)

		LEFT OUTER JOIN ma_line line
		ON shikakari_trn.cd_line = line.cd_line
		--LEFT OUTER JOIN 
		INNER JOIN 
		(
			SELECT 
				haigo_mei.cd_haigo
				,haigo_mei.nm_haigo_en
				,haigo_mei.nm_haigo_ja
				,haigo_mei.nm_haigo_zh
				,haigo_mei.nm_haigo_vi
				,haigo_mei.ritsu_kihon
				,haigo_mei.wt_haigo_gokei
				,haigo_mei.flg_gassan_shikomi
				,haigo_mei.no_han
				,tani.cd_tani
				,tani.nm_tani
			FROM ma_haigo_mei haigo_mei
			--INNER JOIN
			--(
			--	SELECT 
			--		mei.cd_haigo
			--		,MAX(mei.no_han) as no_han
			--	FROM ma_haigo_mei mei
			--	left outer join tr_keikaku_shikakari shika
			--	on mei.cd_haigo = shika.cd_shikakari_hin
			--	and mei.dt_from <= shika.dt_seizo
			--	WHERE mei.flg_mishiyo <> @true
			--	GROUP BY 
			--		mei.cd_haigo
			--) yuko
			--ON haigo_mei.cd_haigo = yuko.cd_haigo
			--AND haigo_mei.no_han = yuko.no_han
			LEFT OUTER JOIN ma_tani tani
			ON haigo_mei.kbn_kanzan = tani.cd_tani
		) haigo_for_trn
		ON shikakari_trn.cd_shikakari_hin = haigo_for_trn.cd_haigo
		AND haigo_for_trn.no_han = (SELECT TOP 1 no_han FROM udf_HaigoRecipeYukoHan(shikakari_trn.cd_shikakari_hin, 0, shikakari_trn.dt_seizo))
		WHERE 
			shikakari_trn.cd_shokuba = @cd_shokuba
			AND shikakari_trn.dt_hitsuyo BETWEEN @dt_hiduke_from AND @dt_hiduke_to
			AND
			(
				(
					@isHinmeiSearch = @true
					AND haigo_for_trn.cd_haigo = @cd_hinmei_search
				)OR (
					@isHinmeiSearch != @true
				)
			)
			AND 
			(
				(
					@isSelectLotNashi = @true -- なし選択
				)OR (
					@isSelectLotOya = @true -- 親
					AND (
						(@no_lot_search IS NOT NULL AND shikakari_trn.no_lot_shikakari_oya = @no_lot_search) 
							OR (@no_lot_search IS NULL AND (shikakari_trn.no_lot_shikakari_oya IS NULL OR shikakari_trn.no_lot_shikakari_oya = ''))
					)
				)OR (
					@isSelectLotSeihin = @true -- 製品
					AND (
						(@no_lot_search IS NOT NULL AND shikakari_trn.no_lot_seihin = @no_lot_search)
							OR (@no_lot_search IS NULL AND (shikakari_trn.no_lot_seihin IS NULL OR shikakari_trn.no_lot_seihin = ''))
					)
				)OR (
					@isSelectLotShikakari = @true -- 仕掛
					AND shikakari_trn.no_lot_shikakari = @no_lot_search
				)
			)
	) shikakari_result 
	--ON calendar.dt_hizuke = shikakari_result.dt_seizo
	ON calendar.dt_hizuke = shikakari_result.dt_hitsuyo
	WHERE
		calendar.dt_hizuke BETWEEN @dt_hiduke_from AND @dt_hiduke_to
	)
	-- 画面に返却する値を取得
	SELECT
		cte_row.cnt
		,cte_row.dt_hitsuyo_tukihi
		,cte_row.dt_hitsuyo_yobi
		,cte_row.dt_hitsuyo_hidden
		,cte_row.flg_kyujitsu
		,cte_row.flg_shukujitsu
		,cte_row.dt_seizo
		,cte_row.dt_seizo_hidden
		,cte_row.cd_hinmei
		,cte_row.nm_haigo_en
		,cte_row.nm_haigo_ja
		,cte_row.nm_haigo_zh
		,cte_row.nm_haigo_vi
		,cte_row.nm_shikakari_en 
		,cte_row.nm_shikakari_ja
		,cte_row.nm_shikakari_zh
		,cte_row.nm_shikakari_vi
		,cte_row.flg_gassan_shikomi
		,cte_row.ritsu_kihon
		,cte_row.wt_haigo_gokei
		,cte_row.cd_tani
		,cte_row.nm_tani
        ,cte_row.wt_shikomi_keikaku
		,cte_row.wt_hitsuyo
		,cte_row.nm_line
		,cte_row.cd_line
		,cte_row.no_lot_seihin
		,cte_row.no_lot_shikakari
		,cte_row.no_lot_shikakari_oya
		,@cd_shokuba AS cd_shokuba
		,cte_row.data_key
		,cte_row.oyaCnt
		,cte_row.flg_jisseki
		,cte_row.flg_shikakari_jisseki
		,cte_row.flg_keikaku
		,cte_row.flg_label
		,cte_row.flg_label_hasu
		,CAST(cte_row.RN AS varchar) AS id
	FROM(
			SELECT 
				MAX(RN) OVER() cnt
				,*
				,(
					SELECT
						COUNT(oya_cnt.no_lot_shikakari_oya) 
					FROM tr_keikaku_shikakari oya_cnt
					WHERE 
						oya_cnt.no_lot_shikakari = cte.no_lot_shikakari
						AND oya_cnt.no_lot_shikakari_oya IS NOT NULL
						AND oya_cnt.no_lot_shikakari_oya != ''
						AND oya_cnt.data_key_oya = cte.data_key_oya
				) AS oyaCnt
			FROM
				cte 
		) cte_row
	WHERE
	( 
		(
			@isExcel != @true
			AND cte_row.RN <= @top
		)
		OR (
			@isExcel = @true
		)
	)
	ORDER BY
		cte_row.dt_hitsuyo_hidden, cte_row.dt_seizo_hidden, cte_row.cd_line, cte_row.no_lot_seihin, cte_row.cd_hinmei, cte_row.data_key
	
	
END
END
GO