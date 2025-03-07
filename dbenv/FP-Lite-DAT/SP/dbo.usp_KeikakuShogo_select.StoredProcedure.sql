IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KeikakuShogo_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KeikakuShogo_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：計画照合 明細検索
ファイル名	：usp_KeikakuShogo_select01
入力引数	：@dt_seizo, @flg_shikomi, @cd_shokuba
              , @no_kotei, @flg_hoshin, @flg_mishiyo
              , @skip, @top
出力引数	：
戻り値		：
作成日		：2013.11.14  ADMAX endo.y
更新日		：2017.12.07  BRC cho.k  端数倍率0時でも端数計画が立つ不具合を修正
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KeikakuShogo_select]
	@dt_seizo		DATETIME
	,@flg_shikomi	SMALLINT
	,@cd_shokuba	VARCHAR(10)
	,@no_kotei		DECIMAL(4)
	,@flg_hoshin	SMALLINT
	,@flg_mishiyo	SMALLINT
	,@skip			DECIMAL(10)
	,@top			DECIMAL(10)
AS
BEGIN
	DECLARE @start	DECIMAL(10)
	        ,@end	DECIMAL(10)
	        ,@day	SMALLINT
	SET @start = @skip + 1
	SET @end   = @skip + @top
	SET @day   = 1

	BEGIN
		WITH cte AS
			(    
				SELECT
					sks.cd_line
					,ml.nm_line
					,sks.cd_shikakari_hin
					,ISNULL(mhm.nm_haigo_ja, '') AS nm_haigo_ja
					,ISNULL(mhm.nm_haigo_en, '') AS nm_haigo_en
					,ISNULL(mhm.nm_haigo_zh, '') AS nm_haigo_zh
					,ISNULL(mhm.nm_haigo_vi, '') AS nm_haigo_vi
					,sks.su_batch_keikaku
					--,sks.su_batch_keikaku_hasu
					,CASE
					  -- 端数バッチ数は、端数倍率が0.00の場合は0
					  WHEN ISNULL(sks.ritsu_keikaku_hasu, 0.00) = 0.00 THEN 0
					  ELSE sks.su_batch_keikaku_hasu
					 END AS su_batch_keikaku_hasu
					,sks.ritsu_keikaku
					--,sks.ritsu_keikaku_hasu
					,CASE
					  -- 端数倍率数は、端数バッチ数が0の場合は0.00
					  WHEN ISNULL(sks.su_batch_keikaku_hasu, 0) = 0 THEN 0.00
					  ELSE sks.ritsu_keikaku_hasu
					 END AS ritsu_keikaku_hasu
					,sks.no_lot_shikakari AS no_lot
					,mhm.wt_haigo
					,mhm.flg_shorihin
					,mhr.no_kotei
					,tt.kbn_kyosei
					,mhm.no_han
					,ROW_NUMBER() OVER (ORDER BY sks.no_lot_shikakari) AS RN
				FROM su_keikaku_shikakari sks
				LEFT OUTER JOIN ma_haigo_mei mhm
				ON mhm.cd_haigo = sks.cd_shikakari_hin
				LEFT OUTER JOIN ma_line ml
				ON ml.cd_line = sks.cd_line
				LEFT OUTER JOIN
					(
						SELECT
							no_kotei,cd_haigo
						FROM ma_haigo_recipe
						GROUP BY
							no_kotei
							,cd_haigo
					) mhr
				ON mhr.cd_haigo = sks.cd_shikakari_hin
				LEFT OUTER JOIN tr_tonyu tt
				ON tt.no_lot_seihin = sks.no_lot_shikakari
				AND tt.no_kotei = @no_kotei
				WHERE
					@dt_seizo <= sks.dt_seizo
					AND sks.dt_seizo <
						(
							SELECT DATEADD(DD,@day,@dt_seizo)
						)
					AND sks.flg_shikomi = @flg_shikomi
					AND sks.cd_shokuba  = @cd_shokuba
					AND mhm.no_han =
						(
							SELECT
								MAX(no_han) AS no_han
							FROM ma_haigo_mei
							WHERE
								ma_haigo_mei.cd_haigo = sks.cd_shikakari_hin
								AND ma_haigo_mei.wt_haigo = CAST(mhm.wt_kihon AS DECIMAL(12,6))
								AND ma_haigo_mei.flg_mishiyo = @flg_mishiyo
								AND ma_haigo_mei.dt_from <
									(
										SELECT DATEADD(DD,@day,@dt_seizo)
									)
						)
					AND mhr.no_kotei = @no_kotei
					AND (
							tt.kbn_kyosei = @flg_hoshin
							OR tt.kbn_kyosei IS NULL
						)
			)
		SELECT
			cnt
			,cte_row.cd_line
			,cte_row.nm_line
			,cte_row.cd_shikakari_hin
			,cte_row.nm_haigo_ja
			,cte_row.nm_haigo_en
			,cte_row.nm_haigo_zh
			,cte_row.nm_haigo_vi
			,cte_row.su_batch_keikaku
			,cte_row.su_batch_keikaku_hasu
			,cte_row.ritsu_keikaku
			,cte_row.ritsu_keikaku_hasu
			,cte_row.no_lot
			,cte_row.wt_haigo
			,cte_row.flg_shorihin
			,cte_row.no_kotei
			,cte_row.kbn_kyosei
			,cte_row.no_han
		FROM
			(
				SELECT
					MAX(RN) OVER() AS cnt
					,*
				FROM cte
			) cte_row
		WHERE
			RN BETWEEN @start AND @end
	END
END
GO