IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KeisanZaiko_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KeisanZaiko_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:		tsujita.s
-- Create date: 2014.01.24
-- Last Update: 2019.11.15 takaki.r
-- Description:	計算在庫作成
--   計算在庫トランの計算と更新処理
--   指定された品名コードの原資材、開始日付～終了日付の期間について
--   在庫数を計算し、テーブルを更新(DELETE→INSERT)する。
-- 2014.06.06: 警告リスト作成画面から計算在庫作成処理を行う
-- 2014.10.01: 未来の調整数も取得するよう修正
-- 2015.01.06: 在庫トランからは良品だけを取得するよう修正
-- 2015.02.17: 在庫トランの倉庫コードをキーに追加したことに伴う修正
-- 2015.06.01: 製品計画トラン取得時、当日未満は実績・当日以降は予定を取得するよう修正
-- 2017.06.26: 使用数の、小数第4位を繰り上げするように修正（KPMサポートNo022）
-- 2017.10.19: 計算在庫の実在庫を翌日から反映するように修正。当日の計算は納入実績を優先するように修正（BQPサポートNo002）
-- 2017.11.27: 全面見直し
-- 2019.11.15: 計算在庫数がNULLで登録されないよう修正
-- =======================================================
CREATE PROCEDURE [dbo].[usp_KeisanZaiko_create]
	 @con_hinmei		VARCHAR(14)		-- 品名コード
	,@hizuke_from		DATETIME		-- 在庫計算開始日
	,@hizuke_to			DATETIME		-- 在庫計算末日
	,@cd_update 		VARCHAR(10)		-- 更新者：ログインユーザコード
	,@flg_shiyo			SMALLINT		-- 定数：未使用フラグ：使用
	,@flg_yojitsu_yo 	SMALLINT		-- 定数：予実フラグ：予定
	,@flg_yojitsu_ji 	SMALLINT		-- 定数：予実フラグ：実績
	,@kbn_hin_genryo 	SMALLINT		-- 定数：品区分：原料
	,@kbn_hin_shizai 	SMALLINT		-- 定数：品区分：資材
	,@kbn_hin_jikagen 	SMALLINT		-- 定数：品区分：自家原料
	,@cd_kg				varchar(2)		-- 定数：単位コード：Kg
	,@cd_li				varchar(2)		-- 定数：単位コード：L
	,@today				DATETIME		-- UTC日付
	,@lang 				VARCHAR(2)		-- ブラウザ言語
	,@con_kbn_hin 		SMALLINT		-- 検索条件：品区分
	,@con_bunrui 		VARCHAR(10)		-- 検索条件：分類
	,@con_kurabasho 	VARCHAR(10)		-- 検索条件：庫場所
	,@con_nm_hinmei 	NVARCHAR(50)	-- 検索条件：品名or品名コード
	,@kbn_zaiko_ryohin	SMALLINT		-- 定数：在庫区分：良品
WITH RECOMPILE
AS
BEGIN

-- ======================================
--		【変数定義】
-- ======================================

	-- 変数リスト
	DECLARE @msg			VARCHAR(100)	-- 処理結果メッセージ格納用
	-- カーソル用の変数リスト
	DECLARE @cur_hizuke		DATETIME
	-- 更新日時
	DECLARE @systemUtcDate	DATETIME = GETUTCDATE()


-- ======================================
--		【一時テーブル定義】
-- ======================================
	-- 品マス一時テーブル
	create table #tmp_hinmei (
		  cd_hinmei				VARCHAR(14) COLLATE database_default
		, kbn_hin				SMALLINT
		, cd_tani_shiyo			VARCHAR(10) COLLATE database_default
		, cd_tani_nonyu			VARCHAR(10) COLLATE database_default
		, cd_tani_nonyu_hasu	VARCHAR(10) COLLATE database_default
		, wt_ko					DECIMAL(12,6) 
		, su_iri				DECIMAL(5,0)
	)
			

	-- 納入一時テーブル
	create table #tmp_nonyu (
		  flg_yojitsu	SMALLINT
		, cd_hinmei		VARCHAR(14) COLLATE database_default
		, dt_nonyu		DATETIME
		, su_nonyu		DECIMAL(13,6)
	)
	
	-- 納入一時テーブルサマリ
	create table #tmp_su_nonyu (
		  cd_hinmei		VARCHAR(14) COLLATE database_default
		, dt_nonyu		DATETIME
		, su_nonyu		DECIMAL(13,6)
	)
	
	-- 製品計画一時テーブル			
	create table #tmp_seihin (
		  cd_hinmei		VARCHAR(14) COLLATE database_default
		, dt_seizo		DATETIME
		, su_seizo		DECIMAL(13,6)
	)
		
	-- 使用予実一時テーブル
	create table #tmp_shiyo (
		flg_yojitsu		SMALLINT
		,cd_hinmei		VARCHAR(14) COLLATE database_default
		,dt_shiyo		DATETIME
		,su_shiyo		DECIMAL(13,6)
	)
	
	-- 使用予実一時テーブルサマリ
	create table #tmp_su_shiyo (
		  cd_hinmei		VARCHAR(14) COLLATE database_default
		, dt_shiyo		DATETIME
		, su_shiyo		DECIMAL(13,6)
	)	
	
	-- 調整一時テーブル			
	create table #tmp_chosei (
		cd_hinmei		VARCHAR(14) COLLATE database_default
		,dt_hizuke		DATETIME
		,su_chosei		DECIMAL(13,6)
	)		
	
	-- 実在庫一時テーブル
	create table #tmp_zaiko (
		  cd_hinmei			VARCHAR(14) COLLATE database_default
		, dt_hizuke			DATETIME
		, su_zaiko			DECIMAL(14,6)
	)

	-- 計算在庫一時テーブル
	create table #tmp_zaiko_keisan (
		  cd_hinmei			VARCHAR(14) COLLATE database_default
		, dt_hizuke			DATETIME
		, su_zaiko			DECIMAL(14,6)
	)

	SET NOCOUNT ON

-- ======================================
--		【一時テーブル準備】
-- ======================================
-- ===========================
--		品名マスタ
-- ===========================
	INSERT INTO #tmp_hinmei
	SELECT
		hin.cd_hinmei
		, hin.kbn_hin
		, hin.cd_tani_shiyo
		, ISNULL(konyu.cd_tani_nonyu, hin.cd_tani_nonyu) AS cd_tani_nonyu
		, ISNULL(konyu.cd_tani_nonyu_hasu, hin.cd_tani_nonyu_hasu) AS cd_tani_nonyu_hasu
		, COALESCE(konyu.wt_nonyu, hin.wt_ko, 1) AS wt_ko
		, COALESCE(konyu.su_iri, hin.su_iri, 1) AS su_iri
	FROM (
		SELECT
			*
		FROM ma_hinmei ma
		WHERE ma.flg_mishiyo = @flg_shiyo
			AND ma.kbn_hin IN(@kbn_hin_genryo, @kbn_hin_shizai, @kbn_hin_jikagen)
			AND (@con_kbn_hin = 0 OR ma.kbn_hin = @con_kbn_hin)
			AND (LEN(@con_nm_hinmei) = 0 OR
					(
					 (@lang = 'ja' AND ma.nm_hinmei_ja LIKE '%' + @con_nm_hinmei + '%')
					 OR (@lang = 'en' AND ma.nm_hinmei_en LIKE '%' + @con_nm_hinmei + '%')
					 OR (@lang = 'zh' AND ma.nm_hinmei_zh LIKE '%' + @con_nm_hinmei + '%')
					)
					OR ma.cd_hinmei LIKE '%' + @con_nm_hinmei + '%'
				)
			AND (LEN(@con_bunrui) = 0 OR ma.cd_bunrui = @con_bunrui)
			AND (LEN(@con_kurabasho) = 0 OR ma.cd_kura = @con_kurabasho)
		) hin
	INNER JOIN (
		SELECT
			cd_hinmei
			, MIN(no_juni_yusen) AS no_juni_yusen
		FROM ma_konyu
		WHERE flg_mishiyo = @flg_shiyo
		GROUP BY cd_hinmei
		) yusen
	  ON yusen.cd_hinmei = hin.cd_hinmei
	INNER JOIN ma_konyu konyu
	  ON konyu.cd_hinmei = yusen.cd_hinmei
	  AND konyu.no_juni_yusen = yusen.no_juni_yusen
	 
	
	-- 一時品名マスタにインデックスを付加
	CREATE NONCLUSTERED INDEX idx_hin1 ON #tmp_hinmei (cd_hinmei)
	
-- ===========================
--		納入トラン
-- ===========================
	-- 一時納入トラン
	INSERT INTO #tmp_nonyu 
	SELECT
		nonyu.flg_yojitsu
		, nonyu.cd_hinmei
		, nonyu.dt_nonyu
		, SUM(
			CASE
				WHEN hin.cd_tani_nonyu IN (@cd_kg, @cd_li)
					THEN nonyu.su_nonyu * hin.su_iri * hin.wt_ko + (nonyu.su_nonyu_hasu / 1000)
				ELSE nonyu.su_nonyu * hin.su_iri * hin.wt_ko + nonyu.su_nonyu_hasu * hin.wt_ko
			END
			) AS su_nonyu
	FROM (
		SELECT
			*
		FROM tr_nonyu  
		WHERE dt_nonyu BETWEEN @hizuke_from AND @hizuke_to
		) nonyu
	INNER JOIN #tmp_hinmei hin
	  ON hin.cd_hinmei = nonyu.cd_hinmei
	GROUP BY nonyu.flg_yojitsu, nonyu.cd_hinmei, nonyu.dt_nonyu
	
	-- 一時納入トランサマリー
	INSERT INTO #tmp_su_nonyu
	SELECT
		base.cd_hinmei
		, base.dt_nonyu
		, CASE
			-- 未来の日付は予定
			WHEN base.dt_nonyu > @today THEN ROUND(COALESCE(yotei.su_nonyu, 0),3,1)
			-- 今日の日付は、実績があれば実績、なければ予定
			WHEN base.dt_nonyu = @today THEN ROUND(COALESCE(jisseki.su_nonyu,yotei.su_nonyu, 0),3,1)
			-- 過去の日付は実績
		    ELSE COALESCE(jisseki.su_nonyu, 0)
		  END AS su_nonyu
	FROM (
		SELECT DISTINCT
			cd_hinmei
			, dt_nonyu
		FROM #tmp_nonyu
	) base
	LEFT OUTER JOIN #tmp_nonyu yotei
	  ON yotei.flg_yojitsu = @flg_yojitsu_yo
	  AND yotei.cd_hinmei = base.cd_hinmei
	  AND yotei.dt_nonyu = base.dt_nonyu
	LEFT OUTER JOIN #tmp_nonyu jisseki
	  ON jisseki.flg_yojitsu = @flg_yojitsu_ji
	  AND jisseki.cd_hinmei = base.cd_hinmei
	  AND jisseki.dt_nonyu = base.dt_nonyu
	  
	-- 一時納入トランにインデックスを付加
	CREATE NONCLUSTERED INDEX idx_nonyu2 ON #tmp_su_nonyu (cd_hinmei, dt_nonyu)
	
-- ===========================
--		製品計画トラン
-- ===========================
	
	INSERT INTO #tmp_seihin
	SELECT
		jikagen.cd_hinmei
		, jikagen.dt_seizo
		, CASE
			-- 未来の日付は予定
			WHEN jikagen.dt_seizo > @today THEN ROUND(su_seizo_yotei, 3, 1)
			-- 今日の日付は、実績があれば実績、なければ予定
			WHEN jikagen.dt_seizo = @today THEN ROUND(COALESCE(su_seizo_jisseki,su_seizo_yotei,0),3,1)
			-- 過去の日付は実績
		    ELSE su_seizo_jisseki
		  END AS su_seizo
	FROM (
		SELECT
			seihin.cd_hinmei
			, seihin.dt_seizo
			, SUM(seihin.su_seizo_yotei * hin.su_iri * hin.wt_ko) AS su_seizo_yotei
			, SUM(seihin.su_seizo_jisseki * hin.su_iri * hin.wt_ko) AS su_seizo_jisseki
		FROM (
			SELECT
				*
			FROM tr_keikaku_seihin
			WHERE dt_seizo BETWEEN @hizuke_from AND @hizuke_to
			) seihin
		INNER JOIN #tmp_hinmei hin
		  ON hin.cd_hinmei = seihin.cd_hinmei
		GROUP BY seihin.cd_hinmei, seihin.dt_seizo
	) jikagen
	
	-- 一時製品計画トランにインデックスを付加
	CREATE NONCLUSTERED INDEX idx_sei1 ON #tmp_seihin (cd_hinmei, dt_seizo)
	
	
-- ===========================
--		使用予実トラン
-- ===========================
	-- 一時使用予実トラン
	INSERT INTO #tmp_shiyo 
	SELECT
		shiyo.flg_yojitsu
		, shiyo.cd_hinmei
		, shiyo.dt_shiyo
		, SUM(shiyo.su_shiyo)AS su_shiyo
	FROM (
		SELECT
			*
		FROM tr_shiyo_yojitsu  
		WHERE dt_shiyo BETWEEN @hizuke_from AND @hizuke_to
		) shiyo
	INNER JOIN #tmp_hinmei hin
	  ON hin.cd_hinmei = shiyo.cd_hinmei
	GROUP BY shiyo.flg_yojitsu, shiyo.cd_hinmei, shiyo.dt_shiyo
	
	-- 一時使用予実サマリー
	INSERT INTO #tmp_su_shiyo
	SELECT
		base.cd_hinmei
		, base.dt_shiyo
		, CASE
			-- 未来の日付は予定（当日含む）
			WHEN base.dt_shiyo >= @today THEN CEILING(COALESCE(yotei.su_shiyo,0) * 1000) / 1000
			-- 過去の日付は実績
		    ELSE CEILING(COALESCE(jisseki.su_shiyo,0) * 1000) / 1000
		  END AS su_shiyo
	FROM (
		SELECT DISTINCT
			cd_hinmei
			, dt_shiyo
		FROM #tmp_shiyo
		) base
	LEFT OUTER JOIN #tmp_shiyo yotei
	  ON yotei.flg_yojitsu = @flg_yojitsu_yo
	  AND yotei.cd_hinmei = base.cd_hinmei
	  AND yotei.dt_shiyo = base.dt_shiyo
	LEFT OUTER JOIN #tmp_shiyo jisseki
	  ON jisseki.flg_yojitsu = @flg_yojitsu_ji
	  AND jisseki.cd_hinmei = base.cd_hinmei
	  AND jisseki.dt_shiyo = base.dt_shiyo
	  
	
	-- 一時使用予実トランにインデックスを付加
	CREATE NONCLUSTERED INDEX idx_shi2 ON #tmp_su_shiyo (cd_hinmei, dt_shiyo)

	
-- ===========================
--		調整トラン
-- ===========================
	INSERT INTO #tmp_chosei
	SELECT
		chosei.cd_hinmei
		, chosei.dt_hizuke
		, CEILING(SUM(COALESCE(chosei.su_chosei, 0)) * 1000) / 1000 AS su_chosei
	FROM (
		SELECT
			*
		FROM tr_chosei
		WHERE dt_hizuke BETWEEN @hizuke_from AND @hizuke_to
		) chosei 
	INNER JOIN  #tmp_hinmei hin
	  ON hin.cd_hinmei = chosei.cd_hinmei
	GROUP BY chosei.cd_hinmei, chosei.dt_hizuke
	  
	-- 一時調整トランにインデックスを付加
	CREATE NONCLUSTERED INDEX idx_cho1 ON #tmp_chosei (cd_hinmei, dt_hizuke)
	

-- ===========================
--		在庫トラン
-- ===========================

	-- 実在庫は前日以降のもを取得
	INSERT INTO #tmp_zaiko
	SELECT
		  zaiko.cd_hinmei
		, zaiko.dt_hizuke
		, ROUND(zaiko.su_zaiko, 3, 1) AS su_zaiko
	FROM (
		SELECT * 
		FROM tr_zaiko
		WHERE dt_hizuke BETWEEN DATEADD(day, -1, @hizuke_from) AND DATEADD(day, -1, @hizuke_to)
          AND kbn_zaiko = @kbn_zaiko_ryohin
		) zaiko
	INNER JOIN #tmp_hinmei hin
	  ON hin.cd_hinmei = zaiko.cd_hinmei

	
	-- 一時在庫トランにインデックスを付加
	CREATE NONCLUSTERED INDEX idx_zai1 ON #tmp_zaiko (cd_hinmei, dt_hizuke)

-- ===========================
--		計算在庫トラン
-- ===========================
	--計算在庫トランは前日時点での計算在庫のみを設定
	INSERT INTO #tmp_zaiko_keisan
	SELECT
		zaiko_keisan.cd_hinmei
		, DATEADD(day, -1, @hizuke_from) AS dt_hizuke
		, ROUND(COALESCE(zaiko_keisan.su_zaiko,0), 3, 1) AS su_zaiko
	FROM (
		SELECT cd_hinmei
		    , MAX(dt_hizuke) dt_hizuke
		FROM tr_zaiko_keisan
		WHERE dt_hizuke < @hizuke_from
		GROUP BY cd_hinmei
		) chokkin_zaiko
	INNER JOIN tr_zaiko_keisan zaiko_keisan
	  ON zaiko_keisan.cd_hinmei = chokkin_zaiko.cd_hinmei
	  AND zaiko_keisan.dt_hizuke = chokkin_zaiko.dt_hizuke
	INNER JOIN #tmp_hinmei hin
	  ON hin.cd_hinmei = zaiko_keisan.cd_hinmei

-- ======================================
--		【計算在庫算出】
-- ======================================

	-- ================================
	--  画面で入力された指定期間を抽出
	-- ================================
	DECLARE cursor_calendar CURSOR FOR
		SELECT
			dt_hizuke
		FROM ma_calendar
		WHERE
			dt_hizuke BETWEEN @hizuke_from AND @hizuke_to


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
		
		INSERT INTO #tmp_zaiko_keisan
		SELECT
			keisan.cd_hinmei
			, @cur_hizuke AS dt_hizuke
			-- 前日在庫＋納入数-使用数-調整数
			, keisan.su_zaiko_zen + keisan.su_nonyu - keisan.su_shiyo - keisan.su_chosei AS zaiko
		FROM (
			SELECT
				hin.cd_hinmei
				, CASE
					WHEN hin.kbn_hin = @kbn_hin_jikagen THEN COALESCE(seihin.su_seizo,0)
					ELSE COALESCE(nonyu.su_nonyu,0)
				  END AS su_nonyu
				, COALESCE(shiyo.su_shiyo,0) AS su_shiyo
				, COALESCE(chosei.su_chosei,0) AS su_chosei
				, COALESCE(zaiko.su_zaiko, zaiko_keisan.su_zaiko,0) AS su_zaiko_zen
			FROM #tmp_hinmei hin
			-- 納入数（原料・資材）
			LEFT OUTER JOIN #tmp_su_nonyu nonyu
			  ON nonyu.cd_hinmei = hin.cd_hinmei
			  AND nonyu.dt_nonyu = @cur_hizuke
			-- 製造数（自家原料）
			LEFT OUTER JOIN #tmp_seihin seihin
			  ON seihin.cd_hinmei = hin.cd_hinmei
			  AND seihin.dt_seizo = @cur_hizuke
			-- 使用数
			LEFT OUTER JOIN #tmp_su_shiyo shiyo
			  ON shiyo.cd_hinmei = hin.cd_hinmei
			  AND shiyo.dt_shiyo = @cur_hizuke
			-- 調整数
			LEFT OUTER JOIN #tmp_chosei chosei
			  ON chosei.cd_hinmei = hin.cd_hinmei
			  AND chosei.dt_hizuke = @cur_hizuke
			-- 実在庫（前日）
			LEFT OUTER JOIN #tmp_zaiko zaiko
			  ON zaiko.cd_hinmei = hin.cd_hinmei
			  AND zaiko.dt_hizuke = DATEADD(day, -1, @cur_hizuke)
			-- 計算在庫（前日以前の直近）
			LEFT OUTER JOIN (
				SELECT cd_hinmei
					, MAX(dt_hizuke) dt_hizuke
				FROM #tmp_zaiko_keisan
				WHERE dt_hizuke < @cur_hizuke
				GROUP BY cd_hinmei
				) chokkin_zaiko
			  ON chokkin_zaiko.cd_hinmei = hin.cd_hinmei
			LEFT OUTER JOIN #tmp_zaiko_keisan zaiko_keisan
			  ON zaiko_keisan.cd_hinmei = chokkin_zaiko.cd_hinmei
			  AND zaiko_keisan.dt_hizuke = chokkin_zaiko.dt_hizuke
		) keisan
		
		-- 計算対象日のカーソルを次の行へ
		FETCH NEXT FROM cursor_calendar INTO
			@cur_hizuke
	END
    IF @@ERROR <> 0
    BEGIN
        SET @msg = 'error :#tmp_zaiko_keisan failed insert.'
        GOTO Error_Handling
    END

	-- カーソルを閉じる
	CLOSE cursor_calendar
	DEALLOCATE cursor_calendar

-- ======================================
--		【一時計算在庫の前日情報を削除】
-- ======================================
	DELETE #tmp_zaiko_keisan
	WHERE dt_hizuke = DATEADD(day, -1, @hizuke_from)

-- ======================================
--		【計算在庫削除】
-- ======================================
	DELETE tr
		FROM tr_zaiko_keisan tr
		INNER JOIN #tmp_hinmei tmp_hin
			ON tr.cd_hinmei = tmp_hin.cd_hinmei
		WHERE tr.dt_hizuke BETWEEN @hizuke_from AND @hizuke_to

	IF @@ERROR <> 0
	BEGIN
        SET @msg = 'error :tr_zaiko_keisan failed delete.'
        GOTO Error_Handling
    END

-- ======================================
--		【計算在庫登録】
-- ======================================
	INSERT INTO tr_zaiko_keisan (
		cd_hinmei
		,dt_hizuke
		,su_zaiko
		,dt_update
		,cd_update
	)
	SELECT
		cd_hinmei
		, dt_hizuke
		, su_zaiko
		, @systemUtcDate
		, @cd_update
	FROM #tmp_zaiko_keisan

    IF @@ERROR <> 0
    BEGIN
        SET @msg = 'error :tr_zaiko_keisan failed insert.'
        GOTO Error_Handling
    END

 --============================
 -- 原資材計画管理トランの更新
 --============================
	-- 存在すればUPDATE、なければINSERT
	MERGE INTO tr_genshizai_keikaku AS tr
		USING
			(
				SELECT DISTINCT 
					tzk.cd_hinmei
				FROM #tmp_zaiko_keisan tzk
			) AS tmp
			ON tr.cd_hinmei = tmp.cd_hinmei
		WHEN MATCHED THEN
			UPDATE SET tr.dt_zaiko_keisan = @hizuke_to
		WHEN NOT MATCHED THEN
			INSERT (cd_hinmei, dt_zaiko_keisan, dt_keikaku_nonyu)
			VALUES (tmp.cd_hinmei, @hizuke_to, NULL);
	
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'error :tr_genshizai_keikaku failed update.'
		GOTO Error_Handling
	END	

-- ======================================
--		【終了処理】
-- ======================================	
	DROP TABLE #tmp_hinmei
	DROP TABLE #tmp_nonyu
	DROP TABLE #tmp_su_nonyu
	DROP TABLE #tmp_shiyo
	DROP TABLE #tmp_su_shiyo
	DROP TABLE #tmp_seihin
	DROP TABLE #tmp_chosei
	DROP TABLE #tmp_zaiko
	DROP TABLE #tmp_zaiko_keisan
	
	RETURN

-- ======================================
--		【エラー処理】
-- ======================================	
	Error_Handling:
		CLOSE cursor_calendar
		DEALLOCATE cursor_calendar
			
		DROP TABLE #tmp_hinmei
		DROP TABLE #tmp_nonyu
		DROP TABLE #tmp_su_nonyu
		DROP TABLE #tmp_shiyo
		DROP TABLE #tmp_su_shiyo
		DROP TABLE #tmp_seihin
		DROP TABLE #tmp_chosei
		DROP TABLE #tmp_zaiko
		DROP TABLE #tmp_zaiko_keisan
		
		PRINT @msg


-- ========== ▼　2017.11.27 全面見直しのよりコメントアウト ▼ ======================
	---- 変数リスト
	--DECLARE @msg			VARCHAR(100)	-- 処理結果メッセージ格納用
	---- カーソル用の変数リスト
	--DECLARE @cur_hizuke		DATETIME
	
	--DECLARE @systemUtcDate	DATETIME = GETUTCDATE()

	---- ====================
	----  一時テーブルの作成
	---- ====================
	---- 計算在庫一時テーブル
	--create table #tmp_zaiko_keisan (
	--	cd_hinmei			VARCHAR(14)
	--	,dt_hizuke			DATETIME
	--	,su_zaiko			DECIMAL(14,6)
	--)

	---- 納入一時テーブル
	--create table #tmp_nonyu (
	--	flg_yojitsu		SMALLINT
	--	,dt_nonyu		DATETIME
	--	,cd_hinmei		VARCHAR(14)
	--	,su_nonyu		DECIMAL(9,2)
	--	,su_nonyu_hasu	DECIMAL(9,2)
	--)			

	---- 品マス一時テーブル
	--create table #tmp_hinmei (
	--	cd_hinmei		VARCHAR(14)
	--)			

	---- 使用予実一時テーブル
	--create table #tmp_shiyo (
	--	flg_yojitsu		SMALLINT
	--	,cd_hinmei		VARCHAR(14)
	--	,dt_shiyo		DATETIME
	--	,su_shiyo		DECIMAL(12,6)
	--)			

	---- 調整一時テーブル			
	--create table #tmp_chosei (
	--	cd_hinmei		VARCHAR(14)
	--	,dt_hizuke		DATETIME
	--	,su_chosei		DECIMAL(12,6)
	--)			

	---- 製品計画一時テーブル			
	--create table #tmp_seihin (
	--	dt_seizo			DATETIME
	--	,cd_hinmei			VARCHAR(14)
	--	,su_seizo_yotei		DECIMAL(10,0)
	--	,su_seizo_jisseki	DECIMAL(10,0)
	--)				

	----SET ARITHABORT ON	-- クエリ実行中にオーバーフローまたは 0 除算のエラーが発生した場合に、クエリを終了します
	--SET NOCOUNT ON

	---- ===========================
	----  一時テーブルへのコピー
	---- ===========================
	---- 納入一時テーブルへ指定範囲の日付分コピー
	--INSERT INTO #tmp_nonyu (flg_yojitsu, dt_nonyu, cd_hinmei, su_nonyu, su_nonyu_hasu)
	--SELECT trn.flg_yojitsu, trn.dt_nonyu, trn.cd_hinmei, trn.su_nonyu, trn.su_nonyu_hasu
	--FROM tr_nonyu trn 
	--WHERE trn.dt_nonyu BETWEEN @hizuke_from AND @hizuke_to
	----CREATE NONCLUSTERED INDEX idx_nonyu1 ON #tmp_nonyu (flg_yojitsu)
	--CREATE NONCLUSTERED INDEX idx_nonyu2 ON #tmp_nonyu (dt_nonyu)
	----CREATE NONCLUSTERED INDEX idx_nonyu3 ON #tmp_nonyu (cd_hinmei)

	---- 品マス一時テーブルに有効なものを挿入
	--INSERT INTO #tmp_hinmei (cd_hinmei)
	--SELECT HIN.cd_hinmei
	--FROM (
	--	SELECT
	--		ma.cd_hinmei
	--	FROM
	--		ma_hinmei ma 
	--	WHERE ma.flg_mishiyo = @flg_shiyo
	--	--AND ma.kbn_hin in (@kbn_hin_genryo, @kbn_hin_shizai, @kbn_hin_jikagen)
	--	AND (ma.kbn_hin = @kbn_hin_genryo OR ma.kbn_hin = @kbn_hin_shizai OR ma.kbn_hin = @kbn_hin_jikagen)
	--	AND (@con_kbn_hin = 0 OR ma.kbn_hin = @con_kbn_hin)
	--	AND (LEN(@con_nm_hinmei) = 0 OR
	--			(
	--			 (@lang = 'ja' AND ma.nm_hinmei_ja LIKE '%' + @con_nm_hinmei + '%')
	--			 OR (@lang = 'en' AND ma.nm_hinmei_en LIKE '%' + @con_nm_hinmei + '%')
	--			 OR (@lang = 'zh' AND ma.nm_hinmei_zh LIKE '%' + @con_nm_hinmei + '%')
	--			)
	--			OR ma.cd_hinmei LIKE '%' + @con_nm_hinmei + '%'
	--		)
	--	AND (LEN(@con_bunrui) = 0 OR ma.cd_bunrui = @con_bunrui)
	--	AND (LEN(@con_kurabasho) = 0 OR ma.cd_kura = @con_kurabasho)
	--) HIN
	--WHERE EXISTS (SELECT ko.cd_hinmei FROM ma_konyu ko 
	--				WHERE ko.flg_mishiyo = @flg_shiyo
	--				AND ko.cd_hinmei = HIN.cd_hinmei)
	----INNER JOIN (
	----	SELECT DISTINCT ko.cd_hinmei
	----	FROM ma_konyu ko 
	----	WHERE ko.flg_mishiyo = @flg_shiyo
	----	--AND (LEN(@con_hinmei) = 0 OR
	----	--	 cd_hinmei = @con_hinmei)
	----) KONYU
	----ON HIN.cd_hinmei = KONYU.cd_hinmei
	--CREATE NONCLUSTERED INDEX idx_hin1 ON #tmp_hinmei (cd_hinmei)

	---- 使用一時にコピー
	--INSERT INTO #tmp_shiyo (
	--	flg_yojitsu, cd_hinmei, dt_shiyo, su_shiyo)
	--SELECT tsy.flg_yojitsu, tsy.cd_hinmei, tsy.dt_shiyo, tsy.su_shiyo
	--FROM tr_shiyo_yojitsu tsy 
	--WHERE tsy.dt_shiyo BETWEEN @hizuke_from AND @hizuke_to
	----CREATE NONCLUSTERED INDEX idx_shi1 ON #tmp_shiyo (flg_yojitsu)
	--CREATE NONCLUSTERED INDEX idx_shi2 ON #tmp_shiyo (dt_shiyo)
	----CREATE NONCLUSTERED INDEX idx_shi3 ON #tmp_shiyo (cd_hinmei)

	---- 調整一時にコピー
	--INSERT INTO #tmp_chosei (
	--	cd_hinmei, dt_hizuke, su_chosei)
	--SELECT tc.cd_hinmei, tc.dt_hizuke, tc.su_chosei
	--FROM tr_chosei tc 
	--WHERE tc.dt_hizuke BETWEEN @hizuke_from AND @hizuke_to
	--CREATE NONCLUSTERED INDEX idx_cho1 ON #tmp_chosei (dt_hizuke)
	----CREATE NONCLUSTERED INDEX idx_cho2 ON #tmp_chosei (cd_hinmei)

	---- 製品計画一時にコピー
	--INSERT INTO #tmp_seihin (
	--	dt_seizo, cd_hinmei, su_seizo_yotei, su_seizo_jisseki)
	--SELECT tks.dt_seizo, tks.cd_hinmei, tks.su_seizo_yotei, tks.su_seizo_jisseki
	--FROM tr_keikaku_seihin tks 
	--WHERE tks.dt_seizo BETWEEN @hizuke_from AND @hizuke_to
	--CREATE NONCLUSTERED INDEX idx_sei1 ON #tmp_seihin (dt_seizo)
	----CREATE NONCLUSTERED INDEX idx_sei2 ON #tmp_seihin (cd_hinmei)


	---- 変数の初期化
	--IF @con_hinmei IS NULL
	--BEGIN
	--	SET @con_hinmei = ''
	--END

	---- ==================================================
	---- ==================================================
	----  指定期間分の計算在庫情報をワークテーブルにINSERT
	---- ==================================================
	---- ==================================================
	--DELETE wk_keisan_zaiko_sakusei	-- 中身を一度クリア
 --   IF @@ERROR <> 0
 --   BEGIN
 --       SET @msg = 'error :wk_keisan_zaiko_sakusei failed clear.'
 --       GOTO Error_Handling
 --   END

	--INSERT INTO wk_keisan_zaiko_sakusei (
	--	cd_hinmei
	--	,dt_hizuke
	--	,su_zaiko
	--	,dt_update
	--	,cd_update
	--)
	--SELECT
	--	zaiko.cd_hinmei
	--	,zaiko.dt_hizuke
	--	,zaiko.su_zaiko
	--	,zaiko.dt_update
	--	,zaiko.cd_update
	----FROM tr_zaiko_keisan zaiko 
	--FROM (
	--	SELECT
	--		tzk.cd_hinmei, tzk.dt_hizuke, tzk.su_zaiko, tzk.dt_update, tzk.cd_update
	--	FROM tr_zaiko_keisan tzk
	--	-- 指定期間分に絞る：前日在庫も見るので開始日-1日～末日
	--	WHERE tzk.dt_hizuke BETWEEN DATEADD(day, -1, @hizuke_from) AND @hizuke_to
	--) zaiko
	---- 有効な品名コードのみ抽出
	--INNER JOIN #tmp_hinmei HIN
	--ON HIN.cd_hinmei = zaiko.cd_hinmei
	----WHERE zaiko.dt_hizuke BETWEEN DATEADD(day, -1, @hizuke_from) AND @hizuke_to

 --   IF @@ERROR <> 0
 --   BEGIN
 --       SET @msg = 'error :wk_keisan_zaiko_sakusei failed insert.'
 --       GOTO Error_Handling
 --   END

	---- ================================
	----  画面で入力された指定期間を抽出
	---- ================================
	--DECLARE cursor_calendar CURSOR FOR
	--	SELECT
	--		[dt_hizuke]       AS 'dt_hizuke'
	--	FROM [ma_calendar] 
	--	WHERE
	--		[dt_hizuke] BETWEEN @hizuke_from AND @hizuke_to


	---- ============================================
	----  ■ 指定期間(計算対象日)のカーソルスタート ■
	---- ============================================
	--OPEN cursor_calendar
	--	IF (@@error <> 0)
	--	BEGIN
	--	    SET @msg = 'CURSOR OPEN ERROR: cursor_calendar'
	--	    GOTO Error_Handling
	--	END

	--FETCH NEXT FROM cursor_calendar INTO
	--	@cur_hizuke

	--WHILE @@FETCH_STATUS = 0
	--BEGIN

	--	-- ==========================================
	--	--  計算在庫一時テーブルに計算在庫情報を挿入
	--	-- ==========================================
	--	INSERT INTO #tmp_zaiko_keisan (	
	--		cd_hinmei
	--		,dt_hizuke
	--		,su_zaiko
	--	)
	--	SELECT
	--		ruikei.cd_hinmei  AS 'cd_hinmei' --品名コード
	--		,@cur_hizuke      AS 'dt_hizuke' --日付

	--		,COALESCE(chokkin_jitsuzaiko.su_jitsuzaiko, zenjitsu_keisanzaiko.su_keisanzaiko, 0.00)
	--			- COALESCE(ruikei.su_shiyo_ruikei, 0.00)
	--			-- + CAST(ruikei.su_nonyu_ruikei AS DECIMAL(12,6))
	--			+ COALESCE(ruikei.su_nonyu_ruikei, 0.00)
	--			- COALESCE(ruikei.su_chosei_ruikei, 0.00)
	--		    AS 'su_zaiko'  --計算在庫数
	--	FROM
	--	(
	--	    SELECT
	--	        ruikei_hinmei.cd_hinmei       AS 'cd_hinmei'        -- 品名コード

	--			-- 納入数のC/S換算対応：KgまたはL以外
	--			,SUM(
	--				CASE WHEN COALESCE(mk.cd_tani_nonyu, mh.cd_tani_shiyo) = @cd_kg 
	--					OR COALESCE(mk.cd_tani_nonyu, mh.cd_tani_shiyo) = @cd_li
	--				THEN ruikei_meisai.su_nonyu * COALESCE(mk.wt_nonyu, mh.wt_ko) * COALESCE(mk.su_iri, mh.su_iri) 
	--					+ (ruikei_meisai.su_nonyu_hasu / 1000 )
	--				ELSE ruikei_meisai.su_nonyu * COALESCE(mk.wt_nonyu, mh.wt_ko) * COALESCE(mk.su_iri, mh.su_iri) 
	--					+ (ruikei_meisai.su_nonyu_hasu * COALESCE(mk.wt_nonyu, mh.wt_ko))
	--				END
	--			 ) AS 'su_nonyu_ruikei'   -- 納入数累計
	--	        --,SUM(ruikei_meisai.su_nonyu)  AS 'su_nonyu_ruikei'  -- 納入数累計

	--	        --,SUM(ruikei_meisai.su_shiyo)  AS 'su_shiyo_ruikei'  -- 使用数累計
	--	        ,SUM(CEILING(ruikei_meisai.su_shiyo * 1000) / 1000 )  AS 'su_shiyo_ruikei'  -- 使用数累計
	--	        ,SUM(ruikei_meisai.su_chosei) AS 'su_chosei_ruikei' -- 調整数累計
	--	    FROM
	--			#tmp_hinmei ruikei_hinmei 

	--	    -- ■ 累計用明細情報(ruikei_meisai)■
	--	    -- ■ 日付・品名コード毎に、その日付までの累計情報を算出する■
	--	    -- ■ 実在庫が存在した場合は累計をリセットし、その翌日から累計する■
	--	    LEFT JOIN
	--	    (
	--	        SELECT
	--	            ruikei_meisai_hinmei.cd_hinmei                             AS 'cd_hinmei' -- 品名コード
	--	            ,COALESCE(ruikei_meisai_nonyu_yojitsu.su_nonyu, 0.00)      AS 'su_nonyu' -- 納入数
	--	            ,COALESCE(ruikei_meisai_nonyu_yojitsu.su_nonyu_hasu, 0.00) AS 'su_nonyu_hasu' -- 納入端数
	--	            ,COALESCE(ruikei_meisai_shiyo_yojitsu.su_shiyo, 0.00)      AS 'su_shiyo' -- 使用数
	--	            ,COALESCE(ruikei_meisai_chosei.su_chosei, 0.00)            AS 'su_chosei' -- 調整数
	--	            ,ruikei_meisai_hinmei.dt_hizuke                                  AS 'dt_hizuke'
	--	        FROM (
	--				--#tmp_hinmei ruikei_meisai_hinmei
	--				SELECT cal.dt_hizuke, hin.cd_hinmei
	--				FROM #tmp_hinmei hin , ma_calendar cal 
	--				WHERE cal.dt_hizuke BETWEEN @hizuke_from AND @cur_hizuke
	--			) ruikei_meisai_hinmei

	--	        -- ■ 累計明細用納入予実(ruikei_meisai_nonyu_yojitsu)■
	--	        -- ■ 納入予実トラン(tr_nonyu)or 製造計画トラン(tr_keikaku_seihin)より、在庫計算開始日～末日の日付単位の納入数を抽出する■
	--	        -- ■ 前日以前は実績から、当日以降は予定から納入数を抽出する■
	--	        LEFT OUTER JOIN
	--	         (
	--	        	-- 原料、資材の予実取得
	--					-- 納入実績取得（前日以前）
	--					SELECT
	--						SUM(COALESCE([su_nonyu], 0.00))      AS 'su_nonyu' --実績納入数
	--						,SUM(COALESCE([su_nonyu_hasu], 0.00)) AS 'su_nonyu_hasu' --納入端数
	--						,trn1.cd_hinmei AS 'cd_hinmei'
	--						,trn1.dt_nonyu AS 'dt_nonyu'
	--					FROM #tmp_nonyu trn1 
	--					WHERE
	--						trn1.[flg_yojitsu] = @flg_yojitsu_ji
	--						AND trn1.[dt_nonyu] BETWEEN @hizuke_from AND @cur_hizuke
	--						AND trn1.[dt_nonyu] < @today
	--						AND (trn1.su_nonyu IS NOT NULL OR trn1.su_nonyu_hasu IS NOT NULL)
	--					GROUP BY
	--						trn1.cd_hinmei, trn1.dt_nonyu
	--					UNION ALL
	--					-- 納入予定取得（後日以降）
	--					SELECT
	--						SUM(COALESCE([su_nonyu], 0.00))      AS 'su_nonyu' --予定納入数
	--						,SUM(COALESCE([su_nonyu_hasu], 0.00)) AS 'su_nonyu_hasu' --納入予定端数
	--						,trn2.cd_hinmei AS 'cd_hinmei'
	--						,trn2.dt_nonyu AS 'dt_nonyu'
	--					FROM #tmp_nonyu trn2 
	--					WHERE
	--						trn2.[flg_yojitsu] = @flg_yojitsu_yo
	--						AND trn2.[dt_nonyu] BETWEEN @hizuke_from AND @cur_hizuke
	--						AND trn2.[dt_nonyu] > @today
	--						AND (trn2.su_nonyu IS NOT NULL OR trn2.su_nonyu_hasu IS NOT NULL)
	--					GROUP BY
	--						trn2.cd_hinmei, trn2.dt_nonyu
	--					UNION ALL
	--					-- 納入実績を取得、無ければ納入予定を取得（当日）
	--					SELECT
	--						su_nonyu
	--						,su_nonyu_hasu
	--						,cd_hinmei
	--						,dt_nonyu
	--					FROM (
	--						SELECT
	--							su_nonyu
	--							,su_nonyu_hasu
	--							,cd_hinmei
	--							,dt_nonyu
	--							,RANK() over(partition by dt_nonyu,cd_hinmei order by flg_yojitsu desc) as rn
	--						FROM (	
	--							SELECT
	--								SUM(COALESCE([su_nonyu], 0.00))      AS 'su_nonyu' --予定納入数
	--								,SUM(COALESCE([su_nonyu_hasu], 0.00)) AS 'su_nonyu_hasu' --納入予定端数
	--								,trn3.cd_hinmei AS 'cd_hinmei'
	--								,trn3.dt_nonyu AS 'dt_nonyu'
	--								,flg_yojitsu
	--							FROM #tmp_nonyu trn3
	--							WHERE
	--								trn3.[dt_nonyu] = @today
	--								AND (trn3.su_nonyu IS NOT NULL OR trn3.su_nonyu_hasu IS NOT NULL)
	--							GROUP BY
	--								trn3.cd_hinmei, trn3.dt_nonyu,trn3.flg_yojitsu
	--						) yojitsu
	--					)rk
	--					WHERE rn = 1
	--					UNION ALL
	--				-- 自家原料の予実取得
	--					-- 製造実績取得（前日以前）
	--					SELECT
	--						SUM(COALESCE(tmps1.su_seizo_jisseki, 0)) AS 'su_nonyu' --製造実績数
	--						,0	AS 'su_nonyu_hasu' -- 端数ダミー値(Sqlエラー回避用)
	--						,tmps1.cd_hinmei AS 'cd_hinmei'
	--						,tmps1.dt_seizo AS 'dt_nonyu'
	--					FROM #tmp_seihin tmps1
	--					WHERE
	--						tmps1.[dt_seizo] BETWEEN @hizuke_from AND @cur_hizuke
	--						AND tmps1.[dt_seizo] < @today
	--						AND tmps1.su_seizo_jisseki IS NOT NULL
	--					GROUP BY
	--						tmps1.[dt_seizo], tmps1.cd_hinmei
	--					UNION ALL
	--					-- 製造予定取得（後日以降）
	--					SELECT
	--						SUM(COALESCE(tmps2.[su_seizo_yotei], 0)) AS 'su_nonyu' --製造予定数
	--						,0	AS 'su_nonyu_hasu' -- 端数ダミー値(Sqlエラー回避用)
	--						,tmps2.cd_hinmei AS 'cd_hinmei'
	--						,tmps2.dt_seizo AS 'dt_nonyu'
	--					FROM #tmp_seihin tmps2
	--					WHERE
	--						tmps2.[dt_seizo] BETWEEN @hizuke_from AND @cur_hizuke
	--						AND tmps2.[dt_seizo] > @today
	--						AND tmps2.su_seizo_yotei IS NOT NULL
	--					GROUP BY
	--						tmps2.[dt_seizo], tmps2.cd_hinmei
	--					UNION ALL
	--					-- 製造実績を取得、無ければ製造予定を取得（当日）
	--					SELECT
	--						su_nonyu
	--						,su_nonyu_hasu
	--						,cd_hinmei 
	--						,dt_nonyu
	--					FROM (
	--						SELECT
	--							su_nonyu
	--							,su_nonyu_hasu
	--							,cd_hinmei 
	--							,dt_nonyu
	--							,RANK() OVER(PARTITION BY dt_nonyu,cd_hinmei ORDER BY flg_yojitsu desc) as rn
	--						FROM (
	--							SELECT
	--								SUM(COALESCE(tmps3.[su_seizo_yotei], 0)) AS 'su_nonyu' --製造予定数
	--								,0	AS 'su_nonyu_hasu' -- 端数ダミー値(Sqlエラー回避用)
	--								,tmps3.cd_hinmei AS 'cd_hinmei'
	--								,tmps3.dt_seizo AS 'dt_nonyu'
	--								,1 as 'flg_yojitsu'
	--							FROM #tmp_seihin tmps3
	--							WHERE
	--								tmps3.[dt_seizo] = @today
	--								AND tmps3.su_seizo_yotei IS NOT NULL
	--							GROUP BY
	--								tmps3.[dt_seizo], tmps3.cd_hinmei
	--							UNION ALL
	--							SELECT
	--								SUM(COALESCE(tmps3.[su_seizo_jisseki], 0)) AS 'su_nonyu' --製造予定数
	--								,0	AS 'su_nonyu_hasu' -- 端数ダミー値(Sqlエラー回避用)
	--								,tmps3.cd_hinmei AS 'cd_hinmei'
	--								,tmps3.dt_seizo AS 'dt_nonyu'
	--								,0 as 'flg_yojitsu'
	--							FROM #tmp_seihin tmps3
	--							WHERE
	--								tmps3.[dt_seizo] = @today
	--								AND tmps3.su_seizo_yotei IS NOT NULL
	--							GROUP BY
	--								tmps3.[dt_seizo], tmps3.cd_hinmei
	--						)uni
	--					)rk
	--					where rn = 1
	--	        ) ruikei_meisai_nonyu_yojitsu
	--	        ON ruikei_meisai_hinmei.cd_hinmei = ruikei_meisai_nonyu_yojitsu.cd_hinmei
	--	        AND ruikei_meisai_hinmei.dt_hizuke = ruikei_meisai_nonyu_yojitsu.dt_nonyu
	--	        -- ■ 累計明細用使用予実(ruikei_meisai_shiyo_yojitsu)■
	--	        -- ■ 使用予実トラン(tr_shiyo_yojitsu)より、在庫計算開始日～末日の日付単位の使用数を抽出する■
	--	        -- ■ 前日以前は実績から、当日以降は予定から使用数を抽出する■
	--	        LEFT OUTER JOIN
	--	        (
	--	            SELECT
	--	                SUM(COALESCE([su_shiyo], 0.00))      AS 'su_shiyo' --実績使用数
	--	                ,trs1.cd_hinmei      AS 'cd_hinmei'
	--	                ,trs1.dt_shiyo       AS 'dt_shiyo'
	--	            FROM #tmp_shiyo trs1 
	--	            WHERE
	--	                trs1.[flg_yojitsu] = @flg_yojitsu_ji
	--	                AND trs1.[dt_shiyo] BETWEEN @hizuke_from AND @cur_hizuke
	--	                AND trs1.[dt_shiyo] < @today
	--	                AND trs1.su_shiyo IS NOT NULL
	--	            GROUP BY
	--	                trs1.cd_hinmei, trs1.dt_shiyo
	--	            UNION ALL
	--	            SELECT
	--	                SUM(COALESCE([su_shiyo], 0.00))      AS 'su_shiyo' --予定使用数
	--	                ,trs2.cd_hinmei       AS 'cd_hinmei'
	--	                ,trs2.dt_shiyo        AS 'dt_shiyo'
	--	            FROM #tmp_shiyo trs2 
	--	            WHERE
	--	                trs2.[flg_yojitsu] = @flg_yojitsu_yo
	--	                AND trs2.[dt_shiyo] BETWEEN @hizuke_from AND @cur_hizuke
	--	                AND trs2.[dt_shiyo] >= @today
	--	                AND trs2.su_shiyo IS NOT NULL
	--	            GROUP BY
	--	                trs2.cd_hinmei, trs2.dt_shiyo
	--	        ) ruikei_meisai_shiyo_yojitsu
	--	        ON ruikei_meisai_hinmei.cd_hinmei = ruikei_meisai_shiyo_yojitsu.cd_hinmei
	--	        AND ruikei_meisai_hinmei.dt_hizuke = ruikei_meisai_shiyo_yojitsu.dt_shiyo
	--	        -- ■ 累計明細用調整(ruikei_meisai_chosei)■
	--	        -- ■ 調整トラン(tr_chosei)より、在庫計算開始日～末日かつ前日以前の日付単位の調整数を抽出する■
	--	        LEFT OUTER JOIN
	--	        (
	--	            SELECT
	--	                SUM(COALESCE([su_chosei], 0.00))      AS 'su_chosei' --調整数
	--	                ,trc1.cd_hinmei       AS 'cd_hinmei'
	--	                ,trc1.dt_hizuke       AS 'dt_hizuke'
	--	            FROM #tmp_chosei trc1 
	--	            WHERE
	--	                trc1.[dt_hizuke] BETWEEN @hizuke_from AND @cur_hizuke
	--	                AND trc1.su_chosei IS NOT NULL
	--	                --AND [dt_hizuke] < @today
	--	            GROUP BY
	--	                trc1.cd_hinmei, trc1.dt_hizuke
	--	        ) ruikei_meisai_chosei
	--	        ON ruikei_meisai_hinmei.cd_hinmei = ruikei_meisai_chosei.cd_hinmei
	--	        AND ruikei_meisai_hinmei.dt_hizuke = ruikei_meisai_chosei.dt_hizuke
	--	    ) ruikei_meisai
	--	    -- ■ 累計の対象は、前日以前で直近の実在庫が存在する日付の翌日からその日付までとする■
	--	    ON ruikei_hinmei.cd_hinmei = ruikei_meisai.cd_hinmei
	--	    AND ruikei_meisai.dt_hizuke > COALESCE((SELECT MAX(tz1.[dt_hizuke])
	--	                                FROM [tr_zaiko] tz1 
	--	                                WHERE tz1.[dt_hizuke] BETWEEN @hizuke_from AND @cur_hizuke
	--	                                AND tz1.cd_hinmei = ruikei_hinmei.cd_hinmei
	--	                                --AND tz1.[dt_hizuke] <= @today
	--	                                AND tz1.[dt_hizuke] < @today
	--	                                AND tz1.kbn_zaiko = @kbn_zaiko_ryohin), 0)

	--	    -- 品名マスタを結合
	--	    LEFT OUTER JOIN (
	--			SELECT mhj.cd_hinmei, mhj.cd_tani_shiyo, mhj.wt_ko, mhj.su_iri
	--			FROM ma_hinmei mhj 
	--			WHERE mhj.flg_mishiyo = @flg_shiyo
	--	    ) mh
	--	    ON mh.cd_hinmei = ruikei_meisai.cd_hinmei
		    
	--	    -- 購入先マスタを結合
	--		LEFT OUTER JOIN (
	--			SELECT mkj.no_juni_yusen, mkj.cd_hinmei, mkj.cd_tani_nonyu, mkj.wt_nonyu, mkj.su_iri
	--			FROM ma_konyu mkj 
	--			WHERE mkj.flg_mishiyo = @flg_shiyo
	--		) mk
	--		ON mk.cd_hinmei = ruikei_meisai.cd_hinmei
	--		AND mk.no_juni_yusen = ( SELECT
	--									MIN(ko.no_juni_yusen) AS no_juni_yusen
	--								 FROM ma_konyu ko 
	--								 WHERE ko.flg_mishiyo = @flg_shiyo
	--								 AND ko.cd_hinmei = ruikei_meisai.cd_hinmei )

	--	    GROUP BY ruikei_hinmei.cd_hinmei
	--	    --GROUP BY ruikei_meisai.cd_hinmei
	--	) ruikei

	--	-- ■ 直近実在庫情報■
	--	-- ■ 日付毎に、前日以前で直近の実在庫情報を抽出する■
	--	LEFT OUTER JOIN
	--	(
	--	    SELECT
	--	        tz2.[dt_hizuke]  AS 'dt_hizuke' --日付
	--	        ,SUM(tz2.[su_zaiko])  AS 'su_jitsuzaiko' --実在庫数
	--	        ,tz2.cd_hinmei   AS 'cd_hinmei'
	--	    FROM
	--	        [tr_zaiko] tz2 
	--	    WHERE
	--	        tz2.[dt_hizuke] BETWEEN DATEADD(day,-1,@hizuke_from) AND @cur_hizuke
	--	        AND tz2.[dt_hizuke] <= @today --DATEADD(day, -1, GETUTCDATE())
	--	        AND tz2.kbn_zaiko = @kbn_zaiko_ryohin
	--	    GROUP BY
	--			tz2.[dt_hizuke], tz2.cd_hinmei
	--	) chokkin_jitsuzaiko
	--	ON ruikei.cd_hinmei = chokkin_jitsuzaiko.cd_hinmei
	--	AND chokkin_jitsuzaiko.dt_hizuke = (SELECT MAX(tz3.[dt_hizuke])
	--	                                    FROM [tr_zaiko] tz3 
	--										--WHERE tz3.[dt_hizuke] BETWEEN @hizuke_from AND @cur_hizuke
	--										WHERE tz3.[dt_hizuke] BETWEEN DATEADD(day,-1,@hizuke_from) AND DATEADD(day,-1,@cur_hizuke)
	--	                                    AND tz3.cd_hinmei = ruikei.cd_hinmei
	--	                                    AND tz3.[dt_hizuke] <= @today --DATEADD(day, -1, GETUTCDATE())
	--	                                    AND tz3.kbn_zaiko = @kbn_zaiko_ryohin)

	--	-- ■ 算出開始日前日計算在庫情報(zenjitsu_keisanzaiko)■
	--	LEFT OUTER JOIN
	--	(
	--	    SELECT
	--	        wkzaiko.[cd_hinmei] AS 'cd_hinmei' --品名コード
	--	        ,wkzaiko.[su_zaiko]  AS 'su_keisanzaiko' --計算在庫数
	--	    FROM wk_keisan_zaiko_sakusei wkzaiko 
	--	    WHERE
	--	        wkzaiko.[dt_hizuke] = DATEADD(day, -1, @hizuke_from)
	--	) zenjitsu_keisanzaiko
	--	ON ruikei.cd_hinmei = zenjitsu_keisanzaiko.cd_hinmei


	--	-- 計算対象日のカーソルを次の行へ
	--	FETCH NEXT FROM cursor_calendar INTO
	--		@cur_hizuke
	--END

 --   IF @@ERROR <> 0
 --   BEGIN
 --       SET @msg = 'error :#tmp_zaiko_keisan failed insert.'
 --       GOTO Error_Handling
 --   END

	--CLOSE cursor_calendar
	--DEALLOCATE cursor_calendar

	---- 計算在庫一時テーブルにインデックスを付与
	--CREATE NONCLUSTERED INDEX idx_zaiko ON #tmp_zaiko_keisan (dt_hizuke)

	---- 計算在庫一時テーブルから前日情報を削除
	----DELETE #tmp_zaiko_keisan
	----WHERE dt_hizuke = DATEADD(day, -1, @hizuke_from)

	---- ======================
	----  計算在庫トランの削除
	---- ======================
	--DELETE tr
	--	FROM tr_zaiko_keisan tr
	--	INNER JOIN (
	--		SELECT th.cd_hinmei
	--		FROM #tmp_hinmei th 
	--	) tmp_hin
	--	ON tr.cd_hinmei = tmp_hin.cd_hinmei
	--	WHERE tr.dt_hizuke BETWEEN @hizuke_from AND @hizuke_to

	--IF @@ERROR <> 0
	--BEGIN
 --       SET @msg = 'error :tr_zaiko_keisan failed delete.'
 --       GOTO Error_Handling
 --   END

	---- ======================
	----  計算在庫トランへ挿入
	---- ======================
	--INSERT INTO tr_zaiko_keisan (
	--	cd_hinmei
	--	,dt_hizuke
	--	,su_zaiko
	--	,dt_update
	--	,cd_update
	--)
	--SELECT
	--	tzk.cd_hinmei
	--	,tzk.dt_hizuke
	--	,tzk.su_zaiko
	--	--,GETUTCDATE()
	--	,@systemUtcDate
	--	,@cd_update
	--FROM
	--	#tmp_zaiko_keisan tzk 

 --   IF @@ERROR <> 0
 --   BEGIN
 --       SET @msg = 'error :tr_zaiko_keisan failed insert.'
 --       GOTO Error_Handling
 --   END

	---- ============================
	----  原資材計画管理トランの更新
	---- ============================
	---- 存在すればUPDATE、なければINSERT
	--MERGE INTO tr_genshizai_keikaku AS tr
	--	USING
	--		(SELECT DISTINCT tzk.cd_hinmei
	--		 FROM #tmp_zaiko_keisan tzk ) AS tmp
	--		--( SELECT tzk.cd_hinmei FROM #tmp_zaiko_keisan tzk
	--		--	WHERE EXISTS (SELECT tgk.cd_hinmei FROM tr_genshizai_keikaku tgk
	--		--		 WHERE tgk.cd_hinmei = tzk.cd_hinmei) ) AS tmp
	--		ON tr.cd_hinmei = tmp.cd_hinmei
	--	WHEN MATCHED THEN
	--		UPDATE SET tr.dt_zaiko_keisan = @hizuke_to
	--	WHEN NOT MATCHED THEN
	--		INSERT (cd_hinmei, dt_zaiko_keisan, dt_keikaku_nonyu)
	--		VALUES (tmp.cd_hinmei, @hizuke_to, NULL);

	--IF @@ERROR <> 0
	--BEGIN
	--	SET @msg = 'error :tr_genshizai_keikaku failed update.'
	--	GOTO Error_Handling
	--END

	---- 計算在庫ワークをクリア
	--DELETE wk_keisan_zaiko_sakusei
 --   IF @@ERROR <> 0
 --   BEGIN
 --       SET @msg = 'error :wk_keisan_zaiko_sakusei failed clear.'
 --       GOTO Error_Handling
 --   END

	----PRINT 'OK 計算在庫作成完了'
	--RETURN

	---- //////////// --
	----  エラー処理
	---- //////////// --
	--Error_Handling:
	--	CLOSE cursor_calendar
	--	DEALLOCATE cursor_calendar
	--	DELETE wk_keisan_zaiko_sakusei
	--	PRINT @msg

-- ========== ▲　2017.11.27 全面見直しのよりコメントアウト ▲ ======================
END
GO
