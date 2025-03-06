IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeJissekiTrace_select_02') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeJissekiTrace_select_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能			：荷受実績トレース画面　検索（製品トレース）
ファイル名	：usp_NiukeJissekiTrace_select
入力引数		：@chk_dt_yotei,@dt_yotei_st,@dt_yotei_en,
			  @chk_dt_jisseki,@dt_jisseki_st,@dt_jisseki_en,
			  @chk_cd_shokuba,@cd_shokuba,@chk_cd_line,
			  @cd_line,@chk_genryo,@genryoLot,
			  @chk_cd_genryo,@cd_genryo,@chk_cd_haigo,
			  @cd_haigo,@no_tonyu,@skip,@top,@isExcel
出力引数	：	
戻り値		：
作成日		：2016.03.30  Khang
更新日		：2017.01.26  BRC cho.k サポートNo.1対応
更新日		：2020.02.28  wang荷受け実績トレースにバッチ数と投入順を追加
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeJissekiTrace_select_02](
	@cd_hinmei					VARCHAR(14)			--検索条件/品名コード
	,@chk_dt_niuke				SMALLINT			--検索条件/荷受日チェック
	,@dt_niuke_st				DATETIME			--検索条件/荷受日(開始)
	,@dt_niuke_en				DATETIME			--検索条件/荷受日(終了)
	,@chk_dt_seizo				SMALLINT			--検索条件/原料製造日チェック
	,@dt_seizo_st				DATETIME			--検索条件/原料製造日(開始)
	,@dt_seizo_en				DATETIME			--検索条件/原料製造日(終了)
	,@chk_dt_kigen				SMALLINT			--検索条件/賞味期限日チェック
	,@dt_kigen_st				DATETIME			--検索条件/賞味期限日(開始)
	,@dt_kigen_en				DATETIME			--検索条件/賞味期限日(終了)
	,@chk_no_denpyo				SMALLINT			--検索条件/伝票Noチェック
	,@no_denpyo					VARCHAR(30)			--検索条件/伝票No
	,@chk_no_lot				SMALLINT			--検索条件/ロットNoチェック
	,@genryoLot					VARCHAR(14)			--検索条件/ロットNo
	,@chk_cd_torihiki			SMALLINT			--検索条件/取引先コードチェック
	,@cd_torihiki				VARCHAR(13)			--検索条件/取引先コード
	,@chk_seihin_nomi_hyoji		SMALLINT			--検索条件/製品のみ表示チェック
	,@no_seq					DECIMAL(8,0)		--シーケンス番号
	,@kbn_hin_seihin			SMALLINT			--品区分(製品）
	,@kbn_hin_genryo			SMALLINT			--品区分(原料）
	,@kbn_hin_jika				SMALLINT			--品区分(自家原料）
	,@kbn_hin_shikakari			SMALLINT			--品区分(仕掛）
	,@kbn_riyu_chosei			SMALLINT			--調整理由
	,@lang						VARCHAR(10)
	,@skip						DECIMAL(10)
	,@top						DECIMAL(10)
	,@isExcel					BIT
)
AS
BEGIN

/*
	-- 荷受テーブル
	DECLARE @tbl_niuke TABLE
	(
		cn_row					INT					--行番号
		,cd_hinmei				VARCHAR(14)			--品コード
		,no_niuke				VARCHAR(14)			--荷受番号
		,dt_niuke				DATETIME			--荷受日
		,dt_seizo_genryo		DATETIME			--製造日
		,dt_kigen				DATETIME			--賞味期限日
		,no_lot					VARCHAR(14)			--ロット番号
		,no_denpyo				VARCHAR(30)			--伝票番号
		,cd_torihiki			VARCHAR(13)			--取引コード
	)

	-- 荷受実績トレーステーブル
	DECLARE @tbl_niuke_jisseki_trace TABLE
	(
		no_lot_shikakari		VARCHAR(14)			--仕掛ロット番号
		,no_lot_seihin			VARCHAR(14)			--製品ロット番号
		,cd_hinmei				VARCHAR(14)			--品コード
		,kbn_hin				SMALLINT			--品区分
		,no_niuke				VARCHAR(14)			--荷受番号
		,no_niuke_moto			VARCHAR(14)			--元の荷受番号
		,cd_seihin_keikaku		VARCHAR(14)			--製品計画
		--,nm_seihin_keikaku	VARCHAR(50)			--製品名
		,nm_seihin_keikaku		NVARCHAR(50)		--製品名
		,dt_seizo_keikaku		DATETIME			--製造日
		,dt_shomi_keikaku		DATETIME			--賞味期限日
		,no_lot_hyoji_keikaku	VARCHAR(50)			--表示ロット番号
	)
	
	-- 処理日が最大の小分テーブル
	DECLARE @tbl_kowake_shoribi_max TABLE
	(
		dt_niuke				DATETIME			--荷受日
		,dt_seizo_genryo		DATETIME			--製造日
		,dt_kigen				DATETIME			--賞味期限日
		,dt_shori_max			DATETIME			--賞味期限日
		,no_lot					VARCHAR(14)			--ロット番号
		,cd_seihin_keikaku		VARCHAR(14)			--製品計画
	)
*/

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

/*
	-- 荷受トランから画面の条件によって取ります
	INSERT INTO @tbl_niuke
	SELECT
		ROW_NUMBER() OVER (ORDER BY (SELECT 1))
		,cd_hinmei
		,no_niuke
		,dt_niuke
		,dt_seizo AS dt_seizo_genryo
		,dt_kigen
		,no_lot
		,no_denpyo
		,cd_torihiki
	FROM tr_niuke 
	WHERE ( @cd_hinmei IS NULL OR cd_hinmei = @cd_hinmei )
	AND 
	(
		( @chk_dt_niuke = @false ) 
		OR ( @dt_niuke_st <= dt_niuke AND dt_niuke < DATEADD(DD, @day, @dt_niuke_en) )
	)
	AND 
	(
		( @chk_dt_seizo = @false ) 
		OR ( @dt_seizo_st <= dt_seizo AND dt_seizo < DATEADD(DD, @day, @dt_seizo_en) )
	)
	AND 
	(
		( @chk_dt_kigen = @false ) 
		OR ( @dt_kigen_st <= dt_kigen AND dt_kigen < DATEADD(DD, @day, @dt_kigen_en) )
	)		
	AND ( @chk_no_denpyo = @false OR no_denpyo = @no_denpyo )
	AND ( @chk_no_lot = @false OR no_lot = @genryoLot )
	AND ( @chk_cd_torihiki = @false OR cd_torihiki = @cd_torihiki )
	AND no_seq = @no_seq

	DECLARE	@no_niuke	VARCHAR(14)
	DECLARE @id				INT
    DECLARE @totalrows		INT 
    DECLARE @currentrow		INT
	SET		@totalrows	=	( SELECT COUNT(*) FROM @tbl_niuke )
	SET		@currentrow =	0

	WHILE @currentrow < @totalrows  
    BEGIN
		SET @no_niuke =
		( 
			SELECT DISTINCT 
				NIUKE.no_niuke
			FROM @tbl_niuke NIUKE

			WHERE NIUKE.no_lot NOT IN
			(
				SELECT no_lot
				FROM tr_lot LOT
				WHERE NIUKE.no_lot = LOT.no_lot
				AND NIUKE.dt_kigen = LOT.dt_shomi
			)
			AND NIUKE.cn_row = @currentrow + 1
		)

		INSERT INTO @tbl_niuke_jisseki_trace
		(
			no_lot_shikakari
			,no_lot_seihin
			,cd_hinmei
			,kbn_hin
			,no_niuke
			,no_niuke_moto
			,cd_seihin_keikaku
			,nm_seihin_keikaku
			,dt_seizo_keikaku
			,dt_shomi_keikaku
			,no_lot_hyoji_keikaku
		)
		EXECUTE usp_NiukeJissekiTrace_select_03 @no_niuke, @chk_seihin_nomi_hyoji, @kbn_hin_seihin, @kbn_hin_genryo, @kbn_hin_jika, @kbn_hin_shikakari, @kbn_riyu_chosei, @lang
		SET @currentrow = @currentrow + 1
	END

	INSERT INTO @tbl_kowake_shoribi_max
	SELECT
		NIUKE.dt_niuke
		,NIUKE.dt_seizo_genryo
		,NIUKE.dt_kigen
		,MAX(TONYU.dt_shori) AS dt_shori
		,NIUKE.no_lot
		,KEIKAKU_SEIHIN.cd_hinmei AS cd_seihin_keikaku		
	FROM @tbl_niuke NIUKE

	LEFT OUTER JOIN tr_lot LOT
	ON NIUKE.no_lot = LOT.no_lot
	AND NIUKE.dt_kigen = LOT.dt_shomi

	LEFT OUTER JOIN tr_kowake KOWAKE
	ON LOT.no_lot_jisseki = KOWAKE.no_lot_kowake

	INNER JOIN tr_tonyu TONYU
	ON TONYU.no_lot_seihin = KOWAKE.no_lot_seihin
	AND TONYU.no_kotei = KOWAKE.no_kotei
	AND TONYU.no_tonyu = KOWAKE.no_tonyu
	AND TONYU.dt_shori = KOWAKE.dt_tonyu
	AND TONYU.su_ko_label = KOWAKE.su_ko
	AND TONYU.su_kai = KOWAKE.su_kai
	AND TONYU.cd_hinmei = KOWAKE.cd_hinmei
	AND TONYU.cd_line = KOWAKE.cd_line
	AND TONYU.kbn_seikihasu = KOWAKE.kbn_seikihasu

	INNER JOIN tr_sap_shiyo_yojitsu_anbun ANBUN
	ON ANBUN.no_lot_shikakari = TONYU.no_lot_seihin

	INNER JOIN tr_keikaku_seihin KEIKAKU_SEIHIN
	ON KEIKAKU_SEIHIN.no_lot_seihin = ANBUN.no_lot_seihin

	GROUP BY
		NIUKE.dt_niuke
		,NIUKE.dt_seizo_genryo
		,NIUKE.dt_kigen
		,NIUKE.no_lot
		,KEIKAKU_SEIHIN.cd_hinmei
	-- 他のテーブルと結び付けます
*/
    BEGIN
		WITH cte AS
		(
			SELECT
				*
				,ROW_NUMBER() OVER (ORDER BY 
					uni.dt_niuke
					,uni.dt_kigen
					,uni.no_lot
				) AS RN
			FROM
			(
				SELECT DISTINCT
					--荷受情報
					  tr.dt_niuke					AS dt_niuke				-- 荷受日
					, tr.dt_seizo_genryo			AS dt_seizo_genryo		-- 原料製造日
					, tr.dt_kigen					AS dt_kigen				-- 賞味期限日
					, tr.no_lot						AS no_lot				-- ロット番号
					, tr.no_denpyo					AS no_denpyo			-- 伝票番号
					, tr.cd_torihiki				AS cd_torihiki			-- 取引先コード
					, mt.nm_torihiki				AS nm_torihiki			-- 取引先名
					-- 製品計画
					, seihin.cd_hinmei				AS cd_seihin_keikaku	-- 製品コード
					, CASE @lang 
						WHEN 'ja' THEN 
							CASE 
								WHEN seihin.nm_hinmei_ja IS NULL OR LEN(seihin.nm_hinmei_ja) = 0 THEN seihin.nm_hinmei_ryaku
								ELSE seihin.nm_hinmei_ja
							END
						WHEN 'en' THEN
							CASE 
								WHEN seihin.nm_hinmei_en IS NULL OR LEN(seihin.nm_hinmei_en) = 0 THEN seihin.nm_hinmei_ryaku
								ELSE seihin.nm_hinmei_en
							END
						WHEN 'zh' THEN
							CASE 
								WHEN seihin.nm_hinmei_zh IS NULL OR LEN(seihin.nm_hinmei_zh) = 0 THEN seihin.nm_hinmei_ryaku
								ELSE seihin.nm_hinmei_zh
							END
						WHEN 'vi' THEN
							CASE 
								WHEN seihin.nm_hinmei_vi IS NULL OR LEN(seihin.nm_hinmei_vi) = 0 THEN seihin.nm_hinmei_ryaku
								ELSE seihin.nm_hinmei_vi
							END
					  END							AS nm_seihin_keikaku	-- 製品名
					, keikaku.dt_seizo				AS dt_seizo_keikaku		-- 製造日
					, keikaku.dt_shomi				AS dt_shomi_keikaku		-- 賞味期限
					, keikaku.no_lot_hyoji			AS no_lot_hyoji_keikaku	-- 表示ロットNo
					-- 小分情報
					, tr.dt_kowake					AS dt_kowake			-- 小分日
					, tr.cd_seihin					AS cd_seihin			-- 製品コード
					, tr.nm_seihin					AS nm_seihin			-- 製品名
					, tr.cd_line_kowake				AS cd_line_kowake		-- 小分ラインコード
					, mlk.nm_line					AS nm_line_kowake		-- 小分ライン名
					,tr.su_kai                      AS su_kai               -- バッチ数
					,tr.su_ko                       AS su_ko                -- 投入順
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
					    ,tk.su_kai          AS su_kai                   -- バッチ数
					    ,tk.su_ko           AS su_ko                    -- 投入順
						, tk.dt_seizo		AS dt_seizo_kowake			--製造日
						-- 投入情報
						, ISNULL(tt1.dt_shori, tt2.dt_shori)	AS dt_shori				--投入日
						, ISNULL(tt1.cd_line, tt2.cd_line)		AS cd_line_tonyu		--投入ラインコード
						-- 残情報
						, tzj.cd_hakari									--秤コード
						, tzj.dt_hyoryo_zan AS dt_hyoryo_zan			--残秤量日
						, tzj.wt_jisseki	AS wt_jisseki				--残重量
						, tzj.flg_haki		AS flg_haki					--破棄
						-- 製品情報
						, ISNULL(tt2.no_lot_seihin, ISNULL(tt1.no_lot_seihin, tlt.no_lot_shikakari)) AS no_lot_shikakari

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
							, tl1.no_lot_jisseki
							, tkn.old_no_lot
							, tk1.cd_hinmei AS cd_hinmei_kowake
							, tzj1.cd_hinmei AS cd_hinmei_zan
							, tl1.dt_shomi
							, tl1.dt_seizo_genryo
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
						
					--残実績トラン
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
					
					LEFT OUTER JOIN tr_lot_trace tlt
						ON tlt.cd_hinmei = tn.cd_hinmei
						AND tlt.no_niuke = tn.no_niuke
						AND NOT EXISTS (
							SELECT * FROM tr_tonyu tonyu
							WHERE tonyu.no_lot_seihin = tlt.no_lot_shikakari
							  AND tonyu.cd_hinmei = tlt.cd_hinmei
							  AND tonyu.no_kotei = tlt.no_kotei
							  AND tonyu.no_tonyu = tlt.no_tonyu
						)
				) tr
				
				-- 製造実績按分トラン
				INNER JOIN tr_sap_shiyo_yojitsu_anbun anbun
					ON anbun.no_lot_shikakari = tr.no_lot_shikakari
					
				-- 月間製品計画トラン
				INNER JOIN tr_keikaku_seihin keikaku
					ON keikaku.no_lot_seihin = anbun.no_lot_seihin
				
				-- 品名マスタ（製品情報）
				INNER JOIN
				(
					SELECT *
					FROM ma_hinmei
					WHERE
						( @chk_seihin_nomi_hyoji = @false ) 
						OR ( kbn_hin = @kbn_hin_seihin )
				) seihin
					ON seihin.cd_hinmei = keikaku.cd_hinmei
				----取引先マスタ
				LEFT OUTER JOIN ma_torihiki mt
					ON mt.cd_torihiki = tr.cd_torihiki
				
				----秤マスタ
				LEFT OUTER JOIN  ma_hakari hakari
					ON hakari.cd_hakari = tr.cd_hakari

				----単位マスタ
				LEFT OUTER JOIN ma_tani tani
					ON tani.cd_tani = hakari.cd_tani
				
				
				----ラインマスタ（小分）
				LEFT OUTER JOIN ma_line mlk
					ON mlk.cd_line = tr.cd_line_kowake

				----ラインマスタ（投入）
				LEFT OUTER JOIN ma_line mlt
					ON mlt.cd_line = tr.cd_line_tonyu
/*
				-- 原料と自家原料用
				SELECT DISTINCT
					--荷受情報
					NIUKE.dt_niuke							--荷受日
					,NIUKE.dt_seizo_genryo					--原料製造日
					,NIUKE.dt_kigen							--賞味期限日
					,NIUKE.no_lot							--ロット番号
					,NIUKE.no_denpyo						--伝票番号
					,NIUKE.cd_torihiki						--取引先コード
					,TORIHIKI.nm_torihiki					--取引先名
					--製品計画
					,NIUKE_JISSEKI_TRACE.cd_seihin_keikaku	--製品コード
					,NIUKE_JISSEKI_TRACE.nm_seihin_keikaku	--製品名
					,NIUKE_JISSEKI_TRACE.dt_seizo_keikaku	--製造日
					,NIUKE_JISSEKI_TRACE.dt_shomi_keikaku	--賞味期限
					,NIUKE_JISSEKI_TRACE.no_lot_hyoji_keikaku--表示ロットNo
					--小分情報
					,NULL AS dt_kowake						--小分日
					,NULL AS cd_seihin						--製品コード
					,NULL AS nm_seihin						--製品名
					,NULL AS cd_line_kowake					--小分ラインコード
					,NULL AS nm_line_kowake					--小分ライン名
					,NULL AS dt_seizo_kowake				--製造日
					--投入情報
					,NULL AS dt_shori						--投入日
					,NULL AS cd_line_tonyu					--投入ラインコード
					,NULL AS nm_line_tonyu					--投入ライン名
					--残情報
					,NULL AS dt_hyoryo_zan					--残秤量日
					,NULL AS wt_jisseki						--残重量
					,NULL AS flg_haki						--破棄
				FROM @tbl_niuke NIUKE

				INNER JOIN @tbl_niuke_jisseki_trace NIUKE_JISSEKI_TRACE
				ON NIUKE.no_niuke = NIUKE_JISSEKI_TRACE.no_niuke_moto

				LEFT OUTER JOIN ma_torihiki TORIHIKI
				ON TORIHIKI.cd_torihiki = NIUKE.cd_torihiki

				UNION ALL

				-- 仕掛用
				SELECT DISTINCT
					--荷受情報
					NIUKE.dt_niuke												--荷受日
					,NIUKE.dt_seizo_genryo										--原料製造日
					,NIUKE.dt_kigen												--賞味期限日
					,NIUKE.no_lot												--ロット番号
					,NIUKE.no_denpyo											--伝票番号
					,NIUKE.cd_torihiki											--取引先コード
					,TORIHIKI.nm_torihiki										--取引先名
					--製品計画
					,KEIKAKU_SHIKAKARI.cd_shikakari_hin AS cd_seihin_keikaku	--製品コード
					,KEIKAKU_SHIKAKARI.nm_shikakari_hin AS nm_seihin_keikaku	--製品名
					,KEIKAKU_SHIKAKARI.dt_seizo AS dt_seizo_keikaku				--製造日
					,NULL AS dt_shomi_keikaku									--賞味期限
					,RIYU.nm_riyu AS no_lot_hyoji_keikaku						--表示ロットNo
					--小分情報
					,NULL AS dt_kowake											--小分日
					,NULL AS cd_seihin											--製品コード
					,NULL AS nm_seihin											--製品名
					,NULL AS cd_line_kowake										--小分ラインコード
					,NULL AS nm_line_kowake										--小分ライン名
					,NULL AS dt_seizo_kowake									--製造日
					--投入情報
					,NULL AS dt_shori											--投入日
					,NULL AS cd_line_tonyu										--投入ラインコード
					,NULL AS nm_line_tonyu										--投入ライン名
					--残情報
					,NULL AS dt_hyoryo_zan										--残秤量日
					,NULL AS wt_jisseki											--残重量
					,NULL AS flg_haki											--破棄
				FROM @tbl_niuke NIUKE

				INNER JOIN
				(
					SELECT
						no_lot_shikakari
						,cd_hinmei
						,no_niuke
					FROM tr_lot_trace
					WHERE
					(
						( @chk_seihin_nomi_hyoji = @false ) 
						OR ( kbn_hin = @kbn_hin_seihin )
					)
				) TRACE
				ON NIUKE.no_niuke = TRACE.no_niuke
	
				INNER JOIN tr_sap_shiyo_yojitsu_anbun ANBUN
				ON ANBUN.no_lot_shikakari = TRACE.no_lot_shikakari
				AND ANBUN.no_lot_seihin IS NULL

				LEFT OUTER JOIN
				(
					SELECT
						KEIKAKU.no_lot_shikakari
						,@kbn_hin_shikakari AS kbn_hin
						,KEIKAKU.cd_shikakari_hin
						,CASE @lang 
							WHEN 'ja' THEN 
								CASE 
									WHEN HAIGO.nm_haigo_ja IS NULL OR LEN(HAIGO.nm_haigo_ja) = 0 THEN HAIGO.nm_haigo_ryaku
									ELSE HAIGO.nm_haigo_ja
								END
							WHEN 'en' THEN
								CASE 
									WHEN HAIGO.nm_haigo_en IS NULL OR LEN(HAIGO.nm_haigo_en) = 0 THEN HAIGO.nm_haigo_ryaku
									ELSE HAIGO.nm_haigo_en
								END
							WHEN 'zh' THEN
								CASE 
									WHEN HAIGO.nm_haigo_zh IS NULL OR LEN(HAIGO.nm_haigo_zh) = 0 THEN HAIGO.nm_haigo_ryaku
									ELSE HAIGO.nm_haigo_zh
								END
						END AS nm_shikakari_hin
						,KEIKAKU.dt_seizo
						,NULL AS dt_shomi
					FROM su_keikaku_shikakari KEIKAKU

					LEFT OUTER JOIN ma_haigo_mei HAIGO
					ON KEIKAKU.cd_shikakari_hin = HAIGO.cd_haigo
				) KEIKAKU_SHIKAKARI
				ON (ANBUN.no_lot_seihin IS NULL AND ANBUN.no_lot_shikakari = KEIKAKU_SHIKAKARI.no_lot_shikakari)

				LEFT OUTER JOIN ma_riyu RIYU
				ON RIYU.cd_riyu = ANBUN.cd_riyu
				AND RIYU.kbn_bunrui_riyu = @kbn_riyu_chosei

				LEFT OUTER JOIN ma_torihiki TORIHIKI
				ON TORIHIKI.cd_torihiki = NIUKE.cd_torihiki

				UNION ALL

				-- 投入・小分用
				SELECT DISTINCT
					--荷受情報
					KEKKA_ALL.dt_niuke							--荷受日
					,KEKKA_ALL.dt_seizo_genryo					--原料製造日
					,KEKKA_ALL.dt_kigen							--賞味期限日
					,KEKKA_ALL.no_lot							--ロット番号
					,KEKKA_ALL.no_denpyo						--伝票番号
					,KEKKA_ALL.cd_torihiki						--取引先コード
					,KEKKA_ALL.nm_torihiki						--取引先名
					--製品計画
					,KEKKA_ALL.cd_seihin_keikaku				--製品コード
					,KEKKA_ALL.nm_seihin_keikaku				--製品名
					,KEKKA_ALL.dt_seizo_keikaku					--製造日
					,KEKKA_ALL.dt_shomi_keikaku					--賞味期限
					,KEKKA_ALL.no_lot_hyoji_keikaku				--表示ロットNo
					--小分情報
					,KEKKA_ALL.dt_kowake						--小分日
					,KEKKA_ALL.cd_seihin						--製品コード
					,KEKKA_ALL.nm_seihin						--製品名
					,KEKKA_ALL.cd_line_kowake					--小分ラインコード
					,KEKKA_ALL.nm_line_kowake					--小分ライン名
					,KEKKA_ALL.dt_seizo_kowake					--製造日
					--投入情報
					,KEKKA_ALL.dt_shori							--小分日
					,KEKKA_ALL.cd_line_tonyu					--投入ラインコード
					,KEKKA_ALL.nm_line_tonyu					--投入ライン名
					--残情報
					,KEKKA_ALL.dt_hyoryo_zan					--残秤量日
					,KEKKA_ALL.wt_jisseki						--残重量
					,KEKKA_ALL.flg_haki							--破棄
				FROM
				(
					SELECT
						--荷受情報
						NIUKE.dt_niuke
						,NIUKE.dt_seizo_genryo
						,NIUKE.dt_kigen
						,NIUKE.no_lot
						,NIUKE.no_denpyo
						,NIUKE.cd_torihiki
						,TORIHIKI.nm_torihiki
						--製品計画
						,KEIKAKU_SEIHIN.cd_seihin_keikaku
						,KEIKAKU_SEIHIN.nm_seihin_keikaku
						,KEIKAKU_SEIHIN.dt_seizo_keikaku
						,KEIKAKU_SEIHIN.dt_shomi_keikaku
						,KEIKAKU_SEIHIN.no_lot_hyoji_keikaku
						--小分情報
						,KOWAKE.dt_kowake
						,KOWAKE.cd_hinmei AS cd_seihin
						,KOWAKE.nm_hinmei AS nm_seihin
						,KOWAKE.cd_line AS cd_line_kowake
						,LINE_KOWAKE.nm_line AS nm_line_kowake
						,KOWAKE.dt_seizo AS dt_seizo_kowake
						--投入情報
						,TONYU.dt_shori
						,TONYU.cd_line AS cd_line_tonyu
						,LINE_TONYU.nm_line AS nm_line_tonyu
						--残情報
						,ZAN.dt_hyoryo_zan
						,ZAN.wt_jisseki
						,ZAN.flg_haki
					FROM @tbl_niuke NIUKE

					LEFT OUTER JOIN tr_lot LOT
					ON NIUKE.no_lot = LOT.no_lot
					AND NIUKE.dt_kigen = LOT.dt_shomi

					LEFT OUTER JOIN tr_zan_jiseki ZAN
					ON ZAN.no_lot_zan = LOT.no_lot_jisseki
					AND ZAN.cd_hinmei = NIUKE.cd_hinmei

					LEFT OUTER JOIN tr_kowake KOWAKE
					ON LOT.no_lot_jisseki = KOWAKE.no_lot_kowake

					INNER JOIN tr_tonyu TONYU
					ON TONYU.no_lot_seihin = KOWAKE.no_lot_seihin
					AND TONYU.no_kotei = KOWAKE.no_kotei
					AND TONYU.no_tonyu = KOWAKE.no_tonyu
					AND TONYU.dt_shori = KOWAKE.dt_tonyu
					AND TONYU.su_ko_label = KOWAKE.su_ko
					AND TONYU.su_kai = KOWAKE.su_kai
					AND TONYU.cd_hinmei = KOWAKE.cd_hinmei
					AND TONYU.cd_line = KOWAKE.cd_line
					AND TONYU.kbn_seikihasu = KOWAKE.kbn_seikihasu

					INNER JOIN tr_sap_shiyo_yojitsu_anbun ANBUN
					ON ANBUN.no_lot_shikakari = TONYU.no_lot_seihin

					INNER JOIN 
					(
						SELECT
							KEIKAKU.no_lot_seihin
							,KEIKAKU.cd_hinmei AS cd_seihin_keikaku
							,CASE @lang 
								WHEN 'ja' THEN 
									CASE 
										WHEN HINMEI.nm_hinmei_ja IS NULL OR LEN(HINMEI.nm_hinmei_ja) = 0 THEN HINMEI.nm_hinmei_ryaku
										ELSE HINMEI.nm_hinmei_ja
									END
								WHEN 'en' THEN
									CASE 
										WHEN HINMEI.nm_hinmei_en IS NULL OR LEN(HINMEI.nm_hinmei_en) = 0 THEN HINMEI.nm_hinmei_ryaku
										ELSE HINMEI.nm_hinmei_en
									END
								WHEN 'zh' THEN
									CASE 
										WHEN HINMEI.nm_hinmei_zh IS NULL OR LEN(HINMEI.nm_hinmei_zh) = 0 THEN HINMEI.nm_hinmei_ryaku
										ELSE HINMEI.nm_hinmei_zh
									END
							END AS nm_seihin_keikaku
							,KEIKAKU.dt_seizo AS dt_seizo_keikaku
							,KEIKAKU.dt_shomi AS dt_shomi_keikaku
							,KEIKAKU.no_lot_hyoji AS no_lot_hyoji_keikaku
						FROM tr_keikaku_seihin KEIKAKU

						INNER JOIN
						(
							SELECT
								cd_hinmei
								,nm_hinmei_ja
								,nm_hinmei_en
								,nm_hinmei_zh
								,nm_hinmei_ryaku
							FROM ma_hinmei 
							WHERE
							(
								( @chk_seihin_nomi_hyoji = @false ) 
								OR ( kbn_hin = @kbn_hin_seihin )
							)
						) HINMEI
						ON KEIKAKU.cd_hinmei = HINMEI.cd_hinmei
					) KEIKAKU_SEIHIN
					ON KEIKAKU_SEIHIN.no_lot_seihin = ANBUN.no_lot_seihin

					LEFT OUTER JOIN ma_torihiki TORIHIKI
					ON TORIHIKI.cd_torihiki = NIUKE.cd_torihiki

					LEFT OUTER JOIN ma_line LINE_KOWAKE
					ON KOWAKE.cd_line = LINE_KOWAKE.cd_line

					LEFT OUTER JOIN ma_line LINE_TONYU
					ON TONYU.cd_line = LINE_TONYU.cd_line
				) KEKKA_ALL
				
				INNER JOIN @tbl_kowake_shoribi_max SHORIBI_MAX
				ON SHORIBI_MAX.dt_niuke = KEKKA_ALL.dt_niuke
				--AND SHORIBI_MAX.dt_seizo_genryo = KEKKA_ALL.dt_seizo_genryo
				AND SHORIBI_MAX.dt_kigen = KEKKA_ALL.dt_kigen
				AND SHORIBI_MAX.dt_shori_max = KEKKA_ALL.dt_shori
				AND SHORIBI_MAX.no_lot = KEKKA_ALL.no_lot
				AND SHORIBI_MAX.cd_seihin_keikaku = KEKKA_ALL.cd_seihin_keikaku
*/
			) uni
		)

		-- 画面に返却する値を取得
		--SELECT DISTINCT
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
			OR (
				@isExcel = @true
			)
		)
	END
/*
	-- 一時テーブルを削除します
	DELETE FROM @tbl_niuke
	DELETE FROM @tbl_niuke_jisseki_trace
	DELETE FROM @tbl_kowake_shoribi_max
*/
END

GO