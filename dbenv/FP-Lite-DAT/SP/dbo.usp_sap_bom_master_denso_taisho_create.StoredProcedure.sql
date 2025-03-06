IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_bom_master_denso_taisho_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_bom_master_denso_taisho_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2015.01.22>
-- Last Update: <2015.10.30 kaneko.m> 品名マスタ.テスト品=1のデータを取り込まないように再修正
-- Last Update: <2019.03.26 BRC kanehira> 未使用の資材を伝送しないように修正
-- Last Update: <2019.09.13 nakamura.r> 配合レシピの有効版の取得方法変更
-- Description:	<Description,,BOMマスタ送信> 
--   伝送対象テーブル作成処理
-- ============================================================================
CREATE PROCEDURE [dbo].[usp_sap_bom_master_denso_taisho_create]
	@kbnCreate			smallint		-- SAP伝送区分：新規
	,@kbnUpdate			smallint		-- SAP伝送区分：更新
	,@kbnDelete			smallint		-- SAP伝送区分：削除
	,@su_kihon			decimal(4, 0)	-- 基本数量
	,@flg_true			smallint		-- 定数：フラグ：1
	,@flg_false			smallint		-- 定数：フラグ：0
	,@kbn_hin_seihin	smallint		-- 定数：品区分：製品
	,@kbn_hin_genryo	smallint		-- 定数：品区分：原料
	,@kbn_hin_shizai	smallint		-- 定数：品区分：資材
	,@kbn_hin_shikakari	smallint		-- 定数：品区分：仕掛品
	,@kbn_hin_jikagen	smallint		-- 定数：品区分：自家原料
	,@fixed_value		smallint		-- 固定値：1
	,@init_tani			varchar(2)		-- 初期値：単位コード：Kg
	,@init_budomari		decimal(5, 2)	-- 初期値：歩留
	,@utc				int				-- 時差：-6（アメリカ）
AS
BEGIN

	-- 対象一時ワークテーブル
	CREATE TABLE #tmp_taisho (
		cd_seihin		VARCHAR(14)
		,no_han			DECIMAL(4, 0)
		,dt_from		DATETIME
		,cd_hinmei		VARCHAR(14)
		,wt_haigo		DECIMAL(12, 6)
		,cd_tani		VARCHAR(2)
		,cd_haigo		VARCHAR(14)
		,no_kotei		DECIMAL(4, 0)
		--,no_tonyu		DECIMAL(4, 0)
		,no_tonyu		VARCHAR(30)
		,flg_mishiyo	SMALLINT
		,kbn_hin		SMALLINT
		,ritsu_budomari	DECIMAL(5, 2)
		,oya_wt_haigo	DECIMAL(12, 6)
		,oya_budomari	DECIMAL(5, 2)
		,oya_haigo		VARCHAR(14)
		,jikagen_code	VARCHAR(14)
	)

	-- 展開用一時ワークテーブル
	CREATE TABLE #tmp_tenkai (
		cd_seihin		VARCHAR(14)
		,no_han			DECIMAL(4, 0)
		,dt_from		DATETIME
		,cd_hinmei		VARCHAR(14)
		,wt_haigo		DECIMAL(12, 6)
		,cd_tani		VARCHAR(2)
		,cd_haigo		VARCHAR(14)
		,no_kotei		DECIMAL(4, 0)
		--,no_tonyu		DECIMAL(4, 0)
		,no_tonyu		VARCHAR(30)
		,flg_mishiyo	SMALLINT
		,kbn_hin		SMALLINT
		,ritsu_budomari	DECIMAL(5, 2)
		,oya_wt_haigo	DECIMAL(12, 6)
		,oya_budomari	DECIMAL(5, 2)
		,oya_haigo		VARCHAR(14)
		,jikagen_code	VARCHAR(14)
	)

	-- 展開用の倍率リスト
	CREATE TABLE #tmp_bairitsu (
		su_kaiso		SMALLINT
		,cd_seihin		VARCHAR(14)
		,cd_haigo		VARCHAR(14)
		,batch			DECIMAL(12, 6)
		,batch_hasu		DECIMAL(12, 6)
		,bairitsu		DECIMAL(12, 6)
		,bairitsu_hasu	DECIMAL(12, 6)
	)

	-- 有効版
	CREATE TABLE #udf_haigo (
		cd_haigo	VARCHAR(14)
		,no_han		DECIMAL(4, 0)
		,dt_from	DATETIME
	)

	-- 変数リスト
	DECLARE @msg					VARCHAR(500)		-- 処理結果メッセージ格納用
	DECLARE @cd_kojo				VARCHAR(13)			-- ログイン情報：工場コード
	DECLARE @tenkai_kaiso			SMALLINT = 1		-- 展開用の階層：初期値1
	DECLARE @flg_error				SMALLINT = 0		-- エラーフラグ
	-- カーソル用の変数リスト
	DECLARE @cur_cd_seihin			VARCHAR(14)
	DECLARE @cur_no_han				DECIMAL(4, 0)
	DECLARE @cur_dt_from			DATETIME
	DECLARE @cur_cd_hinmei			VARCHAR(14)
	DECLARE @cur_wt_haigo			DECIMAL(12, 6)
	DECLARE @cur_cd_tani			VARCHAR(2)
	DECLARE @cur_cd_haigo			VARCHAR(14)
	DECLARE @cur_no_kotei			DECIMAL(4, 0)
	--DECLARE @cur_no_tonyu			DECIMAL(4, 0)
	DECLARE @cur_no_tonyu			VARCHAR(30)
	DECLARE @cur_flg_mishiyo		SMALLINT
	DECLARE @cur_kbn_hin			SMALLINT
	DECLARE @cur_recipe_budomari	DECIMAL(5, 2)
	DECLARE @cur_oya_wt_haigo		DECIMAL(12, 6)		-- 親仕掛品の配合レシピ．配合重量
	DECLARE @cur_oya_budomari		DECIMAL(5, 2)		-- 親仕掛品の配合レシピ．歩留
	DECLARE @cur_oya_haigo			VARCHAR(14)			-- 親仕掛品の配合コード
	DECLARE @cur_jikagen_code		VARCHAR(14)			-- 自家原料の場合、自家原料コードが入る
	DECLARE @cur_su_hinmoku			DECIMAL(30, 6)		-- 100倍にしたときの桁あふれ用

	SET NOCOUNT ON

	-- 工場コードの取得
	SET @cd_kojo = (SELECT TOP 1 cd_kojo FROM ma_kojo)
	-- BOMマスタ送信対象テーブルをクリア
	DELETE ma_sap_bom_denso_taisho
	
	-- システム日付の取得
	DECLARE @systemDate DATETIME = DATEADD(hour, @utc, GETUTCDATE())
	PRINT ''
	PRINT @systemDate
	SET @systemDate = CONVERT(NVARCHAR, @systemDate, 111) + ' 10:00:00'

	-- 有効版の取得
	INSERT INTO #udf_haigo (
		cd_haigo
		,no_han
	)
	SELECT
		yuko.cd_haigo
		,MAX(hai.no_han) AS no_han
	FROM
	(
		SELECT
			cd_haigo
			,MAX(dt_from) AS dt_from
		FROM
			ma_haigo_mei
		WHERE dt_from <= @systemDate
		AND flg_mishiyo = @flg_false
		GROUP BY cd_haigo
	) yuko
	LEFT OUTER JOIN dbo.ma_haigo_mei hai
    ON yuko.cd_haigo = hai.cd_haigo
    AND yuko.dt_from = hai.dt_from
    GROUP BY yuko.cd_haigo, yuko.dt_from


-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
--    BOMマスタ送信対象テーブル(ma_sap_bom_denso_taisho)の作成
-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
	-- ==============================================
	--  資 材
	-- ==============================================
	INSERT INTO ma_sap_bom_denso_taisho (
		cd_seihin
		,no_han
		,cd_kojo
		,dt_from
		,su_kihon
		,cd_hinmei
		,su_hinmoku
		,cd_tani
		,su_kaiso
		,cd_haigo
		,no_kotei
		,no_tonyu
		,flg_mishiyo
	)
	SELECT
		seihin.cd_hinmei AS 'cd_seihin'
		,shizai.no_han AS 'no_han'
		,@cd_kojo AS 'cd_kojo'
		,shizai.dt_from AS 'dt_from'
		,@su_kihon AS 'su_kihon'
		,shizai.cd_shizai AS 'cd_hinmei'
		
		-- 1000C/S単位に換算：1000 * 使用数 / 品名マスタ_資材.歩留 * 100 ※小数点第七位で切り上げ
		,CEILING (
			ROUND(((@su_kihon * shizai.su_shiyo / hin_shizai.ritsu_budomari * 100) * 10000000), 0, 1) / 10
		 ) / 1000000 AS 'su_hinmoku'
		--,(@su_kihon * shizai_b.su_shiyo / hin_shizai.ritsu_budomari * 100) AS debug_val	--デバッグ用
		--,shizai_b.su_shiyo as su_shiyo	--デバッグ用
		--,hin_shizai.ritsu_budomari AS budomari	--デバッグ用

		--,seihin.kbn_kanzan AS 'cd_tani'
		,hin_shizai.cd_tani_shiyo AS 'cd_tani'
		,@fixed_value AS 'su_kaiso'
		,seihin.cd_hinmei AS 'cd_haigo'	-- 資材に配合コードはないので代わりに製品コードを設定
		,@fixed_value AS 'no_kotei'
		,(seihin.cd_hinmei + shizai.cd_shizai) AS 'no_tonyu'
		,seihin.flg_mishiyo
	FROM (
		SELECT cd_hinmei
			,COALESCE(kbn_kanzan, @init_tani) AS kbn_kanzan
			,flg_mishiyo
			,kbn_hin
		FROM ma_hinmei
		WHERE kbn_hin = @kbn_hin_seihin
		OR kbn_hin = @kbn_hin_jikagen
	) seihin

	-- 伝送日で有効な資材使用マスタを取得
	--LEFT JOIN udf_ShizaiShiyoYukoHan(seihin.cd_hinmei, @flg_false, @systemDate) shizai
	--ON shizai.cd_hinmei = seihin.cd_hinmei
	LEFT JOIN (
        SELECT
            h.cd_hinmei
            ,h.dt_from
            ,h.no_han
            ,h.flg_mishiyo
            ,b.cd_shizai
            ,b.su_shiyo
        FROM
        -- 有効日付が版番号間で同一の場合、最大の版番号を取得する
        (
            SELECT
                yuko.cd_hinmei
                ,yuko.dt_from
                ,h.flg_mishiyo
                ,MAX(h.no_han) AS no_han
            FROM
            -- 品名毎の最大の有効日付を取得する
            (
                SELECT
                    cd_hinmei
                    ,MAX(dt_from) AS dt_from
                FROM
                ma_shiyo_h
                WHERE
                    flg_mishiyo = @flg_false
                    AND dt_from <= @systemDate
                GROUP BY cd_hinmei
            ) yuko
            LEFT OUTER JOIN ma_shiyo_h h
            ON yuko.cd_hinmei = h.cd_hinmei
            AND yuko.dt_from = h.dt_from
            GROUP BY 
                yuko.cd_hinmei
                ,yuko.dt_from
                ,h.flg_mishiyo
        ) h
        LEFT OUTER JOIN ma_shiyo_b b
        ON h.cd_hinmei = b.cd_hinmei
        AND h.no_han = b.no_han
    ) shizai
    ON shizai.cd_hinmei = seihin.cd_hinmei

	-- 品名マスタ_資材：使用数の計算用
	INNER JOIN (
		SELECT cd_hinmei
			,COALESCE(ritsu_budomari, @init_budomari) AS ritsu_budomari
			,cd_tani_shiyo
			,flg_mishiyo
		FROM ma_hinmei
		WHERE kbn_hin = @kbn_hin_shizai
	) hin_shizai
	ON shizai.cd_shizai = hin_shizai.cd_hinmei

	WHERE
		-- オーバーフロー対策
		(@su_kihon * shizai.su_shiyo / hin_shizai.ritsu_budomari * 100) <= 999999.999999
		AND seihin.flg_mishiyo = @flg_false
		AND hin_shizai.flg_mishiyo = @flg_false

	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'error :ma_sap_bom_denso_taisho-shizai failed insert.'
		GOTO Error_Handling
	END

	--PRINT '資材終了'

	-- ==============================================
	--  配 合 (仕掛品・自家原料)
	-- ==============================================
	--  製品の情報より、配合データを抽出。
	--  有効版などは気にしない（すべて取得する）
	INSERT INTO #tmp_taisho (
		cd_seihin
		,no_han
		,dt_from
		,cd_hinmei
		,wt_haigo
		,cd_tani
		,cd_haigo
		,no_kotei
		,no_tonyu
		,flg_mishiyo
		,kbn_hin
		,ritsu_budomari
		,oya_wt_haigo
		,oya_budomari
		,oya_haigo
	)
	SELECT
		seihin.cd_hinmei AS 'cd_seihin'
		,haigo_mei.no_han AS 'no_han'
		,haigo_mei.dt_from AS 'dt_from'
		,recipe.cd_hinmei AS 'cd_hinmei'
		,recipe.wt_shikomi AS 'wt_haigo'
		--,seihin.kbn_kanzan AS 'kbn_kanzan'
		,COALESCE(genryo_hin.kbn_kanzan, @init_tani) AS 'kbn_kanzan'
		,haigo_mei.cd_haigo AS 'cd_haigo'
		,recipe.no_kotei AS 'no_kotei'
		,RIGHT('000' + CONVERT(VARCHAR, recipe.no_tonyu), 3) AS 'no_tonyu'
		,seihin.flg_mishiyo AS 'flg_mishiyo'
		,kbn_hin AS 'kbn_hin'
		,recipe.ritsu_budomari
		,@init_budomari AS 'oya_wt_haigo'
		,@init_budomari AS 'oya_budomari'
		,haigo_mei.cd_haigo AS 'oya_haigo'
	FROM (
		SELECT cd_hinmei
			,cd_haigo
			,flg_mishiyo
			,COALESCE(kbn_kanzan, @init_tani) AS kbn_kanzan
			,su_iri
			,wt_ko
			,ritsu_hiju
		FROM ma_hinmei
		WHERE kbn_hin = @kbn_hin_seihin
		OR kbn_hin = @kbn_hin_jikagen
	) seihin
	-- 有効版を取得
	INNER JOIN #udf_haigo udf
	ON udf.cd_haigo = seihin.cd_haigo
	INNER JOIN (
		SELECT cd_haigo
			,no_han
			,dt_from
			--,ritsu_budomari
		FROM ma_haigo_mei
	) haigo_mei
	ON haigo_mei.cd_haigo = udf.cd_haigo
	AND haigo_mei.no_han = udf.no_han
	INNER JOIN (
		SELECT cd_haigo
			,no_han
			,cd_hinmei
			,wt_shikomi
			,no_kotei
			,no_tonyu
			,kbn_hin
			,ritsu_budomari
		FROM ma_haigo_recipe
		WHERE kbn_hin = @kbn_hin_genryo
		OR kbn_hin = @kbn_hin_shikakari
		OR kbn_hin = @kbn_hin_jikagen
	) recipe
	ON haigo_mei.cd_haigo = recipe.cd_haigo
	AND haigo_mei.no_han = recipe.no_han
	-- 原料の品名マスタ
	LEFT JOIN (
		SELECT cd_hinmei
			,kbn_kanzan
		FROM ma_hinmei
	) genryo_hin
	ON genryo_hin.cd_hinmei = recipe.cd_hinmei
	WHERE
		seihin.flg_mishiyo = @flg_false

    IF @@ERROR <> 0
    BEGIN
        SET @msg = 'error :#tmp_taisho failed insert.'
        GOTO Error_Handling
    END

	--PRINT '展開スタート'

	-- ///////////////////////////////////////////
	--  展開処理：仕掛品は展開する（自家原料は原料として扱う）
	-- ///////////////////////////////////////////
	-- 展開は最大10階層までとする。
	WHILE (@tenkai_kaiso < 10)
	BEGIN
		-- /=======================================================/
		--   対象データをカーソルへ：1000C/S単位への換算処理のため
		-- /=======================================================/
		DECLARE cursor_taisho CURSOR FOR
			SELECT
				tmp.cd_seihin
				,tmp.no_han
				,tmp.dt_from
				,tmp.cd_hinmei
				,tmp.wt_haigo
				,tmp.cd_tani
				,tmp.cd_haigo
				,tmp.no_kotei
				,tmp.no_tonyu
				,tmp.flg_mishiyo
				,tmp.ritsu_budomari
				,tmp.oya_wt_haigo
				,tmp.oya_budomari
				,tmp.oya_haigo
				,tmp.jikagen_code
			FROM #tmp_taisho tmp
			WHERE tmp.kbn_hin = @kbn_hin_genryo
			OR tmp.kbn_hin = @kbn_hin_jikagen

--SELECT * FROM #tmp_taisho

		OPEN cursor_taisho
			IF (@@error <> 0)
			BEGIN
				SET @msg = 'CURSOR OPEN ERROR: cursor_taisho'
				GOTO Error_Handling
			END

		FETCH NEXT FROM cursor_taisho INTO
			@cur_cd_seihin
			,@cur_no_han
			,@cur_dt_from
			,@cur_cd_hinmei
			,@cur_wt_haigo
			,@cur_cd_tani
			,@cur_cd_haigo
			,@cur_no_kotei
			,@cur_no_tonyu
			,@cur_flg_mishiyo
			,@cur_recipe_budomari
			,@cur_oya_wt_haigo
			,@cur_oya_budomari
			,@cur_oya_haigo
			,@cur_jikagen_code

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--PRINT 'カーソルスタート'
			--PRINT @tenkai_kaiso
			DECLARE @su_seizo decimal(26, 6) = 0	-- 製造予定数
			DECLARE @batch decimal(12, 6) = 0		-- バッチ数
			DECLARE @batch_hasu decimal(12, 6) = 0	-- バッチ端数
			DECLARE @bairitsu decimal(12, 6) = 0	-- 倍率
			DECLARE @bairitsu_hasu decimal(12, 6) = 0	-- 倍率端数
			--DECLARE @wt_haigo_keikaku_hasu decimal(12, 6) = 0	-- 計画配合重量端数
			DECLARE @hinmoku_suryo decimal(26, 6) = 0	-- 品目数量
			DECLARE @flg_overflow smallint = 0	-- オーバーフローフラグ
			-- 配合名マスタ
			DECLARE @budomari decimal(5, 2) -- 歩留
			DECLARE @wt_haigo_gokei decimal(12, 6) = 0	-- 合計配合重量
			DECLARE @ritsu_kihon decimal(5, 2) = 0	-- 基本倍率
			SELECT TOP 1 @budomari = ritsu_budomari
				,@wt_haigo_gokei = wt_haigo_gokei
				,@ritsu_kihon = ritsu_kihon
			FROM ma_haigo_mei
			WHERE cd_haigo = @cur_cd_haigo
			AND no_han = @cur_no_han
			IF @budomari = 0
				SET @budomari = @init_budomari	-- 歩留が0の場合は初期値100を設定
			IF @cur_recipe_budomari = 0
				SET @cur_recipe_budomari = @init_budomari
			IF @cur_oya_budomari = 0
				SET @cur_oya_budomari = @init_budomari

			IF @wt_haigo_gokei > 0	-- 0除算対策
			BEGIN
				-- ///// 1階層目
				IF @tenkai_kaiso = 1
				BEGIN
					-- 品名マスタ(製品)
					DECLARE @su_iri decimal(5, 0) = 1	-- 入数
					DECLARE @wt_ko decimal(12, 6) = 1	-- 個重量
					DECLARE @ritsu_hiju decimal(6, 4) = 1	-- 比重
					DECLARE @kbn_kanzan_hin varchar(10) = @init_tani	-- 換算区分
					SELECT TOP 1 @su_iri = su_iri, @wt_ko = wt_ko,
						@ritsu_hiju = ritsu_hiju, @kbn_kanzan_hin = kbn_kanzan
					FROM ma_hinmei WHERE cd_hinmei = @cur_cd_seihin
					
					--PRINT '1階層目'
					--PRINT @su_iri
					--PRINT @wt_ko
					--PRINT @ritsu_hiju
					
					IF @ritsu_hiju > 0	-- 0除算対策
					BEGIN
						-- 配合名マスタの換算区分
						DECLARE @kbn_kanzan_haigo varchar(10) = @init_tani	-- 換算区分
						SELECT TOP 1 @kbn_kanzan_haigo = kbn_kanzan
						FROM ma_haigo_mei
						WHERE cd_haigo = @cur_cd_haigo
						AND no_han = @cur_no_han
						
						-- 比重の換算は品名マスタ.換算区分が配合名マスタ.換算区分と違うときのみ加味（安全のため）
						-- ＃換算区分が一緒のときは比重を１にしておけばOK
						IF @kbn_kanzan_hin = @kbn_kanzan_haigo
						BEGIN
							SET @ritsu_hiju = 1
						END
						
						SET @su_seizo = (@su_kihon * @su_iri * @wt_ko / @ritsu_hiju / @budomari * 100)

						IF @su_seizo <= 999999.999999
						BEGIN
							-- 小数点第七位で切り上げ
							SET @su_seizo = CEILING (ROUND((@su_seizo * 10000000), 0, 1) / 10) / 1000000

							-- バッチ数と倍率の設定
							SELECT TOP 1 @batch = batch
								,@batch_hasu = batch_hasu
								,@bairitsu = bairitsu
								,@bairitsu_hasu = bairitsu_hasu
							FROM udf_MakeBairitsuObject(@su_seizo, @wt_haigo_gokei, @ritsu_kihon)
						END
						ELSE BEGIN
							-- 算術オーバーフローなので、フラグをONにする
							SET @flg_overflow = 1
						END
					END
				END
				-- ///// 2階層目以降
				ELSE BEGIN
					-- 倍率リストから前階層のバッチ数と倍率を取得
					SELECT TOP 1 @batch = batch
						,@batch_hasu = batch_hasu
						,@bairitsu = bairitsu
						,@bairitsu_hasu = bairitsu_hasu
					FROM #tmp_bairitsu
					WHERE
						su_kaiso = (@tenkai_kaiso - 1)
					AND cd_haigo = @cur_oya_haigo
					AND cd_seihin = @cur_cd_seihin
					
					--PRINT '2階層目以降'
					--SET @msg = '前階層バッチ:' + CONVERT(VARCHAR, @batch) + ', B端数:' + CONVERT(VARCHAR, @batch_hasu)
					--	+ ', 前階層倍率:' + CONVERT(VARCHAR, @bairitsu) + ', 倍率端数:' + CONVERT(VARCHAR, @bairitsu_hasu)
					--	+ ', 親配合の配合重量:' + CONVERT(VARCHAR, @cur_oya_wt_haigo)
					--	+ ', 親配合レシピ歩留:' + CONVERT(VARCHAR, @cur_oya_budomari) + ', 親配合cd:' + @cur_oya_haigo
					--PRINT @msg
					
					IF @cur_jikagen_code IS NOT NULL
					BEGIN
					-- 自家原料の場合は製造予定数(必要量)の計算が変わる
					-- ＃画面で製品計画を立案したときと同じ動きになる
						DECLARE @su_keikaku decimal(10, 0) = 1	-- 製品計画数
						-- 品名マスタ(自家原料)
						DECLARE @su_iri_jika decimal(5, 0) = 1	-- 入数
						DECLARE @wt_ko_jika decimal(12, 6) = 1	-- 個重量
						DECLARE @ritsu_hiju_jika decimal(6, 4) = 1	-- 比重
						DECLARE @kbn_kanzan_jika varchar(10) = @init_tani	-- 換算区分
						SELECT TOP 1 @su_iri_jika = su_iri, @wt_ko_jika = wt_ko,
							@ritsu_hiju_jika = ritsu_hiju, @kbn_kanzan_jika = kbn_kanzan
						FROM ma_hinmei WHERE cd_hinmei = @cur_jikagen_code

						-- 配合名マスタの換算区分
						DECLARE @kbn_kanzan_jika_haigo varchar(10) = @init_tani	-- 換算区分
						SELECT TOP 1 @kbn_kanzan_jika_haigo = kbn_kanzan
						FROM ma_haigo_mei
						WHERE cd_haigo = @cur_cd_haigo
						AND no_han = @cur_no_han

						--PRINT '自家原料の場合'
						--SET @msg = '自家原cd:' + @cur_jikagen_code + ', 配合cd:' + @cur_cd_haigo
						--	+ ', 入数:' + CONVERT(VARCHAR, @su_iri_jika) + ', 個重量:' + CONVERT(VARCHAR, @wt_ko_jika)
						--	+ ', 比重:' + CONVERT(VARCHAR, @ritsu_hiju_jika) + ', 原料:' + @cur_cd_hinmei
						--	+ ', 換算区分_自:' + @kbn_kanzan_jika + ', 換算区分_配:' + @kbn_kanzan_jika_haigo
						--PRINT @msg
						
						IF @kbn_kanzan_jika = @kbn_kanzan_jika_haigo
						BEGIN
							-- 換算区分が一緒のときは比重を１
							SET @ritsu_hiju_jika = 1
						END
						
						-- まずは製品計画数(自家原料の使用量)を求める
						SET @su_seizo = (@cur_oya_wt_haigo * @batch * @bairitsu / @cur_oya_budomari * 100)
											+ (@cur_oya_wt_haigo * @batch_hasu * @bairitsu_hasu / @cur_oya_budomari * 100)
						SET @su_keikaku = ROUND(@su_seizo, 0, 1)	-- 整数部を製品計画数とする

						--SET @msg = '自家原料の使用量:' + CONVERT(VARCHAR, @su_seizo) + ', C/S:' + CONVERT(VARCHAR, @su_keikaku)
						--PRINT @msg
						
						-- 製造予定数(必要量)を求める
						SET @su_seizo = (@su_keikaku * @su_iri_jika * @wt_ko_jika / @ritsu_hiju_jika / @budomari * 100)
						--PRINT @su_seizo
						--PRINT ' '
					END
					ELSE BEGIN
					-- 仕掛品の場合の製造予定数(必要量)の計算
						SET @su_seizo = (@cur_oya_wt_haigo * @batch * @bairitsu / @cur_oya_budomari * 100
										 + @cur_oya_wt_haigo * @batch_hasu * @bairitsu_hasu / @cur_oya_budomari * 100
										) / @budomari * 100
					END

					IF @su_seizo <= 999999.999999
					BEGIN
						-- バッチ数と倍率の設定
						SELECT TOP 1 @batch = batch
							,@batch_hasu = batch_hasu
							,@bairitsu = bairitsu
							,@bairitsu_hasu = bairitsu_hasu
						FROM udf_MakeBairitsuObject(@su_seizo, @wt_haigo_gokei, @ritsu_kihon)
					END
					ELSE BEGIN
						-- 算術オーバーフローなので、フラグをONにする
						SET @flg_overflow = 1
					END
				END
				
				IF @flg_overflow = 0
				BEGIN
					-- 品目数量の計算
					-- 配合レシピマスタ.仕込重量(画面の配合重量) * バッチ数 * 倍率 / 配合レシピマスタ.歩留 * 100
					--    + 配合レシピマスタ.仕込重量 * バッチ数端数 * 倍率端数 / 配合レシピマスタ.歩留 * 100
					SET @hinmoku_suryo = (@cur_wt_haigo * @batch * @bairitsu / @cur_recipe_budomari * 100)
											+ (@cur_wt_haigo * @batch_hasu * @bairitsu_hasu / @cur_recipe_budomari * 100)
					--SET @hinmoku_suryo = ROUND(@hinmoku_suryo, 6, 1)

						--PRINT 'パラメーターチェック'
						--SET @msg = '製品cd:' + @cur_cd_seihin + ', 配合cd:' + @cur_cd_haigo
						--	+ ', 版:' + CONVERT(VARCHAR, @cur_no_han) + ', 工程:' + CONVERT(VARCHAR, @cur_no_kotei)
						--	+ ', 投入:' + CONVERT(VARCHAR, @cur_no_tonyu) + ', 原料:' + @cur_cd_hinmei
						--	+ ', 必要量:' + CONVERT(VARCHAR, @su_seizo) + ', 使用量:' + CONVERT(VARCHAR, @hinmoku_suryo)
						--	+ ', cur_wt_haigo:' + CONVERT(VARCHAR, @cur_wt_haigo) + ', 合計配合重量:' + CONVERT(VARCHAR, @wt_haigo_gokei)
						--	+ ', バッチ:' + CONVERT(VARCHAR, @batch) + ', バッチ端数:' + CONVERT(VARCHAR, @batch_hasu)
						--	+ ', 倍率:' + CONVERT(VARCHAR, @bairitsu) + ', 倍率端数:' + CONVERT(VARCHAR, @bairitsu_hasu)
						--	+ ', 配合名マスタ歩留:' + CONVERT(VARCHAR, @budomari) + ', 基本倍率:' + CONVERT(VARCHAR, @ritsu_kihon)
						--	+ ', レシピ歩留:' + CONVERT(VARCHAR, @cur_recipe_budomari)
						--	+ ', 階層:' + CONVERT(VARCHAR, @tenkai_kaiso) + ', overFlg:' + CONVERT(VARCHAR, @flg_overflow)
						--PRINT @msg
						--PRINT ' '

					IF @hinmoku_suryo <= 999999.999999	-- オーバーフロー対策
					BEGIN
						-- /==================================/
						--   対象データを対象テーブルへINSERT
						-- /==================================/
						INSERT INTO ma_sap_bom_denso_taisho (
							cd_seihin
							,no_han
							,cd_kojo
							,dt_from
							,su_kihon
							,cd_hinmei
							,su_hinmoku
							,cd_tani
							,su_kaiso
							,cd_haigo
							,no_kotei
							,no_tonyu
							,flg_mishiyo
						)
						VALUES (
							@cur_cd_seihin
							,@cur_no_han
							,@cd_kojo
							,@cur_dt_from
							,@su_kihon
							,@cur_cd_hinmei
							,@hinmoku_suryo
							,@cur_cd_tani
							,@tenkai_kaiso
							,@cur_cd_haigo
							,@cur_no_kotei
							,@cur_no_tonyu
							,@cur_flg_mishiyo
						)

						IF @@ERROR <> 0
						BEGIN
							SET @msg = 'error :ma_sap_bom_denso_taisho-haigo failed insert.'
							GOTO Error_Handling
						END
					END
					ELSE BEGIN
						-- 算術オーバーフローなので、フラグをONにする
						SET @flg_overflow = 1
					END
					
					IF @flg_overflow = 0
					BEGIN
						-- 倍率リストに存在しなければ、バッチと倍率情報を追加する
						IF (SELECT TOP 1 su_kaiso FROM #tmp_bairitsu
							WHERE su_kaiso = @tenkai_kaiso
							AND cd_haigo = @cur_cd_haigo
							AND cd_seihin = @cur_cd_seihin) IS NULL
						BEGIN
							--PRINT '倍率リストに追加'
							--SET @msg = '階層:' + CONVERT(VARCHAR, @tenkai_kaiso)
							--	+ ', 製品cd:' + @cur_cd_seihin + ', 配合cd:' + @cur_cd_haigo
							--	+ ', バッチ:' + CONVERT(VARCHAR, @batch) + ', バッチ端数:' + CONVERT(VARCHAR, @batch_hasu)
							--	+ ', 倍率:' + CONVERT(VARCHAR, @bairitsu) + ', 倍率端数:' + CONVERT(VARCHAR, @bairitsu_hasu)
							--PRINT @msg

							INSERT #tmp_bairitsu (
								su_kaiso
								,cd_seihin
								,cd_haigo
								,batch
								,batch_hasu
								,bairitsu
								,bairitsu_hasu
							)
							VALUES (
								@tenkai_kaiso
								,@cur_cd_seihin
								,@cur_cd_haigo
								,@batch
								,@batch_hasu
								,@bairitsu
								,@bairitsu_hasu
							)
						END
					END
				END

				-- 算術オーバーフローがあったときは対象データをログに表示する
				IF @flg_overflow = 1
				BEGIN
					SET @flg_error = 1	-- エラーフラグを立てる

					PRINT 'Arithmetic overflow or other arithmetic exception occurred.：算術オーバーフロー'
					SET @msg = '  Object data... cd_seihin:' + @cur_cd_seihin + ', cd_haigo:' + @cur_cd_haigo
						+ ', no_han:' + CONVERT(VARCHAR, @cur_no_han) + ', no_kotei:' + CONVERT(VARCHAR, @cur_no_kotei)
						+ ', no_tonyu:' + CONVERT(VARCHAR, @cur_no_tonyu) + ', cd_hinmei:' + @cur_cd_hinmei
						+ ', su_seizo:' + CONVERT(VARCHAR, @su_seizo) + ', su_hinmoku:' + CONVERT(VARCHAR, @hinmoku_suryo)
					PRINT @msg
					PRINT ' '
				END
			END

			FETCH NEXT FROM cursor_taisho INTO
				@cur_cd_seihin
				,@cur_no_han
				,@cur_dt_from
				,@cur_cd_hinmei
				,@cur_wt_haigo
				,@cur_cd_tani
				,@cur_cd_haigo
				,@cur_no_kotei
				,@cur_no_tonyu
				,@cur_flg_mishiyo
				,@cur_recipe_budomari
				,@cur_oya_wt_haigo
				,@cur_oya_budomari
				,@cur_oya_haigo
				,@cur_jikagen_code
		END

		CLOSE cursor_taisho
		DEALLOCATE cursor_taisho
		-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
		--   対象データのカーソルここまで
		-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-

		-- 展開用一時テーブルをクリア
		DELETE #tmp_tenkai
		IF @@ERROR <> 0
		BEGIN
			SET @msg = 'error :#tmp_tenkai failed delete.'
			GOTO Error_Handling
		END

		-- 展開データの有無：仕掛品が存在するか
		IF (SELECT TOP 1 cd_seihin
			FROM #tmp_taisho
			WHERE kbn_hin = @kbn_hin_shikakari
			--OR kbn_hin = @kbn_hin_jikagen
			) IS NULL
		BEGIN
			-- 取得結果がなければ展開処理終了
			--PRINT '取得結果なし'
			BREAK
		END

		-- /==================================/
		--   展開対象を展開用一時テーブルへ
		-- /==================================/
		INSERT INTO #tmp_tenkai (
			cd_seihin
			,no_han
			,dt_from
			,cd_hinmei
			,wt_haigo
			,cd_tani
			,cd_haigo
			,no_kotei
			,no_tonyu
			,flg_mishiyo
			,kbn_hin
			,ritsu_budomari
			,oya_wt_haigo
			,oya_budomari
			,oya_haigo
			,jikagen_code
		)
			-- ////////// 仕掛品 //////////
			SELECT tmp.cd_seihin
				,tenkai_haigo.no_han
				,tenkai_haigo.dt_from
				,tenkai_recipe.cd_hinmei
				,tenkai_recipe.wt_shikomi
				--,tmp.cd_tani
				,COALESCE(genryo_hin.kbn_kanzan, @init_tani) AS kbn_kanzan
				,tenkai_haigo.cd_haigo AS 'cd_haigo'
				,tenkai_recipe.no_kotei
				--,tenkai_recipe.no_tonyu
				,tmp.no_tonyu + RIGHT('000' + CONVERT(VARCHAR, tenkai_recipe.no_tonyu), 3) AS 'no_tonyu'
				,tmp.flg_mishiyo
				,tenkai_recipe.kbn_hin
				,tenkai_recipe.ritsu_budomari
				,tmp.wt_haigo AS 'oya_wt_haigo'
				,tmp.ritsu_budomari AS 'oya_budomari'
				,tmp.cd_haigo AS 'oya_haigo'
				,null AS 'jikagen_code'
			FROM (
				SELECT cd_seihin
					,no_han
					,cd_hinmei
					,cd_tani
					,flg_mishiyo
					,wt_haigo
					,ritsu_budomari
					,cd_haigo
					,no_tonyu
				FROM #tmp_taisho
				WHERE kbn_hin = @kbn_hin_shikakari
				GROUP BY cd_seihin, no_han, cd_hinmei, cd_tani, flg_mishiyo, wt_haigo,
					ritsu_budomari, cd_haigo, no_tonyu
			) tmp
			-- 有効版を取得
			INNER JOIN #udf_haigo udf
			ON udf.cd_haigo = tmp.cd_hinmei
			INNER JOIN (
				SELECT cd_haigo
					,no_han
					,dt_from
				FROM ma_haigo_mei
			) tenkai_haigo
			ON tenkai_haigo.cd_haigo = udf.cd_haigo
			--AND tenkai_haigo.no_han = tmp.no_han
			AND tenkai_haigo.no_han = udf.no_han
			INNER JOIN (
				SELECT cd_haigo
					,no_han
					,cd_hinmei
					,wt_shikomi
					,no_kotei
					,no_tonyu
					,kbn_hin
					,ritsu_budomari
				FROM ma_haigo_recipe
				WHERE kbn_hin = @kbn_hin_genryo
				OR kbn_hin = @kbn_hin_shikakari
				OR kbn_hin = @kbn_hin_jikagen
			) tenkai_recipe
			ON tenkai_haigo.cd_haigo = tenkai_recipe.cd_haigo
			AND tenkai_haigo.no_han = tenkai_recipe.no_han
			-- 原料の品名マスタ
			LEFT JOIN (
				SELECT cd_hinmei
					,kbn_kanzan
				FROM ma_hinmei
			) genryo_hin
			ON genryo_hin.cd_hinmei = tenkai_recipe.cd_hinmei

		-- 自家原料は展開しない(2015.07.03 tsujita.s)
		--UNION ALL
		--	-- ////////// 自家原料 //////////
		--	SELECT tmp.cd_seihin
		--		,tenkai_haigo.no_han
		--		,tenkai_haigo.dt_from
		--		,tenkai_recipe.cd_hinmei
		--		,tenkai_recipe.wt_shikomi
		--		--,tmp.cd_tani
		--		,COALESCE(genryo_hin.kbn_kanzan, @init_tani) AS kbn_kanzan
		--		,tenkai_haigo.cd_haigo
		--		--,tmp.cd_hinmei AS 'cd_haigo'
		--		,tenkai_recipe.no_kotei
		--		--,tenkai_recipe.no_tonyu
		--		,tmp.no_tonyu + RIGHT('000' + CONVERT(VARCHAR, tenkai_recipe.no_tonyu), 3) AS 'no_tonyu'
		--		,tmp.flg_mishiyo
		--		,tenkai_recipe.kbn_hin
		--		,tenkai_recipe.ritsu_budomari
		--		,tmp.wt_haigo AS 'oya_wt_haigo'
		--		,tmp.ritsu_budomari AS 'oya_budomari'
		--		,tmp.cd_haigo AS 'oya_haigo'
		--		,tmp.cd_hinmei AS 'jikagen_code'
		--	FROM (
		--		SELECT cd_seihin
		--			,cd_hinmei
		--			,cd_tani
		--			,flg_mishiyo
		--			,wt_haigo
		--			,ritsu_budomari
		--			,cd_haigo
		--			,no_tonyu
		--		FROM #tmp_taisho
		--		WHERE kbn_hin = @kbn_hin_jikagen
		--		GROUP BY cd_seihin, cd_hinmei, cd_tani, flg_mishiyo, wt_haigo,
		--			ritsu_budomari, cd_haigo, no_tonyu
		--	) tmp
		--	INNER JOIN (
		--		-- 自家原料は品名マスタから配合コードを取得する
		--		SELECT cd_hinmei
		--			,cd_haigo
		--		FROM ma_hinmei
		--		WHERE kbn_hin = @kbn_hin_jikagen
		--	) hin
		--	ON tmp.cd_hinmei = hin.cd_hinmei

		--	-- 有効版を取得
		--	INNER JOIN #udf_haigo udf
		--	ON udf.cd_haigo = hin.cd_haigo
		--	INNER JOIN (
		--		SELECT cd_haigo
		--			,no_han
		--			,dt_from
		--		FROM ma_haigo_mei
		--	) tenkai_haigo
		--	ON tenkai_haigo.cd_haigo = udf.cd_haigo
		--	AND tenkai_haigo.no_han = udf.no_han
		--	INNER JOIN (
		--		SELECT cd_haigo
		--			,no_han
		--			,cd_hinmei
		--			,wt_shikomi
		--			,no_kotei
		--			,no_tonyu
		--			,kbn_hin
		--			,ritsu_budomari
		--		FROM ma_haigo_recipe
		--		WHERE kbn_hin = @kbn_hin_genryo
		--		OR kbn_hin = @kbn_hin_shikakari
		--		OR kbn_hin = @kbn_hin_jikagen
		--	) tenkai_recipe
		--	ON tenkai_haigo.cd_haigo = tenkai_recipe.cd_haigo
		--	AND tenkai_haigo.no_han = tenkai_recipe.no_han
		--	-- 原料の品名マスタ
		--	LEFT JOIN (
		--		SELECT cd_hinmei
		--			,kbn_kanzan
		--		FROM ma_hinmei
		--	) genryo_hin
		--	ON genryo_hin.cd_hinmei = tenkai_recipe.cd_hinmei

		IF @@ERROR <> 0
		BEGIN
			SET @msg = 'error :#tmp_tenkai failed insert.'
			GOTO Error_Handling
		END

		-- 一通りの抽出が終わったので対象一時テーブルの中身をクリア
		DELETE #tmp_taisho
		IF @@ERROR <> 0
		BEGIN
			SET @msg = 'error :#tmp_taisho failed delete.'
			GOTO Error_Handling
		END

		-- 対象データにコピー	
		INSERT INTO #tmp_taisho (
			cd_seihin
			,no_han
			,dt_from
			,cd_hinmei
			,wt_haigo
			,cd_tani
			,cd_haigo
			,no_kotei
			,no_tonyu
			,flg_mishiyo
			,kbn_hin
			,ritsu_budomari
			,oya_wt_haigo
			,oya_budomari
			,oya_haigo
			,jikagen_code
		)
		SELECT
			cd_seihin
			,no_han
			,dt_from
			,cd_hinmei
			,wt_haigo
			,cd_tani
			,cd_haigo
			,no_kotei
			,no_tonyu
			,flg_mishiyo
			,kbn_hin
			,ritsu_budomari
			,oya_wt_haigo
			,oya_budomari
			,oya_haigo
			,jikagen_code
		FROM #tmp_tenkai

		IF @@ERROR <> 0
		BEGIN
			SET @msg = 'error :#tmp_taisho failed insert.'
			GOTO Error_Handling
		END

		-- 次の階層へ
		SET @tenkai_kaiso = @tenkai_kaiso + 1
	END
	-- ///////////////////////////////////////////
	--  展開処理：ここまで
	-- ///////////////////////////////////////////
	DROP TABLE #tmp_taisho
	DROP TABLE #tmp_tenkai
	DROP TABLE #tmp_bairitsu
	DROP TABLE #udf_haigo

	-- オーバーフローがあった場合はエラーで処理を終了する
	IF @flg_error = 1
	BEGIN
		GOTO Overflow_Handling
	END

	--PRINT 'BOMマスタ抽出開始'

-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
--    BOMマスタ抽出テーブル(ma_sap_bom_denso)の作成
-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-

	--送信対象テーブルにテスト品 = 1のデータが存在する場合、そのデータを含む製品自体を送信対象としない
	DELETE FROM ma_sap_bom_denso_taisho
	WHERE cd_seihin IN (
		SELECT DISTINCT
		  bdt.cd_seihin 
		FROM
		  ma_sap_bom_denso_taisho bdt 
		  LEFT OUTER JOIN ma_hinmei mh 
		    ON bdt.cd_seihin = mh.cd_hinmei 
		  LEFT OUTER JOIN ( 
		    SELECT DISTINCT
		      cd_seihin
		      , flg_testitem 
		    FROM
		      ma_sap_bom_denso_taisho bdt 
		      LEFT OUTER JOIN ma_hinmei mh 
		        ON bdt.cd_hinmei = mh.cd_hinmei 
		    WHERE
		      mh.flg_testitem = 1
		  ) test 
		    ON bdt.cd_seihin = test.cd_seihin 
		  LEFT OUTER JOIN ma_hinmei mh2 
		    ON bdt.cd_hinmei = mh2.cd_hinmei 
		WHERE
		  mh.flg_testitem = 1 
		  OR test.flg_testitem = 1
	)

	-- 抽出テーブルを一度クリア
	DELETE ma_sap_bom_denso
		IF @@ERROR <> 0
		BEGIN
			SET @msg = 'error :ma_sap_bom_denso failed delete.'
			GOTO Error_Handling
		END

	INSERT INTO ma_sap_bom_denso (
		kbn_denso_SAP
		,cd_seihin
		--,no_han
		,cd_kojo
		,dt_from
		,su_kihon
		,cd_hinmei
		,su_hinmoku
		,cd_tani
		,su_kaiso
		,cd_haigo
		,no_kotei
		,no_tonyu
	)
	-- ==============================================
	--   新 規
	-- ==============================================
		SELECT
			@kbnCreate AS 'kbn_denso_SAP'
			,UPPER(taisho.cd_seihin) AS cd_seihin
			--,taisho.no_han
			,taisho.cd_kojo
			,CONVERT(DECIMAL, CONVERT(VARCHAR, taisho.dt_from, 112)) AS dt_from
			,CONVERT(VARCHAR, taisho.su_kihon) AS su_kihon
			,UPPER(taisho.cd_hinmei) AS cd_hinmei
			,taisho.su_hinmoku
			,mst.cd_tani_henkan
			,CONVERT(VARCHAR, taisho.su_kaiso) AS su_kaiso
			,taisho.cd_haigo
			,CONVERT(VARCHAR, taisho.no_kotei) AS no_kotei
			,taisho.no_tonyu
		FROM
			ma_sap_bom_denso_taisho taisho
		-- 前回対象テーブル
		LEFT JOIN ma_sap_bom_denso_taisho_zen zen
		ON zen.cd_seihin = taisho.cd_seihin
		--AND zen.no_han = taisho.no_han
		--AND zen.cd_hinmei = taisho.cd_hinmei
		--AND zen.su_kaiso = taisho.su_kaiso
		--AND zen.cd_haigo = taisho.cd_haigo
		--AND zen.no_kotei = taisho.no_kotei
		--AND zen.no_tonyu = taisho.no_tonyu
		-- 単位変換マスタ
		LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = taisho.cd_tani
		
		-- 前回対象テーブルに存在しないデータは新規
		WHERE zen.cd_seihin IS NULL

	-- ==============================================
	--   更 新
	-- ==============================================
		UNION ALL

		-- 有効日付（開始）、品目数量、数量単位が変更となっている
		-- レコードの製品コードを取得
		SELECT
			@kbnUpdate AS 'kbn_denso_SAP'
			,UPPER(taisho.cd_seihin) AS cd_seihin
			--,taisho.no_han
			,taisho.cd_kojo
			,CONVERT(DECIMAL, CONVERT(VARCHAR, taisho.dt_from, 112)) AS dt_from
			,CONVERT(VARCHAR, taisho.su_kihon) AS su_kihon
			,UPPER(taisho.cd_hinmei) AS cd_hinmei
			,taisho.su_hinmoku
			,mst.cd_tani_henkan
			,CONVERT(VARCHAR, taisho.su_kaiso) AS su_kaiso
			,taisho.cd_haigo
			,CONVERT(VARCHAR, taisho.no_kotei) AS no_kotei
			,taisho.no_tonyu
		FROM
			ma_sap_bom_denso_taisho taisho
		LEFT JOIN (
			SELECT
				taisho.cd_seihin
			FROM
				ma_sap_bom_denso_taisho taisho
			-- 前回対象テーブル
			LEFT JOIN ma_sap_bom_denso_taisho_zen zen
			ON zen.cd_seihin = taisho.cd_seihin
			--AND zen.no_han = taisho.no_han
			AND zen.cd_hinmei = taisho.cd_hinmei
			AND zen.su_kaiso = taisho.su_kaiso
			AND zen.cd_haigo = taisho.cd_haigo
			AND zen.no_kotei = taisho.no_kotei
			AND zen.no_tonyu = taisho.no_tonyu
			-- 更新対象カラムのどれかひとつでも変更があれば更新
			WHERE zen.dt_from <> taisho.dt_from
			OR zen.su_hinmoku <> taisho.su_hinmoku
			OR zen.cd_tani <> taisho.cd_tani
			GROUP BY
				taisho.cd_seihin
		) up_data
		ON taisho.cd_seihin = up_data.cd_seihin
		-- 単位変換マスタ
		LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = taisho.cd_tani
		-- 対象の製品コードをすべて抽出
		WHERE taisho.cd_seihin = up_data.cd_seihin

	-- ==============================================
	--   削 除
	-- ==============================================
		UNION ALL
		SELECT
			@kbnDelete AS 'kbn_denso_SAP'
			,UPPER(zen.cd_seihin) AS 'cd_seihin'
			--,0 AS 'no_han'
			,zen.cd_kojo
			,null AS 'dt_from'
			,null AS 'su_kihon'
			,'' AS 'cd_hinmei'
			,null AS 'su_hinmoku'
			,'' AS 'cd_tani_henkan'
			,'' AS 'su_kaiso'
			,'' AS 'cd_haigo'
			,'' AS 'no_kotei'
			,'' AS 'no_tonyu'
		FROM
			ma_sap_bom_denso_taisho_zen zen
		-- 資材使用マスタ、配合マスタの全版番号をヘッダレベルで削除した場合は削除
		LEFT JOIN (
			SELECT
				zen.cd_seihin
				,zen.cd_kojo
			FROM
				ma_sap_bom_denso_taisho_zen zen	-- 前回対象テーブル
			-- 対象テーブル
			LEFT JOIN ma_sap_bom_denso_taisho taisho
			ON zen.cd_seihin = taisho.cd_seihin
			--AND zen.no_han = taisho.no_han
			AND zen.cd_hinmei = taisho.cd_hinmei
			AND zen.su_kaiso = taisho.su_kaiso
			AND zen.cd_haigo = taisho.cd_haigo
			AND zen.no_kotei = taisho.no_kotei
			AND zen.no_tonyu = taisho.no_tonyu
			-- 前回対象テーブルにのみ存在するデータの製品コードを取得
			WHERE taisho.cd_seihin IS NULL
			GROUP BY zen.cd_seihin, zen.cd_kojo
		) del_data
		ON zen.cd_seihin = del_data.cd_seihin
		-- 対象テーブル
		LEFT JOIN ma_sap_bom_denso_taisho taisho
		ON zen.cd_seihin = taisho.cd_seihin
		-- 前回対象テーブルに存在して、送信対象テーブルに存在しない製品コードを抽出
		WHERE
			zen.cd_seihin = del_data.cd_seihin
		AND taisho.cd_seihin IS NULL
		GROUP BY
			zen.cd_seihin, zen.cd_kojo

	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'error :ma_sap_bom_denso failed insert.'
		GOTO Error_Handling
	END

	-- ==============================================
	--   更 新
	-- ==============================================
	INSERT INTO ma_sap_bom_denso (
		kbn_denso_SAP
		,cd_seihin
		,cd_kojo
		,dt_from
		,su_kihon
		,cd_hinmei
		,su_hinmoku
		,cd_tani
		,su_kaiso
		,cd_haigo
		,no_kotei
		,no_tonyu
	)
		-- 前回対象テーブルにのみキーが存在する、かつ、前回対象テーブル．製品コードが
		-- 送信対象テーブルに存在するレコードの製品コードを取得
		SELECT
			@kbnUpdate AS 'kbn_denso_SAP'
			,UPPER(taisho.cd_seihin) AS cd_seihin
			,taisho.cd_kojo
			,CONVERT(DECIMAL, CONVERT(VARCHAR, taisho.dt_from, 112)) AS dt_from
			,CONVERT(VARCHAR, taisho.su_kihon) AS su_kihon
			,UPPER(taisho.cd_hinmei) AS cd_hinmei
			,taisho.su_hinmoku
			,mst.cd_tani_henkan
			,CONVERT(VARCHAR, taisho.su_kaiso) AS su_kaiso
			,taisho.cd_haigo
			,CONVERT(VARCHAR, taisho.no_kotei) AS no_kotei
			,taisho.no_tonyu
		FROM
			ma_sap_bom_denso_taisho taisho
		-- 配合レシピの明細のうち、一部だけ行削除された場合なども変更として扱う
		LEFT JOIN (
			SELECT
				zen.cd_seihin
			FROM
				ma_sap_bom_denso_taisho_zen zen	-- 前回対象テーブル
			-- 対象テーブル
			LEFT JOIN ma_sap_bom_denso_taisho taisho
			ON zen.cd_seihin = taisho.cd_seihin
			AND zen.no_han = taisho.no_han
			AND zen.cd_hinmei = taisho.cd_hinmei
			AND zen.su_kaiso = taisho.su_kaiso
			AND zen.cd_haigo = taisho.cd_haigo
			AND zen.no_kotei = taisho.no_kotei
			AND zen.no_tonyu = taisho.no_tonyu
			-- 前回対象テーブルにのみ存在するデータの製品コードを取得
			WHERE taisho.cd_seihin IS NULL
			GROUP BY zen.cd_seihin
		) up_data
		ON taisho.cd_seihin = up_data.cd_seihin
		-- 抽出テーブル
		LEFT JOIN ma_sap_bom_denso denso
		ON up_data.cd_seihin = denso.cd_seihin
		-- 単位変換マスタ
		LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = taisho.cd_tani
		-- 抽出テーブルに存在しない対象の製品コードをすべて抽出
		WHERE taisho.cd_seihin = up_data.cd_seihin
		AND denso.cd_seihin IS NULL

	-- 投入番号、工程番号などのキーが変更になった場合も変更として扱う
	INSERT INTO ma_sap_bom_denso (
		kbn_denso_SAP
		,cd_seihin
		,cd_kojo
		,dt_from
		,su_kihon
		,cd_hinmei
		,su_hinmoku
		,cd_tani
		,su_kaiso
		,cd_haigo
		,no_kotei
		,no_tonyu
	)
		SELECT
			@kbnUpdate AS 'kbn_denso_SAP'
			,UPPER(taisho.cd_seihin) AS cd_seihin
			,taisho.cd_kojo
			,CONVERT(DECIMAL, CONVERT(VARCHAR, taisho.dt_from, 112)) AS dt_from
			,CONVERT(VARCHAR, taisho.su_kihon) AS su_kihon
			,UPPER(taisho.cd_hinmei) AS cd_hinmei
			,taisho.su_hinmoku
			,mst.cd_tani_henkan
			,CONVERT(VARCHAR, taisho.su_kaiso) AS su_kaiso
			,taisho.cd_haigo
			,CONVERT(VARCHAR, taisho.no_kotei) AS no_kotei
			,taisho.no_tonyu
		FROM
			ma_sap_bom_denso_taisho taisho
		LEFT JOIN (
			SELECT
				taisho.cd_seihin
			FROM
				ma_sap_bom_denso_taisho taisho
			-- 前回対象テーブル
			LEFT JOIN ma_sap_bom_denso_taisho_zen zen
			ON zen.cd_seihin = taisho.cd_seihin
			AND zen.no_han = taisho.no_han
			AND zen.cd_hinmei = taisho.cd_hinmei
			AND zen.su_kaiso = taisho.su_kaiso
			AND zen.cd_haigo = taisho.cd_haigo
			AND zen.no_kotei = taisho.no_kotei
			AND zen.no_tonyu = taisho.no_tonyu
			WHERE zen.cd_seihin IS NULL
			GROUP BY taisho.cd_seihin
		) up_data
		ON taisho.cd_seihin = up_data.cd_seihin
		-- 抽出テーブル
		LEFT JOIN ma_sap_bom_denso denso
		ON up_data.cd_seihin = denso.cd_seihin
		-- 単位変換マスタ
		LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = taisho.cd_tani
		-- 抽出テーブルに存在しない対象の製品コードをすべて抽出
		WHERE taisho.cd_seihin = up_data.cd_seihin
		AND denso.cd_seihin IS NULL

	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'error :ma_sap_bom_denso failed insert2.'
		GOTO Error_Handling
	END


-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
--    桁落ち対応
-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
	-- 品目数量が0.001以下のデータがある場合、対象データの製品の
	-- 基本数量と品目数量を100倍にする(※※製品単位！！※※)
	
	-- 100倍することで桁あふれを起こした場合はエラーとする
	DECLARE cursor_err CURSOR FOR
		SELECT
			cd_seihin
			,cd_hinmei
			,su_hinmoku * 100
			,cd_haigo
			,no_kotei
			,no_tonyu
		FROM
			ma_sap_bom_denso
		WHERE cd_seihin IN (SELECT cd_seihin
							FROM ma_sap_bom_denso
							WHERE su_hinmoku < 0.001
							AND su_hinmoku > 0 -- 0を省きたいとき
							GROUP BY cd_seihin)
		AND (su_hinmoku * 100) > 999999.999999

	OPEN cursor_err
		IF (@@error <> 0)
		BEGIN
			SET @msg = 'CURSOR OPEN ERROR: cursor_err'
			GOTO Error_Handling
		END

	FETCH NEXT FROM cursor_err INTO
		@cur_cd_seihin
		,@cur_cd_hinmei
		,@cur_su_hinmoku
		,@cur_cd_haigo
		,@cur_no_kotei
		,@cur_no_tonyu

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- エラーログの出力
		PRINT 'Arithmetic overflow or other arithmetic exception occurred.：算術オーバーフロー'
		SET @msg = '  Object data... cd_seihin:' + @cur_cd_seihin + ', cd_haigo:' + @cur_cd_haigo
			+ ', cd_hinmei:' + @cur_cd_hinmei + ', no_kotei:' + CONVERT(VARCHAR, @cur_no_kotei)
			+ ', no_tonyu:' + @cur_no_tonyu + ', su_hinmoku:' + CONVERT(VARCHAR, @cur_su_hinmoku)
		PRINT @msg
		PRINT ' '

		SET @flg_error = 1

		FETCH NEXT FROM cursor_err INTO
			@cur_cd_seihin
			,@cur_cd_hinmei
			,@cur_su_hinmoku
			,@cur_cd_haigo
			,@cur_no_kotei
			,@cur_no_tonyu
	END
	CLOSE cursor_err
	DEALLOCATE cursor_err

	IF @flg_error = 1
	BEGIN
		GOTO Overflow_Handling
	END

	-- 対象データの基本数量と品目数量を100倍にする
	--UPDATE ma_sap_bom_denso
	--SET su_kihon = su_kihon * 100
	--	,su_hinmoku = su_hinmoku * 100
	--WHERE cd_seihin IN (SELECT cd_seihin
	--					FROM ma_sap_bom_denso
	--					WHERE su_hinmoku < 0.001
	--					AND su_hinmoku > 0 -- 0を省きたいとき
	--					GROUP BY cd_seihin)
	UPDATE denso
	SET denso.su_kihon = denso.su_kihon * 100
		,denso.su_hinmoku = denso.su_hinmoku * 100
	FROM ma_sap_bom_denso AS denso
	INNER JOIN ma_sap_bom_denso taisho
	ON denso.cd_seihin = taisho.cd_seihin 
	AND taisho.cd_seihin IN (SELECT cd_seihin
						FROM ma_sap_bom_denso
						WHERE su_hinmoku < 0.001
						AND su_hinmoku > 0 -- 0を省きたいとき
						GROUP BY cd_seihin)

	IF @@ERROR <> 0
	BEGIN
		PRINT 'error :ma_sap_bom_denso failed update.'
		RETURN
	END


	RETURN

	-- //////////// --
	--  エラー処理
	-- //////////// --
	Error_Handling:
	--	DELETE ma_sap_bom_denso_taisho
		DELETE ma_sap_bom_denso
		CLOSE cursor_taisho
		DEALLOCATE cursor_taisho
		PRINT @msg

		RETURN

	-- ////////////////////////////// --
	--  オーバーフロー時のエラー処理
	-- ////////////////////////////// --
	Overflow_Handling:
		-- わざと大きな数値をINSERTして無理矢理エラーを起こす
		INSERT INTO ma_sap_bom_denso (
			kbn_denso_SAP
			,cd_seihin
			,cd_kojo
			,dt_from
			,su_kihon
			,cd_hinmei
			,su_hinmoku
			,cd_tani
			,su_kaiso
			,cd_haigo
			,no_kotei
			,no_tonyu
		) VALUES (
			0
			,'cd_seihin'
			,'cd_kojo'
			,null
			,0
			,'cd_hinmei'
			,9999999999
			,'cd_tani'
			,0
			,'cd_haigo'
			,'no_kotei'
			,'no_tonyu'
		)

		RETURN

END



GO
