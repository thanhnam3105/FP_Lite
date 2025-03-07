IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_RecipeTenkai_FromHaigo_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_RecipeTenkai_FromHaigo_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:		sueyoshi.y
-- Create date: 2013.09.05
-- Last Update: 2014.12.12
-- Description:	配合コードからレシピ展開（二階層目以降）
-- =======================================================
CREATE PROCEDURE [dbo].[usp_RecipeTenkai_FromHaigo_select]
    @hinmeiCode varchar(14) -- 画面情報
    ,@haigoCode varchar(14) 
    ,@shokubaCode varchar(10) -- 画面情報
    ,@lineCode varchar(10) -- 画面情報
    ,@seizoDate datetime -- 画面情報
    ,@kaisoSu smallint
    ,@oyashikakariLotNo varchar(14)
	,@haigoFalseFlag smallint
	,@haigoMasterKbn smallint -- マスタ区分：配合マスタ
	,@shiyoFlg smallint -- 未使用フラグ：使用
	,@hinmeiMasterKbn smallint -- マスタ区分：品名マスタ
	,@shikakariHinKbn smallint -- 品区分：仕掛品
	,@jikaGenryoHinKbn smallint -- 品区分：自家原料
AS

	-- 配合コードを元に、製造可能ラインマスタからラインコードを取得
	SELECT @lineCode = cd_line FROM ma_seizo_line
	WHERE cd_haigo = @haigoCode
	AND kbn_master = @haigoMasterKbn
	AND flg_mishiyo = @shiyoFlg
	AND no_juni_yusen = (
			SELECT MIN(no_juni_yusen) AS no_juni_yusen
			FROM ma_seizo_line
			WHERE cd_haigo = @haigoCode
			AND kbn_master = @haigoMasterKbn
			AND flg_mishiyo = @shiyoFlg )

	-- 製造可能ラインマスタから取得したラインコードを元に、ラインマスタから職場コードを取得
	SELECT @shokubaCode = cd_shokuba FROM ma_line
	WHERE cd_line = @lineCode


    SELECT 
        @hinmeiCode cd_hinmei
		
		-- 職場コード
			-- 取得したレシピ品区分が仕掛品だった場合
        ,CASE WHEN ma_haigo_mei_yuko.kbn_hin = @shikakariHinKbn
			THEN
				-- レシピ品名コードの職場コードを取得する
				(SELECT
					LINE_MST.cd_shokuba AS cd_shokuba
				FROM (
					SELECT cd_line AS cd_line
					FROM ma_seizo_line
					WHERE cd_haigo = ma_haigo_mei_yuko.cd_hinmei
					AND kbn_master = @haigoMasterKbn
					AND flg_mishiyo = @shiyoFlg
					AND no_juni_yusen = (
							SELECT MIN(no_juni_yusen) AS no_juni_yusen
							FROM ma_seizo_line
							WHERE cd_haigo = ma_haigo_mei_yuko.cd_hinmei
							AND kbn_master = @haigoMasterKbn
							AND flg_mishiyo = @shiyoFlg )
				) SEIZO_LINE
				INNER JOIN (
					SELECT ml.cd_line AS cd_line
						,ml.cd_shokuba AS cd_shokuba
					FROM ma_line ml
				) LINE_MST
				ON SEIZO_LINE.cd_line = LINE_MST.cd_line)
			-- 取得したレシピ品区分が自家原料だった場合
			--WHEN ma_haigo_mei_yuko.kbn_hin = @jikaGenryoHinKbn
			--THEN
			--	-- レシピ品名コードの職場コードを取得する
			--	(SELECT
			--		LINE_MST.cd_shokuba AS cd_shokuba
			--	FROM (
			--		SELECT cd_line AS cd_line
			--		FROM ma_seizo_line
			--		WHERE cd_haigo = ma_haigo_mei_yuko.cd_hinmei
			--		AND kbn_master = @hinmeiMasterKbn
			--		AND flg_mishiyo = @shiyoFlg
			--		AND no_juni_yusen = (
			--				SELECT MIN(no_juni_yusen) AS no_juni_yusen
			--				FROM ma_seizo_line
			--				WHERE cd_haigo = ma_haigo_mei_yuko.cd_hinmei
			--				AND kbn_master = @hinmeiMasterKbn
			--				AND flg_mishiyo = @shiyoFlg )
			--	) SEIZO_LINE
			--	INNER JOIN (
			--		SELECT ml.cd_line AS cd_line
			--			,ml.cd_shokuba AS cd_shokuba
			--		FROM ma_line ml
			--	) LINE_MST
			--	ON SEIZO_LINE.cd_line = LINE_MST.cd_line)
			ELSE
				@shokubaCode
			END AS cd_shokuba

		-- ラインコード
			-- 取得したレシピ品区分が仕掛品だった場合
        ,CASE WHEN ma_haigo_mei_yuko.kbn_hin = @shikakariHinKbn
			THEN
				-- レシピ品名コードのラインコードを取得する
				(SELECT cd_line AS cd_line
				FROM ma_seizo_line
				WHERE cd_haigo = ma_haigo_mei_yuko.cd_hinmei
				AND kbn_master = @haigoMasterKbn
				AND flg_mishiyo = @shiyoFlg
				AND no_juni_yusen = (
						SELECT MIN(no_juni_yusen) AS no_juni_yusen
						FROM ma_seizo_line
						WHERE cd_haigo = ma_haigo_mei_yuko.cd_hinmei
						AND kbn_master = @haigoMasterKbn
						AND flg_mishiyo = @shiyoFlg )
				)
			-- 取得したレシピ品区分が自家原料だった場合
			--WHEN ma_haigo_mei_yuko.kbn_hin = @jikaGenryoHinKbn
			--THEN
			--	-- レシピ品名コードのラインコードを取得する
			--	(SELECT cd_line AS cd_line
			--	FROM ma_seizo_line
			--	WHERE cd_haigo = ma_haigo_mei_yuko.cd_hinmei
			--	AND kbn_master = @hinmeiMasterKbn
			--	AND flg_mishiyo = @shiyoFlg
			--	AND no_juni_yusen = (
			--			SELECT MIN(no_juni_yusen) AS no_juni_yusen
			--			FROM ma_seizo_line
			--			WHERE cd_haigo = ma_haigo_mei_yuko.cd_hinmei
			--			AND kbn_master = @hinmeiMasterKbn
			--			AND flg_mishiyo = @shiyoFlg )
			--	)
			ELSE
				@lineCode
			END AS cd_line

        ,@seizoDate dt_seizo
        ,CAST(0.0 AS decimal) su_suryo -- ダミーデータ
        ,CAST(0.0 AS decimal) hinmei_budomari

        --,CAST(0 AS SMALLINT) hinmei_flg_tenkai
        ,CASE WHEN ma_haigo_mei_yuko.kbn_hin = @shikakariHinKbn
		 THEN COALESCE((SELECT TOP 1 flg_tenkai
						FROM udf_HaigoRecipeYukoHan(ma_haigo_mei_yuko.cd_hinmei, @haigoFalseFlag, @seizoDate)
						), CAST(0 AS SMALLINT))
		 ELSE CAST(0 AS SMALLINT)
		 END AS hinmei_flg_tenkai

        ,CAST(0.0 AS decimal) ritsu_hiju 
        ,CAST(0.0 AS decimal) su_iri 
        ,CAST(0.0 AS decimal) wt_ko 
        ,'' hinmei_kbn_kanzan
        ,ma_haigo_mei_yuko.cd_haigo 
        ,ma_haigo_mei_yuko.nm_haigo_ja 
        ,ma_haigo_mei_yuko.ritsu_budomari_mei haigo_budomari -- 配合マスタの歩留
        ,ma_haigo_mei_yuko.wt_kihon haigo_wt_kihon 
        ,ma_haigo_mei_yuko.flg_gassan_shikomi 
        ,ma_haigo_mei_yuko.wt_haigo haigo_wt_haigo
        ,ma_haigo_mei_yuko.flg_tenkai haigo_flg_tenkai
        ,ma_haigo_mei_yuko.kbn_kanzan haigo_kbn_kanzan 
        ,ma_haigo_mei_yuko.wt_haigo_gokei
        ,ma_haigo_mei_yuko.ritsu_kihon
        ,ma_haigo_mei_yuko.no_han 
        ,ma_haigo_mei_yuko.wt_haigo recipe_wt_haigo 
        ,ma_haigo_mei_yuko.no_kotei 
        ,ma_haigo_mei_yuko.no_tonyu 
        ,ma_haigo_mei_yuko.kbn_hin recipe_kbn_hin      -- 配合レシピマスタの品区分
        ,ma_haigo_mei_yuko.cd_hinmei recipe_cd_hinmei 
        ,ma_haigo_mei_yuko.nm_hinmei recipe_nm_hinmei 
        ,ma_haigo_mei_yuko.wt_shikomi
        ,ma_haigo_mei_yuko.ritsu_budomari_recipe recipe_budomari  -- 配合レシピマスタの歩留
        ,'' cd_shizai
        ,CAST(0.0 AS decimal) su_shiyo
        ,@kaisoSu su_kaiso
        ,@oyashikakariLotNo no_lot_shikakari_oya
	FROM udf_HaigoRecipeYukoHan(@haigoCode, @haigoFalseFlag, @seizoDate) ma_haigo_mei_yuko
    ORDER BY 
        ma_haigo_mei_yuko.no_kotei 
        ,ma_haigo_mei_yuko.no_tonyu 
        ,ma_haigo_mei_yuko.cd_hinmei
GO
