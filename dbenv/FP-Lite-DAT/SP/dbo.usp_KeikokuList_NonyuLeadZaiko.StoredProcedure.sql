IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KeikokuList_NonyuLeadZaiko') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KeikokuList_NonyuLeadZaiko]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:		tsujita.s
-- Create date: 2014.12.15
-- Last Update: 2017.11.27 cho.k 全面見直し
-- Description:	警告リスト作成
--   納入リードを加味した計算在庫の作成処理
-- =======================================================
CREATE PROCEDURE [dbo].[usp_KeikokuList_NonyuLeadZaiko]
	 @con_hizuke		DATETIME		-- 検索条件：計算開始日
	,@con_dt_end		DATETIME		-- 検索条件：計算末日
	,@con_kubun			varchar(1)		-- 検索条件：品区分
	,@con_bunrui		varchar(10)		-- 検索条件：分類
	,@con_kurabasho		varchar(10)		-- 検索条件：倉場所
	--,@con_hinmei		varchar(50)		-- 検索条件：品名/品名コード
	,@con_hinmei		nvarchar(50)	-- 検索条件：品名/品名コード
	,@lang				varchar(2)		-- ブラウザ言語
	,@cd_update 		VARCHAR(10)		-- 更新者：ログインユーザコード
	,@flg_shiyo			SMALLINT		-- 定数：未使用フラグ：使用
	,@flg_yotei			smallint		-- 定数：予実フラグ：予定：0
	,@flg_jisseki		smallint		-- 定数：予実フラグ：実績：1
	,@genryo			smallint		-- 定数：品区分：原料
	,@shizai			smallint		-- 定数：品区分：資材
	,@jikagenryo		smallint		-- 定数：品区分：自家原料
	,@cd_kg				varchar(2)		-- 定数：単位コード：Kg
	,@cd_li				varchar(2)		-- 定数：単位コード：L
	,@today				DATETIME		-- UTC時間で変換済みシステム日付
	,@kbn_zaiko_ryohin	SMALLINT		-- 定数：在庫区分：良品
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
	-- 最大リードタイム（使用予実トラン抽出用）
	DECLARE @max_leadtime DECIMAL(3,0)


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
		, dd_leadtime			DECIMAL(3,0)
	)
			

	-- 納入一時テーブル
	create table #tmp_nonyu (
		  flg_yojitsu	SMALLINT
		, cd_hinmei		VARCHAR(14) COLLATE database_default
		, dt_nonyu		DATETIME
		, su_nonyu		DECIMAL(12,6)
	)
	
	-- 納入一時テーブルサマリ
	create table #tmp_su_nonyu (
		  cd_hinmei		VARCHAR(14) COLLATE database_default
		, dt_nonyu		DATETIME
		, su_nonyu		DECIMAL(12,6)
	)
	
	-- 製品計画一時テーブル			
	create table #tmp_seihin (
		  cd_hinmei		VARCHAR(14) COLLATE database_default
		, dt_seizo		DATETIME
		, su_seizo		DECIMAL(12,6)
	)
		
	-- 使用予実一時テーブル
	create table #tmp_shiyo (
		flg_yojitsu		SMALLINT
		,cd_hinmei		VARCHAR(14) COLLATE database_default
		,dt_shiyo		DATETIME
		,su_shiyo		DECIMAL(12,6)
	)
	
	-- 使用予実一時テーブルサマリ
	create table #tmp_su_shiyo (
		  cd_hinmei		VARCHAR(14) COLLATE database_default
		, dt_shiyo		DATETIME
		, su_shiyo		DECIMAL(12,6)
	)	
	
	-- 調整一時テーブル			
	create table #tmp_chosei (
		cd_hinmei		VARCHAR(14) COLLATE database_default
		,dt_hizuke		DATETIME
		,su_chosei		DECIMAL(12,6)
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
		, COALESCE(hin.dd_leadtime, 0) AS dd_leadtime
	FROM (
		SELECT
			*
		FROM ma_hinmei ma
		WHERE ma.flg_mishiyo = @flg_shiyo
			AND ma.kbn_hin IN(@genryo, @shizai, @jikagenryo)
			AND (LEN(@con_kubun) = 0 OR ma.kbn_hin = @con_kubun)
			AND (LEN(@con_hinmei) = 0 OR
					(
					 (@lang = 'ja' AND ma.nm_hinmei_ja LIKE '%' + @con_hinmei + '%')
					 OR (@lang = 'en' AND ma.nm_hinmei_en LIKE '%' + @con_hinmei + '%')
					 OR (@lang = 'zh' AND ma.nm_hinmei_zh LIKE '%' + @con_hinmei + '%')
					 OR (@lang = 'vi' AND ma.nm_hinmei_vi LIKE '%' + @con_hinmei + '%')
					)
					OR ma.cd_hinmei LIKE '%' + @con_hinmei + '%'
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
	
	
	-- 一番大きな納入リードタイムを取得
	SET @max_leadtime = (SELECT MAX(dd_leadtime) FROM #tmp_hinmei)
	
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
		WHERE dt_nonyu BETWEEN @con_hizuke AND @con_dt_end
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
	  ON yotei.flg_yojitsu = @flg_yotei
	  AND yotei.cd_hinmei = base.cd_hinmei
	  AND yotei.dt_nonyu = base.dt_nonyu
	LEFT OUTER JOIN #tmp_nonyu jisseki
	  ON jisseki.flg_yojitsu = @flg_jisseki
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
			WHERE dt_seizo BETWEEN @con_hizuke AND @con_dt_end
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
	-- 一時使用予実トラン（リードタイム分過去に遡って取得する）
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
		WHERE dt_shiyo BETWEEN @con_hizuke AND DATEADD(day, @max_leadtime, @con_dt_end)
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
	  ON yotei.flg_yojitsu = @flg_yotei
	  AND yotei.cd_hinmei = base.cd_hinmei
	  AND yotei.dt_shiyo = base.dt_shiyo
	LEFT OUTER JOIN #tmp_shiyo jisseki
	  ON jisseki.flg_yojitsu = @flg_jisseki
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
		WHERE dt_hizuke BETWEEN @con_hizuke AND @con_dt_end
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
		WHERE dt_hizuke BETWEEN DATEADD(day, -1, @con_hizuke) AND DATEADD(day, -1, @con_dt_end)
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
		, DATEADD(day, -1, @con_hizuke) AS dt_hizuke
		, ROUND(COALESCE(zaiko_keisan.su_zaiko,0), 3, 1) AS su_zaiko
	FROM (
		SELECT cd_hinmei
		    , MAX(dt_hizuke) dt_hizuke
		FROM tr_zaiko_keisan
		WHERE dt_hizuke < @con_hizuke
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
			dt_hizuke BETWEEN @con_hizuke AND @con_dt_end


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
					WHEN hin.kbn_hin = @jikagenryo THEN COALESCE(seihin.su_seizo,0)
					ELSE COALESCE(nonyu.su_nonyu,0)
				  END AS su_nonyu
				, COALESCE(shiyo.su_shiyo,0) AS su_shiyo
				, COALESCE(chosei.su_chosei,0) AS su_chosei
				, COALESCE(zaiko.su_zaiko, zaiko_keisan.su_zaiko) AS su_zaiko_zen
			FROM #tmp_hinmei hin
			-- 納入数（原料・資材）
			LEFT OUTER JOIN #tmp_su_nonyu nonyu
			  ON nonyu.cd_hinmei = hin.cd_hinmei
			  AND nonyu.dt_nonyu = @cur_hizuke
			-- 製造数（自家原料）
			LEFT OUTER JOIN #tmp_seihin seihin
			  ON seihin.cd_hinmei = hin.cd_hinmei
			  AND seihin.dt_seizo = @cur_hizuke
			-- 使用数（リードタイム分前倒しで計算する。）
			LEFT OUTER JOIN #tmp_su_shiyo shiyo
			  ON shiyo.cd_hinmei = hin.cd_hinmei
			  AND shiyo.dt_shiyo = DATEADD(day, hin.dd_leadtime, @cur_hizuke)
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
	WHERE dt_hizuke = DATEADD(day, -1, @con_hizuke)

-- ======================================
--		【計算在庫削除】
-- ======================================
	DELETE tr
		FROM wk_zaiko_nonyu_lead tr
		INNER JOIN #tmp_hinmei tmp_hin
			ON tr.cd_hinmei = tmp_hin.cd_hinmei
		WHERE tr.dt_hizuke BETWEEN @con_hizuke AND @con_dt_end

	IF @@ERROR <> 0
	BEGIN
        SET @msg = 'error :wk_zaiko_nonyu_lead failed delete.'
        GOTO Error_Handling
    END

-- ======================================
--		【計算在庫登録】
-- ======================================
	INSERT INTO wk_zaiko_nonyu_lead (
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
        SET @msg = 'error :wk_zaiko_nonyu_lead failed insert.'
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
	---- 一番大きな納入リードタイム
	--DECLARE @max_leadtime	DECIMAL(3, 0)

	---- ====================
	----  一時テーブルの作成
	---- ====================
	---- 計算在庫一時テーブル
	--create table #tmp_zaiko_keisan (
	--	cd_hinmei			VARCHAR(14) COLLATE database_default
	--	,dt_hizuke			DATETIME
	--	,su_zaiko			DECIMAL(14, 6)
	--)

	---- 品マス一時テーブル
	--create table #tmp_hinmei (
	--	cd_hinmei		VARCHAR(14) COLLATE database_default
	--	,dd_leadtime	DECIMAL(3, 0)
	--	,cd_tani		VARCHAR(10) COLLATE database_default
	--	,wt_ko			DECIMAL(12, 6)
	--	,su_iri			DECIMAL(5, 0)
	--)

	---- 納入一時テーブル
	--create table #tmp_nonyu (
	--	flg_yojitsu		SMALLINT
	--	,dt_nonyu		DATETIME
	--	,cd_hinmei		VARCHAR(14) COLLATE database_default
	--	,su_nonyu		DECIMAL(9, 2)
	--	,su_nonyu_hasu	DECIMAL(9, 2)
	--)

	---- 使用予実一時テーブル
	--create table #tmp_shiyo (
	--	flg_yojitsu		SMALLINT
	--	,cd_hinmei		VARCHAR(14) COLLATE database_default
	--	,dt_shiyo		DATETIME
	--	,su_shiyo		DECIMAL(12, 6)
	--)			

	---- 調整一時テーブル
	--create table #tmp_chosei (
	--	cd_hinmei		VARCHAR(14) COLLATE database_default
	--	,dt_hizuke		DATETIME
	--	,su_chosei		DECIMAL(12, 6)
	--)

	---- 製品計画一時テーブル
	--create table #tmp_seihin (
	--	dt_seizo			DATETIME
	--	,cd_hinmei			VARCHAR(14) COLLATE database_default
	--	,su_seizo_yotei		DECIMAL(10, 0)
	--	,su_seizo_jisseki	DECIMAL(10, 0)
	--)

	--SET NOCOUNT ON

	---- ===========================
	----  一時テーブルへのコピー
	---- ===========================
	---- 品マス一時テーブルに有効なものを挿入
	--INSERT INTO #tmp_hinmei (cd_hinmei, dd_leadtime, cd_tani, wt_ko, su_iri)
	--SELECT HIN.cd_hinmei, COALESCE(HIN.dd_leadtime, 0) AS dd_leadtime
	--	,COALESCE(KONYU.cd_tani_nonyu, HIN.cd_tani_shiyo) AS cd_tani
	--	,COALESCE(KONYU.wt_nonyu, HIN.wt_ko) AS wt_ko
	--	,COALESCE(KONYU.su_iri, HIN.su_iri) AS su_iri
	--FROM (
	--	SELECT
	--		ma.cd_hinmei, ma.dd_leadtime, ma.su_iri, ma.cd_tani_shiyo, ma.wt_ko
	--	FROM
	--		ma_hinmei ma WITH(NOLOCK)
	--	WHERE (ma.kbn_hin = @genryo OR ma.kbn_hin = @shizai OR ma.kbn_hin = @jikagenryo)
	--	AND (LEN(@con_kubun) = 0 OR ma.kbn_hin = @con_kubun)
	--	AND ma.flg_mishiyo = @flg_shiyo
	--	AND (LEN(@con_hinmei) = 0 OR
	--			(
	--			 (@lang = 'ja' AND ma.nm_hinmei_ja LIKE '%' + @con_hinmei + '%')
	--			 OR (@lang = 'en' AND ma.nm_hinmei_en LIKE '%' + @con_hinmei + '%')
	--			 OR (@lang = 'zh' AND ma.nm_hinmei_zh LIKE '%' + @con_hinmei + '%')
	--			)
	--			OR ma.cd_hinmei LIKE '%' + @con_hinmei + '%'
	--		)
	--	AND (LEN(@con_bunrui) = 0 OR ma.cd_bunrui = @con_bunrui)
	--	AND (LEN(@con_kurabasho) = 0 OR ma.cd_kura = @con_kurabasho)
	--) HIN
	--INNER JOIN (
	--	SELECT no_juni_yusen, cd_hinmei, cd_tani_nonyu, wt_nonyu, su_iri
	--	FROM ma_konyu
	--	WHERE flg_mishiyo = @flg_shiyo
	--) KONYU
	--ON HIN.cd_hinmei = KONYU.cd_hinmei
	--AND KONYU.no_juni_yusen = ( SELECT
	--							MIN(ko.no_juni_yusen) AS no_juni_yusen
	--							 FROM ma_konyu ko WITH(NOLOCK)
	--							 WHERE ko.flg_mishiyo = @flg_shiyo
	--							 AND ko.cd_hinmei = HIN.cd_hinmei )
	----WHERE EXISTS (SELECT ko.cd_hinmei FROM ma_konyu ko WITH(NOLOCK)
	----				WHERE ko.flg_mishiyo = @flg_shiyo
	----				AND ko.cd_hinmei = HIN.cd_hinmei)
	----CREATE NONCLUSTERED INDEX idx_hin1 ON #tmp_hinmei (cd_hinmei)
	
	---- 一番大きな納入リードタイムを取得
	--SET @max_leadtime = (SELECT MAX(dd_leadtime) FROM #tmp_hinmei)
	

	---- 納入一時テーブルへ指定範囲の日付分コピー
	--INSERT INTO #tmp_nonyu (flg_yojitsu, dt_nonyu, cd_hinmei, su_nonyu, su_nonyu_hasu)
	----SELECT tr_n.flg_yojitsu, tr_n.dt_nonyu, tr_n.cd_hinmei, tr_n.su_nonyu, tr_n.su_nonyu_hasu
	----FROM (
	----	SELECT tn.flg_yojitsu, tn.dt_nonyu, tn.cd_hinmei, tn.su_nonyu, tn.su_nonyu_hasu
	----	FROM tr_nonyu tn WITH(NOLOCK)
	----	WHERE tn.dt_nonyu BETWEEN @con_hizuke AND @con_dt_end
	----) tr_n
	----INNER JOIN #tmp_hinmei hin WITH(NOLOCK)
	----ON hin.cd_hinmei = tr_n.cd_hinmei
	---- 前日以前は実績から、当日以降は予定から納入数を抽出する
 --   SELECT
 --       tnj.flg_yojitsu, tnj.dt_nonyu, tnj.cd_hinmei, tnj.su_nonyu, tnj.su_nonyu_hasu
 --   FROM tr_nonyu tnj WITH(NOLOCK)
 --   WHERE tnj.[dt_nonyu] BETWEEN @con_hizuke AND @con_dt_end
 --       AND tnj.[dt_nonyu] < @today
 --       AND tnj.[flg_yojitsu] = @flg_jisseki
 --   UNION ALL
 --   SELECT
 --       tny.flg_yojitsu, tny.dt_nonyu, tny.cd_hinmei, tny.su_nonyu, tny.su_nonyu_hasu
 --   FROM tr_nonyu tny WITH(NOLOCK)
 --   WHERE tny.[dt_nonyu] BETWEEN @con_hizuke AND @con_dt_end
 --       AND tny.[dt_nonyu] >= @today
 --       AND tny.[flg_yojitsu] = @flg_yotei
	--CREATE NONCLUSTERED INDEX idx_nonyu2 ON #tmp_nonyu (dt_nonyu)
	--CREATE NONCLUSTERED INDEX idx_nonyu3 ON #tmp_nonyu (cd_hinmei)

	---- 使用一時にコピー：最大納入リードタイム日数分、多めに取得
	--INSERT INTO #tmp_shiyo (
	--	flg_yojitsu, cd_hinmei, dt_shiyo, su_shiyo)
	--SELECT tsy.flg_yojitsu, tsy.cd_hinmei, tsy.dt_shiyo, tsy.su_shiyo
	--FROM tr_shiyo_yojitsu tsy 
	--WHERE tsy.dt_shiyo BETWEEN @con_hizuke AND DATEADD(day, @max_leadtime, @con_dt_end)
	----CREATE NONCLUSTERED INDEX idx_shi1 ON #tmp_shiyo (flg_yojitsu)
	--CREATE NONCLUSTERED INDEX idx_shi2 ON #tmp_shiyo (dt_shiyo)
	----CREATE NONCLUSTERED INDEX idx_shi3 ON #tmp_shiyo (cd_hinmei)

	---- 調整一時にコピー
	--INSERT INTO #tmp_chosei (cd_hinmei, dt_hizuke, su_chosei)
	--SELECT tr_c.cd_hinmei, tr_c.dt_hizuke, tr_c.su_chosei
	--FROM (
	--	SELECT tc.cd_hinmei, tc.dt_hizuke, tc.su_chosei
	--	FROM tr_chosei tc WITH(NOLOCK)
	--	WHERE tc.dt_hizuke BETWEEN @con_hizuke AND @con_dt_end
	--) tr_c
	--INNER JOIN #tmp_hinmei hin WITH(NOLOCK)
	--ON hin.cd_hinmei = tr_c.cd_hinmei
	--CREATE NONCLUSTERED INDEX idx_cho1 ON #tmp_chosei (dt_hizuke)
	--CREATE NONCLUSTERED INDEX idx_cho2 ON #tmp_chosei (cd_hinmei)

	---- 製品計画一時にコピー
	--INSERT INTO #tmp_seihin (dt_seizo, cd_hinmei, su_seizo_yotei, su_seizo_jisseki)
	--SELECT tr_s.dt_seizo, tr_s.cd_hinmei, tr_s.su_seizo_yotei, tr_s.su_seizo_jisseki
	--FROM (
	--	SELECT tkc.dt_seizo, tkc.cd_hinmei, tkc.su_seizo_yotei, tkc.su_seizo_jisseki
	--	FROM tr_keikaku_seihin tkc WITH(NOLOCK)
	--	WHERE tkc.dt_seizo BETWEEN @con_hizuke AND @con_dt_end
	--) tr_s
	--INNER JOIN #tmp_hinmei hin WITH(NOLOCK)
	--ON hin.cd_hinmei = tr_s.cd_hinmei
	--CREATE NONCLUSTERED INDEX idx_sei1 ON #tmp_seihin (dt_seizo)
	--CREATE NONCLUSTERED INDEX idx_sei2 ON #tmp_seihin (cd_hinmei)

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
	--DELETE wk_zaiko_nonyu_lead	-- 中身を一度クリア
	--WHERE dt_hizuke BETWEEN @con_hizuke AND @con_dt_end
 --   IF @@ERROR <> 0
 --   BEGIN
 --       SET @msg = 'error: wk_zaiko_nonyu_lead failed clear.'
 --       GOTO Error_Handling
 --   END
    
	---- 前日在庫の取得
	--INSERT INTO wk_zaiko_nonyu_lead (
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
	--FROM (
	--	SELECT cd_hinmei, dt_hizuke, su_zaiko, dt_update, cd_update
	--	FROM tr_zaiko_keisan WITH(NOLOCK)
	--	--WHERE dt_hizuke BETWEEN DATEADD(day, -1, @con_hizuke) AND @con_dt_end
	--	WHERE dt_hizuke = DATEADD(day, -1, @con_hizuke)
	--) zaiko
	---- 有効な品名コードのみ抽出
	--INNER JOIN #tmp_hinmei HIN
	--ON HIN.cd_hinmei = zaiko.cd_hinmei
	---- ワークの前日在庫から取得し、存在しない分だけ計算在庫トランより取得する
	---- ＃初日の前日在庫のみを取得するため
	--LEFT JOIN wk_zaiko_nonyu_lead wk
	--ON wk.cd_hinmei = zaiko.cd_hinmei
	--AND wk.dt_hizuke = zaiko.dt_hizuke --DATEADD(day, -1, zaiko.dt_hizuke)
	--WHERE wk.cd_hinmei IS NULL

 --   IF @@ERROR <> 0
 --   BEGIN
 --       SET @msg = 'error: wk_zaiko_keisan failed insert.'
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
	--		[dt_hizuke] BETWEEN @con_hizuke AND @con_dt_end


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
	--			+ COALESCE(ruikei.su_nonyu_ruikei, 0.00)
	--			- COALESCE(ruikei.su_chosei_ruikei, 0.00)
	--		    AS 'su_zaiko'  --計算在庫数
	--	FROM
	--	(
	--	    SELECT
	--	        ruikei_hinmei.cd_hinmei       AS 'cd_hinmei'        -- 品名コード

	--			-- 納入数のC/S換算対応(BIZ00009)：KgまたはL以外
	--			--,SUM(COALESCE(CASE WHEN COALESCE(mk.cd_tani_nonyu, mh.cd_tani_shiyo) = @cd_kg 
	--			--		OR COALESCE(mk.cd_tani_nonyu, mh.cd_tani_shiyo) = @cd_li
	--			--	THEN COALESCE(ruikei_meisai.su_nonyu, 0.00) * COALESCE(mk.wt_nonyu, mh.wt_ko) * COALESCE(mk.su_iri, mh.su_iri) 
	--			--		+ (COALESCE(ruikei_meisai.su_nonyu_hasu, 0.00) / 1000 )
	--			--	ELSE COALESCE(ruikei_meisai.su_nonyu, 0.00) * COALESCE(mk.wt_nonyu, mh.wt_ko) * COALESCE(mk.su_iri, mh.su_iri) 
	--			--		+ (COALESCE(ruikei_meisai.su_nonyu_hasu, 0.00) * COALESCE(mk.wt_nonyu, mh.wt_ko))
	--			--	END, 0.00))							AS 'su_nonyu_ruikei'   -- 納入数累計
	--			,SUM(
	--				COALESCE(
	--					-- 納入単位がＫｇかＬの時
	--					CASE WHEN ruikei_hinmei.cd_tani = @cd_kg OR ruikei_hinmei.cd_tani = @cd_li
	--					-- 使用単位　＝　納入単位(納入数)x１個の量×入数 ＋ 納入単位(端数)/1000
	--					THEN (COALESCE(ruikei_meisai.su_nonyu, 0.00) * ruikei_hinmei.wt_ko * ruikei_hinmei.su_iri)
	--						+ (COALESCE(ruikei_meisai.su_nonyu_hasu, 0.00) / 1000)
	--					-- それ以外（C/Sなど）の時
	--					ELSE
	--					-- 使用単位　＝　納入単位x１個の量x入数 ＋ 端数x１個の量
	--						(COALESCE(ruikei_meisai.su_nonyu, 0.00) * ruikei_hinmei.wt_ko * ruikei_hinmei.su_iri)
	--						+ (COALESCE(ruikei_meisai.su_nonyu_hasu, 0.00) * ruikei_hinmei.wt_ko)
	--					END
	--				, 0.00)
	--			 ) AS 'su_nonyu_ruikei'   -- 納入数累計

	--	        ,SUM(COALESCE(ruikei_meisai.su_shiyo, 0.00))  AS 'su_shiyo_ruikei'  -- 使用数累計
	--	        ,SUM(COALESCE(ruikei_meisai.su_chosei, 0.00)) AS 'su_chosei_ruikei' -- 調整数累計
	--	    FROM
	--			#tmp_hinmei ruikei_hinmei WITH(NOLOCK)

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
	--	            ,ruikei_meisai_hinmei.dt_hizuke                            AS 'dt_hizuke'
	--	        FROM (
	--				SELECT cal.dt_hizuke, hin.cd_hinmei, hin.dd_leadtime
	--				FROM #tmp_hinmei hin, ma_calendar cal WITH(NOLOCK)
	--				WHERE cal.dt_hizuke BETWEEN @con_hizuke AND @cur_hizuke
	--			) ruikei_meisai_hinmei

	--	        -- ■ 累計明細用納入予実(ruikei_meisai_nonyu_yojitsu)■
	--	        -- ■ 納入予実トラン(tr_nonyu)or 製造計画トランより、在庫計算開始日～末日の日付単位の納入数を抽出する■
	--	        -- ■ 前日以前は実績から、当日以降は予定から納入数を抽出する■
	--	        LEFT OUTER JOIN
	--	        (
	--	            SELECT
	--	                SUM(COALESCE(nonyu.su_nonyu, 0.00))      AS 'su_nonyu' --納入数
	--	                ,SUM(COALESCE(nonyu.su_nonyu_hasu, 0.00)) AS 'su_nonyu_hasu' --納入端数
	--	                ,nonyu.cd_hinmei AS 'cd_hinmei'
	--	                ,nonyu.dt_nonyu AS 'dt_nonyu'
	--	            FROM #tmp_nonyu nonyu WITH(NOLOCK)
	--	            WHERE
	--	                nonyu.dt_nonyu BETWEEN @con_hizuke AND @cur_hizuke
	--	            GROUP BY
	--	                nonyu.cd_hinmei, nonyu.dt_nonyu
	--	            UNION ALL
	--	            SELECT
	--	                SUM(COALESCE(ts.[su_seizo_yotei], 0)) AS 'su_nonyu' --製造予定数
	--	                ,0 -- 端数ダミー値(Sqlエラー回避用)
	--	                ,ts.cd_hinmei AS 'cd_hinmei'
	--	                ,ts.dt_seizo AS 'dt_nonyu'
	--	            FROM #tmp_seihin ts WITH(NOLOCK)
	--	            WHERE
	--	                ts.[dt_seizo] BETWEEN @con_hizuke AND @cur_hizuke
	--	                AND ts.[dt_seizo] >= @today
	--	            GROUP BY
	--	                ts.[dt_seizo], ts.cd_hinmei
	--	            UNION ALL
	--	            SELECT
	--	                SUM(COALESCE(ts2.su_seizo_jisseki, 0)) AS 'su_nonyu' --製造実績数
	--	                ,0 -- 端数ダミー値(Sqlエラー回避用)
	--	                ,ts2.cd_hinmei AS 'cd_hinmei'
	--	                ,ts2.dt_seizo AS 'dt_nonyu'
	--	            FROM #tmp_seihin ts2 WITH(NOLOCK)
	--	            WHERE
	--	                ts2.[dt_seizo] BETWEEN @con_hizuke AND @cur_hizuke
	--	                AND ts2.[dt_seizo] < @today
	--	            GROUP BY
	--	                ts2.[dt_seizo], ts2.cd_hinmei
	--	        ) ruikei_meisai_nonyu_yojitsu
	--	        ON ruikei_meisai_hinmei.cd_hinmei = ruikei_meisai_nonyu_yojitsu.cd_hinmei
	--	        AND ruikei_meisai_hinmei.dt_hizuke = ruikei_meisai_nonyu_yojitsu.dt_nonyu
	--	        -- ■ 累計明細用使用予実(ruikei_meisai_shiyo_yojitsu)■
	--	        -- ■ 使用予実トラン(tr_shiyo_yojitsu)より、在庫計算開始日～末日の日付単位の使用数を抽出する■
	--	        -- ■ 前日以前は実績から、当日以降は予定から使用数を抽出する■
	--	        LEFT OUTER JOIN
	--	        (
	--	        -- 納入リード日数分、後ろにずらして取得する
	--	            SELECT
	--	                SUM(COALESCE(shiyo.su_shiyo, 0.00))      AS 'su_shiyo' --使用数
	--	                ,shiyo.cd_hinmei AS 'cd_hinmei'
	--	                ,DATEADD(day, -(hinm.dd_leadtime), shiyo.dt_shiyo) AS 'dt_shiyo'
	--	            --FROM tr_shiyo_yojitsu shiyo WITH(NOLOCK)
	--	            FROM #tmp_shiyo shiyo WITH(NOLOCK)
	--	            INNER JOIN #tmp_hinmei hinm
	--	            ON hinm.cd_hinmei = shiyo.cd_hinmei
	--	            WHERE
	--	                --shiyo.dt_shiyo <= DATEADD(day, hinm.dd_leadtime, @cur_hizuke)
	--	                shiyo.dt_shiyo BETWEEN DATEADD(day, hinm.dd_leadtime, @con_hizuke) AND DATEADD(day, hinm.dd_leadtime, @cur_hizuke)
	--	                AND shiyo.dt_shiyo < @today
	--	                AND shiyo.flg_yojitsu = @flg_jisseki
	--	            GROUP BY
	--	                shiyo.cd_hinmei, shiyo.dt_shiyo, hinm.dd_leadtime
	--	            UNION ALL
	--	            SELECT
	--	                SUM(COALESCE(shiyo.su_shiyo, 0.00))      AS 'su_shiyo' --使用数
	--	                ,shiyo.cd_hinmei AS 'cd_hinmei'
	--	                ,DATEADD(day, -(hinm.dd_leadtime), shiyo.dt_shiyo) AS 'dt_shiyo'
	--	            --FROM tr_shiyo_yojitsu shiyo WITH(NOLOCK)
	--	            FROM #tmp_shiyo shiyo WITH(NOLOCK)
	--	            INNER JOIN #tmp_hinmei hinm
	--	            ON hinm.cd_hinmei = shiyo.cd_hinmei
	--	            WHERE
	--	                --shiyo.dt_shiyo <= DATEADD(day, hinm.dd_leadtime, @cur_hizuke)
	--	                shiyo.dt_shiyo BETWEEN DATEADD(day, hinm.dd_leadtime, @con_hizuke) AND DATEADD(day, hinm.dd_leadtime, @cur_hizuke)
	--	                AND shiyo.dt_shiyo >= @today
	--	                AND shiyo.flg_yojitsu = @flg_yotei
	--	            GROUP BY
	--	                shiyo.cd_hinmei, shiyo.dt_shiyo, hinm.dd_leadtime
	--	        ) ruikei_meisai_shiyo_yojitsu
	--	        ON ruikei_meisai_hinmei.cd_hinmei = ruikei_meisai_shiyo_yojitsu.cd_hinmei
	--	        AND ruikei_meisai_hinmei.dt_hizuke = ruikei_meisai_shiyo_yojitsu.dt_shiyo
	--	        -- ■ 累計明細用調整(ruikei_meisai_chosei)■
	--	        -- ■ 調整トラン(tr_chosei)より、在庫計算開始日～末日かつ前日以前の日付単位の調整数を抽出する■
	--	        LEFT OUTER JOIN
	--	        (
	--	            SELECT
	--	                SUM(COALESCE(tc.[su_chosei], 0.00))      AS 'su_chosei' --調整数
	--	                ,tc.cd_hinmei AS 'cd_hinmei'
	--	                ,tc.dt_hizuke AS 'dt_hizuke'
	--	            FROM #tmp_chosei tc WITH(NOLOCK)
	--	            --FROM tr_chosei tc WITH(NOLOCK)
	--	            WHERE
	--	                tc.[dt_hizuke] BETWEEN @con_hizuke AND @cur_hizuke
	--	                --AND tc.[dt_hizuke] < @today
	--	            GROUP BY
	--	                tc.cd_hinmei, tc.dt_hizuke
	--	        ) ruikei_meisai_chosei
	--	        ON ruikei_meisai_hinmei.cd_hinmei = ruikei_meisai_chosei.cd_hinmei
	--	        AND ruikei_meisai_hinmei.dt_hizuke = ruikei_meisai_chosei.dt_hizuke
	--	    ) ruikei_meisai
	--	    -- ■ 累計の対象は、前日以前で直近の実在庫が存在する日付の翌日からその日付までとする■
	--	    ON ruikei_hinmei.cd_hinmei = ruikei_meisai.cd_hinmei
	--	    AND ruikei_meisai.dt_hizuke > COALESCE((SELECT MAX(tz.[dt_hizuke])
	--	                                FROM [tr_zaiko] tz WITH(NOLOCK)
	--	                                WHERE tz.[dt_hizuke] >= @con_hizuke
	--	                                AND tz.[dt_hizuke] <= @cur_hizuke
	--	                                AND tz.[dt_hizuke] <= @today
	--	                                AND tz.cd_hinmei = ruikei_hinmei.cd_hinmei), 0)

	--	 --   -- 品名マスタを結合
	--	 --   LEFT OUTER JOIN (
	--		--	SELECT mh.cd_hinmei, mh.cd_tani_shiyo, mh.wt_ko, mh.su_iri
	--		--	FROM ma_hinmei mh WITH(NOLOCK)
	--		--	WHERE (mh.kbn_hin = @genryo OR mh.kbn_hin = @shizai OR mh.kbn_hin = @jikagenryo)
	--		--	AND mh.flg_mishiyo = @flg_shiyo
	--	 --   ) mh
	--	 --   ON mh.cd_hinmei = ruikei_meisai.cd_hinmei
		    
	--	 --   -- 購入先マスタを結合
	--		--LEFT OUTER JOIN (
	--		--	SELECT mk.no_juni_yusen, mk.cd_hinmei, mk.cd_tani_nonyu, mk.wt_nonyu, mk.su_iri
	--		--	FROM ma_konyu mk WITH(NOLOCK)
	--		--	WHERE mk.flg_mishiyo = @flg_shiyo
	--		--) mk
	--		--ON mk.cd_hinmei = ruikei_meisai.cd_hinmei
	--		--AND mk.no_juni_yusen = ( SELECT
	--		--							MIN(ko.no_juni_yusen) AS no_juni_yusen
	--		--						 FROM ma_konyu ko WITH(NOLOCK)
	--		--						 WHERE ko.flg_mishiyo = @flg_shiyo
	--		--						 AND ko.cd_hinmei = ruikei_meisai.cd_hinmei )

	--	    GROUP BY ruikei_hinmei.cd_hinmei
	--	) ruikei

	--	-- ■ 直近実在庫情報■
	--	-- ■ 日付毎に、前日以前で直近の実在庫情報を抽出する■
	--	LEFT OUTER JOIN
	--	(
	--	    SELECT
	--	        tz.[dt_hizuke]  AS 'dt_hizuke' --日付
	--	        ,SUM(tz.[su_zaiko])  AS 'su_jitsuzaiko' --実在庫数
	--	        ,tz.cd_hinmei   AS 'cd_hinmei'
	--	    FROM
	--	        [tr_zaiko] tz WITH(NOLOCK)
	--	    WHERE
	--	        tz.[dt_hizuke] BETWEEN @con_hizuke AND @cur_hizuke
	--	        AND tz.[dt_hizuke] <= @today
	--	        AND tz.kbn_zaiko = @kbn_zaiko_ryohin
	--	    GROUP BY
	--			tz.[dt_hizuke], tz.cd_hinmei
	--	) chokkin_jitsuzaiko
	--	ON ruikei.cd_hinmei = chokkin_jitsuzaiko.cd_hinmei
	--	AND chokkin_jitsuzaiko.dt_hizuke = (SELECT MAX(tzmax.[dt_hizuke]) AS dt_hizuke
	--	                                    FROM [tr_zaiko] tzmax WITH(NOLOCK)
	--										WHERE tzmax.cd_hinmei = ruikei.cd_hinmei
	--										AND tzmax.[dt_hizuke] BETWEEN @con_hizuke AND @cur_hizuke
	--	                                    AND tzmax.[dt_hizuke] <= @today)

	--	-- ■ 算出開始日前日計算在庫情報(zenjitsu_keisanzaiko)■
	--	LEFT OUTER JOIN
	--	(
	--	    SELECT
	--	        tzk.[cd_hinmei] AS 'cd_hinmei' --品名コード
	--	        ,tzk.[su_zaiko]  AS 'su_keisanzaiko' --計算在庫数
	--	    --FROM tr_zaiko_keisan tzk WITH(NOLOCK)
	--	    FROM wk_zaiko_nonyu_lead tzk WITH(NOLOCK)
	--	    WHERE tzk.[dt_hizuke] < @cur_hizuke
	--	    AND tzk.[dt_hizuke] = DATEADD(day, -1, @con_hizuke)
	--	) zenjitsu_keisanzaiko
	--	ON ruikei.cd_hinmei = zenjitsu_keisanzaiko.cd_hinmei


	--	IF @@ERROR <> 0
	--	BEGIN
	--		SET @msg = 'error :#tmp_zaiko_keisan failed insert. ' + CONVERT(VARCHAR, @cur_hizuke)
	--		GOTO Error_Handling
	--	END


	--	-- 計算対象日のカーソルを次の行へ
	--	FETCH NEXT FROM cursor_calendar INTO
	--		@cur_hizuke
	--END

	--CLOSE cursor_calendar
	--DEALLOCATE cursor_calendar
	
	---- 計算在庫一時テーブルにインデックスを付与
	----CREATE NONCLUSTERED INDEX idx_zaiko ON #tmp_zaiko_keisan (dt_hizuke)


	---- =======================================
	----  計算在庫ワークの更新：delete > insert
	---- =======================================
	---- 前日在庫を取得する手前でDELETEしてるのでコメントアウト
	----DELETE wk
	----	FROM (
	----		SELECT cd_hinmei, dt_hizuke
	----		FROM wk_zaiko_nonyu_lead
	----		WHERE dt_hizuke BETWEEN @con_hizuke AND @con_dt_end
	----	) wk
	----	INNER JOIN (
	----		SELECT cd_hinmei
	----		FROM #tmp_hinmei
	----	) tmp_hin
	----	ON wk.cd_hinmei = tmp_hin.cd_hinmei
	----	--WHERE wk.dt_hizuke BETWEEN @con_hizuke AND @con_dt_end

	----IF @@ERROR <> 0
	----BEGIN
 ----       SET @msg = 'error: wk_zaiko_nonyu_lead failed delete.'
 ----       GOTO Error_Handling
 ----   END

	--INSERT INTO wk_zaiko_nonyu_lead (
	--	cd_hinmei
	--	,dt_hizuke
	--	,su_zaiko
	--	,dt_update
	--	,cd_update
	--)
	--SELECT
	--	cd_hinmei
	--	,dt_hizuke
	--	,su_zaiko
	--	,GETUTCDATE()
	--	,@cd_update
	--FROM
	--	#tmp_zaiko_keisan

 --   IF @@ERROR <> 0
 --   BEGIN
 --       SET @msg = 'error: wk_zaiko_nonyu_lead failed insert.'
 --       GOTO Error_Handling
 --   END

	----PRINT 'OK 計算在庫の再計算完了'
	--RETURN

	---- //////////////////////// --
	----   エラー処理
	---- //////////////////////// --
	--Error_Handling:
	--	DELETE wk_zaiko_nonyu_lead
	--	CLOSE cursor_calendar
	--	DEALLOCATE cursor_calendar
	--	PRINT @msg
-- ========== ▲　2017.11.27 全面見直しのよりコメントアウト ▲ ======================

END
GO
