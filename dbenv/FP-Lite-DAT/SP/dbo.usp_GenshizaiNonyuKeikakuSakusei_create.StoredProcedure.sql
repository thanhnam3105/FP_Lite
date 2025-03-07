IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiNonyuKeikakuSakusei_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiNonyuKeikakuSakusei_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:		tsujita.s
-- Create date: 2013.12.13
-- Last Update: 2016.05.20 motojima.m
-- Description:	原資材納入計画作成：変動計算処理
-- =======================================================
CREATE PROCEDURE [dbo].[usp_GenshizaiNonyuKeikakuSakusei_create]
	@hizuke_from			DATETIME		-- 検索条件：変動計算初日
	,@hizuke_to				DATETIME		-- 検索条件：変動計算末日
	,@con_hinmei			VARCHAR(14)		-- 検索条件：品名コード
	,@flg_shiyo				SMALLINT		-- 定数：未使用フラグ：使用
	,@flg_heijitsu			SMALLINT		-- 定数：休日フラグ：平日
	,@flg_yojitsu_yo 		SMALLINT		-- 定数：予実フラグ：予定
	,@flg_yojitsu_ji 		SMALLINT		-- 定数：予実フラグ：実績
	,@saiban_kubun 			VARCHAR(2)		-- 定数：採番区分：納入番号
	,@saiban_prefix 		VARCHAR(1)		-- 定数：プリフィクス：納入番号
	,@kbn_ksys_denso 		SMALLINT		-- 定数：KSYS伝送区分：伝送対象外
	,@flg_mikakutei 		SMALLINT		-- 定数：確定フラグ：未確定
	,@kbn_hin_genryo 		SMALLINT		-- 定数：品区分：原料
	,@kbn_hin_shizai 		SMALLINT		-- 定数：品区分：資材
	,@cd_update 			VARCHAR(10)		-- 更新者：ログインユーザコード
	,@leadtime 				DECIMAL(3,0)	-- 任意の納入リードタイム日数
	,@cd_kg					VARCHAR(2)		-- 定数：単位コード：Kg
	,@cd_li					VARCHAR(2)		-- 定数：単位コード：L
	,@utc_sysdate			DATETIME		-- UTCシステム日付
AS
BEGIN

	-- 変数リスト
	DECLARE @msg			VARCHAR(100)	-- 処理結果メッセージ格納用
	DECLARE @no_nonyu		VARCHAR(13)		-- 納入番号
	DECLARE	@con_dt_start	DATETIME		-- 計算在庫の計算用検索開始日
	DECLARE @hachu_tani		DECIMAL(12,6)	-- 発注単位数
	DECLARE @kasan_zaiko	DECIMAL(12,6)	-- 加算在庫数
	DECLARE @su_nonyu		DECIMAL(12,6)	-- 算出された納入数
	DECLARE @su_nonyu_hasu	DECIMAL(12,6)	-- 算出された納入端数
	DECLARE @chk_su_shiyo	DECIMAL(20,10)	-- チェック用使用数
	DECLARE @skip_code		VARCHAR(4200) = ''	-- 飛ばしたコード。MAX300品分(300*14)
	-- カーソル用の変数リスト
	DECLARE @cur_hizuke		DATETIME	-- 日付
	-- 計算在庫カーソル用の変数リスト
	DECLARE @cur_cd_hinmei	VARCHAR(14)
	DECLARE @cur_dt_nonyu	DATETIME		-- 納入日(検索開始日)
	DECLARE @cur_dt_zaiko	DATETIME		-- 製造日(検索末日)
	DECLARE @cur_su_zaiko	DECIMAL(14,6)	-- 在庫数
	DECLARE @cur_zaiko_min	DECIMAL(14,6)	-- 最低在庫数
	DECLARE @cur_su_iri		DECIMAL(5,0)	-- 入数
	DECLARE @cur_wt_ko		DECIMAL(12,6)	-- 重量
	DECLARE	@cur_leadtime	DECIMAL(3,0)	-- 納入リードタイム
	DECLARE @cur_lot_size	DECIMAL(7,2)	-- 発注ロットサイズ
	DECLARE @cur_tanka		DECIMAL(12,4)	-- 納入単価
	DECLARE @cur_date_new	DATETIME		-- 新単価切替日
	DECLARE @cur_tanka_new	DECIMAL(12,4)	-- 新納入単価
	DECLARE @cur_kbn_zei	SMALLINT		-- 税区分
	DECLARE @cur_torihiki	VARCHAR(13)		-- 取引先コード
	DECLARE @cur_torihiki2	VARCHAR(13)		-- 取引先コード2
	-- 納入日の有効チェック用変数
	DECLARE @kyujitsu_count DECIMAL(4,0)	-- 休日カウント
	DECLARE @check_kotei	DATETIME		-- チェック用固定日

	-- デバッグ用変数
	--DECLARE @debug_cd VARCHAR(100)
	--DECLARE @debug_su DECIMAL(20,10)
	--DECLARE @debug_dt DATETIME

	-- ====================
	--  一時テーブルの作成
	-- ====================
	-- 最低在庫を切る計算在庫情報とそれに対する納入日
	CREATE TABLE #tmp_zaiko_min (
		cd_hinmei			VARCHAR(14)
		,dt_hizuke			DATETIME
		,su_zaiko			DECIMAL(14,6)
		,dt_nonyu			DATETIME	-- 納入日
		,cd_torihiki		VARCHAR(13)
		,cd_torihiki2		VARCHAR(13)
		,su_zaiko_min		DECIMAL(14,6)
		,su_iri				DECIMAL(12,6)
		,wt_ko				DECIMAL(12,6)
		,leadtime			DECIMAL(3,0)
		,hachu_lot_size		DECIMAL(7,2)
		,tan_nonyu_ko		DECIMAL(12,4)
		,dt_tanka_new		DATETIME
		,tan_nonyu_new		DECIMAL(12,4)
		,kbn_zei			SMALLINT
		,tan_nonyu_hin		DECIMAL(12,4)
	)

	-- 納入予実トラン一時テーブル
	CREATE TABLE #tmp_tr_nonyu (
		no_nonyu		VARCHAR(13)
		,dt_nonyu		DATETIME
		,cd_hinmei		VARCHAR(14)
		,su_nonyu		DECIMAL(9,2)
		,su_nonyu_hasu	DECIMAL(9,2)
		,cd_torihiki	VARCHAR(13)
		,cd_torihiki2	VARCHAR(13)
		,tan_nonyu		DECIMAL(12,4)
		,kbn_zei		SMALLINT
		,dt_seizo		DATETIME
		,kasan_zaiko	DECIMAL(14,6)
	)

	-- 対象の品名マスタ一時テーブル
	CREATE TABLE #target_hinmei (
		cd_hinmei		VARCHAR(14)
		,dt_kotei		DATETIME
	)			

	-- SKIP対象の品名コード一時テーブル
	CREATE TABLE #skip_hinmei (
		cd_hinmei		VARCHAR(14)
	)			

	-- ===================================
	--  性能改善対策：一時テーブルの作成
	-- ===================================
	-- 納入一時テーブル
	CREATE TABLE #tmp_nonyu_tbl (
		dt_nonyu		DATETIME
		,cd_hinmei		VARCHAR(14)
		,su_nonyu		DECIMAL(9,2)
		,su_nonyu_hasu	DECIMAL(9,2)
	)
	-- 使用予実一時テーブル
	CREATE TABLE #tmp_shiyo_tbl (
		cd_hinmei		VARCHAR(14)
		,dt_shiyo		DATETIME
		,su_shiyo		DECIMAL(12,6)
	)


	-- 変数の初期化
	SET @kyujitsu_count = 0
	IF @con_hinmei IS NULL
	BEGIN
		SET @con_hinmei = ''
	END

	SET NOCOUNT ON

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
		WHERE dt_nonyu BETWEEN @hizuke_from AND @hizuke_to
		AND flg_yojitsu = @flg_yojitsu_yo
		GROUP BY cd_hinmei, dt_nonyu
	) tr
	ON tr.cnt > 1
	AND ma.cd_hinmei = tr.cd_hinmei
	WHERE (LEN(@con_hinmei) = 0 OR ma.cd_hinmei = @con_hinmei)
	AND (ma.kbn_hin = @kbn_hin_genryo OR ma.kbn_hin = @kbn_hin_shizai)
	AND ma.flg_mishiyo = @flg_shiyo
	GROUP BY ma.cd_hinmei


	-- 対象の品名マスタ一時テーブルに有効なものを挿入
	INSERT INTO #target_hinmei (cd_hinmei, dt_kotei)
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
		WHERE dt_hizuke BETWEEN @utc_sysdate AND @hizuke_to
		AND flg_kyujitsu = @flg_shiyo
	) KOTEI
	ON KOTEI.no_kotei = HIN.dd_kotei
	WHERE KOTEI.dt_kotei IS NOT NULL	-- 固定日外(dt_koteiが計算末日より未来)＝対象外なので、抽出しない
	AND sk.cd_hinmei IS NULL			-- 同日に同品名の納入予定が複数件あるものは取得しない
	CREATE NONCLUSTERED INDEX idx_hin1 ON #target_hinmei (cd_hinmei)

    -- 原資材納入計画は未来しか処理しないので実績は取得しない
	-- 使用一時にコピー
	INSERT INTO #tmp_shiyo_tbl (cd_hinmei, dt_shiyo, su_shiyo)
	SELECT cd_hinmei, dt_shiyo, su_shiyo
	FROM tr_shiyo_yojitsu
	WHERE dt_shiyo BETWEEN @hizuke_from AND @hizuke_to
	AND flg_yojitsu = @flg_yojitsu_yo
	CREATE NONCLUSTERED INDEX idx_shi2 ON #tmp_shiyo_tbl (dt_shiyo)
	CREATE NONCLUSTERED INDEX idx_shi3 ON #tmp_shiyo_tbl (cd_hinmei)
	
	-- 納入一時テーブルへ指定範囲の日付分コピー
	-- 固定日以内は計画を立てなおさないので計算在庫に反映させる
	INSERT INTO #tmp_nonyu_tbl (dt_nonyu, cd_hinmei, su_nonyu, su_nonyu_hasu)
    SELECT tny.dt_nonyu, tny.cd_hinmei, tny.su_nonyu, tny.su_nonyu_hasu
	FROM (
		SELECT
			flg_yojitsu, dt_nonyu, cd_hinmei, su_nonyu, su_nonyu_hasu
		FROM tr_nonyu tny WITH(NOLOCK)
	    WHERE dt_nonyu BETWEEN @hizuke_from AND @hizuke_to
	    AND flg_yojitsu = @flg_yojitsu_yo
	) tny
	INNER JOIN #target_hinmei hin
	ON tny.cd_hinmei = hin.cd_hinmei
	WHERE tny.dt_nonyu <= hin.dt_kotei
	CREATE NONCLUSTERED INDEX idx_nonyu2 ON #tmp_nonyu_tbl (dt_nonyu)
	CREATE NONCLUSTERED INDEX idx_nonyu3 ON #tmp_nonyu_tbl (cd_hinmei)

	-- SKIP対象の品名コードを変数にカンマ区切りで設定
	SELECT
		@skip_code = CASE @skip_code
			   WHEN '' THEN sk.cd_hinmei
			   ELSE @skip_code + ', ' + sk.cd_hinmei
			   END
	FROM
		#skip_hinmei sk
	-- 変数への設定が終わったらSKIP一時テーブルを削除
	DROP TABLE #skip_hinmei


	-- ================
	-- ================
	--  指定期間の抽出
	-- ================
	-- ================
	DECLARE cursor_kikan CURSOR FOR
		SELECT
			dt_hizuke
		FROM ma_calendar WITH(NOLOCK)
		WHERE dt_hizuke BETWEEN @hizuke_from AND @hizuke_to

	-- ==================================
	--  ■ 指定期間のカーソルスタート ■
	-- ==================================
	OPEN cursor_kikan
		IF (@@error <> 0)
		BEGIN
		    SET @msg = 'CURSOR OPEN ERROR: cursor_kikan'
		    GOTO Error_Handling
		END

	FETCH NEXT FROM cursor_kikan INTO
		@cur_hizuke

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- =============================
		--  計算在庫ワーク情報の取得
		-- =============================
		-- 最低在庫を下回っていれば取得する
		INSERT INTO #tmp_zaiko_min (
			cd_hinmei
			,dt_hizuke
			,su_zaiko
			,dt_nonyu
			,cd_torihiki
			,cd_torihiki2
			,su_zaiko_min
			,su_iri
			,wt_ko
			,leadtime
			,hachu_lot_size
			,tan_nonyu_ko
			,dt_tanka_new
			,tan_nonyu_new
			,kbn_zei
			,tan_nonyu_hin
		)
		SELECT
			zaiko.cd_hinmei AS cd_hinmei
			,zaiko.dt_hizuke AS dt_hizuke
			,COALESCE(zaiko.su_zaiko, 0.00) AS su_zaiko

			-- 納入日を取得
			-- 在庫が切れる日を起点に、任意のリードタイムの日数分過去の日付を取得 ※休日は除く
			-- ※※ 2014/01/08時点で@leadtimeは「0」固定 ※※
			-- 　今後、XX日前に納入したいという要望が出たときに対応しやすくするため。
			--,(SELECT MAX(dt_hizuke) AS dt_nonyu
			--	FROM ma_calendar WITH(NOLOCK)
			--	WHERE
			--	dt_hizuke BETWEEN @hizuke_from AND DATEADD(day, -(@leadtime), @cur_hizuke)
			--	AND flg_kyujitsu = @flg_heijitsu
			--) AS dt_nonyu
			-- 在庫が切れる日を起点に、任意のリードタイムの日数分過去の日付を取得 ※休日は除かない
			,DATEADD(day, -(@leadtime), @cur_hizuke) AS dt_nonyu

			,ma.cd_torihiki AS cd_torihiki
			,ma.cd_torihiki2 AS cd_torihiki2
			,ma.su_zaiko_min AS su_zaiko_min
			,ma.su_iri AS su_iri
			,ma.wt_ko AS wt_ko
			,ma.leadtime AS leadtime
			,ma.hachu_lot_size AS hachu_lot_size
			,ma.tan_nonyu_ko AS tan_nonyu_ko
			,ma.dt_tanka_new AS dt_tanka_new
			,ma.tan_nonyu_new AS tan_nonyu_new
			,ma.kbn_zei AS kbn_zei
			,ma.tan_nonyu_hin AS tan_nonyu_hin
		FROM
			wk_zaiko_keisan zaiko WITH(NOLOCK)
		INNER JOIN (
			SELECT
				HIN.cd_hinmei
				,COALESCE(KONYU.cd_torihiki, '') AS cd_torihiki
				,COALESCE(KONYU.cd_torihiki2, '') AS cd_torihiki2
				,COALESCE(HIN.su_zaiko_min, 0.00) AS su_zaiko_min
				,CASE WHEN KONYU.su_iri > 0 THEN KONYU.su_iri
				 ELSE HIN.su_iri END AS su_iri
				,CASE WHEN KONYU.wt_nonyu > 0 THEN KONYU.wt_nonyu
				 ELSE HIN.wt_ko END AS wt_ko
				,COALESCE(KONYU.su_leadtime, HIN.dd_leadtime, 0) AS leadtime
				,CASE WHEN KONYU.su_hachu_lot_size > 0 THEN KONYU.su_hachu_lot_size
				 ELSE HIN.su_hachu_lot_size END AS hachu_lot_size
				,KONYU.tan_nonyu AS tan_nonyu_ko
				,KONYU.dt_tanka_new AS dt_tanka_new
				,KONYU.tan_nonyu_new AS tan_nonyu_new
				,COALESCE(HIN.kbn_zei, 0) AS kbn_zei
				,HIN.tan_nonyu AS tan_nonyu_hin
			FROM (
				SELECT
					ma.cd_hinmei
					,su_zaiko_min
					,su_iri
					,wt_ko
					,dd_leadtime
					,su_hachu_lot_size
					,kbn_zei
					,tan_nonyu
				FROM ma_hinmei ma WITH(NOLOCK)
				INNER JOIN #target_hinmei tmp_hin
				ON tmp_hin.cd_hinmei = ma.cd_hinmei
			) HIN

			-- 優先順位が一番高い原資材購入先マスタ
			INNER JOIN ma_konyu KONYU
			ON KONYU.cd_hinmei = HIN.cd_hinmei
			AND KONYU.no_juni_yusen = (
					SELECT
						MIN(ko.no_juni_yusen) AS no_juni_yusen
					--FROM ma_konyu ko WITH(NOLOCK)
					FROM ma_konyu ko
					WHERE ko.cd_hinmei = HIN.cd_hinmei
					AND ko.flg_mishiyo = @flg_shiyo
				)

			-- 購入先マスタ、品名マスタのどちらかの
			-- 重量、入数、発注ロットサイズが0以上のものを抽出
			WHERE (KONYU.su_iri > 0 OR HIN.su_iri > 0)
			AND (KONYU.wt_nonyu > 0 OR HIN.wt_ko > 0)
			AND (KONYU.su_hachu_lot_size > 0 OR HIN.su_hachu_lot_size > 0)
		) ma
		ON ma.cd_hinmei = zaiko.cd_hinmei

		-- 指定日に使用予定があるレコードのみ抽出する
		INNER JOIN (
			SELECT
				cd_hinmei
				,dt_shiyo
				,MAX(su_shiyo) AS su_shiyo
			FROM
				#tmp_shiyo_tbl
			WHERE
				dt_shiyo = @cur_hizuke
				--AND flg_yojitsu = @flg_yojitsu_yo
				AND su_shiyo > 0
			GROUP BY
				cd_hinmei, dt_shiyo
		) shiyo
		ON shiyo.cd_hinmei = zaiko.cd_hinmei

		WHERE
			zaiko.dt_hizuke = @cur_hizuke
		AND DATEADD(day, COALESCE(ma.leadtime, 0), @hizuke_from) <= @cur_hizuke
		-- 最低在庫を下回るものを抽出
		--AND COALESCE(zaiko.su_zaiko, 0.00) < ma.su_zaiko_min
		AND COALESCE(zaiko.su_zaiko, 0.00) < COALESCE(ma.su_zaiko_min, 0.00)

		IF @@ERROR <> 0
		BEGIN
			SET @msg = 'error: tmp_zaiko_min failed insert.'
			GOTO Error_Handling
		END
		
		-- ==============================
		--  計算在庫ワークの更新と再計算
		-- ==============================
		DECLARE cursor_keisan CURSOR FOR
			SELECT
				cd_hinmei
				,dt_nonyu
				,dt_hizuke
				,su_zaiko
				,su_zaiko_min
				,su_iri
				,wt_ko
				,leadtime
				,hachu_lot_size

				-- 納入単価の取得
				,CASE WHEN dt_tanka_new IS NOT NULL
					 -- 新単価切替日がNULLではない場合
					 THEN
						-- 納入日 >= 新単価切替日の場合：新納入単価を設定
						CASE WHEN dt_nonyu >= dt_tanka_new
							THEN tan_nonyu_new
							-- 上記以外：原資材購入先マスタの納入単価を設定
							ELSE tan_nonyu_ko
						END
					 -- 原資材購入先マスタの納入単価がNULLの場合、品名マスタの納入単価を設定する
					 ELSE COALESCE(tan_nonyu_ko, tan_nonyu_hin, 0)
				 END

				,kbn_zei
				,cd_torihiki
				,cd_torihiki2
			FROM #tmp_zaiko_min
			
		-- ==================================
		--  ■ 計算在庫のカーソルスタート ■
		-- ==================================
		OPEN cursor_keisan
			IF (@@error <> 0)
			BEGIN
			    SET @msg = 'CURSOR OPEN ERROR: cursor_keisan'
			    GOTO Error_Handling
			END

		FETCH NEXT FROM cursor_keisan INTO
			@cur_cd_hinmei
			,@cur_dt_nonyu
			,@cur_dt_zaiko
			,@cur_su_zaiko
			,@cur_zaiko_min
			,@cur_su_iri
			,@cur_wt_ko
			,@cur_leadtime
			,@cur_lot_size
			,@cur_tanka
			,@cur_kbn_zei
			,@cur_torihiki
			,@cur_torihiki2

		IF (@@error <> 0)
		BEGIN
			SET @msg = 'FETCH NEXT ERROR1: cursor_keisan'
			GOTO Error_Handling
		END

		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- ======================================
			--  納入日の再設定と納入日の有効チェック
			-- ======================================
			-- 納入日が存在しない場合、次のカーソルへ
			IF @cur_dt_nonyu IS NULL
				GOTO NEXT_cursor_keisan
			
			-- 納入リードタイムを加味した納入日を設定しなおす
			SET @cur_dt_nonyu = DATEADD(day, -(@cur_leadtime), @cur_dt_nonyu)
			
			-- 納入日～指定日までにある休日数を取得
			SET @kyujitsu_count = 0	-- 一度中身をクリアする
			SET @kyujitsu_count =
				( SELECT count(flg_kyujitsu) AS kyujitsu_count
					FROM ma_calendar
					WHERE dt_hizuke BETWEEN @cur_dt_nonyu AND @cur_hizuke
					AND flg_kyujitsu <> @flg_heijitsu
				)
			
			-- 休日を除いた営業日に対してリードタイム日数を引くため、休日カウント分さらに遡る
			-- 遡った日付が休日だった場合、さらに直近の営業日まで遡る
			-- ※納入リードタイムとは、納入してから使用できるまでにかかる日数のこと
			SET @cur_dt_nonyu =
				( SELECT MAX(dt_hizuke) AS dt_nonyu
					FROM ma_calendar WITH(NOLOCK)
					WHERE
						dt_hizuke BETWEEN @hizuke_from
						AND DATEADD(day, -(@kyujitsu_count), @cur_dt_nonyu)
					AND flg_kyujitsu = @flg_heijitsu
				)

			-- 納入日がシステム日付未満の場合、次のカーソルへ(納入が間に合わないので)
			IF @cur_dt_nonyu < @utc_sysdate
				GOTO NEXT_cursor_keisan
				
		-- /////// SAP連携：固定日を加味 ///////
			-- 固定日の取得
			SET @check_kotei = null	-- 一度中身をクリアする
			SET @check_kotei = (SELECT dt_kotei FROM #target_hinmei WHERE cd_hinmei = @cur_cd_hinmei)

			-- 納入日が固定日以内の場合、次のカーソルへ(固定日内は納入しない)
			IF @cur_dt_nonyu <= @check_kotei
				GOTO NEXT_cursor_keisan
		-- /////// SAP連携：ここまで ///////

			-- ========================
			--  納入数の取得
			-- ========================
			-- // 一度中身をクリアする //
			SET @hachu_tani = 0.00
			SET @kasan_zaiko = 0.00
			SET @su_nonyu = 0.00
			SET @su_nonyu_hasu = 0.00

			-- デバッグ用
			--PRINT '情報'
			--PRINT @cur_cd_hinmei
			--PRINT @cur_dt_nonyu
			--PRINT @cur_su_zaiko
			--PRINT @cur_zaiko_min
			--PRINT @cur_dt_zaiko

			--PRINT '重量など'
			--PRINT @cur_wt_ko
			--PRINT @cur_su_iri
			--PRINT @cur_lot_size


			-- ■１．発注単位数を取得
			IF @cur_su_zaiko < 0
			BEGIN
			-- 在庫数 < 0 の場合
				-- (在庫数 * -1 + 最低在庫数) / (重量 * 入数 * 発注ロットサイズ)
				SET @hachu_tani = (@cur_su_zaiko * -1 + @cur_zaiko_min) / (@cur_wt_ko * @cur_su_iri * @cur_lot_size)
			END
			ELSE BEGIN
			-- 在庫数 >= 0 の場合
				-- (最低在庫数 - 在庫数) / (重量 * 入数 * 発注ロットサイズ)
				SET @hachu_tani = (@cur_zaiko_min - @cur_su_zaiko) / (@cur_wt_ko * @cur_su_iri * @cur_lot_size)
			END

			-- デバッグ用
			--PRINT '発注単位:切り上げ前'
			--PRINT @hachu_tani

			-- 小数点以下切り上げ
			SET @hachu_tani = CEILING(@hachu_tani)
			
			-- ■２．加算在庫数を取得：(重量 * 入数 * 発注ロットサイズ) * 発注単位数
			SET @kasan_zaiko = (@cur_wt_ko * @cur_su_iri * @cur_lot_size) * @hachu_tani

			-- デバッグ用
			--PRINT '加算在庫'
			--PRINT @kasan_zaiko

			-- ■３．納入数を算出：加算在庫数 / (重量 * 入数)を小数以下切捨て
			SET @su_nonyu = FLOOR(@kasan_zaiko / (@cur_wt_ko * @cur_su_iri))

			-- デバッグ用
			--PRINT '納入数'
			--PRINT @su_nonyu

			-- ■４．納入端数を算出：((加算在庫数 / (重量 * 入数)) - 納入数) * 入数
			SET @su_nonyu_hasu = ((@kasan_zaiko / (@cur_wt_ko * @cur_su_iri)) - @su_nonyu) * @cur_su_iri

			-- デバッグ用
			--PRINT '納入端数'
			--PRINT @su_nonyu_hasu


			-- ================
			--  計算在庫の更新
			-- ================
			UPDATE wk_zaiko_keisan
			SET su_zaiko = (su_zaiko + @kasan_zaiko)
				,dt_update = @utc_sysdate
				,cd_update = @cd_update
			WHERE cd_hinmei = @cur_cd_hinmei
			AND dt_hizuke BETWEEN @cur_dt_nonyu AND @cur_dt_zaiko

			IF @@ERROR <> 0
			BEGIN
				SET @msg = 'error: wk_zaiko_keisan failed update.'
				GOTO Error_Handling
			END

			-- ========================
			--  計算在庫ワークの再計算
			-- ========================
			-- 計算開始日：製造日の翌日を設定
			SET @con_dt_start = DATEADD(day, 1, @cur_dt_zaiko)

			DECLARE @zenjitsu_su_zaiko DECIMAL(14,6) = 0.00
			SET @zenjitsu_su_zaiko = (SELECT su_zaiko FROM wk_zaiko_keisan
										WHERE cd_hinmei = @cur_cd_hinmei
										AND dt_hizuke = @cur_dt_zaiko)
			
			-- デバッグ用
			--PRINT '計算開始日'
			--PRINT @con_dt_start
			--PRINT @zenjitsu_su_zaiko

			-- 指定範囲をDELETE＞INSERT
			DELETE wk_zaiko_keisan
			WHERE cd_hinmei = @cur_cd_hinmei
			AND dt_hizuke BETWEEN @con_dt_start AND @hizuke_to

			INSERT INTO wk_zaiko_keisan (
				cd_hinmei
				,dt_hizuke
				,su_zaiko
				,dt_update
				,cd_update
			)
			SELECT
				@cur_cd_hinmei AS 'cd_hinmei' --品名コード
				,ruikei.dt_hizuke AS 'dt_hizuke' --日付
				,@zenjitsu_su_zaiko - ruikei.su_shiyo_ruikei
				-- 固定日以内の納入数はクリアしないので計算在庫に含める
					+ CAST(COALESCE(ruikei.su_nonyu_ruikei, 0) AS DECIMAL(14, 6))
					- COALESCE(ruikei.su_chosei_ruikei, 0.00)
					AS 'su_keisanzaiko'  --計算在庫数

				,GETUTCDATE() AS dt_update	-- 更新日
				,@cd_update	AS cd_update	-- 更新者
			FROM
			-- ■累計情報(ruikei)■
			-- ■日付毎に、その日付までの累計情報を抽出する■
			(
				SELECT
					ruikei_calendar.dt_hizuke     AS 'dt_hizuke' --日付

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

					,SUM(ruikei_meisai.su_shiyo) AS 'su_shiyo_ruikei' --使用数累計
			        ,SUM(ruikei_meisai.su_chosei) AS 'su_chosei_ruikei' -- 調整数累計
				FROM
				-- ■累計用カレンダー情報(ruikei_calendar)■
				-- ■カレンダーマスタ(ma_calendar)より、開始日付～終了日付の日付を抽出する■
				(
					SELECT
						[dt_hizuke] AS 'dt_hizuke' --日付
					FROM [ma_calendar] WITH(NOLOCK)
					WHERE
						[dt_hizuke] BETWEEN @con_dt_start AND @hizuke_to
				) ruikei_calendar
				INNER JOIN
				-- ■累計用明細情報(ruikei_meisai)■
				-- ■日付毎に、その日付までの累計情報を算出するための明細情報を抽出する■
				(
					SELECT
						ruikei_meisai_calendar.dt_hizuke                      AS 'dt_hizuke' --日付
						,COALESCE(ruikei_meisai_nonyu.su_nonyu, 0.00)         AS 'su_nonyu' -- 納入数
						,COALESCE(ruikei_meisai_nonyu.su_nonyu_hasu, 0.00)    AS 'su_nonyu_hasu' -- 納入端数
						,COALESCE(ruikei_meisai_shiyo_yojitsu.su_shiyo, 0.00) AS 'su_shiyo' --使用数
			            ,COALESCE(ruikei_meisai_chosei.su_chosei, 0.00)       AS 'su_chosei' -- 調整数
					FROM
					-- ■累計明細用カレンダー情報(ruikei_meisai_calendar)■
					-- ■カレンダーマスタ(ma_calendar)より、開始日付～終了日付の日付を抽出する■
					(
						SELECT
							[dt_hizuke] AS 'dt_hizuke' --日付
						FROM [ma_calendar] WITH(NOLOCK)
						WHERE
							[dt_hizuke] BETWEEN @con_dt_start AND @hizuke_to
					) ruikei_meisai_calendar
					-- ■ 累計明細用納入予実(ruikei_meisai_nonyu)
					-- ■ 納入予実トラン(tr_nonyu)より、指定日～末日の日付単位の納入数を抽出する
					LEFT OUTER JOIN
					(
						SELECT
							SUM(COALESCE(su_nonyu, 0.00))       AS 'su_nonyu' --納入数
							,SUM(COALESCE(su_nonyu_hasu, 0.00))	AS 'su_nonyu_hasu' --納入数
							,dt_nonyu AS 'dt_hizuke'
						FROM #tmp_nonyu_tbl
						WHERE dt_nonyu BETWEEN @hizuke_from AND @cur_hizuke
						GROUP BY dt_nonyu
					) ruikei_meisai_nonyu
					ON ruikei_meisai_calendar.dt_hizuke = ruikei_meisai_nonyu.dt_hizuke
					-- ■累計明細用使用予実(ruikei_meisai_shiyo_yojitsu)■
					-- ■使用予実トラン(tr_shiyo_yojitsu)より、開始日付～終了日付の日付単位の使用数を抽出する■
					LEFT OUTER JOIN
					(
						SELECT
							[dt_shiyo] AS 'dt_hizuke' --日付
							,SUM(COALESCE([su_shiyo], 0.00)) AS 'su_shiyo' --使用数
						FROM #tmp_shiyo_tbl --tr_shiyo_yojitsu
						WHERE
							[dt_shiyo] BETWEEN @con_dt_start AND @hizuke_to
							AND [cd_hinmei] = @cur_cd_hinmei
						GROUP BY
							[dt_shiyo]
					) ruikei_meisai_shiyo_yojitsu
					ON ruikei_meisai_calendar.dt_hizuke = ruikei_meisai_shiyo_yojitsu.dt_hizuke
					-- ■ 累計明細用調整(ruikei_meisai_chosei)■
					-- ■ 調整トラン(tr_chosei)より、在庫計算開始日～末日かつ前日以前の日付単位の調整数を抽出する■
					LEFT OUTER JOIN
					(
						SELECT
							SUM(COALESCE([su_chosei], 0.00))      AS 'su_chosei' --調整数
							,dt_hizuke AS 'dt_hizuke'
						FROM tr_chosei WITH(NOLOCK)
						WHERE
							[dt_hizuke] BETWEEN @con_dt_start AND @hizuke_to
						AND [cd_hinmei] = @cur_cd_hinmei
						GROUP BY
							dt_hizuke
					) ruikei_meisai_chosei
					ON ruikei_meisai_calendar.dt_hizuke = ruikei_meisai_chosei.dt_hizuke
				) ruikei_meisai
				-- ■累計の対象は、指定範囲から末日まで■
				ON ruikei_calendar.dt_hizuke >= ruikei_meisai.dt_hizuke

				-- 品名マスタを結合
				LEFT OUTER JOIN (
					SELECT mhj.cd_hinmei, mhj.cd_tani_shiyo, mhj.wt_ko, mhj.su_iri
					FROM ma_hinmei mhj 
					WHERE mhj.flg_mishiyo = @flg_shiyo
					AND mhj.cd_hinmei = @cur_cd_hinmei
				) mh
				ON mh.cd_hinmei = @cur_cd_hinmei
			    
				-- 購入先マスタを結合
				LEFT OUTER JOIN (
					SELECT mkj.no_juni_yusen, mkj.cd_hinmei, mkj.cd_tani_nonyu, mkj.wt_nonyu, mkj.su_iri
					FROM ma_konyu mkj 
					WHERE mkj.flg_mishiyo = @flg_shiyo
					AND mkj.cd_hinmei = @cur_cd_hinmei
				) mk
				ON mk.cd_hinmei = @cur_cd_hinmei
				AND mk.no_juni_yusen = ( SELECT MIN(ko.no_juni_yusen) AS no_juni_yusen
										 FROM ma_konyu ko 
										 WHERE ko.flg_mishiyo = @flg_shiyo
										 AND ko.cd_hinmei = @cur_cd_hinmei )

				GROUP BY
					ruikei_calendar.dt_hizuke
			) ruikei

			IF @@ERROR <> 0
			BEGIN
				SET @msg = 'error: wk_zaiko_keisan failed calculation and insert.'
				GOTO Error_Handling
			END


			-- ==================================
			--  納入情報を納入一時テーブルに追加
			-- ==================================
			-- 納入予定の有無チェック
			SET @no_nonyu = NULL	-- 納入番号を一度クリア
			SET @no_nonyu = (SELECT no_nonyu
							 FROM #tmp_tr_nonyu WITH(NOLOCK)
							 WHERE cd_hinmei = @cur_cd_hinmei
							 AND dt_nonyu = @cur_dt_nonyu)
			
			IF @no_nonyu IS NOT NULL
			BEGIN
				-- 存在した場合：UPDATE
				UPDATE #tmp_tr_nonyu
				SET su_nonyu = su_nonyu + @su_nonyu
					,su_nonyu_hasu = su_nonyu_hasu + @su_nonyu_hasu
				WHERE no_nonyu = @no_nonyu

				IF @@ERROR <> 0
				BEGIN
					SET @msg = 'error: tmp_tr_nonyu failed update.'
					GOTO Error_Handling
				END
			END
			ELSE BEGIN
				-- 存在しなかった場合：INSERT

				-- ================================
				--  採番テーブルより納入番号を取得
				-- ================================
				EXEC dbo.usp_cm_Saiban
					@saiban_kubun,
					@saiban_prefix,
					@no_saiban = @no_nonyu output

				-- ==================================
				--  納入情報を納入一時テーブルに追加
				-- ==================================
				INSERT INTO #tmp_tr_nonyu (
					no_nonyu
					,dt_nonyu
					,cd_hinmei
					,su_nonyu
					,su_nonyu_hasu
					,cd_torihiki
					,cd_torihiki2
					,tan_nonyu
					,kbn_zei
					,dt_seizo
					,kasan_zaiko
				)
				SELECT
					@no_nonyu
					,@cur_dt_nonyu
					,@cur_cd_hinmei
					,@su_nonyu
					,@su_nonyu_hasu
					,@cur_torihiki
					,@cur_torihiki2
					,@cur_tanka
					,@cur_kbn_zei
					,@cur_dt_zaiko
					,@kasan_zaiko

				IF @@ERROR <> 0
				BEGIN
					SET @msg = 'error: tmp_tr_nonyu failed insert.'
					GOTO Error_Handling
				END
			END

		NEXT_cursor_keisan:

			-- 計算在庫のカーソルを次の行へ
			FETCH NEXT FROM cursor_keisan INTO
				@cur_cd_hinmei
				,@cur_dt_nonyu
				,@cur_dt_zaiko
				,@cur_su_zaiko
				,@cur_zaiko_min
				,@cur_su_iri
				,@cur_wt_ko
				,@cur_leadtime
				,@cur_lot_size
				,@cur_tanka
				,@cur_kbn_zei
				,@cur_torihiki
				,@cur_torihiki2

			IF (@@error <> 0)
			BEGIN
				SET @msg = 'FETCH NEXT ERROR2: cursor_keisan'
				GOTO Error_Handling
			END
		END

		CLOSE cursor_keisan
		DEALLOCATE cursor_keisan

		-- テーブルをクリア
		delete #tmp_zaiko_min

		-- カーソルを次の行へ
		FETCH NEXT FROM cursor_kikan INTO
			@cur_hizuke
	END

	-- 期間カーソルを閉じる
	CLOSE cursor_kikan
	DEALLOCATE cursor_kikan


	-- ========================================
	-- ========================================
	--  一時テーブルから実テーブルへの反映処理
	-- ========================================
	-- ========================================

	-- 画面で入力された変動計算初日～変動計算末日の予定を削除
	-- 固定日以内は削除しない
	DELETE tr_nonyu
	FROM tr_nonyu tr
	INNER JOIN #target_hinmei hin
	ON hin.cd_hinmei = tr.cd_hinmei
	--WHERE tr.dt_nonyu BETWEEN @hizuke_from AND @hizuke_to
	WHERE tr.dt_nonyu > hin.dt_kotei
	AND tr.dt_nonyu <= @hizuke_to
	AND tr.flg_yojitsu = @flg_yojitsu_yo

	IF @@ERROR <> 0
	BEGIN
	    SET @msg = 'error: tr_nonyu failed delete.'
	    GOTO Error_Handling
	END

	-- ============================
	--  納入予実トランへの追加処理
	-- ============================
	INSERT INTO tr_nonyu (
		flg_yojitsu
		,no_nonyu
		,dt_nonyu
		,cd_hinmei
		,su_nonyu
		,su_nonyu_hasu
		,cd_torihiki
		,cd_torihiki2
		,tan_nonyu
		,kin_kingaku
		,no_nonyusho
		,kbn_zei
		,kbn_denso
		,flg_kakutei
		,dt_seizo
	)
	SELECT
		@flg_yojitsu_yo
		,no_nonyu
		,dt_nonyu
		,cd_hinmei
		,su_nonyu
		,su_nonyu_hasu
		,cd_torihiki
		,cd_torihiki2
		,tan_nonyu
		,0
		,NULL
		,kbn_zei
		,@kbn_ksys_denso
		,@flg_mikakutei
		,dt_seizo
	FROM
		#tmp_tr_nonyu

	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'error: tr_nonyu failed insert.'
		GOTO Error_Handling
	END

	-- ==================================
	--  計算在庫トランへの削除＞追加処理
	-- ==================================
	DELETE tr
		FROM tr_zaiko_keisan tr
		INNER JOIN #target_hinmei hin
		ON hin.cd_hinmei = tr.cd_hinmei
		WHERE tr.dt_hizuke BETWEEN @hizuke_from AND @hizuke_to

	INSERT INTO tr_zaiko_keisan (
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
		,dt_update
		,cd_update
	FROM
		wk_zaiko_keisan WITH(NOLOCK)
	WHERE
		dt_hizuke BETWEEN @hizuke_from AND @hizuke_to

	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'error: tr_zaiko_keisan failed delete > insert.'
		GOTO Error_Handling
	END

	-- ============================
	--  原資材計画管理トランの更新
	-- ============================
	-- 存在すればUPDATE、なければINSERT
	MERGE INTO tr_genshizai_keikaku AS tr
		USING
			(SELECT DISTINCT cd_hinmei
			--FROM #tmp_tr_nonyu WITH(NOLOCK)) AS tmp
			FROM #target_hinmei WITH(NOLOCK)) AS tmp
			ON tr.cd_hinmei = tmp.cd_hinmei
		WHEN MATCHED THEN
			UPDATE SET
				tr.dt_keikaku_nonyu = @hizuke_to
				,tr.dt_zaiko_keisan = @hizuke_to
		WHEN NOT MATCHED THEN
			INSERT (cd_hinmei, dt_zaiko_keisan, dt_keikaku_nonyu)
			VALUES (tmp.cd_hinmei, NULL, @hizuke_to);

	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'error: tr_genshizai_keikaku failed update.'
		GOTO Error_Handling
	END

	-- ======================
	--  計算在庫ワークの削除
	-- ======================
	DELETE wk_zaiko_keisan
    IF @@ERROR <> 0
    BEGIN
        SET @msg = 'error: wk_zaiko_keisan failed delete.'
        GOTO Error_Handling
    END

	-- ======================
	--  SKIPしたコードを返却
	-- ======================
	SELECT @skip_code AS 'skip_code'

	--PRINT 'OK 原資材納入計画作成完了'
	RETURN

	-- //////////////////////// --
	--   エラー処理
	-- //////////////////////// --
	Error_Handling:
		SET @skip_code = '-1'	-- エラーコード
		DELETE wk_zaiko_keisan
		CLOSE cursor_kikan
		DEALLOCATE cursor_kikan
		CLOSE cursor_keisan
		DEALLOCATE cursor_keisan
		PRINT @msg
		
		SELECT @skip_code AS 'skip_code'


END
GO
