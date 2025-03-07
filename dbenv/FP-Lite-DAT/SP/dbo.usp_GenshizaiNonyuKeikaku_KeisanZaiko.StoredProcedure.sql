IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiNonyuKeikaku_KeisanZaiko') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiNonyuKeikaku_KeisanZaiko]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:		tsujita.s
-- Create date: 2014.03.18
-- Last Update: 2016.05.20 motojima.m
-- Description:	納入計画作成
--   計算在庫トランの再計算処理
-- =======================================================
CREATE PROCEDURE [dbo].[usp_GenshizaiNonyuKeikaku_KeisanZaiko]
	 @con_hinmei		VARCHAR(14)		-- 品名コード
	,@hizuke_from		DATETIME		-- 計算開始日
	,@hizuke_to			DATETIME		-- 計算終了日
	,@cd_update 		VARCHAR(10)		-- 更新者：ログインユーザコード
	,@flg_shiyo			SMALLINT		-- 定数：未使用フラグ：使用
	,@flg_yojitsu_yo 	SMALLINT		-- 定数：予実フラグ：予定
	,@flg_yojitsu_ji 	SMALLINT		-- 定数：予実フラグ：実績
	,@kbn_hin_genryo 	SMALLINT		-- 定数：品区分：原料
	,@kbn_hin_shizai 	SMALLINT		-- 定数：品区分：資材
	,@cd_kg				VARCHAR(2)		-- 定数：単位コード：Kg
	,@cd_li				VARCHAR(2)		-- 定数：単位コード：L
	,@utc_sysdate		DATETIME		-- UTCシステム日付
	,@kbn_zaiko_ryohin	SMALLINT		-- 定数：在庫区分：良品
	,@dt_hendo_from		DATETIME		-- 変動計算開始日：画面の変動計算初日
	,@dt_hendo_to		DATETIME		-- 変動計算末日：画面の変動計算末日
AS
BEGIN

	-- 変数リスト
	DECLARE @msg			VARCHAR(100)	-- 処理結果メッセージ格納用
	-- カーソル用の変数リスト
	DECLARE @cur_hizuke		DATETIME

	-- ====================
	--  一時テーブルの作成
	-- ====================
	-- 計算在庫一時テーブル
	create table #tmp_zaiko_keisan (
		cd_hinmei			VARCHAR(14)
		,dt_hizuke			DATETIME
		,su_zaiko			DECIMAL(14,6)
	)

	-- 品マス一時テーブル
	create table #tmp_hinmei (
		cd_hinmei		VARCHAR(14)
		,dt_kotei		DATETIME
	)

	-- 使用予実一時テーブル
	create table #tmp_shiyo (
		cd_hinmei		VARCHAR(14)
		,dt_shiyo		DATETIME
		,su_shiyo		DECIMAL(12,6)
	)

	-- 納入一時テーブル
	create table #tmp_nonyu (
		dt_nonyu		DATETIME
		,cd_hinmei		VARCHAR(14)
		,su_nonyu		DECIMAL(9,2)
		,su_nonyu_hasu	DECIMAL(9,2)
	)

	-- SKIP対象の品名コード一時テーブル
	CREATE TABLE #skip_hinmei (
		cd_hinmei		VARCHAR(14)
	)

	SET NOCOUNT ON


	-- ===========================
	--  一時テーブルへのコピー
	-- ===========================

	-- SKIP対象テーブルの作成
	-- 同日に同品名の納入予定が複数あるデータを抽出
	INSERT INTO #skip_hinmei (cd_hinmei)
	SELECT
		ma.cd_hinmei
	FROM
		ma_hinmei ma
	INNER JOIN (
		SELECT
			cd_hinmei
			,COUNT(cd_hinmei) AS cnt
		FROM tr_nonyu
		WHERE dt_nonyu BETWEEN @dt_hendo_from AND @dt_hendo_to
		AND flg_yojitsu = @flg_yojitsu_yo
		GROUP BY cd_hinmei, dt_nonyu
	) tr
	ON tr.cnt > 1
	AND ma.cd_hinmei = tr.cd_hinmei
	WHERE (LEN(@con_hinmei) = 0 OR ma.cd_hinmei = @con_hinmei)
	AND (ma.kbn_hin = @kbn_hin_genryo OR ma.kbn_hin = @kbn_hin_shizai)
	AND ma.flg_mishiyo = @flg_shiyo
	GROUP BY ma.cd_hinmei

	-- 品マス一時テーブルに有効なものを挿入
	INSERT INTO #tmp_hinmei (cd_hinmei, dt_kotei)
	-- /////////////////////////////////
	--  SAP連携：各品の固定日を取得する
	-- /////////////////////////////////
	SELECT
		HIN.cd_hinmei, KOTEI.dt_kotei
	FROM (
		SELECT cd_hinmei, COALESCE(dd_kotei, 0) AS dd_kotei FROM ma_hinmei
		WHERE kbn_hin = @kbn_hin_genryo AND flg_mishiyo = @flg_shiyo
		  UNION ALL
		SELECT cd_hinmei, COALESCE(dd_kotei, 0) AS dd_kotei FROM ma_hinmei
		WHERE kbn_hin = @kbn_hin_shizai AND flg_mishiyo = @flg_shiyo
	) HIN
	INNER JOIN (
		SELECT DISTINCT cd_hinmei
		FROM ma_konyu ko WITH(NOLOCK)
		WHERE flg_mishiyo = @flg_shiyo
		AND (LEN(@con_hinmei) = 0 OR
			 cd_hinmei = @con_hinmei)
	) KONYU
	ON HIN.cd_hinmei = KONYU.cd_hinmei
	LEFT JOIN #skip_hinmei sk
	ON HIN.cd_hinmei = sk.cd_hinmei
	LEFT JOIN (
		-- 固定日用にカレンダーマスタから営業日だけを取得
		SELECT dt_hizuke AS dt_kotei
			,ROW_NUMBER() OVER(ORDER BY dt_hizuke) - 1 AS no_kotei
		FROM ma_calendar
		WHERE dt_hizuke BETWEEN @utc_sysdate AND @dt_hendo_to
		AND flg_kyujitsu = @flg_shiyo
	) KOTEI
	ON KOTEI.no_kotei = HIN.dd_kotei
	WHERE KOTEI.dt_kotei IS NOT NULL	-- 固定日外(dt_koteiが計算末日より未来)＝対象外なので、抽出しない
	AND sk.cd_hinmei IS NULL			-- 同日に同品名の納入予定が複数件あるものは取得しない
	CREATE NONCLUSTERED INDEX idx_hin1 ON #tmp_hinmei (cd_hinmei)

    -- 原資材納入計画は未来しか処理しないので実績は取得しない
	-- 使用一時にコピー
	INSERT INTO #tmp_shiyo (
		cd_hinmei, dt_shiyo, su_shiyo)
	SELECT cd_hinmei, dt_shiyo, su_shiyo
	FROM tr_shiyo_yojitsu
	WHERE dt_shiyo BETWEEN @hizuke_from AND @hizuke_to
	AND [flg_yojitsu] = @flg_yojitsu_yo
	CREATE NONCLUSTERED INDEX idx_shi2 ON #tmp_shiyo (dt_shiyo)
	CREATE NONCLUSTERED INDEX idx_shi3 ON #tmp_shiyo (cd_hinmei)

	-- 納入一時にコピー
	-- 固定日以内は計画を立てなおさないので計算在庫に反映させる
	INSERT INTO #tmp_nonyu (dt_nonyu, cd_hinmei, su_nonyu, su_nonyu_hasu)
    SELECT tny.dt_nonyu, tny.cd_hinmei, tny.su_nonyu, tny.su_nonyu_hasu
	FROM (
		SELECT
			flg_yojitsu, dt_nonyu, cd_hinmei, su_nonyu, su_nonyu_hasu
		FROM tr_nonyu tny WITH(NOLOCK)
	    WHERE dt_nonyu BETWEEN @hizuke_from AND @hizuke_to
	    AND flg_yojitsu = @flg_yojitsu_yo
	) tny
	INNER JOIN #tmp_hinmei hin
	ON tny.cd_hinmei = hin.cd_hinmei
	WHERE tny.dt_nonyu <= hin.dt_kotei
	CREATE NONCLUSTERED INDEX idx_nonyu2 ON #tmp_nonyu (dt_nonyu)
	CREATE NONCLUSTERED INDEX idx_nonyu3 ON #tmp_nonyu (cd_hinmei)

	-- 対象の絞り込みが終わったらSKIP一時テーブルを削除
	DROP TABLE #skip_hinmei

	-- ==================================================
	-- ==================================================
	--  指定期間分の計算在庫情報をワークテーブルにINSERT
	-- ==================================================
	-- ==================================================
	DELETE wk_zaiko_keisan	-- 中身を一度クリア
	WHERE dt_hizuke BETWEEN @hizuke_from AND @hizuke_to
    IF @@ERROR <> 0
    BEGIN
        SET @msg = 'error: wk_zaiko_keisan failed clear.'
        GOTO Error_Handling
    END

	-- 前日在庫の取得
	INSERT INTO wk_zaiko_keisan (
		cd_hinmei
		,dt_hizuke
		,su_zaiko
		,dt_update
		,cd_update
	)
	SELECT
		zaiko.cd_hinmei
		,zaiko.dt_hizuke
		,zaiko.su_zaiko
		,zaiko.dt_update
		,zaiko.cd_update
	FROM (
		SELECT cd_hinmei, dt_hizuke, su_zaiko, dt_update, cd_update
		FROM tr_zaiko_keisan WITH(NOLOCK)
		--WHERE dt_hizuke BETWEEN DATEADD(day, -1, @hizuke_from) AND @hizuke_to
		WHERE dt_hizuke = DATEADD(day, -1, @hizuke_from)
	) zaiko
	-- 有効な品名コードのみ抽出
	INNER JOIN #tmp_hinmei HIN
	ON HIN.cd_hinmei = zaiko.cd_hinmei
	-- ワークの前日在庫から取得し、存在しない分だけ計算在庫トランより取得する
	-- ＃初日の前日在庫のみを取得するため
	LEFT JOIN wk_zaiko_keisan wk
	ON wk.cd_hinmei = zaiko.cd_hinmei
	AND wk.dt_hizuke = zaiko.dt_hizuke  --DATEADD(day, -1, zaiko.dt_hizuke)
	WHERE wk.cd_hinmei IS NULL

    IF @@ERROR <> 0
    BEGIN
        SET @msg = 'error: wk_zaiko_keisan failed insert1.'
        GOTO Error_Handling
    END

	-- ================================
	--  画面で入力された指定期間を抽出
	-- ================================
	DECLARE cursor_calendar CURSOR FOR
		SELECT
			[dt_hizuke]       AS 'dt_hizuke'
		FROM [ma_calendar]
		WHERE
			[dt_hizuke] BETWEEN @hizuke_from AND @hizuke_to


	-- ============================================
	--  ■ 指定期間(計算対象日)のカーソルスタート ■
	-- ============================================
	OPEN cursor_calendar
		IF (@@error <> 0)
		BEGIN
		    SET @msg = 'CURSOR OPEN ERROR: cursor_calendar'
		    GOTO Error_Handling
		END

	FETCH NEXT FROM cursor_calendar INTO
		@cur_hizuke

	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- ==========================================
		--  計算在庫一時テーブルに計算在庫情報を挿入
		-- ==========================================
		INSERT INTO #tmp_zaiko_keisan (	
			cd_hinmei
			,dt_hizuke
			,su_zaiko
		)
		SELECT
			ruikei.cd_hinmei  AS 'cd_hinmei' --品名コード
			,@cur_hizuke      AS 'dt_hizuke' --日付
			,COALESCE(zenjitsu_keisanzaiko.su_keisanzaiko, 0.00)
			--	+ COALESCE(ruikei.su_nonyu_ruikei, 0.00)
				+ CAST(COALESCE(ruikei.su_nonyu_ruikei, 0) AS DECIMAL(14, 6))
				- COALESCE(ruikei.su_shiyo_ruikei, 0.00)
				- COALESCE(ruikei.su_chosei_ruikei, 0.00) AS 'su_zaiko'  --計算在庫数
		FROM
		(
		    SELECT
		        ruikei_hinmei.cd_hinmei       AS 'cd_hinmei'        -- 品名コード

				-- 納入数のC/S換算対応：KgまたはL以外
				,SUM(
					CASE WHEN COALESCE(mk.cd_tani_nonyu, mh.cd_tani_shiyo) = @cd_kg 
						OR COALESCE(mk.cd_tani_nonyu, mh.cd_tani_shiyo) = @cd_li
					THEN ruikei_meisai.su_nonyu * COALESCE(mk.wt_nonyu, mh.wt_ko) * COALESCE(mk.su_iri, mh.su_iri) 
						+ (ruikei_meisai.su_nonyu_hasu / 1000 )
					ELSE ruikei_meisai.su_nonyu * COALESCE(mk.wt_nonyu, mh.wt_ko) * COALESCE(mk.su_iri, mh.su_iri) 
						+ (ruikei_meisai.su_nonyu_hasu * COALESCE(mk.wt_nonyu, mh.wt_ko))
					END
				 ) AS 'su_nonyu_ruikei'   -- 納入数累計

		        ,SUM(ruikei_meisai.su_shiyo)  AS 'su_shiyo_ruikei'  -- 使用数累計
		        ,SUM(ruikei_meisai.su_chosei) AS 'su_chosei_ruikei' -- 調整数累計
		    FROM
				#tmp_hinmei ruikei_hinmei

		    -- ■ 累計用明細情報(ruikei_meisai)■
		    -- ■ 日付毎に、その日付までの累計情報を算出するための明細情報を抽出する■
		    LEFT JOIN
		    (
		        SELECT
		            ruikei_meisai_hinmei.cd_hinmei							AS 'cd_hinmei' -- 品名コード
		            ,COALESCE(ruikei_meisai_nonyu.su_nonyu, 0.00)			AS 'su_nonyu'  -- 納入数
		            ,COALESCE(ruikei_meisai_nonyu.su_nonyu_hasu, 0.00)		AS 'su_nonyu_hasu'  -- 納入数端数
		            ,COALESCE(ruikei_meisai_shiyo_yojitsu.su_shiyo, 0.00)	AS 'su_shiyo'  -- 使用数
		            ,COALESCE(ruikei_meisai_chosei.su_chosei, 0.00)			AS 'su_chosei' -- 調整数
		            ,ruikei_meisai_hinmei.dt_hizuke							AS 'dt_hizuke'
		        FROM (
					SELECT cal.dt_hizuke, hin.cd_hinmei
					FROM #tmp_hinmei hin, ma_calendar cal
					WHERE cal.dt_hizuke BETWEEN @hizuke_from AND @cur_hizuke
				) ruikei_meisai_hinmei

		        -- ■ 累計明細用納入予実(ruikei_meisai_nonyu)
		        -- ■ 納入予実トラン(tr_nonyu)より、指定日～末日の日付単位の納入数を抽出する
		        LEFT OUTER JOIN
		        (
					SELECT
						SUM(COALESCE(su_nonyu, 0.00))       AS 'su_nonyu' --納入数
						,SUM(COALESCE(su_nonyu_hasu, 0.00))	AS 'su_nonyu_hasu' --納入数端数
		                ,cd_hinmei AS 'cd_hinmei'
		                ,dt_nonyu AS 'dt_nonyu'
					FROM #tmp_nonyu
					WHERE dt_nonyu BETWEEN @hizuke_from AND @cur_hizuke
					GROUP BY cd_hinmei, dt_nonyu
		        ) ruikei_meisai_nonyu
		        ON ruikei_meisai_hinmei.cd_hinmei = ruikei_meisai_nonyu.cd_hinmei
		        AND ruikei_meisai_hinmei.dt_hizuke = ruikei_meisai_nonyu.dt_nonyu
		        -- ■ 累計明細用使用予実(ruikei_meisai_shiyo_yojitsu)
		        -- ■ 使用予実トラン(tr_shiyo_yojitsu)より、指定日～末日の日付単位の使用数を抽出する
		        LEFT OUTER JOIN
		        (
		            SELECT
		                SUM(COALESCE([su_shiyo], 0.00))      AS 'su_shiyo' --使用数
		                ,cd_hinmei AS 'cd_hinmei'
		                ,dt_shiyo AS 'dt_shiyo'
		            FROM #tmp_shiyo
		            WHERE
		                [dt_shiyo] BETWEEN @hizuke_from AND @cur_hizuke
		            GROUP BY
		                cd_hinmei, dt_shiyo
		        ) ruikei_meisai_shiyo_yojitsu
		        ON ruikei_meisai_hinmei.cd_hinmei = ruikei_meisai_shiyo_yojitsu.cd_hinmei
		        AND ruikei_meisai_hinmei.dt_hizuke = ruikei_meisai_shiyo_yojitsu.dt_shiyo
		        -- ■ 累計明細用調整(ruikei_meisai_chosei)■
		        -- ■ 調整トラン(tr_chosei)より、在庫計算開始日～末日かつ前日以前の日付単位の調整数を抽出する■
		        LEFT OUTER JOIN
		        (
		            SELECT
		                SUM(COALESCE([su_chosei], 0.00))      AS 'su_chosei' --調整数
		                ,cd_hinmei AS 'cd_hinmei'
		                ,dt_hizuke AS 'dt_hizuke'
		            FROM tr_chosei WITH(NOLOCK)
		            WHERE
		                [dt_hizuke] BETWEEN @hizuke_from AND @cur_hizuke
		            GROUP BY
		                cd_hinmei, dt_hizuke
		        ) ruikei_meisai_chosei
		        ON ruikei_meisai_hinmei.cd_hinmei = ruikei_meisai_chosei.cd_hinmei
		        AND ruikei_meisai_hinmei.dt_hizuke = ruikei_meisai_chosei.dt_hizuke
		    ) ruikei_meisai
		    -- ■ 累計の対象を抽出：開始日～指定日まで
		    ON ruikei_hinmei.cd_hinmei = ruikei_meisai.cd_hinmei
		    AND ruikei_meisai.dt_hizuke >= @hizuke_from

			-- 品名マスタを結合
			LEFT OUTER JOIN (
				SELECT mhj.cd_hinmei, mhj.cd_tani_shiyo, mhj.wt_ko, mhj.su_iri
				FROM ma_hinmei mhj 
				WHERE mhj.flg_mishiyo = @flg_shiyo
			) mh
			ON mh.cd_hinmei = ruikei_meisai.cd_hinmei
		    
			-- 購入先マスタを結合
			LEFT OUTER JOIN (
				SELECT mkj.no_juni_yusen, mkj.cd_hinmei, mkj.cd_tani_nonyu, mkj.wt_nonyu, mkj.su_iri
				FROM ma_konyu mkj 
				WHERE mkj.flg_mishiyo = @flg_shiyo
			) mk
			ON mk.cd_hinmei = ruikei_meisai.cd_hinmei
			AND mk.no_juni_yusen = ( SELECT
										MIN(ko.no_juni_yusen) AS no_juni_yusen
									 FROM ma_konyu ko 
									 WHERE ko.flg_mishiyo = @flg_shiyo
									 AND ko.cd_hinmei = ruikei_meisai.cd_hinmei )

		    GROUP BY ruikei_hinmei.cd_hinmei
		) ruikei

		-- ■ 算出開始日前日計算在庫情報(zenjitsu_keisanzaiko)
		LEFT OUTER JOIN
		(
		    SELECT
		        keisan_zaiko.cd_hinmei AS 'cd_hinmei' --品名コード
		        ,COALESCE(jitsu_zaiko.su_zaiko, keisan_zaiko.su_zaiko) AS 'su_keisanzaiko' --計算在庫数
		    FROM (
				SELECT cd_hinmei
					,su_zaiko
					,dt_hizuke
				FROM wk_zaiko_keisan
				WHERE [dt_hizuke] = DATEADD(day, -1, @hizuke_from)
			) keisan_zaiko
			LEFT JOIN (
				SELECT cd_hinmei
					,SUM(su_zaiko) AS su_zaiko
					,dt_hizuke
				FROM tr_zaiko
				WHERE [dt_hizuke] = DATEADD(day, -1, @hizuke_from)
				AND kbn_zaiko = @kbn_zaiko_ryohin
				GROUP BY cd_hinmei, dt_hizuke
			) jitsu_zaiko
			ON jitsu_zaiko.dt_hizuke = keisan_zaiko.dt_hizuke
			AND jitsu_zaiko.cd_hinmei = keisan_zaiko.cd_hinmei
		) zenjitsu_keisanzaiko
		ON ruikei.cd_hinmei = zenjitsu_keisanzaiko.cd_hinmei


		-- 計算対象日のカーソルを次の行へ
		FETCH NEXT FROM cursor_calendar INTO
			@cur_hizuke
	END

	CLOSE cursor_calendar
	DEALLOCATE cursor_calendar

	-- =======================================
	--  計算在庫ワークの更新：delete > insert
	-- =======================================
	-- 前日在庫を取得する手前でDELETEしてるのでコメントアウト
	--DELETE wk
	--	FROM wk_zaiko_keisan wk
	--	INNER JOIN (
	--		SELECT cd_hinmei
	--		FROM #tmp_hinmei
	--	) tmp_hin
	--	ON wk.cd_hinmei = tmp_hin.cd_hinmei
	--	WHERE wk.dt_hizuke BETWEEN @hizuke_from AND @hizuke_to

	--IF @@ERROR <> 0
	--BEGIN
 --       SET @msg = 'error: wk_zaiko_keisan failed delete.'
 --       GOTO Error_Handling
 --   END

	INSERT INTO wk_zaiko_keisan (
		cd_hinmei
		,dt_hizuke
		,su_zaiko
		,dt_update
		,cd_update
	)
	SELECT
		cd_hinmei
		,dt_hizuke
		,su_zaiko
		,GETUTCDATE()
		,@cd_update
	FROM
		#tmp_zaiko_keisan

    IF @@ERROR <> 0
    BEGIN
        SET @msg = 'error: wk_zaiko_keisan failed insert2.'
        GOTO Error_Handling
    END

	--PRINT 'OK 計算在庫の再計算完了'
	RETURN

	-- //////////////////////// --
	--   エラー処理
	-- //////////////////////// --
	Error_Handling:
		DELETE wk_zaiko_keisan
		CLOSE cursor_calendar
		DEALLOCATE cursor_calendar
		PRINT @msg

END
GO
