IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikomiKeikakuHyoExcel_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikomiKeikakuHyoExcel_select]
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
CREATE PROCEDURE [dbo].[usp_ShikomiKeikakuHyoExcel_select]
    @cd_shokuba varchar(10)
    ,@cd_line varchar(10)
    ,@dt_hiduke datetime
    ,@flg_kakutei smallint
    ,@flg_mikakutei smallint
    ,@true smallint
    ,@false smallint
AS
BEGIN

    DECLARE @start decimal(10)
    DECLARE @end decimal(10)
    
	BEGIN
	
		SELECT
			ROW_NUMBER() OVER(ORDER BY shikakari_sum.cd_line, shikakari_sum.no_lot_shikakari) AS row
			,shikakari_sum.flg_shikomi 
			,shikakari_sum.cd_shikakari_hin
			,shikakari_sum.dt_seizo
			--,shikakari_sum.wt_hitsuyo
			,COALESCE(CEILING(shikakari_sum.wt_hitsuyo * 1000)/1000,0.000) AS wt_hitsuyo 
			--,shikakari_sum.wt_shikomi_keikaku
			,COALESCE(CEILING(shikakari_sum.wt_shikomi_keikaku * 1000)/1000,0.000) AS wt_shikomi_keikaku
			--,( shikakari_sum.wt_shikomi_keikaku 
			-- - shikakari_sum.wt_hitsuyo  ) AS wt_zan_shikakari
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
				FROM ma_haigo_mei haigo_mei
				INNER JOIN
				(
					SELECT
						haigomei.cd_haigo
						,no_han
					FROM ma_haigo_mei haigomei
					INNER JOIN
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
					ON haigomei.cd_haigo = yukohaigo.cd_haigo
					AND haigomei.dt_from = yukohaigo.dt_from
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
		ORDER BY
			shikakari_sum.cd_line
			,shikakari_sum.no_lot_shikakari
    END
END
GO
