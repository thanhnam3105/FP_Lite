IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenkaTanka_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenkaTanka_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author:      <Author,,tsujita.s>
-- Create date: <Create Date,,2014.08.20>
-- Last Update: 2015.02.18 tsujita.s
-- Description: <Description,,原価単価作成処理>
--	<TODO>原価単価は一律、小数点４位以下を切り捨て
-- ================================================
CREATE PROCEDURE [dbo].[usp_GenkaTanka_create]
    @dt_from			datetime	-- 検索条件：年月(開始)
    ,@dt_to				datetime	-- 検索条件：年月(終了)
    ,@kbn_hin			varchar(2)	-- 検索条件：品区分
    ,@cd_bunrui			varchar(10)	-- 検索条件：分類コード
    ,@cd_hinmei			varchar(14)	-- 検索条件：品名コード
    ,@flg_yotei			smallint	-- 定数：予実フラグ：予定
    ,@flg_jisseki		smallint	-- 定数：予実フラグ：実績
    ,@kbn_kanzan_kg		varchar(2)	-- 定数：換算区分：Kg
    ,@kbn_kanzan_li		varchar(2)	-- 定数：換算区分：L
    ,@flg_shiyo			smallint	-- 定数：未使用フラグ：使用
    ,@kbn_tanka_tana	smallint	-- 定数：単価区分：棚卸単価
    ,@kbn_tanka_nonyu	smallint	-- 定数：単価区分：納入単価
    ,@kbn_tanka_romu	smallint	-- 定数：単価区分：労務費
    ,@kbn_tanka_keihi	smallint	-- 定数：単価区分：経費
    ,@kbn_tanka_cs		smallint	-- 定数：単価区分：CS単価
    ,@kbn_seihin		smallint	-- 定数：品区分：製品
    ,@kbn_jikagen		smallint	-- 定数：品区分：自家原料
    ,@max_genka			decimal(12, 4)	-- 原価単価の最大値(桁溢れの算術オーバー対策)
    ,@kbn_zaiko_ryohin	SMALLINT		-- 定数：在庫区分：良品
AS
BEGIN

	-- ====================
	--  一時テーブルの作成
	-- ====================
	-- 品マス一時テーブル
	create table #tmp_hinmei (
		cd_hinmei		varchar(14)
		,kbn_hin		smallint
		,cd_tani_nonyu	varchar(10)
		,su_iri			decimal(5, 0)
		,tan_ko			decimal(12, 4)
		,wt_ko			decimal(12, 6)
		,kin_romu		decimal(12, 4)
		,kin_keihi_cs	decimal(12, 4)
	)			


	SET NOCOUNT ON

	-- 対象の品名マスタデータを先に抽出しておく
	INSERT INTO #tmp_hinmei (
		cd_hinmei
		,kbn_hin
		,cd_tani_nonyu
		,su_iri
		,tan_ko
		,wt_ko
		,kin_romu
		,kin_keihi_cs
	)
	SELECT
		cd_hinmei
		,kbn_hin
		,cd_tani_nonyu
		,su_iri
		,tan_ko
		,wt_ko
		,kin_romu
		,kin_keihi_cs
	FROM ma_hinmei
	WHERE (LEN(@kbn_hin) = 0 OR kbn_hin = @kbn_hin)
	AND (LEN(@cd_bunrui) = 0 OR cd_bunrui = @cd_bunrui)
	AND (LEN(@cd_hinmei) = 0 OR cd_hinmei = @cd_hinmei)

    IF @@ERROR <> 0
    BEGIN
        PRINT 'error :tmp_hinmei failed insert.'
        RETURN
    END

	-- ===============================
	--   既存データ削除処理
	-- ===============================
	DELETE tr_genka_tanka
	WHERE dt_genka_keisan BETWEEN @dt_from AND @dt_to
	AND cd_hinmei IN (SELECT cd_hinmei
					  FROM #tmp_hinmei)

    IF @@ERROR <> 0
    BEGIN
        PRINT 'error :tr_genka_tanka failed delete.'
        RETURN
    END


	-- ==============================
	--   棚卸単価作成
	-- ==============================
	INSERT INTO tr_genka_tanka (
		dt_genka_keisan
		,cd_hinmei
		,kbn_tanka
		,tan_genka
	)
	SELECT
		@dt_to AS dt_genka_keisan
		,MEISAI_TOTAL.cd_hinmei
		,@kbn_tanka_tana AS kbn_tanka
		-- 加重平均：SUM(合計金額) / SUM(在庫数)
		--,SUM(MEISAI_TOTAL.kin_total) / SUM(MEISAI_TOTAL.su_zaiko) AS ave_kaju
		,ROUND(SUM(MEISAI_TOTAL.kin_total) / SUM(MEISAI_TOTAL.su_zaiko), 4, 1) AS ave_kaju
	FROM (
		-- 明細毎の合計金額を求める
		SELECT
			tr.cd_hinmei, tr.su_zaiko
			-- 棚卸単価または在庫数が0の場合、合計金額に0を設定
			-- 上記以外：(在庫数 / 品名マスタ.個重量)ｘ棚卸単価
			,ROUND(CASE WHEN COALESCE(tr.tan_tana, 0) = 0 OR tr.su_zaiko = 0
				THEN 0
				ELSE (tr.su_zaiko / hin.wt_ko) * tr.tan_tana
			END, 0, 1) AS kin_total
		FROM (
			SELECT
				cd_hinmei
				,dt_hizuke
				,SUM(su_zaiko) AS su_zaiko
				,SUM(tan_tana) AS tan_tana
			FROM tr_zaiko
			WHERE dt_hizuke BETWEEN @dt_from AND @dt_to
			AND kbn_zaiko = @kbn_zaiko_ryohin
			GROUP BY cd_hinmei, dt_hizuke
		) tr
		INNER JOIN #tmp_hinmei hin
		ON tr.cd_hinmei = hin.cd_hinmei
	) MEISAI_TOTAL
	WHERE MEISAI_TOTAL.su_zaiko > 0
	GROUP BY MEISAI_TOTAL.cd_hinmei

    IF @@ERROR <> 0
    BEGIN
        PRINT 'error :tanaoroshi_tanka failed.'
        RETURN
    END


	-- ==============================
	--   納入単価作成
	-- ==============================
	INSERT INTO tr_genka_tanka (
		dt_genka_keisan
		,cd_hinmei
		,kbn_tanka
		,tan_genka
	)
	SELECT
		@dt_to AS dt_genka_keisan
		,MEISAI_TOTAL.cd_hinmei
		,@kbn_tanka_nonyu AS kbn_tanka
		-- 加重平均：SUM(合計金額) / SUM(合計数量)
		,ROUND(SUM(MEISAI_TOTAL.kin_total) / SUM(MEISAI_TOTAL.su_total), 4, 1) AS ave_kaju
	FROM (
		-- 明細毎の合計金額を求める
		SELECT
			tr.cd_hinmei
			-- 合計金額
			-- 納入単価または納入数と納入端数が0の場合、合計金額に0を設定
			,ROUND(CASE WHEN COALESCE(tr.tan_nonyu, 0) = 0
				OR (tr.su_nonyu = 0 AND COALESCE(tr.su_nonyu_hasu, 0) = 0)
				THEN 0
				ELSE 
					-- 品名マスタ.納入単位がKgまたはLの場合
					-- (納入数ｘ納入単価)＋((納入端数 / (入数ｘ個重量ｘ1000))ｘ納入単価)
					CASE WHEN hin.cd_tani_nonyu = @kbn_kanzan_kg OR hin.cd_tani_nonyu = @kbn_kanzan_li
					THEN (tr.su_nonyu * tr.tan_nonyu) + ((COALESCE(tr.su_nonyu_hasu, 0) / (hin.su_iri * hin.wt_ko * 1000)) * tr.tan_nonyu)
					-- 品名マスタ.納入単位がKgとL以外の場合
					-- (納入数ｘ納入単価)＋((納入端数 / 入数)ｘ納入単価)
					ELSE (tr.su_nonyu * tr.tan_nonyu) + ((COALESCE(tr.su_nonyu_hasu, 0) / hin.su_iri) * tr.tan_nonyu)
					END
			 END, 0, 1) AS kin_total
			-- 合計数量
			-- 納入単価または納入数と納入端数が0の場合、合計金額に0を設定
			,CASE WHEN COALESCE(tr.tan_nonyu, 0) = 0
				OR (tr.su_nonyu = 0 AND COALESCE(tr.su_nonyu_hasu, 0) = 0)
				THEN 0
				ELSE
					-- 品名マスタ.納入単位がKgまたはLの場合
					-- (納入数ｘ個重量ｘ入数)＋(納入端数 / 1000)
					CASE WHEN hin.cd_tani_nonyu = @kbn_kanzan_kg OR hin.cd_tani_nonyu = @kbn_kanzan_li
					THEN (tr.su_nonyu * hin.wt_ko * hin.su_iri) + (COALESCE(tr.su_nonyu_hasu, 0) / 1000)
					-- 品名マスタ.納入単位がKgとL以外の場合
					-- (納入数ｘ個重量ｘ入数)＋(納入端数ｘ個重量)
					ELSE (tr.su_nonyu * hin.wt_ko * hin.su_iri) + (COALESCE(tr.su_nonyu_hasu, 0) * hin.wt_ko)
					END
			 END AS su_total
		FROM (
			SELECT cd_hinmei, dt_nonyu, su_nonyu, su_nonyu_hasu, tan_nonyu
			FROM tr_nonyu
			WHERE dt_nonyu BETWEEN @dt_from AND @dt_to
			AND flg_yojitsu = @flg_jisseki
		) tr
		--INNER JOIN ma_hinmei hin
		INNER JOIN #tmp_hinmei hin
		ON hin.kbn_hin <> @kbn_seihin	-- 製品以外
		AND tr.cd_hinmei = hin.cd_hinmei
	) MEISAI_TOTAL
	WHERE MEISAI_TOTAL.su_total > 0
	GROUP BY MEISAI_TOTAL.cd_hinmei

    IF @@ERROR <> 0
    BEGIN
        PRINT 'error :nonyu_tanka failed.'
        RETURN
    END


	-- ==============================
	--   製品単価作成
	-- ==============================
	INSERT INTO tr_genka_tanka (
		dt_genka_keisan
		,cd_hinmei
		,kbn_tanka
		,tan_genka
	)
	------- 労務費：品名マスタ.標準労務費
	SELECT
		@dt_to AS dt_genka_keisan
		,cd_hinmei
		,@kbn_tanka_romu AS kbn_tanka
		,COALESCE(kin_romu, 0) AS tan_genka
	FROM #tmp_hinmei
	WHERE kbn_hin = @kbn_seihin
	OR kbn_hin = @kbn_jikagen	-- 製品または自家原料のみ
		-- ＃パフォーマンスを考慮してINではなくORを使用

	UNION ALL

	------- 経費：品名マスタ.1C/S経費
	SELECT
		@dt_to AS dt_genka_keisan
		,cd_hinmei
		,@kbn_tanka_keihi AS kbn_tanka
		,COALESCE(kin_keihi_cs, 0) AS tan_genka
	FROM #tmp_hinmei
	WHERE kbn_hin = @kbn_seihin
	OR kbn_hin = @kbn_jikagen

	UNION ALL

	------- CS単価：品名マスタ.個単価ｘ品名マスタ.入数
	SELECT
		@dt_to AS dt_genka_keisan
		,cd_hinmei
		,@kbn_tanka_cs AS kbn_tanka
		,COALESCE(tan_ko, 0) * su_iri AS tan_genka
	FROM #tmp_hinmei
	WHERE (kbn_hin = @kbn_seihin OR kbn_hin = @kbn_jikagen)
	AND COALESCE(tan_ko, 0) * su_iri <= @max_genka

    IF @@ERROR <> 0
    BEGIN
        PRINT 'error :seihin_tanka failed.'
        RETURN
    END


END
GO
