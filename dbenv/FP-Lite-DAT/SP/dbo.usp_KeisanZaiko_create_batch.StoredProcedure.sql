IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KeisanZaiko_create_batch') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KeisanZaiko_create_batch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =======================================================
-- Author:		nakamura.r
-- Create date: 2019.05.27
-- Last Update: 2019.11.15 takaki.r
-- Description:	計算在庫作成
--   計算在庫トランの計算と更新処理
--   (バッチ起動)
-- 2019.11.15: 計算在庫数がNULLで登録されないよう修正
-- =======================================================
CREATE PROCEDURE [dbo].[usp_KeisanZaiko_create_batch]
	 @cd_update 		VARCHAR(10)		-- 更新者：SYSTEM
	,@flg_shiyo			SMALLINT		-- 定数：未使用フラグ：使用
	,@flg_yojitsu_yo 	SMALLINT		-- 定数：予実フラグ：予定
	,@flg_yojitsu_ji 	SMALLINT		-- 定数：予実フラグ：実績
	,@kbn_hin_genryo 	SMALLINT		-- 定数：品区分：原料
	,@kbn_hin_shizai 	SMALLINT		-- 定数：品区分：資材
	,@kbn_hin_jikagen 	SMALLINT		-- 定数：品区分：自家原料
	,@cd_kg				varchar(2)		-- 定数：単位コード：Kg
	,@cd_li				varchar(2)		-- 定数：単位コード：L
	,@kbn_zaiko_ryohin	SMALLINT		-- 定数：在庫区分：良品
	,@kikan_from		SMALLINT		-- 定数：対象期間：～ヶ月
	,@kikan_to			SMALLINT		-- 定数：対象期間：～ヶ月
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
	-- シンガポールの日取得
	DECLARE @today	DATETIME = CONVERT(DATETIME,CONVERT(VARCHAR,GETDATE(),111) + ' 10:00')

	--対象日時取得
	DECLARE @hizuke_from DATETIME = DATEADD(mm,@kikan_from,@today)
	DECLARE @hizuke_to DATETIME = DATEADD(mm,@kikan_to,@today)


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
	
	RETURN 0

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
		RETURN 1


END



GO
