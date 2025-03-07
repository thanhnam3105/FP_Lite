IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikakarihinShikomiKeikaku_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikakarihinShikomiKeikaku_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author,,kobayashi.y>
-- Create date: <Create Date,,2013.09.25>
-- Last Update: <2023.07.28,,BRC.quang>#2184対応
-- Description: <Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[usp_ShikakarihinShikomiKeikaku_select]
    @cd_shokuba varchar(10)
    ,@cd_line varchar(10)
    ,@dt_hiduke datetime
    ,@flg_kakutei smallint
    ,@flg_mikakutei smallint
    ,@skip decimal(10)
    ,@top decimal(10)
    ,@true smallint
    ,@false smallint
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
		shikakari_sum.flg_shikomi 
		,shikakari_sum.cd_shikakari_hin
		,shikakari_sum.dt_seizo
		--,shikakari_sum.wt_hitsuyo 
		,COALESCE(CEILING(shikakari_sum.wt_hitsuyo * 1000)/1000,0.000) AS wt_hitsuyo 
		--,shikakari_sum.wt_shikomi_keikaku
		,COALESCE(CEILING(shikakari_sum.wt_shikomi_keikaku * 1000)/1000,0.000) AS wt_shikomi_keikaku
		--,( shikakari_sum.wt_shikomi_keikaku 
		--	- shikakari_sum.wt_hitsuyo  ) AS wt_zan_shikakari
		,CEILING(ISNULL(shikakari_sum.wt_shikomi_keikaku,0.000)*1000)/1000
			- CEILING(ISNULL(shikakari_sum.wt_hitsuyo,0.000)*1000)/1000 AS wt_zan_shikakari
		,shikakari_sum.ritsu_keikaku
		,shikakari_sum.ritsu_keikaku_hasu
		,shikakari_sum.su_batch_keikaku
		,shikakari_sum.su_batch_keikaku_hasu
		,shikakari_sum.su_label_sumi
		,shikakari_sum.su_label_sumi_hasu
		,shikakari_sum.flg_label
		,shikakari_sum.flg_label_hasu
		,shikakari_sum.no_lot_shikakari
		,line.nm_line
		,haigo.nm_tani
		,haigo.nm_haigo_en
		,haigo.nm_haigo_ja
		,haigo.nm_haigo_zh
		,haigo.nm_haigo_vi
		,shikakari_sum.cd_line
		,haigo.wt_haigo_gokei
		,haigo.ritsu_kihon
		,haigo.wt_haigo_gokei * shikakari_sum.ritsu_keikaku * shikakari_sum.su_batch_keikaku AS wt_haigo_keikaku
		,haigo.wt_haigo_gokei * shikakari_sum.ritsu_keikaku_hasu * shikakari_sum.su_batch_keikaku_hasu AS wt_haigo_keikaku_hasu
		,haigo.flg_tanto_hinkan
		,haigo.flg_tanto_seizo
		,shikakari_sum.flg_jisseki
		,ROW_NUMBER() OVER (ORDER BY
			shikakari_sum.cd_line
			,shikakari_sum.no_lot_shikakari) AS RN
	FROM 
		su_keikaku_shikakari shikakari_sum
		LEFT OUTER JOIN ma_line line
		ON shikakari_sum.cd_line = line.cd_line
		LEFT OUTER JOIN
			(
				SELECT 
					haigo_mei.cd_haigo
					,haigo_mei.nm_haigo_en
					,haigo_mei.nm_haigo_ja
					,haigo_mei.nm_haigo_zh
					,haigo_mei.nm_haigo_vi
					,haigo_mei.wt_haigo_gokei
					,haigo_mei.ritsu_budomari
					,haigo_mei.ritsu_kihon
					,tani.nm_tani
					,haigo_mei.flg_tanto_hinkan
					,haigo_mei.flg_tanto_seizo
				FROM ma_haigo_mei haigo_mei
				INNER JOIN
				(
					SELECT
						haigomei.cd_haigo
						,no_han
					FROM ma_haigo_mei haigomei
					inner join
					(
						SELECT 
							cd_haigo
							,MAX(dt_from) AS dt_from
						FROM ma_haigo_mei 
						WHERE 
							dt_from <= @dt_hiduke
							AND flg_mishiyo = @false
						GROUP BY 
							cd_haigo
					) yukohaigo
					on haigomei.cd_haigo = yukohaigo.cd_haigo
					and haigomei.dt_from = yukohaigo.dt_from
				) yuko
				ON haigo_mei.cd_haigo = yuko.cd_haigo
				AND haigo_mei.no_han = yuko.no_han
				LEFT OUTER JOIN ma_tani tani
				ON haigo_mei.kbn_kanzan = tani.cd_tani
			) AS haigo
		ON shikakari_sum.cd_shikakari_hin = haigo.cd_haigo
	WHERE
		
			shikakari_sum.dt_seizo = @dt_hiduke
			AND shikakari_sum.cd_shokuba = @cd_shokuba
			AND shikakari_sum.cd_line = CASE WHEN ISNULL(@cd_line, '') = '' THEN shikakari_sum.cd_line ELSE @cd_line END
			AND -- 確定/未確定
			(
				(
					@flg_kakutei = @true
					AND @flg_mikakutei = @false
					AND shikakari_sum.flg_shikomi = @true
				) OR (
					@flg_kakutei = @false
					AND @flg_mikakutei = @true
					AND shikakari_sum.flg_shikomi = @false
				) OR (
					@flg_kakutei = @true
					AND @flg_mikakutei = @true
				) OR (
					@flg_kakutei = @false
					AND @flg_mikakutei = @false
					AND @true = @false
				)
			)
			AND haigo.cd_haigo is not null
		
	)
	SELECT
		cte_row.cnt
		,cte_row.flg_shikomi 
		,cte_row.cd_shikakari_hin
		,cte_row.dt_seizo
		,cte_row.wt_hitsuyo 
		,cte_row.wt_shikomi_keikaku
		,cte_row.wt_zan_shikakari
		,cte_row.ritsu_keikaku
		,cte_row.ritsu_keikaku_hasu
		,cte_row.su_batch_keikaku
		,cte_row.su_batch_keikaku_hasu
		,cte_row.su_label_sumi
		,cte_row.su_label_sumi_hasu
		,cte_row.flg_label
		,cte_row.flg_label_hasu
		,cte_row.no_lot_shikakari
		,cte_row.nm_line
		,cte_row.nm_tani
		,cte_row.nm_haigo_en
		,cte_row.nm_haigo_ja
		,cte_row.nm_haigo_zh
		,cte_row.nm_haigo_vi
		,cte_row.cd_line
		,@cd_shokuba AS cd_shokuba
		,cte_row.uchiwake
		,cte_row.wt_haigo_gokei
		,cte_row.ritsu_kihon
		,cte_row.wt_haigo_keikaku
		,cte_row.wt_haigo_keikaku_hasu
		,cte_row.flg_tanto_hinkan
		,cte_row.flg_tanto_seizo
		,cte_row.flg_jisseki
	FROM
		(
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
				) AS uchiwake
			FROM
				cte 
		) cte_row
	WHERE
		cte_row.RN <= @top
	END
END
GO
