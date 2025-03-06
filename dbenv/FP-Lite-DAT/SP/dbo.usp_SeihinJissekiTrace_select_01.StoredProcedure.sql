IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeihinJissekiTrace_select_01') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeihinJissekiTrace_select_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能			：製品実績トレース画面　検索
ファイル名	：usp_SeihinJissekiTrace_select_01
入力引数		：@cd_hinmei,
			  @chk_dt_seizo, @dt_seizo_st, @dt_seizo_en
			  @chk_dt_kigen, @dt_kigen_st, @dt_kigen_en,
			  @cd_shokuba, @cd_line, @no_lot_hyoji,
			  @no_seq, @kbn_hin_genryo, @kbn_hin_jika,
			  @lang, @skip, @top, @isExcel
出力引数		：	
戻り値		：
作成日		：2016.03.17  Khang
更新日      ：2019.02.25  BRC takaki.r ニアショア作業依頼No.502
*****************************************************/
CREATE PROCEDURE [dbo].[usp_SeihinJissekiTrace_select_01](
	@cd_hinmei					VARCHAR(14)			--検索条件/品名コード
	,@chk_dt_seizo				SMALLINT			--検索条件/製造日チェック
	,@dt_seizo_st				DATETIME			--検索条件/製造日(開始)
	,@dt_seizo_en				DATETIME			--検索条件/製造日(終了)
	,@chk_dt_kigen				SMALLINT			--検索条件/賞味期限日チェック
	,@dt_kigen_st				DATETIME			--検索条件/賞味期限日(開始)
	,@dt_kigen_en				DATETIME			--検索条件/賞味期限日(終了)
	,@cd_shokuba				VARCHAR(10)			--検索条件/職場コード
	,@cd_line					VARCHAR(10)			--検索条件/ラインコード
	,@no_lot_hyoji				VARCHAR(30)			--検索条件/表示ロットNo
	,@no_seq					DECIMAL(8,0)		--シーケンス番号
	,@kbn_hin_seihin			SMALLINT			--品区分(製品）
	,@kbn_hin_genryo			SMALLINT			--品区分(原料）
	,@kbn_hin_jika				SMALLINT			--品区分(自家原料）
	,@lang						VARCHAR(10)
	,@skip						DECIMAL(10)
	,@top						DECIMAL(10)
	,@isExcel					BIT
)
AS

BEGIN
    DECLARE  @start				DECIMAL(10)
    DECLARE  @end				DECIMAL(10)
	DECLARE  @true				BIT
	DECLARE  @false				BIT
	DECLARE  @day				SMALLINT
	DECLARE  @zero				SMALLINT
    SET      @start = @skip + 1
    SET      @end   = @skip + @top
    SET      @true  = 1
    SET      @false = 0
    SET		 @day   = 1
	SET		 @zero	= 0

	-- 計画製品テーブル
	DECLARE @tbl_keikaku_seihin TABLE
	(
		cn_row					INT					--行番号
		,no_lot_seihin			VARCHAR(14)			--製品ロット番号
		,dt_seizo				DATETIME			--製造日
		,cd_seihin				VARCHAR(14)			--製品コード
		,cd_shokuba				VARCHAR(10)			--職場コード
		,cd_line				VARCHAR(10)			--ラインコード
		,dt_kigen				DATETIME			--賞味期限日
		,no_lot_hyoji			VARCHAR(30)			--表示ロット番号
		,kbn_sonzai				BIT					--存在区分
	)

	-- 投入トランに存在するテーブル
	DECLARE @tbl_seihin_jisseki_trace_02 TABLE
	(
		no_lot_shikakari		VARCHAR(14)			--製品ロット番号
		,no_lot_seihin_moto		VARCHAR(14)			--元の製品ロット番号
		,no_lot_seihin			VARCHAR(14)			--製品ロット番号
		,cd_hinmei				VARCHAR(14)			--品コード
		,kbn_hin				SMALLINT			--品区分
		,no_niuke				VARCHAR(14)			--荷受番号
		,dt_niuke_genshizai		DATETIME			--荷受日
		,cd_genshizai			VARCHAR(14)			--原資材コード
		,nm_genshizai			NVARCHAR(50)		--原資材名
		,no_lot_genshizai		VARCHAR(14)			--原資材ロットNo
		,dt_kigen_genshizai		DATETIME			--原資材-賞味期限
		,no_nohinsho_genshizai	VARCHAR(16)			--原資材-納品書番号
	)

	-- 投入トランに存在しないテーブル
	DECLARE @tbl_seihin_jisseki_trace_03 TABLE
	(
		no_lot_shikakari		VARCHAR(14)			--製品ロット番号
		,no_lot_seihin			VARCHAR(14)			--製品ロット番号
		,dt_niuke_genshizai		DATETIME			--荷受日
		,cd_genshizai			VARCHAR(14)			--原資材コード
		,nm_genshizai			NVARCHAR(50)		--原資材名
		,no_lot_genshizai		VARCHAR(14)			--原資材ロットNo
		,dt_kigen_genshizai		DATETIME			--原資材-賞味期限
		,no_nohinsho_genshizai	VARCHAR(16)			--原資材-納品書番号
	)

	-- 製品計画トランから画面の条件によって取ります
	INSERT INTO @tbl_keikaku_seihin
	SELECT
		ROW_NUMBER() OVER 
		( 
			PARTITION BY 
				uni.kbn_sonzai
			ORDER BY 
				uni.no_lot_seihin
		) AS cn_row 
		,*
	FROM
	(	
		SELECT
			KEIKAKU_SEIHIN.no_lot_seihin
			,KEIKAKU_SEIHIN.dt_seizo
			,KEIKAKU_SEIHIN.cd_hinmei AS cd_seihin
			,KEIKAKU_SEIHIN.cd_shokuba
			,KEIKAKU_SEIHIN.cd_line
			,KEIKAKU_SEIHIN.dt_shomi AS dt_kigen
			,KEIKAKU_SEIHIN.no_lot_hyoji
			,CASE
				WHEN EXISTS
				(
					SELECT 1
					FROM 
					(
						SELECT
							no_lot_shikakari
						FROM tr_sap_shiyo_yojitsu_anbun
						WHERE no_lot_seihin = KEIKAKU_SEIHIN.no_lot_seihin
					) ANBUN

					INNER JOIN tr_tonyu TONYU
					ON ANBUN.no_lot_shikakari = TONYU.no_lot_seihin
				) THEN @true
				ELSE @false
			END AS kbn_sonzai
		FROM tr_keikaku_seihin KEIKAKU_SEIHIN
		WHERE ( @cd_hinmei IS NULL OR KEIKAKU_SEIHIN.cd_hinmei = @cd_hinmei )
		AND 
		(
			( @chk_dt_seizo = @false ) 
			OR ( @dt_seizo_st <= KEIKAKU_SEIHIN.dt_seizo AND KEIKAKU_SEIHIN.dt_seizo < DATEADD(DD, @day, @dt_seizo_en) )
		)
		AND 
		(
			( @chk_dt_kigen = @false ) 
			OR ( @dt_kigen_st <= KEIKAKU_SEIHIN.dt_shomi AND KEIKAKU_SEIHIN.dt_shomi < DATEADD(DD, @day, @dt_kigen_en) )
		)
		AND ( @cd_shokuba IS NULL OR KEIKAKU_SEIHIN.cd_shokuba = @cd_shokuba )
		AND ( @cd_line IS NULL OR KEIKAKU_SEIHIN.cd_line = @cd_line )
		AND ( @no_lot_hyoji IS NULL OR KEIKAKU_SEIHIN.no_lot_hyoji = @no_lot_hyoji )
	) uni

	DECLARE	@no_lot_seihin	VARCHAR(14)
    DECLARE @totalrows		INT 
    DECLARE @currentrow		INT
	SET		@totalrows	=	( SELECT COUNT(*) FROM @tbl_keikaku_seihin )

	-- 投入トランに存在しない場合、トレース用ロットトランからとります
	SET		@currentrow =	0

	WHILE @currentrow < @totalrows  
    BEGIN
		SET @no_lot_seihin = 
		( 
			SELECT DISTINCT
				KEIKAKU.no_lot_seihin 
			FROM @tbl_keikaku_seihin KEIKAKU
						
			INNER JOIN tr_sap_shiyo_yojitsu_anbun ANBUN
			ON KEIKAKU.no_lot_seihin = ANBUN.no_lot_seihin

			WHERE KEIKAKU.cn_row = @currentrow + 1
			AND KEIKAKU.kbn_sonzai = @false
		)

		INSERT INTO @tbl_seihin_jisseki_trace_02
		(
			no_lot_shikakari
			,no_lot_seihin_moto
			,no_lot_seihin
			,cd_hinmei
			,kbn_hin
			,no_niuke
			,dt_niuke_genshizai
			,cd_genshizai
			,nm_genshizai
			,no_lot_genshizai
			,dt_kigen_genshizai
			,no_nohinsho_genshizai
		)
		EXECUTE usp_SeihinJissekiTrace_select_02 @no_lot_seihin, @no_seq, @kbn_hin_genryo, @kbn_hin_jika, @lang
		SET @currentrow = @currentrow + 1
	END

	-- 投入トランに存在する場合、投入トランから取ります
	SET		@currentrow =	0

	WHILE @currentrow < @totalrows  
    BEGIN
		SET @no_lot_seihin = 
		( 
			SELECT DISTINCT 
				KEIKAKU.no_lot_seihin 
			FROM @tbl_keikaku_seihin KEIKAKU

			INNER JOIN tr_sap_shiyo_yojitsu_anbun ANBUN
			ON KEIKAKU.no_lot_seihin = ANBUN.no_lot_seihin

			WHERE KEIKAKU.cn_row = @currentrow + 1
			AND KEIKAKU.kbn_sonzai = @true
		)

		INSERT INTO @tbl_seihin_jisseki_trace_03
		(
			no_lot_shikakari
			,no_lot_seihin
			,dt_niuke_genshizai
			,cd_genshizai
			,nm_genshizai
			,no_lot_genshizai
			,dt_kigen_genshizai
			,no_nohinsho_genshizai
		)
		EXECUTE usp_SeihinJissekiTrace_select_03 @no_lot_seihin, @no_seq, @lang
		SET @currentrow = @currentrow + 1
	END

	-- 他のテーブルと結び付けます
    BEGIN
		WITH cte AS
		(
			SELECT
				*
				,ROW_NUMBER() OVER (ORDER BY
					uni.dt_seizo
					,uni.cd_seihin
					,uni.nm_seihin
					,uni.cd_shokuba
					,uni.nm_shokuba
					,uni.cd_line
					,uni.nm_line
					,uni.dt_kigen
					,uni.no_lot_hyoji
					,uni.dt_niuke_genshizai
					,uni.cd_genshizai
					,uni.nm_genshizai
					,uni.no_lot_genshizai
					,uni.dt_kigen_genshizai
					,uni.no_nohinsho_genshizai
				) AS RN
			FROM
			(
				SELECT
					SEIHIN.dt_seizo								--製造日
					,SEIHIN.cd_seihin							--製品コード
					,CASE @lang 
						WHEN 'ja' THEN 
							CASE 
								WHEN HIN_SEIHIN.nm_hinmei_ja IS NULL OR LEN(HIN_SEIHIN.nm_hinmei_ja) = 0 THEN HIN_SEIHIN.nm_hinmei_ryaku
								ELSE HIN_SEIHIN.nm_hinmei_ja
							END
						WHEN 'en' THEN
							CASE 
								WHEN HIN_SEIHIN.nm_hinmei_en IS NULL OR LEN(HIN_SEIHIN.nm_hinmei_en) = 0 THEN HIN_SEIHIN.nm_hinmei_ryaku
								ELSE HIN_SEIHIN.nm_hinmei_en
							END
						WHEN 'zh' THEN
							CASE 
								WHEN HIN_SEIHIN.nm_hinmei_zh IS NULL OR LEN(HIN_SEIHIN.nm_hinmei_zh) = 0 THEN HIN_SEIHIN.nm_hinmei_ryaku
								ELSE HIN_SEIHIN.nm_hinmei_zh
							END
						WHEN 'vi' THEN
							CASE 
								WHEN HIN_SEIHIN.nm_hinmei_vi IS NULL OR LEN(HIN_SEIHIN.nm_hinmei_vi) = 0 THEN HIN_SEIHIN.nm_hinmei_ryaku
								ELSE HIN_SEIHIN.nm_hinmei_vi
							END
					END AS nm_seihin							--製品名
					,SEIHIN.cd_shokuba							--職場コード
					,SHOKUBA.nm_shokuba							--職場名
					,SEIHIN.cd_line								--ラインコード
					,LINE.nm_line								--ライン名
					,SEIHIN.dt_kigen							--賞味期限日
					,SEIHIN.no_lot_hyoji						--表示用ロットＮｏ
					,SEIHIN_JISSEKI_TRACE.dt_niuke_genshizai		--荷受日
					,SEIHIN_JISSEKI_TRACE.cd_genshizai			--原資材コード
					,SEIHIN_JISSEKI_TRACE.nm_genshizai			--原資材名
					,SEIHIN_JISSEKI_TRACE.no_lot_genshizai		--原資材ロットNo
					,SEIHIN_JISSEKI_TRACE.dt_kigen_genshizai		--原資材-賞味期限
					,SEIHIN_JISSEKI_TRACE.no_nohinsho_genshizai	--原資材-納品書番号
				FROM @tbl_keikaku_seihin SEIHIN

				LEFT OUTER JOIN ma_hinmei HIN_SEIHIN
				ON SEIHIN.cd_seihin = HIN_SEIHIN.cd_hinmei

				LEFT OUTER JOIN ma_shokuba SHOKUBA
				ON SEIHIN.cd_shokuba = SHOKUBA.cd_shokuba

				LEFT OUTER JOIN ma_line LINE
				ON SEIHIN.cd_line = LINE.cd_line

				INNER JOIN
				(
					SELECT DISTINCT
						SEIHIN_JISSEKI_TRACE_02.no_lot_seihin_moto
						,SEIHIN_JISSEKI_TRACE_02.dt_niuke_genshizai
						,SEIHIN_JISSEKI_TRACE_02.cd_genshizai
						,SEIHIN_JISSEKI_TRACE_02.nm_genshizai
						,SEIHIN_JISSEKI_TRACE_02.no_lot_genshizai
						,SEIHIN_JISSEKI_TRACE_02.dt_kigen_genshizai
						,SEIHIN_JISSEKI_TRACE_02.no_nohinsho_genshizai
						,SEIHIN_JISSEKI_TRACE_02.kbn_hin
					FROM @tbl_seihin_jisseki_trace_02 SEIHIN_JISSEKI_TRACE_02

					UNION ALL
					
					SELECT DISTINCT
						SEIHIN_JISSEKI_TRACE_03.no_lot_seihin AS no_lot_seihin_moto
						,SEIHIN_JISSEKI_TRACE_03.dt_niuke_genshizai
						,SEIHIN_JISSEKI_TRACE_03.cd_genshizai
						,SEIHIN_JISSEKI_TRACE_03.nm_genshizai
						,SEIHIN_JISSEKI_TRACE_03.no_lot_genshizai
						,SEIHIN_JISSEKI_TRACE_03.dt_kigen_genshizai
						,SEIHIN_JISSEKI_TRACE_03.no_nohinsho_genshizai
						,'2' AS kbn_hin
					FROM @tbl_seihin_jisseki_trace_03 SEIHIN_JISSEKI_TRACE_03
				) SEIHIN_JISSEKI_TRACE
				ON SEIHIN.no_lot_seihin = SEIHIN_JISSEKI_TRACE.no_lot_seihin_moto
				AND SEIHIN_JISSEKI_TRACE.kbn_hin IN (@kbn_hin_genryo,@kbn_hin_jika)
			) uni
		)

		--画面に返却する値を取得
		SELECT
			cnt
			,cte_row.dt_seizo
			,cte_row.cd_seihin
			,cte_row.nm_seihin
			,cte_row.cd_shokuba
			,cte_row.nm_shokuba
			,cte_row.cd_line
			,cte_row.nm_line
			,cte_row.dt_kigen
			,cte_row.no_lot_hyoji
			,cte_row.dt_niuke_genshizai
			,cte_row.cd_genshizai
			,cte_row.nm_genshizai
			,cte_row.no_lot_genshizai
			,cte_row.dt_kigen_genshizai
			,cte_row.no_nohinsho_genshizai
		FROM
		(
			SELECT 
				MAX(RN) OVER() cnt
				,*
			FROM cte 
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

	-- 一時テーブルを削除します
	DELETE FROM @tbl_keikaku_seihin
	DELETE FROM @tbl_seihin_jisseki_trace_02
	DELETE FROM @tbl_seihin_jisseki_trace_03

END

GO