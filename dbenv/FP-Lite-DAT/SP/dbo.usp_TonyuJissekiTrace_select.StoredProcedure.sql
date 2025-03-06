IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_TonyuJissekiTrace_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_TonyuJissekiTrace_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：投入実績トレース画面　検索
ファイル名	：usp_TonyuJissekiTrace_select
入力引数	：@chk_dt_yotei, @dt_yotei_st, @dt_yotei_en,
			  @chk_dt_jisseki, @dt_jisseki_st, @dt_jisseki_en,
			  @chk_cd_shokuba, @cd_shokuba, @chk_cd_line,
			  @cd_line, @chk_genryo, @genryoLot,
			  @chk_cd_genryo, @cd_genryo, @chk_cd_haigo,
			  @cd_haigo, @no_tonyu, @skip, @top, @isExcel
出力引数	：	
戻り値		：
作成日		：2014.01.16  ADMAX endo.y
更新日		：2016.01.04  matsushita.y  配合名を投入開始トランから取得するよう修正
更新日		：2017.02.17  motojima.m    投入実績の文字化けを修正
更新日		：2018.05.15  tokumoto.k    開封前賞味期限追加
*****************************************************/
CREATE  PROCEDURE [dbo].[usp_TonyuJissekiTrace_select](
	@chk_dt_yotei		SMALLINT	--検索条件/ミキサー製造予定日チェック
	,@dt_yotei_st		DATETIME	--検索条件/ミキサー製造予定日(開始)
	,@dt_yotei_en		DATETIME	--検索条件/ミキサー製造予定日(終了)
	,@chk_dt_jisseki	SMALLINT	--検索条件/ミキサー製造実績日チェック
	,@dt_jisseki_st		DATETIME    --検索条件/ミキサー製造実績日(開始)
	,@dt_jisseki_en		DATETIME	--検索条件/ミキサー製造実績日(終了)
	,@chk_cd_shokuba	SMALLINT	--検索条件/職場チェック
	,@cd_shokuba		VARCHAR(10)	--検索条件/職場
	,@chk_cd_line		SMALLINT	--検索条件/ラインチェック
	,@cd_line			VARCHAR(10)	--検索条件/ライン
	,@chk_genryo		SMALLINT	--検索条件/荷姿原料ロットチェック
	,@genryoLot			VARCHAR(50)	--検索条件/荷姿原料ロット
	,@chk_cd_genryo		SMALLINT	--検索条件/原料コードチェック
	,@cd_genryo			VARCHAR(14)	--検索条件/原料
	,@chk_cd_haigo		SMALLINT	--検索条件/配合コードチェック
	,@cd_haigo			VARCHAR(14)	--検索条件/配合
	,@no_tonyu			SMALLINT	--検索条件/投入順番１のみ
	,@skip				DECIMAL(10)
	,@top				DECIMAL(10)
	,@lang				VARCHAR(10)
	,@isExcel			BIT
)
AS
BEGIN
    DECLARE  @start				DECIMAL(10)
    DECLARE  @end				DECIMAL(10)
	DECLARE  @true				BIT
	DECLARE  @false				BIT
	DECLARE  @day				SMALLINT
	DECLARE  @yotei_start		DATETIME
	DECLARE  @yotei_end			DATETIME
	DECLARE  @jisseki_start		DATETIME
	DECLARE  @jisseki_end		DATETIME
	DECLARE  @param				VARCHAR(3)
    SET      @start = @skip + 1
    SET      @end   = @skip + @top
    SET      @true  = 1
    SET      @false = 0
    SET		 @day   = 1
	SET @param = 'P%'
    BEGIN
		WITH cte AS
		(    
			SELECT
				tt.dt_yotei_seizo AS dt_yotei
				,tt.dt_shori AS dt_seizo
				,tt.dt_shori AS dt_shori
				,ml.nm_line
				,tt.cd_haigo
				--,CASE @lang WHEN 'ja' THEN mhm.nm_haigo_ja
				--			WHEN 'en' THEN mhm.nm_haigo_en
				--			WHEN 'zh' THEN mhm.nm_haigo_zh
				--END AS nm_haigo
				,tts.nm_haigo
				--,mhm.nm_haigo_ja AS nm_haigo
				,tt.cd_hinmei AS cd_genryo
				,tt.nm_hinmei AS nm_genryo
				,tt.nm_mark
				,tt.no_kotei
				,tt.su_kai
				,tt.no_tonyu
				--,tt.su_ko
				--,ROUND(tt.wt_haigo,3) AS qty_haigo
				,tt.wt_haigo AS qty_haigo
				--,ISNULL(CAST(tk.wt_jisseki AS VARCHAR),tt.nm_naiyo_jisseki) AS qty_jiseki_1
				,ISNULL(CAST(tk.wt_jisseki AS NVARCHAR),tt.nm_naiyo_jisseki) AS qty_jiseki_1
				--,ROUND(tt.wt_nisugata,3) AS qty_nisugata
				,tt.wt_nisugata AS qty_nisugata
				,tt.su_nisugata
				--,ROUND(tt.wt_kowake,3) AS qty_kowake
				,tt.wt_kowake AS qty_kowake
				,tt.su_kowake
				--,ROUND(tt.wt_kowake_hasu,3) AS qty_kowake_hasu
				,tt.wt_kowake_hasu AS qty_kowake_hasu
				,tt.su_kowake_hasu
				--,CASE
				--	WHEN tt.no_lot  LIKE @param THEN ''
				--	ELSE tt.no_lot 
				--	END AS no_lot
				--,tt.no_lot
				--,ISNULL(tkn.old_no_lot, ISNULL(tl.no_lot, tt.no_lot)) AS no_lot
				,ISNULL(tl.no_lot, tt.no_lot) AS no_lot
				,CASE WHEN tk.dt_shomi IS NOT NULL THEN tk.dt_shomi
				 ELSE tt.dt_shomi
				 END AS dt_shomi_mikaifu
				--,tt.dt_shomi AS dt_shomi
				,ISNULL(tt.dt_shomi,tk.dt_shomi_kaifu) AS dt_shomi
				,tt.nm_tani
				,tt.ritsu_hiju AS hijyu
				,mt.nm_tanto
				,ms.nm_shokuba
				,tt.cd_shokuba
				,tt.cd_line
				,ROW_NUMBER() OVER (ORDER BY 
										tt.cd_shokuba,
										tt.dt_yotei_seizo,
										tt.dt_shori,
										tt.cd_line,
										tt.cd_haigo,
										tt.no_kotei,
										tt.su_kai,
										tt.no_tonyu
										--tt.su_ko
									) AS RN

			FROM tr_tonyu tt
				LEFT OUTER JOIN tr_kowake tk
					ON tt.no_lot_seihin = tk.no_lot_seihin
					AND tt.no_kotei = tk.no_kotei
					AND tt.no_tonyu = tk.no_tonyu
					AND tt.dt_shori = tk.dt_tonyu	
					AND tt.su_ko_label = tk.su_ko		
					AND tt.su_kai = tk.su_kai
					AND tt.cd_hinmei = tk.cd_hinmei
					AND tt.cd_line = tk.cd_line
					AND tt.kbn_seikihasu = tk.kbn_seikihasu		
				LEFT OUTER JOIN tr_lot tl
					ON tk.no_lot_kowake = tl.no_lot_jisseki		
				--LEFT OUTER JOIN tr_kongo_nisugata tkn
				--	ON tl.no_lot = tkn.old_no_lot
				LEFT OUTER JOIN ma_line ml
					ON ml.cd_line = tt.cd_line
				LEFT OUTER JOIN ma_shokuba ms
					ON ms.cd_shokuba = tt.cd_shokuba
				LEFT OUTER JOIN ma_tanto mt
					ON mt.cd_tanto = tt.cd_tanto
				--LEFT OUTER JOIN ma_haigo_mei mhm
				--	ON mhm.cd_haigo = tt.cd_haigo
				--	AND mhm.no_han = 1
				LEFT OUTER JOIN tr_tonyu_start tts
					ON tts.cd_haigo = tt.cd_haigo
					AND tts.no_kotei = tt.no_kotei
					AND tts.su_kai = tt.su_kai
					AND tts.no_lot_seihin = tt.no_lot_seihin
					AND tts.kbn_seikihasu = tt.kbn_seikihasu
					AND tts.cd_line = tt.cd_line

			WHERE ((@chk_cd_shokuba = @false) OR ms.cd_shokuba = @cd_shokuba)
				and ((@chk_dt_yotei = @false) 
						or ( tt.dt_yotei_seizo >= @dt_yotei_st and tt.dt_yotei_seizo < DATEADD(DD,@day,@dt_yotei_en))
					)
				and ((@chk_dt_jisseki = @false) 
						or ( tt.dt_shori >= @dt_jisseki_st and tt.dt_shori < DATEADD(DD,@day,@dt_jisseki_en))
					)
				AND ((@chk_cd_line = @false) OR ml.cd_line = @cd_line)
				--AND ((@chk_genryo = @false) OR tt.no_lot = @genryoLot)
				AND ((@chk_genryo = @false)
					--OR ISNULL(tkn.old_no_lot, ISNULL(tl.no_lot, tt.no_lot)) = @genryoLot
					OR ISNULL(tl.no_lot, tt.no_lot) = @genryoLot
					)
				AND ((@chk_cd_genryo = @false) OR tt.cd_hinmei = @cd_genryo)
				AND ((@chk_cd_haigo = @false) OR tt.cd_haigo = @cd_haigo)
				AND ((@no_tonyu = @false) OR tt.no_tonyu = @no_tonyu)
					
			--		AND ((@chk_dt_yotei = @false) 
			--			OR ( tt.dt_yotei >= @yotei_start
			--				AND tt.dt_yotei < @yotei_end
			--			)
			--		)
			--		AND ((@chk_dt_jisseki = @false) 
			--			OR ( tt.dt_shori >= @jisseki_start
			--				AND tt.dt_shori < @jisseki_end
			--			)
			--		)
			--		AND ((@chk_cd_line = @false) OR ml.cd_line = @cd_line)
			--		AND ((@chk_genryo = @false) OR tt.no_lot = @genryoLot)
			--		AND ((@chk_cd_genryo = @false) OR tt.cd_genryo = @cd_genryo)
			--		AND ((@chk_cd_haigo = @false) OR tt.cd_haigo = @cd_haigo)
			--		AND ((@no_tonyu = @false) OR tt.no_tonyu = @no_tonyu)
		)
		-- 画面に返却する値を取得
		SELECT
			cnt
			, cte_row.dt_yotei
			, cte_row.dt_seizo
			, cte_row.dt_shori
			, cte_row.nm_line
			, cte_row.cd_haigo
			, cte_row.nm_haigo
			, cte_row.cd_genryo
			, cte_row.nm_genryo
			, cte_row.nm_mark
			, cte_row.no_kotei
			, cte_row.su_kai
			, cte_row.no_tonyu
			--, cte_row.su_ko
			, cte_row.qty_haigo
			, cte_row.qty_jiseki_1
			, cte_row.qty_nisugata
			, cte_row.su_nisugata
			, cte_row.qty_kowake
			, cte_row.su_kowake
			, cte_row.qty_kowake_hasu
			, cte_row.su_kowake_hasu
			, cte_row.no_lot
			, cte_row.dt_shomi_mikaifu
			, cte_row.dt_shomi
			, cte_row.nm_tani
			, cte_row.hijyu
			, cte_row.nm_tanto
			, cte_row.nm_shokuba
			, cte_row.cd_shokuba
			, cte_row.cd_line
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
				AND RN BETWEEN @start AND @end
			)
			OR (
				@isExcel = @true
			)
		)
		ORDER BY
			cte_row.dt_yotei
			, cte_row.nm_line
			, cte_row.cd_haigo
			, cte_row.no_kotei
			, cte_row.su_kai
			, cte_row.no_tonyu
			, cte_row.su_nisugata
	END
END

GO
