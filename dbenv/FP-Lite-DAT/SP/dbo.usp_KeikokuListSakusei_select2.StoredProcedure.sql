IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KeikokuListSakusei_select2') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KeikokuListSakusei_select2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		tsujita.s
-- Create date: 2014.08.08
-- Last Update: 2016.12.13 motojima.m 中文対応
-- Description:	警告リスト
--    データ抽出処理：★★★ 試行錯誤中 ★★★
-- ===============================================
CREATE PROCEDURE [dbo].[usp_KeikokuListSakusei_select2]
	 @con_hizuke			datetime		-- 検索条件：開始日
	,@con_kubun				varchar(2)		-- 検索条件：品区分
	,@con_bunrui			varchar(10)		-- 検索条件：分類
	,@con_kurabasho			varchar(10)		-- 検索条件：倉場所
	--,@con_hinmei			varchar(100)	-- 検索条件：品名/品名コード
	,@con_hinmei			nvarchar(100)	-- 検索条件：品名/品名コード
	,@con_keikoku_list		smallint		-- 検索条件：警告条件：警告リスト…0、前日在庫－当日使用…1
	,@con_zaiko_max_flg		smallint		-- 検索条件：「最大在庫も警告」チェックあり…1、チェックなし…0
	,@lang					varchar(2)		-- ブラウザ言語
	,@today					datetime		-- UTC時間で変換済みシステム日付
	,@flg_shiyo				smallint		-- 定数：未使用フラグ：使用：0
	,@flg_yotei				smallint		-- 定数：予実フラグ：予定：0
	,@flg_jisseki			smallint		-- 定数：予実フラグ：実績：1
	,@genryo				smallint		-- 定数：品区分：原料
	,@shizai				smallint		-- 定数：品区分：資材
	,@jikagenryo			smallint		-- 定数：品区分：自家原料
	,@con_dt_end			datetime		-- 検索条件：終了日
	,@all_genshizai			smallint		-- 検索条件：全ての原資材を表示：チェックあり…1、チェックなし…0
	,@flg_leadtime			smallint		-- 検索条件：納入リードタイムを加味する：チェックあり…1、チェックなし…0
	,@cd_kg					varchar(2)		-- 単位：Kg
	,@cd_li					varchar(2)		-- 単位：L
AS
BEGIN
	-- 変数リスト
	DECLARE @msg			VARCHAR(100)	-- 処理結果メッセージ格納用
	-- カーソル用の変数リスト
	DECLARE @cur_hizuke		DATETIME

	-- ====================
	--  一時テーブルの作成
	-- ====================
	-- 警告対象テーブル
	create table #tmp_target (
		cd_hinmei			VARCHAR(14)
		,dt_hizuke			DATETIME
		,su_zaiko			DECIMAL(14,6)
		,su_leadtime		DECIMAL(3,0)
	)
	-- 計算在庫一時テーブル
	create table #tmp_zaiko_keisan (
		cd_hinmei			VARCHAR(14)
		,dt_hizuke			DATETIME
		,su_zaiko			DECIMAL(14,6)
	)

	-- 品マス一時テーブル
	create table #tmp_hinmei (
		cd_hinmei		VARCHAR(14)
		,dd_leadtime	DECIMAL(12,6)
	)


	SET NOCOUNT ON

	-- 品マス一時テーブルに有効なものを挿入
	INSERT INTO #tmp_hinmei (cd_hinmei, dd_leadtime)
	SELECT HIN.cd_hinmei, HIN.dd_leadtime
	FROM (
		SELECT
			cd_hinmei, dd_leadtime
		FROM
			ma_hinmei
		WHERE flg_mishiyo = @flg_shiyo
		AND kbn_hin in (@genryo, @shizai, @jikagenryo)
		AND (@con_kubun = 0 OR kbn_hin = @con_kubun)
		AND (LEN(@con_hinmei) = 0 OR
				(
				 (@lang = 'ja' AND nm_hinmei_ja LIKE '%' + @con_hinmei + '%')
				 OR (@lang = 'en' AND nm_hinmei_en LIKE '%' + @con_hinmei + '%')
				 OR (@lang = 'zh' AND nm_hinmei_zh LIKE '%' + @con_hinmei + '%')
				 OR (@lang = 'vi' AND nm_hinmei_vi LIKE '%' + @con_hinmei + '%')
				)
				OR cd_hinmei LIKE '%' + @con_hinmei + '%'
			)
		AND (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
		AND (LEN(@con_kurabasho) = 0 OR cd_kura = @con_kurabasho)
	) HIN
	INNER JOIN (
		SELECT DISTINCT cd_hinmei
		FROM ma_konyu ko WITH(NOLOCK)
		WHERE flg_mishiyo = @flg_shiyo
		AND (LEN(@con_hinmei) = 0 OR
			 cd_hinmei LIKE '%' + @con_hinmei + '%')
	) KONYU
	ON HIN.cd_hinmei = KONYU.cd_hinmei
	CREATE NONCLUSTERED INDEX idx_hin1 ON #tmp_hinmei (cd_hinmei)

	-- ■「納入リードタイムを加味する」にチェックがあった場合
	IF @flg_leadtime = 1
	BEGIN
		-- ////////////////////////////////////////////////////////////
		--  使用予実をリードタイムの日数分過去に遡って在庫を再計算する
		-- ////////////////////////////////////////////////////////////

		-- ==============================
		--  再計算用の一時テーブルを作成
		-- ==============================

		-- 納入一時テーブル
		create table #tmp_nonyu (
			flg_yojitsu		SMALLINT
			,dt_nonyu		DATETIME
			,cd_hinmei		VARCHAR(14)
			,su_nonyu		DECIMAL(9,2)
			,su_nonyu_hasu	DECIMAL(9,2)
		)

		-- 調整一時テーブル
		create table #tmp_chosei (
			cd_hinmei		VARCHAR(14)
			,dt_hizuke		DATETIME
			,su_chosei		DECIMAL(12,6)
		)

		-- 製品計画一時テーブル
		create table #tmp_seihin (
			dt_seizo			DATETIME
			,cd_hinmei			VARCHAR(14)
			,su_seizo_yotei		DECIMAL(10,0)
			,su_seizo_jisseki	DECIMAL(10,0)
		)

		-- ===========================
		--  一時テーブルへのコピー
		-- ===========================
		-- 納入一時テーブルへ指定範囲の日付分コピー
		INSERT INTO #tmp_nonyu (flg_yojitsu, dt_nonyu, cd_hinmei, su_nonyu, su_nonyu_hasu)
		SELECT tr.flg_yojitsu, tr.dt_nonyu, tr.cd_hinmei, tr.su_nonyu, tr.su_nonyu_hasu
		FROM tr_nonyu tr
		INNER JOIN #tmp_hinmei hin
		ON hin.cd_hinmei = tr.cd_hinmei
		WHERE tr.dt_nonyu BETWEEN @con_hizuke AND @con_dt_end
		CREATE NONCLUSTERED INDEX idx_nonyu1 ON #tmp_nonyu (flg_yojitsu)
		CREATE NONCLUSTERED INDEX idx_nonyu2 ON #tmp_nonyu (dt_nonyu)
		CREATE NONCLUSTERED INDEX idx_nonyu3 ON #tmp_nonyu (cd_hinmei)

		-- 調整一時にコピー
		INSERT INTO #tmp_chosei (cd_hinmei, dt_hizuke, su_chosei)
		SELECT tr.cd_hinmei, tr.dt_hizuke, tr.su_chosei
		FROM tr_chosei tr
		INNER JOIN #tmp_hinmei hin
		ON hin.cd_hinmei = tr.cd_hinmei
		WHERE tr.dt_hizuke BETWEEN @con_hizuke AND @con_dt_end
		CREATE NONCLUSTERED INDEX idx_cho1 ON #tmp_chosei (dt_hizuke)
		CREATE NONCLUSTERED INDEX idx_cho2 ON #tmp_chosei (cd_hinmei)

		-- 製品計画一時にコピー
		INSERT INTO #tmp_seihin (dt_seizo, cd_hinmei, su_seizo_yotei, su_seizo_jisseki)
		SELECT tr.dt_seizo, tr.cd_hinmei, tr.su_seizo_yotei, tr.su_seizo_jisseki
		FROM tr_keikaku_seihin tr
		INNER JOIN #tmp_hinmei hin
		ON hin.cd_hinmei = tr.cd_hinmei
		WHERE tr.dt_seizo BETWEEN @con_hizuke AND @con_dt_end
		CREATE NONCLUSTERED INDEX idx_sei1 ON #tmp_seihin (dt_seizo)
		CREATE NONCLUSTERED INDEX idx_sei2 ON #tmp_seihin (cd_hinmei)

		-- ================================
		--  画面で入力された指定期間を抽出
		-- ================================
		DECLARE cursor_calendar CURSOR FOR
			SELECT
				[dt_hizuke]       AS 'dt_hizuke'
			FROM [ma_calendar]
			WHERE
				[dt_hizuke] BETWEEN @con_hizuke AND @con_dt_end


		-- ============================================
		--  ■ 指定期間(計算対象日)のカーソルスタート ■
		-- ============================================
		OPEN cursor_calendar
			IF (@@error <> 0)
			BEGIN
			    SET @msg = 'CURSOR OPEN ERROR: cursor_calendar'
			    GOTO Error_Handling_Cursor
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
				,COALESCE(chokkin_jitsuzaiko.su_jitsuzaiko, zenjitsu_keisanzaiko.su_keisanzaiko, 0.00)
					- COALESCE(ruikei.su_shiyo_ruikei, 0.00)
					+ COALESCE(ruikei.su_nonyu_ruikei, 0.00)
					- COALESCE(ruikei.su_chosei_ruikei, 0.00)
				    AS 'su_zaiko'  --計算在庫数
			FROM
			(
			    SELECT
			        ruikei_hinmei.cd_hinmei       AS 'cd_hinmei'        -- 品名コード

					-- 納入数のC/S換算対応：KgまたはL以外
					,SUM(CASE WHEN COALESCE(mk.cd_tani_nonyu, mh.cd_tani_shiyo) = @cd_kg 
							OR COALESCE(mk.cd_tani_nonyu, mh.cd_tani_shiyo) = @cd_li
						THEN ruikei_meisai.su_nonyu * COALESCE(mk.wt_nonyu, mh.wt_ko) * COALESCE(mk.su_iri, mh.su_iri) 
							+ (ruikei_meisai.su_nonyu_hasu / 1000 )
						ELSE ruikei_meisai.su_nonyu * COALESCE(mk.wt_nonyu, mh.wt_ko) * COALESCE(mk.su_iri, mh.su_iri) 
							+ (ruikei_meisai.su_nonyu_hasu * COALESCE(mk.wt_nonyu, mh.wt_ko))
					END)							AS 'su_nonyu_ruikei'   -- 納入数累計

			        ,SUM(ruikei_meisai.su_shiyo)  AS 'su_shiyo_ruikei'  -- 使用数累計
			        ,SUM(ruikei_meisai.su_chosei) AS 'su_chosei_ruikei' -- 調整数累計
			    FROM
					#tmp_hinmei ruikei_hinmei

			    -- ■ 累計用明細情報(ruikei_meisai)■
			    -- ■ 日付・品名コード毎に、その日付までの累計情報を算出する■
			    -- ■ 実在庫が存在した場合は累計をリセットし、その翌日から累計する■
			    LEFT JOIN
			    (
			        SELECT
			            ruikei_meisai_hinmei.cd_hinmei                             AS 'cd_hinmei' -- 品名コード
			            ,COALESCE(ruikei_meisai_nonyu_yojitsu.su_nonyu, 0.00)      AS 'su_nonyu' -- 納入数
			            ,COALESCE(ruikei_meisai_nonyu_yojitsu.su_nonyu_hasu, 0.00) AS 'su_nonyu_hasu' -- 納入端数
			            ,COALESCE(ruikei_meisai_shiyo_yojitsu.su_shiyo, 0.00)      AS 'su_shiyo' -- 使用数
			            ,COALESCE(ruikei_meisai_chosei.su_chosei, 0.00)            AS 'su_chosei' -- 調整数
			            ,ruikei_meisai_hinmei.dt_hizuke                            AS 'dt_hizuke'
			        FROM (
						SELECT cal.dt_hizuke, hin.cd_hinmei, hin.dd_leadtime
						FROM #tmp_hinmei hin, ma_calendar cal
						WHERE cal.dt_hizuke BETWEEN @con_hizuke AND @cur_hizuke
					) ruikei_meisai_hinmei

			        -- ■ 累計明細用納入予実(ruikei_meisai_nonyu_yojitsu)■
			        -- ■ 納入予実トラン(tr_nonyu)or 製造計画トランより、在庫計算開始日～末日の日付単位の納入数を抽出する■
			        -- ■ 前日以前は実績から、当日以降は予定から納入数を抽出する■
			        LEFT OUTER JOIN
			        (
			            SELECT
			                SUM(COALESCE([su_nonyu], 0.00))      AS 'su_nonyu' --納入数
			                ,SUM(COALESCE([su_nonyu_hasu], 0.00)) AS 'su_nonyu_hasu' --納入予定端数
			                ,cd_hinmei AS 'cd_hinmei'
			                ,dt_nonyu AS 'dt_nonyu'
			            FROM #tmp_nonyu
			            WHERE
			                [flg_yojitsu] = @flg_jisseki
			                AND [dt_nonyu] BETWEEN @con_hizuke AND @cur_hizuke
			                AND [dt_nonyu] < @today
			            GROUP BY
			                cd_hinmei, dt_nonyu
			            UNION
			            SELECT
			                SUM(COALESCE([su_nonyu], 0.00))      AS 'su_nonyu' --納入数
			                ,SUM(COALESCE([su_nonyu_hasu], 0.00)) AS 'su_nonyu_hasu' --納入予定端数
			                ,cd_hinmei AS 'cd_hinmei'
			                ,dt_nonyu AS 'dt_nonyu'
			            FROM #tmp_nonyu
			            WHERE
			                [flg_yojitsu] = @flg_yotei
			                AND [dt_nonyu] BETWEEN @con_hizuke AND @cur_hizuke
			                AND [dt_nonyu] >= @today
			            GROUP BY
			                cd_hinmei, dt_nonyu
			            UNION
			            SELECT
			                SUM(COALESCE([su_seizo_yotei], 0)) AS 'su_nonyu' --製造予定数
			                ,0 -- 端数ダミー値(Sqlエラー回避用)
			                ,cd_hinmei AS 'cd_hinmei'
			                ,dt_seizo AS 'dt_nonyu'
			            FROM #tmp_seihin WITH(NOLOCK)
			            WHERE
			                [dt_seizo] BETWEEN @con_hizuke AND @cur_hizuke
			            GROUP BY
			                [dt_seizo], cd_hinmei
			        ) ruikei_meisai_nonyu_yojitsu
			        ON ruikei_meisai_hinmei.cd_hinmei = ruikei_meisai_nonyu_yojitsu.cd_hinmei
			        AND ruikei_meisai_hinmei.dt_hizuke = ruikei_meisai_nonyu_yojitsu.dt_nonyu
			        -- ■ 累計明細用使用予実(ruikei_meisai_shiyo_yojitsu)■
			        -- ■ 使用予実トラン(tr_shiyo_yojitsu)より、在庫計算開始日～末日の日付単位の使用数を抽出する■
			        -- ■ 前日以前は実績から、当日以降は予定から使用数を抽出する■
			        LEFT OUTER JOIN
			        (
			            SELECT
			                SUM(COALESCE(shiyo.su_shiyo, 0.00))      AS 'su_shiyo' --使用数
			                ,shiyo.cd_hinmei AS 'cd_hinmei'
			                --,dt_shiyo AS 'dt_shiyo'
			                ,DATEADD(day, -(hinm.dd_leadtime), shiyo.dt_shiyo) AS 'dt_shiyo'
			            FROM tr_shiyo_yojitsu shiyo
			            INNER JOIN #tmp_hinmei hinm
			            ON hinm.cd_hinmei = shiyo.cd_hinmei
			            WHERE
			                shiyo.flg_yojitsu = @flg_jisseki
			                AND shiyo.dt_shiyo <= DATEADD(day, hinm.dd_leadtime, @cur_hizuke)
			                AND shiyo.dt_shiyo < @today
			            GROUP BY
			                shiyo.cd_hinmei, shiyo.dt_shiyo, hinm.dd_leadtime
			            UNION
			            SELECT
			                SUM(COALESCE(shiyo.su_shiyo, 0.00))      AS 'su_shiyo' --使用数
			                ,shiyo.cd_hinmei AS 'cd_hinmei'
			                --,shiyo.dt_shiyo AS 'dt_shiyo'
			                ,DATEADD(day, -(hinm.dd_leadtime), shiyo.dt_shiyo) AS 'dt_shiyo'
			            FROM tr_shiyo_yojitsu shiyo
			            INNER JOIN #tmp_hinmei hinm
			            ON hinm.cd_hinmei = shiyo.cd_hinmei
			            WHERE
			                shiyo.flg_yojitsu = @flg_yotei
			                AND shiyo.dt_shiyo <= DATEADD(day, hinm.dd_leadtime, @cur_hizuke)
			                AND shiyo.dt_shiyo >= @today
			            GROUP BY
			                shiyo.cd_hinmei, shiyo.dt_shiyo, hinm.dd_leadtime
			        ) ruikei_meisai_shiyo_yojitsu
			        ON ruikei_meisai_hinmei.cd_hinmei = ruikei_meisai_shiyo_yojitsu.cd_hinmei
			        AND ruikei_meisai_hinmei.dt_hizuke = ruikei_meisai_shiyo_yojitsu.dt_shiyo
			        --AND DATEADD(day, -(ruikei_meisai_hinmei.dd_leadtime), ruikei_meisai_hinmei.dt_hizuke)
					--		= ruikei_meisai_shiyo_yojitsu.dt_shiyo
			        -- ■ 累計明細用調整(ruikei_meisai_chosei)■
			        -- ■ 調整トラン(tr_chosei)より、在庫計算開始日～末日かつ前日以前の日付単位の調整数を抽出する■
			        LEFT OUTER JOIN
			        (
			            SELECT
			                SUM(COALESCE([su_chosei], 0.00))      AS 'su_chosei' --調整数
			                ,cd_hinmei AS 'cd_hinmei'
			                ,dt_hizuke AS 'dt_hizuke'
			            FROM #tmp_chosei WITH(NOLOCK)
			            WHERE
			                [dt_hizuke] BETWEEN @con_hizuke AND @cur_hizuke
			                AND [dt_hizuke] < @today
			            GROUP BY
			                cd_hinmei, dt_hizuke
			        ) ruikei_meisai_chosei
			        ON ruikei_meisai_hinmei.cd_hinmei = ruikei_meisai_chosei.cd_hinmei
			        AND ruikei_meisai_hinmei.dt_hizuke = ruikei_meisai_chosei.dt_hizuke
			    ) ruikei_meisai
			    -- ■ 累計の対象は、前日以前で直近の実在庫が存在する日付の翌日からその日付までとする■
			    ON ruikei_hinmei.cd_hinmei = ruikei_meisai.cd_hinmei
			    AND ruikei_meisai.dt_hizuke > COALESCE((SELECT MAX([dt_hizuke])
			                                FROM [tr_zaiko] WITH(NOLOCK)
			                                WHERE [dt_hizuke] >= @con_hizuke
			                                AND [dt_hizuke] <= @cur_hizuke
			                                AND [dt_hizuke] <= @today
			                                AND cd_hinmei = ruikei_hinmei.cd_hinmei), 0)

			    -- 品名マスタを結合
			    LEFT OUTER JOIN (
					SELECT cd_hinmei, cd_tani_shiyo, wt_ko, su_iri
					FROM ma_hinmei
					WHERE flg_mishiyo = @flg_shiyo
			    ) mh
			    ON mh.cd_hinmei = ruikei_meisai.cd_hinmei
			    
			    -- 購入先マスタを結合
				LEFT OUTER JOIN (
					SELECT no_juni_yusen, cd_hinmei, cd_tani_nonyu, wt_nonyu, su_iri
					FROM ma_konyu
					WHERE flg_mishiyo = @flg_shiyo
				) mk
				ON mk.cd_hinmei = ruikei_meisai.cd_hinmei
				AND mk.no_juni_yusen = ( SELECT
											MIN(ko.no_juni_yusen) AS no_juni_yusen
										 FROM ma_konyu ko WITH(NOLOCK)
										 WHERE ko.flg_mishiyo = @flg_shiyo
										 AND ko.cd_hinmei = ruikei_meisai.cd_hinmei )

			    GROUP BY ruikei_hinmei.cd_hinmei
			) ruikei

			-- ■ 直近実在庫情報■
			-- ■ 日付毎に、前日以前で直近の実在庫情報を抽出する■
			LEFT OUTER JOIN
			(
			    SELECT
			        [dt_hizuke]  AS 'dt_hizuke' --日付
			        ,[su_zaiko]  AS 'su_jitsuzaiko' --実在庫数
			        ,cd_hinmei   AS 'cd_hinmei'
			    FROM
			        [tr_zaiko] WITH(NOLOCK)
			    WHERE
			        [dt_hizuke] BETWEEN @con_hizuke AND @cur_hizuke
			        AND [dt_hizuke] <= @today
			) chokkin_jitsuzaiko
			ON ruikei.cd_hinmei = chokkin_jitsuzaiko.cd_hinmei
			AND chokkin_jitsuzaiko.dt_hizuke = (SELECT MAX([dt_hizuke])
			                                    FROM [tr_zaiko] WITH(NOLOCK)
												WHERE [dt_hizuke] BETWEEN @con_hizuke AND @cur_hizuke
			                                    AND [dt_hizuke] <= @today
			                                    AND cd_hinmei = ruikei.cd_hinmei)

			-- ■ 算出開始日前日計算在庫情報(zenjitsu_keisanzaiko)■
			LEFT OUTER JOIN
			(
			    SELECT
			        [cd_hinmei] AS 'cd_hinmei' --品名コード
			        ,[su_zaiko]  AS 'su_keisanzaiko' --計算在庫数
			    FROM tr_zaiko_keisan
			    WHERE
			        [dt_hizuke] = DATEADD(day, -1, @con_hizuke)
			) zenjitsu_keisanzaiko
			ON ruikei.cd_hinmei = zenjitsu_keisanzaiko.cd_hinmei


			-- 計算対象日のカーソルを次の行へ
			FETCH NEXT FROM cursor_calendar INTO
				@cur_hizuke
		END

	    IF @@ERROR <> 0
	    BEGIN
	        SET @msg = 'error :#tmp_zaiko_keisan failed insert.'
	        GOTO Error_Handling_Cursor
	    END

		CLOSE cursor_calendar
		DEALLOCATE cursor_calendar
		
	-- /-/-/-/-/-/ 納入リードタイムを加味する場合の処理：ここまで /-/-/-/-/-/
	END
	ELSE BEGIN
	
		INSERT INTO #tmp_zaiko_keisan (
			cd_hinmei
			,dt_hizuke
			,su_zaiko
		)
		SELECT
			zaiko.cd_hinmei
			,zaiko.dt_hizuke
			,zaiko.su_zaiko
		FROM tr_zaiko_keisan zaiko WITH(NOLOCK)
		INNER JOIN #tmp_hinmei HIN
		ON HIN.cd_hinmei = zaiko.cd_hinmei
		-- 指定期間分に絞る
		WHERE zaiko.dt_hizuke >= @con_hizuke
		AND (@con_dt_end IS NULL OR zaiko.dt_hizuke <= @con_dt_end)
	
	END


	-- ■「前日在庫－当日使用」が選択されていた場合
	IF @con_keikoku_list = 1
	BEGIN
		-- ======================
		--  警告対象データを抽出
		-- ======================
		INSERT INTO #tmp_target (	
			cd_hinmei
			,dt_hizuke
			,su_leadtime
		)
		SELECT
			za.cd_hinmei
			,MIN(dt_hizuke) AS dt_hizuke
			,CASE WHEN @flg_leadtime = 1
			 THEN COALESCE(ma.dd_leadtime, 0)
			 ELSE 0 END AS su_leadtime
		FROM #tmp_zaiko_keisan za WITH(NOLOCK)

		INNER JOIN ma_hinmei ma WITH(NOLOCK)
		ON ma.cd_hinmei = za.cd_hinmei
		AND ma.flg_mishiyo = @flg_shiyo

		LEFT JOIN (
			SELECT MAX(no_juni_yusen) AS no_juni_yusen, cd_hinmei
			FROM ma_konyu
			WHERE flg_mishiyo = @flg_shiyo
			GROUP BY cd_hinmei
		) yusen
		ON ma.cd_hinmei = yusen.cd_hinmei
		
		INNER JOIN ma_konyu mk WITH(NOLOCK)
		ON mk.cd_hinmei = yusen.cd_hinmei
		AND mk.no_juni_yusen = yusen.no_juni_yusen
		--AND mk.flg_mishiyo = @flg_shiyo

		INNER JOIN ma_torihiki mt WITH(NOLOCK)
		ON mt.cd_torihiki = mk.cd_torihiki
		AND mt.flg_mishiyo = @flg_shiyo

		-- 納入数
		LEFT JOIN (
			-- 予定
			SELECT
				cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,SUM(su_nonyu) AS su_nonyu
			FROM tr_nonyu WITH(NOLOCK)
			WHERE flg_yojitsu = @flg_yotei
			AND dt_nonyu >= @con_hizuke
			AND dt_nonyu >= @today
			GROUP BY cd_hinmei, dt_nonyu

			UNION

			-- 実績
			SELECT
				cd_hinmei AS cd_hinmei
				,dt_nonyu AS dt_nonyu
				,SUM(su_nonyu) AS su_nonyu
			FROM tr_nonyu WITH(NOLOCK)
			WHERE flg_yojitsu = @flg_jisseki
			AND dt_nonyu >= @con_hizuke
			AND dt_nonyu < @today
			GROUP BY cd_hinmei, dt_nonyu
		) NONYU
		ON NONYU.dt_nonyu = za.dt_hizuke
		AND NONYU.cd_hinmei = za.cd_hinmei

		-- 開始日以降または開始日～終了日に存在する納入予定を取得する
		LEFT JOIN (
			-- 実績
			SELECT cd_hinmei
				,dt_nonyu AS dt_nonyu
				,SUM(su_nonyu) AS su_nonyu
			FROM tr_nonyu
			WHERE dt_nonyu >= @con_hizuke
			AND dt_nonyu < @today
			AND flg_yojitsu = @flg_jisseki
			AND (su_nonyu > 0 OR su_nonyu_hasu > 0)
			AND (@con_dt_end IS NULL OR dt_nonyu <= @con_dt_end)
			GROUP BY cd_hinmei, dt_nonyu
			UNION
			-- 予定
			SELECT cd_hinmei
				,dt_nonyu AS dt_nonyu
				,SUM(su_nonyu) AS su_nonyu
			FROM tr_nonyu
			WHERE dt_nonyu >= @con_hizuke
			AND dt_nonyu >= @today
			AND flg_yojitsu = @flg_yotei
			AND (su_nonyu > 0 OR su_nonyu_hasu > 0)
			AND (@con_dt_end IS NULL OR dt_nonyu <= @con_dt_end)
			GROUP BY cd_hinmei, dt_nonyu
		) nonyu_yotei
		ON nonyu_yotei.cd_hinmei = za.cd_hinmei
		AND nonyu_yotei.dt_nonyu = za.dt_hizuke

		-- 開始日以降または開始日～終了日に存在する使用予定を取得する
		LEFT JOIN (
			-- 実績
			SELECT cd_hinmei
				,dt_shiyo AS dt_shiyo
				,SUM(su_shiyo) AS su_shiyo
			FROM tr_shiyo_yojitsu
			WHERE dt_shiyo >= @con_hizuke
			AND dt_shiyo < @today
			AND flg_yojitsu = @flg_jisseki
			AND su_shiyo > 0
			AND (@con_dt_end IS NULL OR dt_shiyo <= @con_dt_end)
			GROUP BY cd_hinmei, dt_shiyo
			UNION
			-- 予定
			SELECT cd_hinmei
				,dt_shiyo AS dt_shiyo
				,SUM(su_shiyo) AS su_shiyo
			FROM tr_shiyo_yojitsu
			WHERE dt_shiyo >= @con_hizuke
			AND dt_shiyo >= @today
			AND flg_yojitsu = @flg_yotei
			AND su_shiyo > 0
			AND (@con_dt_end IS NULL OR dt_shiyo <= @con_dt_end)
			GROUP BY cd_hinmei, dt_shiyo
		) shiyo_yotei
		ON shiyo_yotei.cd_hinmei = za.cd_hinmei
		AND shiyo_yotei.dt_shiyo = za.dt_hizuke

		WHERE za.dt_hizuke >= @con_hizuke
		AND (@con_dt_end IS NULL OR za.dt_hizuke <= @con_dt_end)
		-- 2014.06.10:「全ての原資材を表示」の対応
		-- チェックなしの場合は開始日以降に納入予定、使用予定があるものだけを表示する
		AND (@all_genshizai = 1
			OR (nonyu_yotei.cd_hinmei IS NOT NULL
				OR shiyo_yotei.cd_hinmei IS NOT NULL)
		)
		-- 在庫から納入数を引くことで、納入数を加味しない前日の在庫となる
		AND (ISNULL(za.su_zaiko, 0) - ISNULL(NONYU.su_nonyu, 0)) <= 0

		GROUP BY za.cd_hinmei, mk.su_leadtime, ma.dd_leadtime
	END

	-- ■「警告リスト」が選択されていた場合
	ELSE BEGIN
		-- ======================
		--  警告対象データを抽出
		-- ======================
		INSERT INTO #tmp_target (	
			cd_hinmei
			,dt_hizuke
			--,su_zaiko
			,su_leadtime
		)
		SELECT
			za.cd_hinmei
			,MIN(dt_hizuke) AS dt_hizuke
			,CASE WHEN @flg_leadtime = 1
			 THEN COALESCE(ma.dd_leadtime, 0)
			 ELSE 0 END AS su_leadtime
		FROM #tmp_zaiko_keisan za WITH(NOLOCK)

		INNER JOIN ma_hinmei ma WITH(NOLOCK)
		ON ma.cd_hinmei = za.cd_hinmei
		AND ma.flg_mishiyo = @flg_shiyo

		LEFT JOIN (
			SELECT MAX(no_juni_yusen) AS no_juni_yusen, cd_hinmei
			FROM ma_konyu
			WHERE flg_mishiyo = @flg_shiyo
			GROUP BY cd_hinmei
		) yusen
		ON ma.cd_hinmei = yusen.cd_hinmei
		
		INNER JOIN ma_konyu mk WITH(NOLOCK)
		ON mk.cd_hinmei = yusen.cd_hinmei
		AND mk.no_juni_yusen = yusen.no_juni_yusen
		--AND mk.flg_mishiyo = @flg_shiyo

		INNER JOIN ma_torihiki mt WITH(NOLOCK)
		ON mt.cd_torihiki = mk.cd_torihiki
		AND mt.flg_mishiyo = @flg_shiyo

		-- 開始日以降または開始日～終了日に存在する納入予定を取得する
		LEFT JOIN (
			-- 実績
			SELECT cd_hinmei
				,dt_nonyu AS dt_nonyu
				,SUM(su_nonyu) AS su_nonyu
			FROM tr_nonyu
			WHERE dt_nonyu >= @con_hizuke
			AND dt_nonyu < @today
			AND flg_yojitsu = @flg_jisseki
			AND (su_nonyu > 0 OR su_nonyu_hasu > 0)
			AND (@con_dt_end IS NULL OR dt_nonyu <= @con_dt_end)
			GROUP BY cd_hinmei, dt_nonyu
			UNION
			-- 予定
			SELECT cd_hinmei
				,dt_nonyu AS dt_nonyu
				,SUM(su_nonyu) AS su_nonyu
			FROM tr_nonyu
			WHERE dt_nonyu >= @con_hizuke
			AND dt_nonyu >= @today
			AND flg_yojitsu = @flg_yotei
			AND (su_nonyu > 0 OR su_nonyu_hasu > 0)
			AND (@con_dt_end IS NULL OR dt_nonyu <= @con_dt_end)
			GROUP BY cd_hinmei, dt_nonyu
		) nonyu_yotei
		ON nonyu_yotei.cd_hinmei = za.cd_hinmei
		AND nonyu_yotei.dt_nonyu = za.dt_hizuke

		-- 開始日以降または開始日～終了日に存在する使用予定を取得する
		LEFT JOIN (
			-- 実績
			SELECT cd_hinmei
				,dt_shiyo AS dt_shiyo
				,SUM(su_shiyo) AS su_shiyo
			FROM tr_shiyo_yojitsu
			WHERE dt_shiyo >= @con_hizuke
			AND dt_shiyo < @today
			AND flg_yojitsu = @flg_jisseki
			AND su_shiyo > 0
			AND (@con_dt_end IS NULL OR dt_shiyo <= @con_dt_end)
			GROUP BY cd_hinmei, dt_shiyo
			UNION
			-- 予定
			SELECT cd_hinmei
				,dt_shiyo AS dt_shiyo
				,SUM(su_shiyo) AS su_shiyo
			FROM tr_shiyo_yojitsu
			WHERE dt_shiyo >= @con_hizuke
			AND dt_shiyo >= @today
			AND flg_yojitsu = @flg_yotei
			AND su_shiyo > 0
			AND (@con_dt_end IS NULL OR dt_shiyo <= @con_dt_end)
			GROUP BY cd_hinmei, dt_shiyo
		) shiyo_yotei
		ON shiyo_yotei.cd_hinmei = za.cd_hinmei
		AND shiyo_yotei.dt_shiyo = za.dt_hizuke

		WHERE za.dt_hizuke >= @con_hizuke
		AND ma.flg_mishiyo = @flg_shiyo
		AND (@con_dt_end IS NULL OR za.dt_hizuke <= @con_dt_end)
		-- 2014.06.10:「全ての原資材を表示」の対応
		-- チェックなしの場合は開始日以降に納入予定、使用予定があるものだけを表示する
		AND (@all_genshizai = 1
			OR (nonyu_yotei.cd_hinmei IS NOT NULL
				OR shiyo_yotei.cd_hinmei IS NOT NULL)
		)
		AND ISNULL(za.su_zaiko, 0) < ma.su_zaiko_min

		GROUP BY za.cd_hinmei, mk.su_leadtime, ma.dd_leadtime

		-- ■「最大在庫も警告」にチェックが入っていた場合
		IF @con_zaiko_max_flg = 1
		BEGIN
			-- 最大在庫を上回る在庫を追加する
			INSERT INTO #tmp_target (	
				cd_hinmei
				,dt_hizuke
				--,su_zaiko
			)
			SELECT za.cd_hinmei
				,MIN(dt_hizuke) AS dt_hizuke
			FROM #tmp_zaiko_keisan za WITH(NOLOCK)

			INNER JOIN ma_hinmei ma WITH(NOLOCK)
			ON ma.cd_hinmei = za.cd_hinmei
			AND ma.flg_mishiyo = @flg_shiyo

			LEFT JOIN (
				SELECT MAX(no_juni_yusen) AS no_juni_yusen, cd_hinmei
				FROM ma_konyu
				WHERE flg_mishiyo = @flg_shiyo
				GROUP BY cd_hinmei
			) yusen
			ON ma.cd_hinmei = yusen.cd_hinmei
			
			INNER JOIN ma_konyu mk WITH(NOLOCK)
			ON mk.cd_hinmei = yusen.cd_hinmei
			AND mk.no_juni_yusen = yusen.no_juni_yusen
			--AND mk.flg_mishiyo = @flg_shiyo

			INNER JOIN ma_torihiki mt WITH(NOLOCK)
			ON mt.cd_torihiki = mk.cd_torihiki
			AND mt.flg_mishiyo = @flg_shiyo

			-- 開始日以降または開始日～終了日に存在する納入予定を取得する
			LEFT JOIN (
				-- 実績
				SELECT cd_hinmei
					,dt_nonyu AS dt_nonyu
					,SUM(su_nonyu) AS su_nonyu
				FROM tr_nonyu
				WHERE dt_nonyu >= @con_hizuke
				AND dt_nonyu < @today
				AND flg_yojitsu = @flg_jisseki
				AND (su_nonyu > 0 OR su_nonyu_hasu > 0)
				AND (@con_dt_end IS NULL OR dt_nonyu <= @con_dt_end)
				GROUP BY cd_hinmei, dt_nonyu
				UNION
				-- 予定
				SELECT cd_hinmei
					,dt_nonyu AS dt_nonyu
					,SUM(su_nonyu) AS su_nonyu
				FROM tr_nonyu
				WHERE dt_nonyu >= @con_hizuke
				AND dt_nonyu >= @today
				AND flg_yojitsu = @flg_yotei
				AND (su_nonyu > 0 OR su_nonyu_hasu > 0)
				AND (@con_dt_end IS NULL OR dt_nonyu <= @con_dt_end)
				GROUP BY cd_hinmei, dt_nonyu
			) nonyu_yotei
			ON nonyu_yotei.cd_hinmei = za.cd_hinmei
			AND nonyu_yotei.dt_nonyu = za.dt_hizuke

			-- 開始日以降または開始日～終了日に存在する使用予定を取得する
			LEFT JOIN (
				-- 実績
				SELECT cd_hinmei
					,dt_shiyo AS dt_shiyo
					,SUM(su_shiyo) AS su_shiyo
				FROM tr_shiyo_yojitsu
				WHERE dt_shiyo >= @con_hizuke
				AND dt_shiyo < @today
				AND flg_yojitsu = @flg_jisseki
				AND su_shiyo > 0
				AND (@con_dt_end IS NULL OR dt_shiyo <= @con_dt_end)
				GROUP BY cd_hinmei, dt_shiyo
				UNION
				-- 予定
				SELECT cd_hinmei
					,dt_shiyo AS dt_shiyo
					,SUM(su_shiyo) AS su_shiyo
				FROM tr_shiyo_yojitsu
				WHERE dt_shiyo >= @con_hizuke
				AND dt_shiyo >= @today
				AND flg_yojitsu = @flg_yotei
				AND su_shiyo > 0
				AND (@con_dt_end IS NULL OR dt_shiyo <= @con_dt_end)
				GROUP BY cd_hinmei, dt_shiyo
			) shiyo_yotei
			ON shiyo_yotei.cd_hinmei = za.cd_hinmei
			AND shiyo_yotei.dt_shiyo = za.dt_hizuke

			WHERE za.dt_hizuke >= @con_hizuke
			AND ma.flg_mishiyo = @flg_shiyo
			AND (@con_dt_end IS NULL OR za.dt_hizuke <= @con_dt_end)
			-- 2014.06.10:「全ての原資材を表示」の対応
			-- チェックなしの場合は開始日以降に納入予定、使用予定があるものだけを表示する
			AND (@all_genshizai = 1
				OR (nonyu_yotei.cd_hinmei IS NOT NULL
					OR shiyo_yotei.cd_hinmei IS NOT NULL)
			)
			AND ISNULL(za.su_zaiko, 0) > ma.su_zaiko_max
			GROUP BY za.cd_hinmei
		END
	END;
	
	SELECT
		 zaiko.dt_hizuke AS dt_hizuke
		,zaiko.dt_hizuke AS dt_hizuke_full
		,zaiko.cd_hinmei AS cd_hinmei
		,hin.nm_hinmei_ja AS nm_hinmei_ja
		,hin.nm_hinmei_en AS nm_hinmei_en
		,hin.nm_hinmei_zh AS nm_hinmei_zh
		,hin.nm_hinmei_vi AS nm_hinmei_vi
		,hin.nm_nisugata_hyoji AS nm_nisugata_hyoji
		,tani.nm_tani AS tani_shiyo
		,COALESCE(zaiko.su_zaiko, 0) AS su_zaiko
		,COALESCE(hin.su_zaiko_min, 0) AS su_zaiko_min
		,COALESCE(hin.su_zaiko_max, 0) AS su_zaiko_max
		,tori.cd_torihiki AS cd_torihiki
		,tori.nm_torihiki AS nm_torihiki
	FROM #tmp_zaiko_keisan zaiko

	INNER JOIN #tmp_target MIN_TBL
--	ON zaiko.dt_hizuke = DATEADD(day, MIN_TBL.su_leadtime, MIN_TBL.dt_hizuke)
--	AND zaiko.cd_hinmei = MIN_TBL.cd_hinmei
	ON zaiko.cd_hinmei = MIN_TBL.cd_hinmei
	AND zaiko.dt_hizuke = MIN_TBL.dt_hizuke
	
	INNER JOIN ma_hinmei hin WITH(NOLOCK)
	ON hin.cd_hinmei = zaiko.cd_hinmei

	INNER JOIN ma_tani tani WITH(NOLOCK)
	ON tani.cd_tani = hin.cd_tani_shiyo
	AND tani.flg_mishiyo = @flg_shiyo

	LEFT JOIN ma_torihiki tori WITH(NOLOCK)
	ON tori.flg_mishiyo = @flg_shiyo
	AND tori.cd_torihiki = (
			SELECT TOP 1 konyu.cd_torihiki
			FROM ma_konyu konyu WITH(NOLOCK)
			WHERE konyu.flg_mishiyo = @flg_shiyo
			--AND konyu.cd_hinmei = KEISAN_MIN.cd_hinmei
			AND konyu.cd_hinmei = zaiko.cd_hinmei
			ORDER BY konyu.no_juni_yusen ASC
		)

	-- 以下の条件については、指定された場合のみ検索条件に含める
	-- (指定されていない場合は、全件取得される)
	--WHERE (LEN(@con_kubun) = 0 OR hin.kbn_hin = @con_kubun)
	--AND (LEN(@con_bunrui) = 0 OR hin.cd_bunrui = @con_bunrui)
	--AND (LEN(@con_kurabasho) = 0 OR hin.cd_kura = @con_kurabasho)

	---- 品区分：原料、資材、自家原料のみ取得する
	--AND (hin.kbn_hin = @genryo OR hin.kbn_hin = @shizai OR hin.kbn_hin = @jikagenryo)

	---- 多言語対応：言語によって検索対象の品名カラムを変更する
	--AND (LEN(@con_hinmei) = 0 OR
	--		(@lang = 'en' OR @lang = 'zh') OR
	--			hin.cd_hinmei like '%' + @con_hinmei + '%' OR hin.nm_hinmei_ja like '%' + @con_hinmei + '%'
	--	)
	--AND (LEN(@con_hinmei) = 0 OR
	--		(@lang = 'ja' OR @lang = 'zh') OR
	--			hin.cd_hinmei like '%' + @con_hinmei + '%' OR hin.nm_hinmei_en like '%' + @con_hinmei + '%'
	--	)
	--AND (LEN(@con_hinmei) = 0 OR
	--		(@lang = 'ja' OR @lang = 'en') OR
	--			hin.cd_hinmei like '%' + @con_hinmei + '%' OR hin.nm_hinmei_zh like '%' + @con_hinmei + '%'
	--	)
	ORDER BY zaiko.cd_hinmei

	-- =/=/=/=/=/=/=/=/=/=
	--   結 果 の 返 却
	-- =/=/=/=/=/=/=/=/=/=
	--SELECT * FROM [cte_target]
	--ORDER BY cd_hinmei
	
	RETURN


	-- ///////////////////////////// --
	--  エラー処理 ：カーソル使用中
	-- ///////////////////////////// --
	Error_Handling_Cursor:
		CLOSE cursor_calendar
		DEALLOCATE cursor_calendar
		PRINT @msg
		RETURN

	-- ///////////////////// --
	--  エラー処理 ：通常時
	-- ///////////////////// --
	Error_Handling:
		PRINT @msg
		RETURN


END
GO
