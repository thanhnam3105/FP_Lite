IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KeikokuListSakusei_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KeikokuListSakusei_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		tsujita.s
-- Create date: 2013.09.03
-- Last Update: 2017.11.28 cho.k HQPシステム導入
-- Description:	警告リスト
--    データ抽出処理
-- ===============================================
CREATE PROCEDURE [dbo].[usp_KeikokuListSakusei_select]
	 @con_hizuke			datetime		-- 検索条件：開始日
	,@con_kubun				varchar(1)		-- 検索条件：品区分
	,@con_bunrui			varchar(10)		-- 検索条件：分類
	,@con_kurabasho			varchar(10)		-- 検索条件：倉場所
	--,@con_hinmei			varchar(50)		-- 検索条件：品名/品名コード
	,@con_hinmei			nvarchar(50)	-- 検索条件：品名/品名コード
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
	DECLARE @msg   VARCHAR(50) -- 処理結果メッセージ格納用
	-- カーソル用の変数リスト
	DECLARE @cur_hizuke  DATETIME

	-- ====================
	--  一時テーブルの作成
	-- ====================
	-- 警告対象テーブル
	create table #tmp_target (
		cd_hinmei		VARCHAR(14) COLLATE database_default
		,dt_hizuke		DATETIME
		,su_zaiko		DECIMAL(14, 6)
		,su_leadtime	DECIMAL(3, 0)
	)
	-- 計算在庫一時テーブル
	create table #tmp_zaiko_keisan (
		cd_hinmei		VARCHAR(14) COLLATE database_default
		,dt_hizuke		DATETIME
		,su_zaiko		DECIMAL(14, 6)
	)
	-- 品マス一時テーブル
	create table #tmp_hinmei (
		cd_hinmei		VARCHAR(14) COLLATE database_default
		,dd_leadtime	DECIMAL(12, 6)
		,cd_tani		VARCHAR(10) COLLATE database_default
		,wt_ko			DECIMAL(12, 6)
		,su_iri			DECIMAL(5, 0)
		,cd_torihiki	VARCHAR(13) COLLATE database_default
		,su_zaiko_min	DECIMAL(14, 6)
	)


	SET NOCOUNT ON
	--SET ARITHABORT ON

	-- 品マス一時テーブルに有効なものを挿入
	INSERT INTO #tmp_hinmei (
		cd_hinmei
		,dd_leadtime
		,cd_tani
		,wt_ko
		,su_iri
		,cd_torihiki
		,su_zaiko_min
	)
	SELECT
		HIN.cd_hinmei
		,HIN.dd_leadtime
		,COALESCE(KONYU.cd_tani_nonyu, HIN.cd_tani_shiyo)
		,COALESCE(KONYU.wt_nonyu, HIN.wt_ko)
		,COALESCE(KONYU.su_iri, HIN.su_iri)
		,KONYU.cd_torihiki
		,su_zaiko_min
	FROM (
		SELECT
			ma.cd_hinmei, ma.dd_leadtime, cd_tani_shiyo, wt_ko, su_iri, su_zaiko_min
		FROM
			ma_hinmei ma WITH(NOLOCK)
		WHERE ma.flg_mishiyo = @flg_shiyo
		AND (ma.kbn_hin = @genryo OR ma.kbn_hin = @shizai OR ma.kbn_hin = @jikagenryo)
		--AND (@con_kubun = 0 OR kbn_hin = @con_kubun)
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
	) HIN
	INNER JOIN (
		SELECT cd_hinmei
			,MIN(no_juni_yusen) AS no_juni_yusen
		FROM ma_konyu
		WHERE flg_mishiyo = @flg_shiyo
		GROUP BY cd_hinmei
	) yusen
	ON yusen.cd_hinmei = HIN.cd_hinmei
	INNER JOIN ma_konyu KONYU
	ON KONYU.cd_hinmei = yusen.cd_hinmei
	AND KONYU.no_juni_yusen = yusen.no_juni_yusen

	--WHERE EXISTS (SELECT ko.cd_hinmei FROM ma_konyu ko WITH(NOLOCK)
	--	WHERE ko.flg_mishiyo = @flg_shiyo
	--	AND ko.cd_hinmei = HIN.cd_hinmei)
	CREATE NONCLUSTERED INDEX idx_hin1 ON #tmp_hinmei (cd_hinmei)

	-- ■「納入リードタイムを加味する」にチェックがあった場合
	IF @flg_leadtime = 1
	BEGIN
	---- ////////////////////////////////////////////////////////////
	----  使用予実をリードタイムの日数分過去に遡って在庫を再計算する
	---- ////////////////////////////////////////////////////////////

	-- 納入リードタイムを加味して再計算した納入リード在庫ワークから取得
	INSERT INTO #tmp_zaiko_keisan (
		cd_hinmei
		,dt_hizuke
		,su_zaiko
	)
	SELECT
		zaiko.cd_hinmei
		,zaiko.dt_hizuke
		,zaiko.su_zaiko
	FROM (
		SELECT cd_hinmei, dt_hizuke, su_zaiko
		FROM wk_zaiko_nonyu_lead WITH(NOLOCK)
		-- 納入リードタイムを加味するときは終了日必須なのでBETWEENでOK
		WHERE dt_hizuke BETWEEN @con_hizuke AND @con_dt_end
	) zaiko
	INNER JOIN #tmp_hinmei HIN
	ON HIN.cd_hinmei = zaiko.cd_hinmei

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

	-- 計算在庫一時テーブルにインデックスを付与
	--CREATE NONCLUSTERED INDEX idx_zaiko ON #tmp_zaiko_keisan (dt_hizuke)
	END

	-- 計算在庫一時テーブルにインデックスを付与
	CREATE NONCLUSTERED INDEX idx_zaiko ON #tmp_zaiko_keisan (dt_hizuke)


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

		-- 検索条件で絞られた品名マスタ情報
		INNER JOIN #tmp_hinmei ma
		ON ma.cd_hinmei = za.cd_hinmei

		-- 最優先の購入先マスタ
		--LEFT JOIN (
		--	SELECT MIN(mky.no_juni_yusen) AS no_juni_yusen, mky.cd_hinmei
		--	FROM ma_konyu mky WITH(NOLOCK)
		--	WHERE mky.flg_mishiyo = @flg_shiyo
		--	GROUP BY mky.cd_hinmei
		--) yusen
		--ON ma.cd_hinmei = yusen.cd_hinmei
		--INNER JOIN (
		--	SELECT mkm.cd_hinmei, mkm.no_juni_yusen, mkm.cd_torihiki
		--	FROM ma_konyu mkm WITH(NOLOCK)
		--	WHERE mkm.flg_mishiyo = @flg_shiyo
		--) mk
		--ON mk.cd_hinmei = yusen.cd_hinmei
		--AND mk.no_juni_yusen = yusen.no_juni_yusen

		-- 取引先マスタ
		INNER JOIN (
			SELECT tori.cd_torihiki, tori.nm_torihiki
			FROM ma_torihiki tori WITH(NOLOCK)
			WHERE tori.flg_mishiyo = @flg_shiyo
		) mt
		ON mt.cd_torihiki = ma.cd_torihiki

		-- 納入数
		LEFT JOIN (
			-- 予定
			SELECT
				trn1.cd_hinmei AS cd_hinmei
				,trn1.dt_nonyu AS dt_nonyu
				,SUM(trn1.su_nonyu) AS su_nonyu
				,SUM(trn1.su_nonyu_hasu) AS su_nonyu_hasu
			FROM tr_nonyu trn1 WITH(NOLOCK)
			WHERE trn1.flg_yojitsu = @flg_yotei
			AND trn1.dt_nonyu >= @con_hizuke
			AND trn1.dt_nonyu >= @today
			GROUP BY trn1.cd_hinmei, trn1.dt_nonyu

			UNION ALL

			-- 実績
			SELECT
				trn2.cd_hinmei AS cd_hinmei
				,trn2.dt_nonyu AS dt_nonyu
				,SUM(trn2.su_nonyu) AS su_nonyu
				,SUM(trn2.su_nonyu_hasu) AS su_nonyu_hasu
			FROM tr_nonyu trn2 WITH(NOLOCK)
			WHERE trn2.flg_yojitsu = @flg_jisseki
			AND trn2.dt_nonyu >= @con_hizuke
			AND trn2.dt_nonyu < @today
			GROUP BY trn2.cd_hinmei, trn2.dt_nonyu
		) NONYU
		ON NONYU.dt_nonyu = za.dt_hizuke
		AND NONYU.cd_hinmei = za.cd_hinmei

		-- 開始日以降または開始日～終了日に存在する納入予定を取得する
		LEFT JOIN (
			-- 実績
			SELECT trn3.cd_hinmei
				,trn3.dt_nonyu AS dt_nonyu
				,SUM(trn3.su_nonyu) AS su_nonyu
			FROM tr_nonyu trn3 WITH(NOLOCK)
			WHERE trn3.dt_nonyu >= @con_hizuke
			AND trn3.dt_nonyu < @today
			AND trn3.flg_yojitsu = @flg_jisseki
			AND (trn3.su_nonyu > 0 OR trn3.su_nonyu_hasu > 0)
			AND (@con_dt_end IS NULL OR trn3.dt_nonyu <= @con_dt_end)
			GROUP BY trn3.cd_hinmei, trn3.dt_nonyu

			UNION ALL

			-- 予定
			SELECT trn4.cd_hinmei
				,trn4.dt_nonyu AS dt_nonyu
				,SUM(trn4.su_nonyu) AS su_nonyu
			FROM tr_nonyu trn4 WITH(NOLOCK)
			WHERE trn4.dt_nonyu >= @con_hizuke
			AND trn4.dt_nonyu >= @today
			AND trn4.flg_yojitsu = @flg_yotei
			AND (trn4.su_nonyu > 0 OR trn4.su_nonyu_hasu > 0)
			AND (@con_dt_end IS NULL OR trn4.dt_nonyu <= @con_dt_end)
			GROUP BY trn4.cd_hinmei, trn4.dt_nonyu
		) nonyu_yotei
		ON nonyu_yotei.cd_hinmei = za.cd_hinmei
		AND nonyu_yotei.dt_nonyu = za.dt_hizuke

		-- 開始日以降または開始日～終了日に存在する使用予定を取得する
		LEFT JOIN (
			-- 実績
			SELECT ts1.cd_hinmei
				,ts1.dt_shiyo AS dt_shiyo
				,SUM(ts1.su_shiyo) AS su_shiyo
			FROM tr_shiyo_yojitsu ts1 WITH(NOLOCK)
			WHERE ts1.dt_shiyo >= @con_hizuke
			AND ts1.dt_shiyo < @today
			AND ts1.flg_yojitsu = @flg_jisseki
			AND ts1.su_shiyo > 0
			AND (@con_dt_end IS NULL OR ts1.dt_shiyo <= @con_dt_end)
			GROUP BY ts1.cd_hinmei, ts1.dt_shiyo

			UNION ALL

			-- 予定
			SELECT cd_hinmei
				,ts2.dt_shiyo AS dt_shiyo
				,SUM(ts2.su_shiyo) AS su_shiyo
			FROM tr_shiyo_yojitsu ts2 WITH(NOLOCK)
			WHERE ts2.dt_shiyo >= @con_hizuke
			AND ts2.dt_shiyo >= @today
			AND ts2.flg_yojitsu = @flg_yotei
			AND ts2.su_shiyo > 0
			AND (@con_dt_end IS NULL OR ts2.dt_shiyo <= @con_dt_end)
			GROUP BY ts2.cd_hinmei, ts2.dt_shiyo
			) shiyo_yotei
		ON shiyo_yotei.cd_hinmei = za.cd_hinmei
		AND (
			  (@flg_leadtime = 0 AND shiyo_yotei.dt_shiyo = za.dt_hizuke) 
		       OR
		      (@flg_leadtime = 1 AND shiyo_yotei.dt_shiyo = DATEADD(DD, ma.dd_leadtime, za.dt_hizuke))
             )

		WHERE za.dt_hizuke >= @con_hizuke
		AND (@con_dt_end IS NULL OR za.dt_hizuke <= @con_dt_end)
		-- 2014.06.10:「全ての原資材を表示」の対応
		-- チェックなしの場合は開始日以降に納入予定、使用予定があるものだけを表示する
		AND (@all_genshizai = 1
			OR (nonyu_yotei.cd_hinmei IS NOT NULL
				OR shiyo_yotei.cd_hinmei IS NOT NULL)
		)
		-- 在庫から納入数を引くことで、納入数を加味しない前日の在庫となる
		-- 2015.07.23 納入数を使用単位に換算してから計算する
		--AND (ISNULL(za.su_zaiko, 0) - ISNULL(NONYU.su_nonyu, 0)) <= 0
		AND (ISNULL(za.su_zaiko, 0) - 
			 CASE WHEN ma.cd_tani = @cd_kg OR ma.cd_tani = @cd_li
			 THEN
				ISNULL(NONYU.su_nonyu, 0) * ma.wt_ko * ma.su_iri
				+ ISNULL(NONYU.su_nonyu_hasu, 0) / 1000
			 ELSE
				ISNULL(NONYU.su_nonyu, 0) * ma.wt_ko * ma.su_iri
				+ ISNULL(NONYU.su_nonyu_hasu, 0) * ma.wt_ko
			 --END ) <= 0
			 END ) < ma.su_zaiko_min

		GROUP BY za.cd_hinmei, ma.dd_leadtime
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

		-- 品名マスタ
		INNER JOIN (
			SELECT mh.cd_hinmei, mh.dd_leadtime, mh.su_zaiko_min
			FROM ma_hinmei mh WITH(NOLOCK)
			WHERE mh.flg_mishiyo = @flg_shiyo
		) ma
		ON ma.cd_hinmei = za.cd_hinmei

		-- 最優先の購入先マスタ
		LEFT JOIN (
			SELECT MIN(mky.no_juni_yusen) AS no_juni_yusen, mky.cd_hinmei
			FROM ma_konyu mky WITH(NOLOCK)
			WHERE mky.flg_mishiyo = @flg_shiyo
			GROUP BY mky.cd_hinmei
		) yusen
		ON ma.cd_hinmei = yusen.cd_hinmei
		INNER JOIN (
			SELECT mkm.cd_hinmei, mkm.no_juni_yusen, mkm.cd_torihiki
			FROM ma_konyu mkm WITH(NOLOCK)
			WHERE mkm.flg_mishiyo = @flg_shiyo
		) mk
		ON mk.cd_hinmei = yusen.cd_hinmei
		AND mk.no_juni_yusen = yusen.no_juni_yusen

		-- 取引先マスタ
		INNER JOIN (
			SELECT mtj.cd_torihiki, mtj.nm_torihiki
			FROM ma_torihiki mtj WITH(NOLOCK)
			WHERE mtj.flg_mishiyo = @flg_shiyo
		) mt
		ON mt.cd_torihiki = mk.cd_torihiki

		-- 開始日以降または開始日～終了日に存在する納入予定を取得する
		LEFT JOIN (
			-- 実績
			SELECT trn5.cd_hinmei
				,trn5.dt_nonyu AS dt_nonyu
				,SUM(trn5.su_nonyu) AS su_nonyu
			FROM tr_nonyu trn5 WITH(NOLOCK)
			WHERE trn5.dt_nonyu >= @con_hizuke
			AND trn5.dt_nonyu < @today
			AND trn5.flg_yojitsu = @flg_jisseki
			AND (trn5.su_nonyu > 0 OR trn5.su_nonyu_hasu > 0)
			AND (@con_dt_end IS NULL OR trn5.dt_nonyu <= @con_dt_end)
			GROUP BY trn5.cd_hinmei, trn5.dt_nonyu

			UNION ALL

			-- 予定
			SELECT trn6.cd_hinmei
				,trn6.dt_nonyu AS dt_nonyu
				,SUM(trn6.su_nonyu) AS su_nonyu
			FROM tr_nonyu trn6 WITH(NOLOCK)
			WHERE trn6.dt_nonyu >= @con_hizuke
			AND trn6.dt_nonyu >= @today
			AND trn6.flg_yojitsu = @flg_yotei
			AND (trn6.su_nonyu > 0 OR trn6.su_nonyu_hasu > 0)
			AND (@con_dt_end IS NULL OR trn6.dt_nonyu <= @con_dt_end)
			GROUP BY trn6.cd_hinmei, trn6.dt_nonyu
		) nonyu_yotei
		ON nonyu_yotei.cd_hinmei = za.cd_hinmei
		AND nonyu_yotei.dt_nonyu = za.dt_hizuke

		-- 開始日以降または開始日～終了日に存在する使用予定を取得する
		LEFT JOIN (
		-- 実績
			SELECT ts3.cd_hinmei
				,ts3.dt_shiyo AS dt_shiyo
				,SUM(ts3.su_shiyo) AS su_shiyo
			FROM tr_shiyo_yojitsu ts3 WITH(NOLOCK)
			WHERE ts3.dt_shiyo >= @con_hizuke
			AND ts3.dt_shiyo < @today
			AND ts3.flg_yojitsu = @flg_jisseki
			AND ts3.su_shiyo > 0
			AND (@con_dt_end IS NULL OR ts3.dt_shiyo <= @con_dt_end)
			GROUP BY ts3.cd_hinmei, ts3.dt_shiyo

			UNION ALL

			-- 予定
			SELECT ts4.cd_hinmei
				,ts4.dt_shiyo AS dt_shiyo
				,SUM(ts4.su_shiyo) AS su_shiyo
			FROM tr_shiyo_yojitsu ts4 WITH(NOLOCK)
			WHERE ts4.dt_shiyo >= @con_hizuke
			AND ts4.dt_shiyo >= @today
			AND ts4.flg_yojitsu = @flg_yotei
			AND ts4.su_shiyo > 0
			AND (@con_dt_end IS NULL OR ts4.dt_shiyo <= @con_dt_end)
			GROUP BY ts4.cd_hinmei, ts4.dt_shiyo
		) shiyo_yotei
		ON shiyo_yotei.cd_hinmei = za.cd_hinmei
		AND (
			  (@flg_leadtime = 0 AND shiyo_yotei.dt_shiyo = za.dt_hizuke) 
		       OR
		      (@flg_leadtime = 1 AND shiyo_yotei.dt_shiyo = DATEADD(DD, ma.dd_leadtime, za.dt_hizuke))
             )

		WHERE za.dt_hizuke >= @con_hizuke
		AND (@con_dt_end IS NULL OR za.dt_hizuke <= @con_dt_end)
		-- 2014.06.10:「全ての原資材を表示」の対応
		-- チェックなしの場合は開始日以降に納入予定、使用予定があるものだけを表示する
		AND (@all_genshizai = 1
			OR (nonyu_yotei.cd_hinmei IS NOT NULL
				OR shiyo_yotei.cd_hinmei IS NOT NULL)
		)
		AND ISNULL(za.su_zaiko, 0) < ma.su_zaiko_min

		GROUP BY za.cd_hinmei, ma.dd_leadtime

		-- ■「最大在庫も警告」にチェックが入っていた場合
		IF @con_zaiko_max_flg = 1
		BEGIN
			-- 最大在庫を上回る在庫を追加する
			INSERT INTO #tmp_target ( 
				cd_hinmei
				,dt_hizuke
			)
			SELECT za.cd_hinmei
				,MIN(dt_hizuke) AS dt_hizuke
			FROM #tmp_zaiko_keisan za WITH(NOLOCK)

			-- 品名マスタ
			INNER JOIN (
				SELECT mhmax.cd_hinmei, mhmax.su_zaiko_max, mhmax.dd_leadtime
				FROM ma_hinmei mhmax WITH(NOLOCK)
				WHERE mhmax.flg_mishiyo = @flg_shiyo
			) ma
			ON ma.cd_hinmei = za.cd_hinmei

			-- 最優先の購入先マスタ
			LEFT JOIN (
				SELECT MIN(mky3.no_juni_yusen) AS no_juni_yusen, mky3.cd_hinmei
				FROM ma_konyu mky3 WITH(NOLOCK)
				WHERE mky3.flg_mishiyo = @flg_shiyo
				GROUP BY mky3.cd_hinmei
			) yusen
			ON ma.cd_hinmei = yusen.cd_hinmei
			INNER JOIN (
				SELECT mkm3.cd_hinmei, mkm3.no_juni_yusen, mkm3.cd_torihiki
				FROM ma_konyu mkm3 WITH(NOLOCK)
				WHERE mkm3.flg_mishiyo = @flg_shiyo
			) mk
			ON mk.cd_hinmei = yusen.cd_hinmei
			AND mk.no_juni_yusen = yusen.no_juni_yusen

			-- 取引先マスタ
			INNER JOIN (
				SELECT mtm3.cd_torihiki, mtm3.nm_torihiki
				FROM ma_torihiki mtm3 WITH(NOLOCK)
				WHERE mtm3.flg_mishiyo = @flg_shiyo
			) mt
			ON mt.cd_torihiki = mk.cd_torihiki

			-- 開始日以降または開始日～終了日に存在する納入予定を取得する
			LEFT JOIN (
				-- 実績
				SELECT trn7.cd_hinmei
					,trn7.dt_nonyu AS dt_nonyu
					,SUM(trn7.su_nonyu) AS su_nonyu
				FROM tr_nonyu trn7 WITH(NOLOCK)
				WHERE trn7.dt_nonyu >= @con_hizuke
				AND trn7.dt_nonyu < @today
				AND trn7.flg_yojitsu = @flg_jisseki
				AND (trn7.su_nonyu > 0 OR trn7.su_nonyu_hasu > 0)
				AND (@con_dt_end IS NULL OR trn7.dt_nonyu <= @con_dt_end)
				GROUP BY trn7.cd_hinmei, trn7.dt_nonyu

				UNION ALL

				-- 予定
				SELECT trn8.cd_hinmei
					,trn8.dt_nonyu AS dt_nonyu
					,SUM(trn8.su_nonyu) AS su_nonyu
				FROM tr_nonyu trn8 WITH(NOLOCK)
				WHERE trn8.dt_nonyu >= @con_hizuke
				AND trn8.dt_nonyu >= @today
				AND trn8.flg_yojitsu = @flg_yotei
				AND (trn8.su_nonyu > 0 OR trn8.su_nonyu_hasu > 0)
				AND (@con_dt_end IS NULL OR trn8.dt_nonyu <= @con_dt_end)
				GROUP BY trn8.cd_hinmei, trn8.dt_nonyu
			) nonyu_yotei
			ON nonyu_yotei.cd_hinmei = za.cd_hinmei
			AND nonyu_yotei.dt_nonyu = za.dt_hizuke

			-- 開始日以降または開始日～終了日に存在する使用予定を取得する
			LEFT JOIN (
				-- 実績
				SELECT trs4.cd_hinmei
					,trs4.dt_shiyo AS dt_shiyo
					,SUM(trs4.su_shiyo) AS su_shiyo
				FROM tr_shiyo_yojitsu trs4 WITH(NOLOCK)
				WHERE trs4.dt_shiyo >= @con_hizuke
				AND trs4.dt_shiyo < @today
				AND trs4.flg_yojitsu = @flg_jisseki
				AND trs4.su_shiyo > 0
				AND (@con_dt_end IS NULL OR trs4.dt_shiyo <= @con_dt_end)
				GROUP BY trs4.cd_hinmei, trs4.dt_shiyo
			
				UNION ALL
			
				-- 予定
				SELECT trs5.cd_hinmei
					,trs5.dt_shiyo AS dt_shiyo
					,SUM(trs5.su_shiyo) AS su_shiyo
				FROM tr_shiyo_yojitsu trs5 WITH(NOLOCK)
				WHERE trs5.dt_shiyo >= @con_hizuke
				AND trs5.dt_shiyo >= @today
				AND trs5.flg_yojitsu = @flg_yotei
				AND trs5.su_shiyo > 0
				AND (@con_dt_end IS NULL OR trs5.dt_shiyo <= @con_dt_end)
				GROUP BY trs5.cd_hinmei, trs5.dt_shiyo
			) shiyo_yotei
			ON shiyo_yotei.cd_hinmei = za.cd_hinmei
			AND (
			  (@flg_leadtime = 0 AND shiyo_yotei.dt_shiyo = za.dt_hizuke) 
		       OR
		      (@flg_leadtime = 1 AND shiyo_yotei.dt_shiyo = DATEADD(DD, ma.dd_leadtime, za.dt_hizuke))
             )

			WHERE za.dt_hizuke >= @con_hizuke
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

	-- 納入リード在庫ワークをクリア
	DELETE wk_zaiko_nonyu_lead

	SELECT
		MIN_TBL.dt_hizuke AS dt_hizuke
		,MIN_TBL.dt_hizuke AS dt_hizuke_full
		,MIN_TBL.cd_hinmei AS cd_hinmei
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
	FROM #tmp_target MIN_TBL

	INNER JOIN (
		SELECT cd_hinmei, dt_hizuke, su_zaiko
		FROM tr_zaiko_keisan
		WHERE dt_hizuke BETWEEN @con_hizuke AND @con_dt_end
	) zaiko
	ON MIN_TBL.cd_hinmei = zaiko.cd_hinmei
	AND MIN_TBL.dt_hizuke = zaiko.dt_hizuke

	-- 品名マスタ
	INNER JOIN (
		SELECT
			sel_mh.cd_hinmei
			,sel_mh.nm_hinmei_ja
			,sel_mh.nm_hinmei_en
			,sel_mh.nm_hinmei_zh
			,sel_mh.nm_hinmei_vi
			,sel_mh.nm_nisugata_hyoji
			,sel_mh.dd_leadtime
			,sel_mh.su_zaiko_min
			,sel_mh.su_zaiko_max
			,sel_mh.cd_tani_shiyo
		FROM ma_hinmei sel_mh WITH(NOLOCK)
		WHERE sel_mh.flg_mishiyo = @flg_shiyo
	) hin
	ON hin.cd_hinmei = MIN_TBL.cd_hinmei

	-- 単位マスタ
	INNER JOIN (
		SELECT mta.cd_tani, mta.nm_tani
		FROM ma_tani mta WITH(NOLOCK)
		WHERE mta.flg_mishiyo = @flg_shiyo
	) tani
	ON tani.cd_tani = hin.cd_tani_shiyo

	-- 取引先マスタ
	LEFT JOIN (
		SELECT m_tori.cd_torihiki, m_tori.nm_torihiki
		FROM ma_torihiki m_tori WITH(NOLOCK)
		WHERE flg_mishiyo = @flg_shiyo
	) tori
	ON tori.cd_torihiki = (SELECT TOP 1 konyu.cd_torihiki
							FROM ma_konyu konyu WITH(NOLOCK)
							WHERE konyu.flg_mishiyo = @flg_shiyo
							AND konyu.cd_hinmei = MIN_TBL.cd_hinmei
							ORDER BY konyu.no_juni_yusen ASC
							)
	ORDER BY zaiko.cd_hinmei

	RETURN


 -- ///////////////////// --
 --  エラー処理 ：通常時
 -- ///////////////////// --
 Error_Handling:
  DELETE wk_zaiko_nonyu_lead
  PRINT @msg

  RETURN


END
GO
