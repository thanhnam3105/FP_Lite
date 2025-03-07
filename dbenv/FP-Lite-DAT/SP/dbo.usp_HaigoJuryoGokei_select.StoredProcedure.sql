IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoJuryoGokei_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoJuryoGokei_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,okada.k>
-- Create date: <Create Date,,2013.12.12>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_HaigoJuryoGokei_select]
	@cd_haigo		AS VARCHAR(14) -- 配合コード
	,@no_han		AS DECIMAL(4,0) -- 版
	,@no_kotei		AS DECIMAL(4,0) -- 工程
	,@kbn_kanzan		AS VARCHAR(10) -- 換算区分
	,@wt_haigo_gokei	AS DECIMAL(12,6) -- 配合重量合計
	,@genryoHinKbn	AS SMALLINT -- 原料区分
	,@shikakariHinKbn		AS SMALLINT -- 仕掛区分
	,@jikaGenryoHinKbn		AS SMALLINT -- 自家原料区分
	,@kgKanzanKbn		AS VARCHAR(10) -- 換算区分(Kg)
	,@lKanzanKbn		AS VARCHAR(10) -- 換算区分(L)
AS
BEGIN

	DECLARE @kbn_shiagari	AS SMALLINT -- 仕上がり区分
	DECLARE @cd_hinmei 	AS VARCHAR(14) -- 品コード
	DECLARE @cd_tani_shiyo 	AS SMALLINT -- 換算区分(レシピ)
	DECLARE @wt_shikomi 	AS DECIMAL(12,6) -- 仕込重量
	DECLARE @ritsu_hiju 	AS DECIMAL(6,4) -- 比重
	
	-- カーソル定義
	-- 配合重量計算対象レシピを取得
	DECLARE cur_calc_qty_haigo_kei CURSOR FOR
	-- レシピが原料の場合
	SELECT
		recipe.cd_hinmei AS cd_hinmei
		,ISNULL(hinmei.cd_tani_shiyo,@kgKanzanKbn) AS cd_tani_shiyo
		,CONVERT(DECIMAL(12,6),recipe.wt_shikomi) AS wt_shikomi
		,ISNULL(hinmei.ritsu_hiju,1) AS hiju
	FROM
		(
		SELECT
			cd_haigo
			,no_han
			,kbn_hin
			,wt_shikomi
			,cd_hinmei
		FROM ma_haigo_recipe
		WHERE 
			cd_haigo = @cd_haigo
			AND no_han = @no_han
			AND no_kotei <> @no_kotei
			AND kbn_hin = @genryoHinKbn
		) recipe
	INNER JOIN ma_hinmei hinmei
	ON recipe.cd_hinmei = hinmei.cd_hinmei

	UNION ALL
	-- レシピが仕掛品の場合
	SELECT
		recipe.cd_hinmei AS cd_hinmei
		,ISNULL(haigo_mei.kbn_kanzan,@kgKanzanKbn) AS cd_tani_shiyo
		,CONVERT(DECIMAL(12,6),recipe.wt_shikomi) AS wt_shikomi
		,ISNULL(haigo_mei.ritsu_hiju,1) AS hiju
	FROM
		(
		SELECT
			cd_haigo
			,no_han
			,kbn_hin
			,wt_shikomi
			,cd_hinmei
		FROM ma_haigo_recipe
		WHERE 
			cd_haigo = @cd_haigo
			AND no_han = @no_han
			AND no_kotei <> @no_kotei			
			AND kbn_hin = @shikakariHinKbn
		) recipe
	INNER JOIN ma_haigo_mei haigo_mei
	ON recipe.cd_hinmei = haigo_mei.cd_haigo
	AND haigo_mei.no_han = 1

	UNION ALL
	-- レシピが自家原料の場合
	SELECT
		recipe.cd_hinmei AS cd_hinmei
		,ISNULL(hinmei.cd_tani_shiyo,@kgKanzanKbn) AS cd_tani_shiyo
		,CONVERT(DECIMAL(12,6),recipe.wt_shikomi) AS wt_shikomi
		,ISNULL(hinmei.ritsu_hiju,1) AS hiju
	FROM
		(
		SELECT
			cd_haigo
			,no_han
			,kbn_hin
			,wt_shikomi
			,cd_hinmei
		FROM ma_haigo_recipe
		WHERE 
			cd_haigo = @cd_haigo
			AND no_han = @no_han
			AND no_kotei <> @no_kotei			
			AND kbn_hin = @jikaGenryoHinKbn
		) recipe
	INNER JOIN ma_hinmei hinmei
	ON recipe.cd_hinmei = hinmei.cd_hinmei

	-- カーソルを開く
	OPEN cur_calc_qty_haigo_kei

	-- フェッチする
	FETCH NEXT FROM cur_calc_qty_haigo_kei
	INTO @cd_hinmei -- 品コード
		,@cd_tani_shiyo -- 換算区分(レシピ)
		,@wt_shikomi -- 仕込重量
		,@ritsu_hiju -- 比重

	-- カーソルの終わりまで
	WHILE @@FETCH_STATUS = 0
	BEGIN
			-- 配合マスタ詳細画面の換算区分がKgの場合
			IF @kbn_kanzan = @kgKanzanKbn
			BEGIN
				-- レシピの換算区分がKgの場合
				IF @cd_tani_shiyo = @kgKanzanKbn
				BEGIN
					SET @wt_haigo_gokei = @wt_haigo_gokei + @wt_shikomi
				END
				-- レシピの換算区分がKg以外の場合
				ELSE
				BEGIN
					-- 配合重量 * 比重
					SET @wt_haigo_gokei = @wt_haigo_gokei + ROUND(@wt_shikomi * @ritsu_hiju,6,1)
				END
			END
			ELSE
			BEGIN
				-- レシピの換算区分がLの場合
				IF @cd_tani_shiyo = @lKanzanKbn
				BEGIN
					SET @wt_haigo_gokei = @wt_haigo_gokei + @wt_shikomi
				END
				-- レシピの換算区分がL以外の場合
				ELSE
				BEGIN
					IF @ritsu_hiju = 0
					BEGIN
						SET @ritsu_hiju = 1
					END
					-- 配合重量 / 比重
					SET @wt_haigo_gokei = @wt_haigo_gokei + ROUND(@wt_shikomi / @ritsu_hiju,6,1)
				END
			END
	-- フェッチする
	FETCH NEXT FROM cur_calc_qty_haigo_kei
	INTO @cd_hinmei -- 品コード
		,@cd_tani_shiyo -- 換算区分(レシピ)
		,@wt_shikomi -- 仕込重量
		,@ritsu_hiju -- 比重
	END

	-- カーソルを閉じる
	CLOSE cur_calc_qty_haigo_kei
	DEALLOCATE cur_calc_qty_haigo_kei
	
	SELECT @wt_haigo_gokei AS wt_haigo_gokei

END
GO
