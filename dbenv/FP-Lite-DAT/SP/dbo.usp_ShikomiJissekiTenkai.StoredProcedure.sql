IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikomiJissekiTenkai') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikomiJissekiTenkai]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Description:	仕込実績レシピ展開（仕掛品）
-- Update: 2017.11.21	BRC	cho.k	新規
-- =============================================
CREATE PROCEDURE [dbo].[usp_ShikomiJissekiTenkai]
	(
		  @dt_seizo					DATETIME		-- 製造日
		, @cd_hinmei				VARCHAR(14)		-- 品名コード
		, @no_lot_seihin			VARCHAR(14)		-- 製品ロット番号
		, @su_seizo_jisseki			DECIMAL(12,6)	-- 製造実績数
	)
AS
BEGIN

-- =============================================
--               変数定義
-- =============================================
	
	-- 対象一時ワークテーブル
	CREATE TABLE #wk_tr_shikakari_1 (
	      dt_seizo			DATETIME
		, cd_haigo			VARCHAR(14) COLLATE database_default
		, su_kai            INT
		, no_lot_seihin		VARCHAR(14) COLLATE database_default
		, no_lot_shikakari	VARCHAR(14) COLLATE database_default
		, wt_shikomi		DECIMAL(12, 6)
	)

	
	-- 対象一時ワークテーブル
	CREATE TABLE #wk_tr_shikakari_2 (
	      dt_seizo			DATETIME
		, cd_haigo			VARCHAR(14) COLLATE database_default
		, su_kai            INT
		, no_lot_seihin		VARCHAR(14) COLLATE database_default
		, no_lot_shikakari	VARCHAR(14) COLLATE database_default
		, wt_shikomi		DECIMAL(12, 6)
	)
	
	-- 対象一時ワークテーブル
	CREATE TABLE #wk_tr_shikakari_3 (
	      dt_seizo			DATETIME
		, cd_haigo			VARCHAR(14) COLLATE database_default
		, su_kai            INT
		, no_lot_seihin		VARCHAR(14) COLLATE database_default
		, no_lot_shikakari	VARCHAR(14) COLLATE database_default
		, wt_shikomi		DECIMAL(12, 6)
	)

	-- 内部変数
	DECLARE @wt_shikomi_jisseki		DECIMAL(12,6)
	DECLARE @cnt					INT
	DECLARE @msg					VARCHAR(500)		-- 処理結果メッセージ格納用
	DECLARE @flg_break				BIT
	DECLARE @cd_haigo				VARCHAR(14)
	
	-- カーソル用変数
	DECLARE @cur_dt_seizo			DATETIME
	DECLARE @cur_cd_haigo			VARCHAR(14)
	DECLARE @cur_no_han				DECIMAL(4, 0)
	DECLARE @cur_su_kai				INT
	DECLARE @cur_no_lot_seihin		VARCHAR(14)
	DECLARE @cur_no_lot_shikakari	VARCHAR(14)
	DECLARE @cur_wt_shikomi			DECIMAL(12, 6)
	
	-- レシピ展開階層の初期化
	SET @cnt = 1

-- =============================================
--               仕込実績重量を計算
-- =============================================
	-- (1) 製造実績数から仕込実績重量を算出
	--【仕込実績重量＝製造実績数×入数×個重量×比重÷歩留率×100】
	SELECT 
		  @wt_shikomi_jisseki = (@su_seizo_jisseki * su_iri * wt_ko * ritsu_hiju) / ritsu_budomari
		, @cd_haigo = cd_haigo
	FROM (
		SELECT
			hin.cd_hinmei
			, hin.su_iri
			, hin.wt_ko
			, ISNULL(hin.ritsu_hiju, 1.00) AS ritsu_hiju
			, ISNULL(haigo.ritsu_budomari, 100.000) / 100.000 AS ritsu_budomari
			, hin.cd_haigo
		FROM ma_hinmei hin
		INNER JOIN (
			SELECT
				cd_haigo
				, MAX(no_han) AS no_han
			FROM ma_haigo_mei
			WHERE flg_mishiyo = 0
			  AND dt_from <= @dt_seizo
			GROUP BY cd_haigo
			  ) max_han
		  ON max_han.cd_haigo = hin.cd_haigo
		INNER JOIN ma_haigo_mei haigo
		  ON haigo.cd_haigo = max_han.cd_haigo
		  AND haigo.no_han = max_han.no_han
		WHERE hin.cd_hinmei = @cd_hinmei
		  AND hin.flg_mishiyo = 0
	) shikomi
	
	-- (2) 仕掛品実績を一時テーブルに登録する。
	INSERT INTO #wk_tr_shikakari_2
	SELECT TOP(1)
		 @dt_seizo AS dt_seizo
	   , @cd_haigo AS cd_haigo
	   , 1 AS su_kai
	   , @no_lot_seihin AS no_lot_seihin
	   , no_lot_shikakari AS no_lot_shikakari
	   , @wt_shikomi_jisseki AS wt_shikomi_jisseki
	FROM tr_keikaku_shikakari 
	WHERE no_lot_seihin = @no_lot_seihin
	  AND cd_shikakari_hin = @cd_haigo

-- =============================================
--               仕掛品のレシピ展開
-- =============================================
	---- レシピ展開を実施する。（品区分：仕掛品のみ）
	WHILE @cnt < 10
	BEGIN
	
		-- 中断フラグをリセットをオンにする。
		--（展開不要な場合に処理をループを抜ける為）
		SET @flg_break = 1
		
		DECLARE cursor_taisho CURSOR FOR
		SELECT
			*
		FROM #wk_tr_shikakari_2
		
	  	OPEN cursor_taisho
		IF (@@error <> 0)
		BEGIN
			SET @msg = 'CURSOR OPEN ERROR: cursor_taisho'
			GOTO Error_Handling
		END
		
		FETCH NEXT FROM cursor_taisho INTO
			  @cur_dt_seizo
			, @cur_cd_haigo	
			, @cur_su_kai 
			, @cur_no_lot_seihin
			, @cur_no_lot_shikakari
			, @cur_wt_shikomi
		  
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- 中断フラグをリセットをオフにする。
			SET @flg_break = 0
			
			INSERT INTO #wk_tr_shikakari_3
			SELECT
				@dt_seizo AS dt_seizo
				, recipe.cd_hinmei AS cd_haigo
				, @cur_su_kai + 1 AS su_kai
				, @cur_no_lot_seihin AS no_lot_seihin
				, shikakari.no_lot_shikakari
				, CAST(CEILING(
						@cur_wt_shikomi * (recipe.wt_shikomi / haigo.wt_haigo_gokei)
							* (100 /ISNULL(recipe.ritsu_budomari,100.00))
							* (100 /ISNULL(hin.ritsu_budomari,100.00)) * 1000000
							) / 1000000 AS DECIMAL(12,6)) AS wt_shikomi
			FROM (
				SELECT TOP(1)
					*
				FROM ma_haigo_mei
				WHERE flg_mishiyo = 0
				  AND cd_haigo = @cur_cd_haigo
				  AND dt_from <= @cur_dt_seizo
				ORDER BY no_han desc
				) haigo
			INNER JOIN ma_haigo_recipe recipe
			  ON recipe.cd_haigo = haigo.cd_haigo
			  AND recipe.no_han = haigo.no_han
			  AND recipe.kbn_hin = 5
			INNER JOIN (
				SELECT
					cd_haigo
					, MAX(no_han) AS no_han
				FROM ma_haigo_mei
				WHERE flg_mishiyo = 0
				  AND dt_from <= @cur_dt_seizo
				GROUP BY cd_haigo
				) max_han
				ON max_han.cd_haigo = recipe.cd_hinmei
			INNER JOIN ma_haigo_mei hin
			   ON hin.cd_haigo = max_han.cd_haigo
			   AND hin.no_han = max_han.no_han
			INNER JOIN tr_keikaku_shikakari shikakari
			  ON shikakari.dt_seizo = @cur_dt_seizo
			  AND shikakari.cd_shikakari_hin = recipe.cd_hinmei
			  AND shikakari.no_lot_seihin = @cur_no_lot_seihin
			
			
			FETCH NEXT FROM cursor_taisho INTO
				  @cur_dt_seizo
				, @cur_cd_haigo	
				, @cur_su_kai 
				, @cur_no_lot_seihin
				, @cur_no_lot_shikakari
				, @cur_wt_shikomi
				
		END
		
		CLOSE cursor_taisho
		DEALLOCATE cursor_taisho
		
		-- ワーク2をワーク1に移す
		INSERT INTO #wk_tr_shikakari_1
		SELECT * 
		FROM #wk_tr_shikakari_2
		
		
		-- ワーク２をクリア
		DELETE FROM #wk_tr_shikakari_2
		
		-- ワーク３をワーク２に移す
		INSERT INTO #wk_tr_shikakari_2
		SELECT * 
		FROM #wk_tr_shikakari_3
		
		
		-- ワーク３をクリア
		DELETE FROM #wk_tr_shikakari_3
		
		
		IF @flg_break = 1
		BEGIN
			BREAK;
		END
		
		SET @cnt = @cnt + 1
	END
	
	SELECT
		*
	FROM #wk_tr_shikakari_1
	
	DROP TABLE #wk_tr_shikakari_1
	DROP TABLE #wk_tr_shikakari_2
	DROP TABLE #wk_tr_shikakari_3
	
	RETURN
	
-- =============================================
--         例外処理
-- =============================================
	-- //////////// --
	--  エラー処理
	-- //////////// --
	Error_Handling:
		CLOSE cursor_taisho
		DEALLOCATE cursor_taisho
		PRINT @msg
		DROP TABLE #wk_tr_shikakari_1
		DROP TABLE #wk_tr_shikakari_2
		DROP TABLE #wk_tr_shikakari_3

		RETURN
END
GO