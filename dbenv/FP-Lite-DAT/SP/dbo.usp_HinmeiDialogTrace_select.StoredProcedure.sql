IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HinmeiDialogTrace_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HinmeiDialogTrace_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能			：マスタ検索画面　検索
ファイル名	：usp_HinmeiDialogTrace_select
入力引数		：@kbn, @kbnDialog, @hinmei, 
			  @flg_mishiyo, @skip, @top,
			  @lang, @kbnSeihin, @kbnGenryo, @kbnJikaGenryo
出力引数		：	
戻り値		：
作成日		：2014.02.07  ADMAX endo.y
更新日		：2015.12.25  matsushita.y
更新日		：2016.04.04  Khang（製品検索追加）
更新日		：2016.06.06  Khang（未使用フラグを消し）
更新日		：2016.12.13  motojima.m（中文対応）
*****************************************************/
CREATE  PROCEDURE [dbo].[usp_HinmeiDialogTrace_select](
	@kbn				SMALLINT
	,@kbnDialog			SMALLINT
	--,@hinmei			VARCHAR(60)
	,@hinmei			NVARCHAR(60)
	,@flg_mishiyo		SMALLINT
	,@skip				DECIMAL(10)
	,@top				DECIMAL(10)
	,@lang				VARCHAR(10)
	,@kbnSeihin			SMALLINT
	,@kbnGenryo			SMALLINT
	,@kbnJikaGenryo		SMALLINT
)
AS
BEGIN
	DECLARE @start		DECIMAL(10)
    DECLARE @end		DECIMAL(10)
    DECLARE @chkMishiyo	DECIMAL(10)
    SET		@start	= @skip + 1
    SET		@end	= @skip + @top
    SET		@chkMishiyo	= 1

IF @kbn = 0				-- 原料から開かれた場合
	BEGIN

	WITH cte AS
	(
		SELECT
			mh.cd_hinmei AS cd_hin
			,CASE @lang WHEN 'ja' THEN mh.nm_hinmei_ja
						WHEN 'en' THEN mh.nm_hinmei_en
						WHEN 'zh' THEN mh.nm_hinmei_zh
						WHEN 'vi' THEN mh.nm_hinmei_vi
			END AS nm_hin
			--,mh.nm_hinmei_ja AS nm_hin
			,0 AS no_han
			,mh.nm_nisugata_hyoji AS nisugata_hyoji
			,mh.flg_mishiyo
			,ROW_NUMBER() OVER (ORDER BY cd_hinmei) AS RN
		FROM ma_hinmei mh
		WHERE (mh.kbn_hin = @kbnGenryo OR mh.kbn_hin = @kbnJikaGenryo) 
			--AND (( @flg_mishiyo = @chkMishiyo) OR (flg_mishiyo = @flg_mishiyo))	-- トレースのため、未使用フラグを気にしない
			AND (
					(@kbnDialog = 1 
						AND (cd_hinmei LIKE '%' + @hinmei + '%' 
							OR (CASE @lang WHEN 'ja' THEN nm_hinmei_ja
								WHEN 'en' THEN nm_hinmei_en
								WHEN 'zh' THEN nm_hinmei_zh 
								WHEN 'vi' THEN nm_hinmei_vi END LIKE '%' + @hinmei + '%'
								)
							)
					)
					OR (@kbnDialog = 0 AND cd_hinmei = @hinmei)
				)
	)
		SELECT
			cnt
			, cte_row.cd_hin
			, cte_row.nm_hin
			, cte_row.no_han
			, cte_row.nisugata_hyoji
		FROM(
			SELECT 
				MAX(RN) OVER() cnt
				,*
			FROM
				cte 
			) cte_row
		WHERE
			 RN BETWEEN @start AND @end
	END
	
ELSE IF @kbn = 1					-- 配合から開かれた場合
	BEGIN

	WITH cte AS
	(
		SELECT 
			mhm.cd_haigo AS cd_hin
			,CASE @lang WHEN 'ja' THEN mhm.nm_haigo_ja
						WHEN 'en' THEN mhm.nm_haigo_en
						WHEN 'zh' THEN mhm.nm_haigo_zh
						WHEN 'vi' THEN mhm.nm_haigo_vi
			END AS nm_hin
			--,mhm.nm_haigo_ja AS nm_hin
			,CAST(mhm.no_han as int) AS no_han
			,CONVERT(VARCHAR,mhm.wt_kihon) AS nisugata_hyoji
			,ROW_NUMBER() OVER (ORDER BY mhm.cd_haigo) AS RN
		FROM ma_haigo_mei mhm
		WHERE --mhm.flg_sakujyo = 0
			--(( @flg_mishiyo = @chkMishiyo) OR (mhm.flg_mishiyo = @flg_mishiyo))	-- トレースのため、未使用フラグを気にしない
			(
				--(@kbnDialog = 1 AND (mhm.cd_haigo LIKE '%' + @hinmei + '%' OR mhm.nm_haigo_ja LIKE '%' + @hinmei + '%'))
					(@kbnDialog = 1 
						AND (mhm.cd_haigo LIKE '%' + @hinmei + '%' 
							OR (CASE @lang WHEN 'ja' THEN mhm.nm_haigo_ja
								WHEN 'en' THEN mhm.nm_haigo_en
								WHEN 'zh' THEN mhm.nm_haigo_zh
								WHEN 'vi' THEN mhm.nm_haigo_vi END LIKE '%' + @hinmei + '%'
								)
							)
					)
				OR (@kbnDialog = 0 AND mhm.cd_haigo = @hinmei)
			)
	)
		SELECT
			cnt
			, cte_row.cd_hin
			, cte_row.nm_hin
			, cte_row.no_han
			, cte_row.nisugata_hyoji
		FROM(
			SELECT 
				MAX(RN) OVER() cnt
				,*
			FROM
				cte 
			) cte_row
		WHERE
			RN BETWEEN @start AND @end
	END

ELSE IF @kbn = 2				-- 製品と自家原料から開かれた場合
	BEGIN

	WITH cte AS
	(
		SELECT
			mh.cd_hinmei AS cd_hin
			,CASE @lang WHEN 'ja' THEN mh.nm_hinmei_ja
						WHEN 'en' THEN mh.nm_hinmei_en
						WHEN 'zh' THEN mh.nm_hinmei_zh
						WHEN 'vi' THEN mh.nm_hinmei_vi
			END AS nm_hin
			--,mh.nm_hinmei_ja AS nm_hin
			,0 AS no_han
			,mh.nm_nisugata_hyoji AS nisugata_hyoji
			,mh.flg_mishiyo
			,ROW_NUMBER() OVER (ORDER BY cd_hinmei) AS RN
		FROM ma_hinmei mh
		WHERE (mh.kbn_hin = @kbnSeihin OR mh.kbn_hin = @kbnJikaGenryo) 
			--AND (( @flg_mishiyo = @chkMishiyo) OR (flg_mishiyo = @flg_mishiyo))	-- トレースのため、未使用フラグを気にしない
			AND (
					(@kbnDialog = 1 
						AND (cd_hinmei LIKE '%' + @hinmei + '%' 
							OR (CASE @lang WHEN 'ja' THEN nm_hinmei_ja
								WHEN 'en' THEN nm_hinmei_en
								WHEN 'zh' THEN nm_hinmei_zh
								WHEN 'vi' THEN nm_hinmei_vi END LIKE '%' + @hinmei + '%'
								)
							)
					)
					OR (@kbnDialog = 0 AND cd_hinmei = @hinmei)
				)
	)
		SELECT
			cnt
			, cte_row.cd_hin
			, cte_row.nm_hin
			, cte_row.no_han
			, cte_row.nisugata_hyoji
		FROM(
			SELECT 
				MAX(RN) OVER() cnt
				,*
			FROM
				cte 
			) cte_row
		WHERE
			 RN BETWEEN @start AND @end
	END
END




GO