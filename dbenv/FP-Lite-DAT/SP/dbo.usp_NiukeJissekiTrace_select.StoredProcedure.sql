IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeJissekiTrace_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeJissekiTrace_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能			：荷受実績トレース画面　検索
ファイル名	：usp_NiukeJissekiTrace_select
入力引数		：@chk_dt_yotei,@dt_yotei_st,@dt_yotei_en,
			  @chk_dt_jisseki,@dt_jisseki_st,@dt_jisseki_en,
			  @chk_cd_shokuba,@cd_shokuba,@chk_cd_line,
			  @cd_line,@chk_genryo,@genryoLot,
			  @chk_cd_genryo,@cd_genryo,@chk_cd_haigo,
			  @cd_haigo,@no_tonyu,@skip,@top,@isExcel
出力引数	：	
戻り値		：
作成日		：2014.01.16  ADMAX endo.y
更新日		：2015.09.08  ADMAX taira.s
更新日		：2015.10.06  MJ    ueno.k
更新日		：2015.10.09  ADMAX taira.s
更新日		：2016.03.31  Khang
更新日		：2016.08.19  BRC motojima.m LB対応
更新日		：2017.01.26  BRC cho.k サポートNo.1対応
更新日		：2020.02.28  wang荷受け実績トレース画面にバッチ数と投入順を追加
*****************************************************/
CREATE  PROCEDURE [dbo].[usp_NiukeJissekiTrace_select](
	@cd_hinmei			VARCHAR(14)	--検索条件/品名コード
	,@chk_dt_niuke		SMALLINT	--検索条件/荷受日チェック
	,@dt_niuke_st		DATETIME	--検索条件/荷受日(開始)
	,@dt_niuke_en		DATETIME	--検索条件/荷受日(終了)
	,@chk_dt_seizo		SMALLINT	--検索条件/原料製造日チェック
	,@dt_seizo_st		DATETIME    --検索条件/原料製造日(開始)
	,@dt_seizo_en		DATETIME	--検索条件/原料製造日(終了)
	,@chk_dt_kigen		SMALLINT	--検索条件/賞味期限日チェック
	,@dt_kigen_st		DATETIME    --検索条件/賞味期限日(開始)
	,@dt_kigen_en		DATETIME	--検索条件/賞味期限日(終了)
	,@chk_no_denpyo		SMALLINT	--検索条件/伝票Noチェック
	,@no_denpyo			VARCHAR(30)	--検索条件/伝票No
	,@chk_no_lot		SMALLINT	--検索条件/ロットNoチェック
	,@genryoLot			VARCHAR(14)	--検索条件/ロットNo
	,@chk_cd_torihiki	SMALLINT	--検索条件/取引先コードチェック
	,@cd_torihiki		VARCHAR(13)	--検索条件/取引先コード
	,@skip				DECIMAL(10)
	,@top				DECIMAL(10)
	,@isExcel			BIT
)
AS
BEGIN
    DECLARE  @start				DECIMAL(10)
    DECLARE  @end				DECIMAL(10)
	DECLARE  @true				BIT
	DECLARE  @false				BIT
	DECLARE  @day				SMALLINT
    SET      @start = @skip + 1
    SET      @end   = @skip + @top
    SET      @true  = 1
    SET      @false = 0
    SET		 @day   = 1

    BEGIN
		WITH cte AS
		(
			SELECT
				*
				,ROW_NUMBER() OVER (ORDER BY 
					uni.dt_niuke,
					uni.dt_kigen,
					uni.no_lot,
					uni.dt_hyoryo_zan,
					uni.dt_kowake,
					uni.dt_shori
				) AS RN
			FROM
			(
				SELECT DISTINCT
					-- 荷受情報
					  tr.dt_niuke					AS dt_niuke				-- 荷受日
					, tr.dt_seizo_genryo			AS dt_seizo_genryo		-- 原料製造日
					, tr.dt_kigen					AS dt_kigen				-- 賞味期限日
					, tr.no_lot						AS no_lot				-- ロット番号
					, tr.no_denpyo					AS no_denpyo			-- 伝票番号
					, tr.cd_torihiki				AS cd_torihiki			-- 取引先コード
					, mt.nm_torihiki				AS nm_torihiki			-- 取引先名
					-- 製品計画
					, NULL							AS cd_seihin_keikaku	-- 製品コード
					, NULL							AS nm_seihin_keikaku	-- 製品名
					, NULL							AS dt_seizo_keikaku		-- 製造日
					, NULL							AS dt_shomi_keikaku		-- 賞味期限
					, NULL							AS no_lot_hyoji_keikaku	-- 表示ロットNo
					-- 小分情報
					, tr.dt_kowake					AS dt_kowake			-- 小分日
					, tr.cd_seihin					AS cd_seihin			-- 製品コード
					, tr.nm_seihin					AS nm_seihin			-- 製品名
					, tr.cd_line_kowake				AS cd_line_kowake		-- 小分ラインコード
					, mlk.nm_line					AS nm_line_kowake		-- 小分ライン名
					,tr.su_kai						AS su_kai				-- バッチ数
					,tr.su_ko						AS su_ko				-- 投入順
					, tr.dt_seizo_kowake			AS dt_seizo_kowake		-- 製造日
					-- 投入情報
					, tr.dt_shori					AS dt_shori				-- 投入日
					, tr.cd_line_tonyu				AS cd_line_tonyu		-- 投入ラインコード
					, mlt.nm_line					AS nm_line_tonyu		-- 投入ライン名
					-- 残情報
					, tr.dt_hyoryo_zan				AS dt_hyoryo_zan		-- 残秤量日
					, tr.wt_jisseki					AS wt_jisseki			-- 残重量
					, tani.nm_tani					AS nm_tani				-- 単位名
					, tr.flg_haki					AS flg_haki				-- 破棄
				FROM 
				(
					SELECT
						-- 荷受情報
						  tn.dt_nonyu		AS dt_niuke					--荷受日
						, tn.dt_seizo		AS dt_seizo_genryo			--原料製造日
						, tn.dt_kigen		AS dt_kigen					--賞味期限日
						, tn.no_lot			AS no_lot					--ロット番号
						, tn.no_denpyo		AS no_denpyo				--伝票番号
						, tn.cd_torihiki	AS cd_torihiki				--取引先コード
						-- 小分情報
						, tk.dt_kowake		AS dt_kowake				--小分日
						, tk.cd_seihin		AS cd_seihin				--製品コード
						, tk.nm_seihin		AS nm_seihin				--製品名
						, tk.cd_line		AS cd_line_kowake			--小分ラインコード
					    ,tk.su_kai			AS su_kai					-- バッチ数
					    ,tk.su_ko			AS su_ko					-- 投入順
						, tk.dt_seizo		AS dt_seizo_kowake			--製造日
						-- 投入情報
						, ISNULL(tt1.dt_shori, tt2.dt_shori) AS dt_shori			--投入日
						, ISNULL(tt1.cd_line, tt2.cd_line) AS cd_line_tonyu			--投入ラインコード
						-- 残情報
						, tzj.cd_hakari		AS cd_hakari				--秤コード
						, tzj.dt_hyoryo_zan AS dt_hyoryo_zan			--残秤量日
						, tzj.wt_jisseki	AS wt_jisseki				--残重量
						, tzj.flg_haki		AS flg_haki					--破棄
					FROM 
					(
						SELECT * 
						FROM tr_niuke niuke
						WHERE 
							    niuke.no_seq = 1
							--【検索条件】
							-- [品名コード]
						    AND niuke.cd_hinmei = @cd_hinmei
							-- [荷受日]
							AND 
							(
								(@chk_dt_niuke = @false) 
								OR (niuke.dt_nonyu >= @dt_niuke_st and niuke.dt_nonyu < DATEADD(DD,@day,@dt_niuke_en))
							)
							-- [原料製造日]
							AND 
							(
								(@chk_dt_seizo = @false) 
								OR (niuke.dt_seizo >= @dt_seizo_st and niuke.dt_seizo < DATEADD(DD,@day,@dt_seizo_en))
							)
							-- [賞味期限日]
							AND (
								(@chk_dt_kigen = @false) 
								OR (niuke.dt_kigen >= @dt_kigen_st and niuke.dt_kigen < DATEADD(DD,@day,@dt_kigen_en))
							)
							-- [ロットNo]
							AND ((@chk_no_lot = @false) OR niuke.no_lot = @genryoLot)
							-- [伝票No]
							AND ((@chk_no_denpyo = @false) OR niuke.no_denpyo = @no_denpyo)
							-- [取引先コード]
							AND ((@chk_cd_torihiki = @false) OR niuke.cd_torihiki = @cd_torihiki)
					) tn	

					-- 混合ロット実績トラン
					LEFT OUTER JOIN 
					(
						SELECT 
							tl1.no_lot
							,tl1.no_lot_jisseki
							,tkn.old_no_lot
							,tk1.cd_hinmei AS cd_hinmei_kowake
							,tzj1.cd_hinmei AS cd_hinmei_zan
							,tl1.dt_shomi
							,tl1.dt_seizo_genryo
						FROM tr_lot tl1

						LEFT OUTER JOIN  tr_kongo_nisugata tkn
							ON tl1.no_lot = tkn.no_lot
						LEFT OUTER JOIN  tr_kowake tk1
							ON tl1.no_lot_jisseki = tk1.no_lot_kowake
						LEFT OUTER JOIN  tr_zan_jiseki tzj1
							ON  tl1.no_lot_jisseki = tzj1.no_lot_zan 
					) tl
					ON (tl.no_lot = tn.no_lot OR tl.old_no_lot = tn.no_lot)
					AND (tl.cd_hinmei_kowake = tn.cd_hinmei OR tl.cd_hinmei_zan = tn.cd_hinmei)
					AND tl.dt_shomi = tn.dt_kigen

					-- 小分実績トラン
					LEFT OUTER JOIN tr_kowake tk
						ON tk.no_lot_kowake = tl.no_lot_jisseki

					-- 残実績トラン
					LEFT OUTER JOIN tr_zan_jiseki tzj
						ON tl.no_lot_jisseki = tzj.no_lot_zan
					
					-- 投入トラン（小分けラベル読み込み）
					LEFT OUTER JOIN tr_tonyu tt1
						--ON tt1.dt_seizo = tk.dt_seizo
						ON tt1.cd_hinmei = tk.cd_hinmei
						AND tt1.su_kai = tk.su_kai
						AND tt1.no_tonyu = tk.no_tonyu
						AND tt1.no_kotei = tk.no_kotei
						AND tt1.no_lot_seihin = tk.no_lot_seihin
						AND tt1.su_ko_label = tk.su_ko
						AND tt1.cd_line = tk.cd_line
						AND tt1.dt_shori = tk.dt_tonyu
						AND tt1.kbn_seikihasu = tk.kbn_seikihasu
					
					-- 投入トラン（荷姿ラベル読み込み）
					LEFT OUTER JOIN tr_tonyu tt2
						ON tt2.no_lot = tn.no_lot
						AND tt2.cd_hinmei = tn.cd_hinmei
						--AND tt2.dt_shomi = tn.dt_kigen
			) tr
			
			---- 取引先マスタ
			LEFT OUTER JOIN ma_torihiki mt
				ON mt.cd_torihiki = tr.cd_torihiki
			
			---- 秤マスタ
			LEFT OUTER JOIN  ma_hakari hakari
				ON hakari.cd_hakari = tr.cd_hakari

			---- 単位マスタ
			LEFT OUTER JOIN ma_tani tani
				ON tani.cd_tani = hakari.cd_tani
			
			
			---- ラインマスタ（小分）
			LEFT OUTER JOIN ma_line mlk
				ON mlk.cd_line = tr.cd_line_kowake

			---- ラインマスタ（投入）
			LEFT OUTER JOIN ma_line mlt
				ON mlt.cd_line = tr.cd_line_tonyu
			
		/* -- ▼ 2017.01.12 サポート対応により削除 ▼ --
				SELECT
					--荷受情報
					tn.dt_nonyu AS dt_niuke					--荷受日
					--tn.dt_niuke AS dt_niuke
					,tn.dt_seizo AS dt_seizo_genryo			--原料製造日
					,tn.dt_kigen AS dt_kigen				--賞味期限日
					,tn.no_lot AS no_lot					--ロット番号
					,tn.no_denpyo AS no_denpyo				--伝票番号
					,tn.cd_torihiki AS cd_torihiki			--取引先コード
					,mt.nm_torihiki AS nm_torihiki			--取引先名
					--製品計画
					,NULL AS cd_seihin_keikaku				--製品コード
					,NULL AS nm_seihin_keikaku				--製品名
					,NULL AS dt_seizo_keikaku				--製造日
					,NULL AS dt_shomi_keikaku				--賞味期限
					,NULL AS no_lot_hyoji_keikaku			--表示ロットNo
					--小分情報
					,tk.dt_kowake AS dt_kowake				--小分日
					,tk.cd_seihin AS cd_seihin				--製品コード
					,tk.nm_seihin AS nm_seihin				--製品名
					,tk.cd_line AS cd_line_kowake			--小分ラインコード
					,mlk.nm_line AS nm_line_kowake			--小分ライン名
					,tk.dt_seizo AS dt_seizo_kowake			--製造日
					--投入情報
					--,tt.dt_shori AS dt_shori
					--,tt.cd_line AS cd_line_tonyu
					--,mlt.nm_line AS nm_line_tonyu
					,tt.dt_shori AS dt_shori				--投入日
					,tt.cd_line AS cd_line_tonyu			--投入ラインコード
					,mlt.nm_line AS nm_line_tonyu			--投入ライン名
					--残情報
					,tzj.dt_hyoryo_zan AS dt_hyoryo_zan		--残秤量日
					,tzj.wt_jisseki AS wt_jisseki			--残重量
					,tani.nm_tani							--単位名
					,tzj.flg_haki AS flg_haki				--破棄
					--,tt.no_lot_seihin AS '製品ロット'
				FROM tr_niuke tn
					--取引先マスタ
					LEFT OUTER JOIN ma_torihiki mt
					ON mt.cd_torihiki = tn.cd_torihiki

					--混合ロット実績トラン
					LEFT OUTER JOIN 
					(
						SELECT 
							tl1.no_lot
							,tl1.no_lot_jisseki
							,tkn.old_no_lot
							,tk1.cd_hinmei AS cd_hinmei_kowake
							,tzj1.cd_hinmei AS cd_hinmei_zan
							,tl1.dt_shomi
							,tl1.dt_seizo_genryo
						FROM tr_lot tl1

						--LEFT OUTER JOIN  tr_zan_jiseki tzj
						--ON tzj.no_lot_zan = tl1.no_lot_jisseki

						LEFT OUTER JOIN  tr_kongo_nisugata tkn
						--on tl1.no_lot_jisseki = tkn.no_lot_jisseki
						ON tl1.no_lot = tkn.no_lot
						LEFT OUTER JOIN  tr_kowake tk1
						ON tl1.no_lot_jisseki = tk1.no_lot_kowake
						LEFT OUTER JOIN  tr_zan_jiseki tzj1
						ON  tl1.no_lot_jisseki = tzj1.no_lot_zan 
					) tl
					ON (tl.no_lot = tn.no_lot OR tl.old_no_lot = tn.no_lot)
					AND (tl.cd_hinmei_kowake = tn.cd_hinmei OR tl.cd_hinmei_zan = tn.cd_hinmei)
					AND tl.dt_shomi = tn.dt_kigen
					AND tl.dt_seizo_genryo = tn.dt_seizo

					--小分実績トラン
					LEFT OUTER JOIN tr_kowake tk
					ON tk.no_lot_kowake = tl.no_lot_jisseki

					--残実績トラン
					LEFT OUTER JOIN tr_zan_jiseki tzj
					ON tl.no_lot_jisseki = tzj.no_lot_zan
					
					----秤マスタ
					LEFT OUTER JOIN  ma_hakari hakari
					ON tzj.cd_hakari = hakari.cd_hakari

					----単位マスタ
					LEFT OUTER JOIN ma_tani tani
					ON hakari.cd_tani = tani.cd_tani
					
					--投入トラン
					LEFT OUTER JOIN tr_tonyu tt
					ON tt.no_lot_seihin = tk.no_lot_seihin
					AND tt.no_kotei = tk.no_kotei
					AND tt.su_kai = tk.su_kai
					AND tt.dt_shori = tk.dt_tonyu
					
					--ラインマスタ（小分）
					LEFT OUTER JOIN ma_line mlk
					ON mlk.cd_line = tk.cd_line

					----ラインマスタ（投入）
					LEFT OUTER JOIN ma_line mlt
					ON mlt.cd_line = tt.cd_line

				WHERE tn.cd_hinmei = @cd_hinmei
				--荷受実績日を検索条件に
				AND 
				(
					(@chk_dt_niuke = @false) 
					OR (tn.dt_nonyu >= @dt_niuke_st and tn.dt_nonyu < DATEADD(DD,@day,@dt_niuke_en))
				)
				--AND 
				--(
				--	(@chk_dt_niuke = @false) 
				--	OR (tn.dt_niuke >= @dt_niuke_st and tn.dt_niuke < DATEADD(DD,@day,@dt_niuke_en))
				--)
				AND 
				(
					(@chk_dt_seizo = @false) 
					OR (tn.dt_seizo >= @dt_seizo_st and tn.dt_seizo < DATEADD(DD,@day,@dt_seizo_en))
				)
				AND (
					(@chk_dt_kigen = @false) 
					OR (tn.dt_kigen >= @dt_kigen_st and tn.dt_kigen < DATEADD(DD,@day,@dt_kigen_en))
				)
				AND ((@chk_no_denpyo = @false) OR tn.no_denpyo = @no_denpyo)
				AND ((@chk_no_lot = @false) OR tn.no_lot = @genryoLot)
				AND ((@chk_cd_torihiki = @false) OR tn.cd_torihiki = @cd_torihiki)
				AND tn.no_seq = 1
					
				UNION ALL

				SELECT
					--荷受情報
					tn2.dt_nonyu AS dt_niuke				--荷受日
					,tn2.dt_seizo AS dt_seizo_genryo		--原料製造日
					,tn2.dt_kigen AS dt_kigen				--賞味期限日
					,tn2.no_lot AS no_lot					--ロット番号
					,tn2.no_denpyo AS no_denpyo				--伝票番号
					,tn2.cd_torihiki AS cd_torihiki			--取引先コード
					,mt2.nm_torihiki AS nm_torihiki			--取引先名
					--製品計画
					,NULL AS cd_seihin_keikaku				--製品コード
					,NULL AS nm_seihin_keikaku				--製品名
					,NULL AS dt_seizo_keikaku				--製造日
					,NULL AS dt_shomi_keikaku				--賞味期限
					,NULL AS no_lot_hyoji_keikaku			--表示ロットNo
					--小分情報
					,NULL AS dt_kowake						--小分日
					,NULL AS cd_seihin						--製品コード
					,NULL AS nm_seihin						--製品名
					,NULL AS cd_line_kowake					--小分ラインコード
					,NULL AS nm_line_kowake					--小分ライン名
					,NULL AS dt_seizo_kowake				--製造日
					--投入情報
					,tt2.dt_shori AS dt_shori				--投入日
					,tt2.cd_line AS cd_line_tonyu			--投入ラインコード
					,mlt2.nm_line AS nm_line_tonyu			--投入ライン名
					--残情報
					,NULL AS dt_hyoryo_zan					--残秤量日
					,NULL AS wt_jisseki						--残重量
					,NULL AS nm_tani						--単位名
					,NULL AS flg_haki						--破棄
				FROM tr_niuke tn2
					--取引先マスタ
					LEFT OUTER JOIN ma_torihiki mt2
					ON mt2.cd_torihiki = tn2.cd_torihiki
					--投入マスタ（小分がない）
					LEFT OUTER JOIN tr_tonyu tt2
					ON tn2.no_lot = tt2.no_lot
					AND tn2.cd_hinmei = tt2.cd_hinmei
					AND tn2.dt_kigen = tt2.dt_shomi
					--ラインマスタ（小分がない）
					LEFT OUTER JOIN ma_line mlt2
					ON mlt2.cd_line = tt2.cd_line
				WHERE tn2.cd_hinmei = @cd_hinmei
				--荷受実績日を検索条件に
				AND 
				(
					(@chk_dt_niuke = @false) 
					OR (tn2.dt_nonyu >= @dt_niuke_st and tn2.dt_nonyu < DATEADD(DD,@day,@dt_niuke_en))
				)
				AND 
				(
					(@chk_dt_seizo = @false) 
					OR (tn2.dt_seizo >= @dt_seizo_st and tn2.dt_seizo < DATEADD(DD,@day,@dt_seizo_en))
				)
				AND 
				(
					(@chk_dt_kigen = @false) 
					OR (tn2.dt_kigen >= @dt_kigen_st and tn2.dt_kigen < DATEADD(DD,@day,@dt_kigen_en))
				)
				AND ((@chk_no_denpyo = @false) OR tn2.no_denpyo = @no_denpyo)
				AND ((@chk_no_lot = @false) OR tn2.no_lot = @genryoLot)
				AND ((@chk_cd_torihiki = @false) OR tn2.cd_torihiki = @cd_torihiki)
				AND tn2.no_seq = 1
				AND tt2.dt_shori IS NOT NULL
				-- ▲ 2017.01.12 サポート対応により削除 ▲ -- */
			) uni
		)

		-- 画面に返却する値を取得
		SELECT
			cnt
			,cte_row.dt_niuke
			,cte_row.dt_seizo_genryo
			,cte_row.dt_kigen
			,cte_row.no_lot
			,cte_row.no_denpyo
			,cte_row.cd_torihiki
			,cte_row.nm_torihiki
			,cte_row.cd_seihin_keikaku
			,cte_row.nm_seihin_keikaku
			,cte_row.dt_seizo_keikaku
			,cte_row.dt_shomi_keikaku
			,cte_row.no_lot_hyoji_keikaku
			,cte_row.dt_kowake
			,cte_row.cd_seihin
			,cte_row.nm_seihin
			,cte_row.cd_line_kowake
			,cte_row.nm_line_kowake
			,cte_row.su_kai
			,cte_row.su_ko
			,cte_row.dt_seizo_kowake
			,cte_row.dt_shori
			,cte_row.cd_line_tonyu
			,cte_row.nm_line_tonyu
			,cte_row.dt_hyoryo_zan
			,cte_row.wt_jisseki
			,cte_row.nm_tani
			,cte_row.flg_haki
		FROM
		(
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
			OR 
			(
				@isExcel = @true
			)
		)
	END
END

GO