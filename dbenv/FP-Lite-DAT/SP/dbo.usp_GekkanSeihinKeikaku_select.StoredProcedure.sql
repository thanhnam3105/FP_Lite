IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GekkanSeihinKeikaku_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GekkanSeihinKeikaku_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author,,kobayashi.y>
-- Create date: <Create Date,,2013.08.08>
-- Last Update: <2016.10.07,kanehira.d>
--				<2021.05.11,BRC.saito #1196>
-- Description: <Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[usp_GekkanSeihinKeikaku_select]
    @cd_shokuba varchar(10)
    ,@cd_line varchar(10)
    ,@kbn_riyu smallint
    ,@flg_mishiyo smallint
    ,@dt_hiduke_from datetime
    ,@dt_hiduke_to datetime
    ,@isAllLine smallint
    ,@isExcel smallint
    ,@true smallint
    ,@false smallint
    ,@skip decimal(10)
    ,@top decimal(10)
    ,@count int output
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
				calendar.dt_hizuke
				,calendar.flg_kyujitsu
				,calendar.cd_line AS cd_kyujitsu_line
				,calendar.nm_line AS nm_kyujitsu_line
				,calendar.cd_riyu
				,calendar.nm_riyu
				,keikaku.cd_shokuba
				,keikaku.nm_shokuba
				,keikaku.cd_line
				,keikaku.nm_line
				,keikaku.cd_hinmei
				,keikaku.nm_hinmei_ja
				,keikaku.nm_hinmei_en
				,keikaku.nm_hinmei_zh
				,keikaku.nm_hinmei_vi
				,keikaku.nm_hinmei_ryaku
				,keikaku.nm_nisugata_hyoji
				,keikaku.su_seizo_yotei
				,CASE WHEN keikaku.flg_jisseki = @true THEN keikaku.su_seizo_jisseki ELSE null END AS su_seizo_jisseki
				,keikaku.flg_jisseki	AS flg_seihin_jisseki	-- 製造実績フラグ
				,keikaku.no_lot_seihin
				,keikaku.su_batch_keikaku
				,shikakari.flg_shikakari_jisseki				-- 仕込実績フラグ
				,shikakari.flg_shikomi							-- 仕込計画確定フラグ
				,shikakari.flg_label
				,shikakari.flg_label_hasu
				 -- 倍率
				,CASE WHEN keikaku.cd_hinmei IS NOT NULL
				 THEN (SELECT TOP 1 ritsu_kihon FROM udf_HaigoRecipeYukoHan(keikaku.cd_haigo, @false, calendar.dt_hizuke))
				 ELSE NULL END AS ritsu_kihon
				 -- 合計配合重量
				,CASE WHEN keikaku.cd_hinmei IS NOT NULL
				 THEN (SELECT TOP 1 wt_haigo_gokei FROM udf_HaigoRecipeYukoHan(keikaku.cd_haigo, @false, calendar.dt_hizuke))
				 ELSE 0 END AS wt_haigo_gokei
				,keikaku.cd_haigo
				,keikaku.wt_ko
				,keikaku.su_iri
				 -- 歩留
				,CASE WHEN keikaku.cd_hinmei IS NOT NULL
				 THEN (SELECT TOP 1 ritsu_budomari_mei FROM udf_HaigoRecipeYukoHan(keikaku.cd_haigo, @false, calendar.dt_hizuke))
				 ELSE NULL END AS haigo_budomari
				,ROW_NUMBER() OVER (ORDER BY calendar.dt_hizuke) AS RN
				,keikaku.dt_update
			FROM 
				(
					SELECT 
						ma_calendar.dt_hizuke 
						,ma_calendar.flg_kyujitsu
						,tr_line_kyujitsu.cd_line
						,ma_line.nm_line
						,tr_line_kyujitsu.cd_riyu
						,ma_riyu.nm_riyu
					FROM ma_calendar ma_calendar
					LEFT OUTER JOIN tr_line_kyujitsu 
					ON ma_calendar.dt_hizuke = tr_line_kyujitsu.dt_seizo
					LEFT OUTER JOIN  ma_riyu 
					ON tr_line_kyujitsu.cd_riyu = ma_riyu.cd_riyu
					AND ma_riyu.kbn_bunrui_riyu = @kbn_riyu -- 区分一覧＃理由区分＃休日理由 
					LEFT OUTER JOIN ma_line
					ON tr_line_kyujitsu.cd_line = ma_line.cd_line
				) calendar
			LEFT OUTER JOIN 
				(
					SELECT 
						tr_keikaku_seihin.dt_seizo
						,tr_keikaku_seihin.cd_shokuba
						,ma_shokuba.nm_shokuba
						,tr_keikaku_seihin.cd_line
						,ma_line.nm_line
						,tr_keikaku_seihin.cd_hinmei
						,ma_hinmei.nm_hinmei_ja
						,ma_hinmei.nm_hinmei_en
						,ma_hinmei.nm_hinmei_zh
						,ma_hinmei.nm_hinmei_vi
						,ma_hinmei.nm_hinmei_ryaku
						,ma_hinmei.nm_nisugata_hyoji
						,tr_keikaku_seihin.su_seizo_yotei
						,tr_keikaku_seihin.su_seizo_jisseki
						,tr_keikaku_seihin.flg_jisseki
						,tr_keikaku_seihin.no_lot_seihin
						,tr_keikaku_seihin.su_batch_keikaku
						,ma_hinmei.cd_haigo
						,ma_hinmei.wt_ko
						,ma_hinmei.su_iri
						,tr_keikaku_seihin.dt_update
					FROM  tr_keikaku_seihin
					LEFT OUTER JOIN ma_line
					ON tr_keikaku_seihin.cd_line = ma_line.cd_line
					AND ma_line.flg_mishiyo = @flg_mishiyo --未使用フラグ
					LEFT OUTER JOIN ma_shokuba
					ON tr_keikaku_seihin.cd_shokuba = ma_shokuba.cd_shokuba
					AND ma_shokuba.flg_mishiyo = @flg_mishiyo --未使用フラグ
					LEFT OUTER JOIN ma_hinmei
					ON tr_keikaku_seihin.cd_hinmei = ma_hinmei.cd_hinmei
					WHERE 
						-- 先に職場、ラインでの絞り込みを行うか検討
						(
							(
								@isAllLine = @false
								AND tr_keikaku_seihin.cd_line = @cd_line
							)
							OR ( @isAllLine = @true -- 全ライン抽出時は不要
							)
						)
						AND tr_keikaku_seihin.cd_shokuba = @cd_shokuba
				) keikaku
				ON calendar.dt_hizuke = keikaku.dt_seizo
				
				LEFT OUTER JOIN
						(
							SELECT 
							tr_shikakari.no_lot_seihin
							,IsNull(MAX(su_shikakari.flg_shikomi),0) AS flg_shikomi
							,IsNull(MAX(su_shikakari.flg_jisseki),0) AS flg_shikakari_jisseki
							,IsNull(MAX(su_shikakari.flg_label),0) AS flg_label
							,IsNull(MAX(su_shikakari.flg_label_hasu),0) AS flg_label_hasu

							FROM tr_keikaku_shikakari tr_shikakari

							LEFT OUTER JOIN su_keikaku_shikakari su_shikakari
							ON tr_shikakari.no_lot_shikakari = su_shikakari.no_lot_shikakari

							WHERE 
							tr_shikakari.no_lot_seihin IS NOT NULL

							GROUP BY  tr_shikakari.no_lot_seihin
				
						) shikakari
				
						ON  keikaku.no_lot_seihin = shikakari.no_lot_seihin
						
				WHERE 
					calendar.dt_hizuke >= @dt_hiduke_from
					AND calendar.dt_hizuke <=  @dt_hiduke_to
		)
		-- 画面に返却する値を取得
		SELECT
			cte_row.cnt
			,cte_row.dt_hizuke AS dt_seizo
			,cte_row.dt_hizuke AS dt_seizo_yobi 
			,cte_row.dt_hizuke AS dt_seizo_hidden 
			,cte_row.cd_riyu
			,cte_row.nm_riyu
			,cte_row.cd_line
			,cte_row.nm_line
			,cte_row.cd_hinmei
			,cte_row.nm_hinmei_en
			,cte_row.nm_hinmei_ja
			,cte_row.nm_hinmei_zh
			,cte_row.nm_hinmei_vi
			,cte_row.nm_nisugata_hyoji
			,cte_row.su_seizo_yotei
			,cte_row.su_seizo_jisseki
			,cte_row.flg_kyujitsu
			,cte_row.no_lot_seihin
			,@cd_shokuba AS cd_shokuba_search
			,@cd_line AS cd_line_search
			,cte_row.su_batch_keikaku
			,cte_row.ritsu_kihon
			,cte_row.wt_ko
			,cte_row.su_iri
			,cte_row.cd_haigo
			,cte_row.wt_haigo_gokei
			,cte_row.haigo_budomari
			,CAST(cte_row.RN AS varchar) AS id
			,cte_row.flg_seihin_jisseki
			,cte_row.flg_shikakari_jisseki
			,cte_row.flg_shikomi
			,cte_row.flg_label
			,cte_row.flg_label_hasu
			,cte_row.dt_update
		FROM(
				SELECT 
					MAX(RN) OVER() cnt
					,*
				FROM
					cte 
			) cte_row
		WHERE
		( 
			(
				@isExcel = @false
				AND cte_row.RN <= @top
			)
			OR (
				@isExcel = @true
			)
		)
		ORDER BY cte_row.dt_hizuke

    END
END
GO