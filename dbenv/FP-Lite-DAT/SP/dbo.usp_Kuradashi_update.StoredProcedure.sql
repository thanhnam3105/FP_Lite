IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_Kuradashi_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_Kuradashi_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：移動出庫画面　庫出受信
ファイル名	：usp_Kuradashi_update
作成日		：2014.11.05  ADMAX endo.y
更新日		：2015.07.29  ADMAX tsujita.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_Kuradashi_update](
	@dt_search		DATETIME	--検索条件/出庫日
	,@hinKbn		SMALLINT	--検索条件/品区分
	,@kbnZaiko		SMALLINT	--在庫区分.良品
	,@kbnShukko		SMALLINT	--入出庫区分.出庫
	,@kbnKakozan	SMALLINT	--入出庫区分.加工残
	,@flg_mishiyo	SMALLINT	--未使用フラグ.使用
	,@flg_kakutei	SMALLINT	--確定フラグ.確定
	,@miJusin		SMALLINT	--受信区分.未受信
	,@sumiJusin		SMALLINT	--受信区分.受信済
	,@cd_update		VARCHAR(10)	--ログインユーザーID
	,@kbnShizai		SMALLINT	--品区分.資材
	,@cd_niuke_basho VARCHAR(10)--検索条件/荷受場所
	,@cd_bunrui		VARCHAR(10)	--検索条件/分類
	,@KgCode		VARCHAR(10)	--単位コード：Kg
	,@LCode			VARCHAR(10)	--単位コード：L
	,@print_status	VARCHAR(1)	--検索条件/印刷ステータス
)
AS
BEGIN
	DECLARE @flgExist DECIMAL(2, 0)
	DECLARE @incSeq SMALLINT
	DECLARE @newSeq DECIMAL(8, 0)

	-- 検索条件/印刷ステータスの設定
	DECLARE @st_print SMALLINT
	IF LEN(@print_status) > 0
	BEGIN
		SET @st_print = CAST(@print_status AS SMALLINT)
	END

	--ワーク庫出の作成
	INSERT INTO wk_kuradashi (
		cd_hinmei,
		su_kuradashi_all,
		su_kuradashi_zan,
		su_iri,
		dt_shukko,
		dt_hizuke,
		cd_tani_nonyu
	)
	SELECT
		tk.cd_hinmei,
		--tk.su_kuradashi * mh.su_iri,
		--tk.su_kuradashi * mh.su_iri,
		CASE
			WHEN m_konyu.cd_tani_nonyu = @KgCode OR m_konyu.cd_tani_nonyu = @LCode
				THEN tk.su_kuradashi * mh.su_iri + (tk.su_kuradashi_hasu * 1.00 / 1000)
			ELSE tk.su_kuradashi * mh.su_iri + tk.su_kuradashi_hasu
		END AS su_kuradashi_all,
		CASE
			WHEN m_konyu.cd_tani_nonyu = @KgCode OR m_konyu.cd_tani_nonyu = @LCode
				THEN tk.su_kuradashi * mh.su_iri + (tk.su_kuradashi_hasu * 1.00 / 1000)
			ELSE tk.su_kuradashi * mh.su_iri + tk.su_kuradashi_hasu
		END AS su_kuradashi_zan,
		mh.su_iri,
		tk.dt_shukko,
		tk.dt_hizuke,
		m_konyu.cd_tani_nonyu
	FROM tr_kuradashi tk
	INNER JOIN (
		SELECT 
			su_iri
			,cd_hinmei
		FROM ma_hinmei
		WHERE kbn_hin = @hinKbn
			AND flg_mishiyo = @flg_mishiyo
	) mh
	ON tk.cd_hinmei = mh.cd_hinmei
	LEFT OUTER JOIN (
		SELECT 
			ma_konyu.cd_hinmei
			,cd_tani_nonyu
		FROM ma_konyu
		INNER JOIN (
			SELECT cd_hinmei
				,MIN(no_juni_yusen) AS juni
			FROM ma_konyu
			WHERE flg_mishiyo = 0
			GROUP BY cd_hinmei
		)mk
		ON mk.cd_hinmei = ma_konyu.cd_hinmei
			AND mk.juni = ma_konyu.no_juni_yusen
		WHERE ma_konyu.no_juni_yusen = mk.juni
			AND ma_konyu.flg_mishiyo = 0
	) m_konyu
	ON mh.cd_hinmei = m_konyu.cd_hinmei
	WHERE tk.dt_shukko = @dt_search
		AND tk.flg_kakutei = @flg_kakutei
		AND tk.kbn_status = @miJusin
	ORDER BY tk.cd_hinmei, tk.dt_hizuke

	-- カーソル用の変数リスト
	DECLARE @hinCode VARCHAR(14)
	DECLARE @kuradashiAll DECIMAL(18,3)
	DECLARE @hizuke DATETIME
	DECLARE @taniCode VARCHAR(10)


	DECLARE cursor_hinmei CURSOR FOR
	SELECT 
		cd_hinmei
		,su_kuradashi_all
		,dt_hizuke
		,cd_tani_nonyu
	FROM wk_kuradashi
	WHERE dt_shukko = @dt_search

	OPEN cursor_hinmei
		IF (@@error <> 0)
		BEGIN
			GOTO closeCursor
		END

	FETCH NEXT FROM cursor_hinmei INTO
		@hinCode
		,@kuradashiAll
		,@hizuke
		,@taniCode
	--ワーク庫出の件数分ループ開始
	WHILE @@FETCH_STATUS = 0
	BEGIN

		DECLARE @zaikoAll DECIMAL(18, 3) = 0
		
		IF OBJECT_ID('tempdb..#niukeinfo') IS NOT NULL
		BEGIN
			DROP TABLE #niukeinfo
		END
		--最新の荷受情報を格納する一時テーブルの作成
		CREATE TABLE #niukeinfo (
			no_seq DECIMAL(8, 0)
			,no_niuke VARCHAR(14)
			,dt_kigen DATETIME
			,dt_niuke DATETIME
		)
		--一時テーブルにデータ格納
		INSERT INTO #niukeinfo (
			no_seq
			,no_niuke
			,dt_kigen
			,dt_niuke
		)
		SELECT
			MAX(no_seq) AS seq
			,tr_niuke.no_niuke
			,dt_kigen
			,'1970-01-01 10:00:00.000'
		FROM tr_niuke
		-- 品名マスタ
		INNER JOIN ma_hinmei mh
		ON tr_niuke.cd_hinmei = mh.cd_hinmei
		INNER JOIN (SELECT no_niuke FROM tr_niuke WHERE no_seq = 1 AND dt_niuke <= @dt_search) yukozaiko
		ON tr_niuke.no_niuke = yukozaiko.no_niuke
		--WHERE dt_niuke <= @dt_search
		WHERE tr_niuke.cd_hinmei = @hinCode
			AND kbn_zaiko = @kbnZaiko
			AND (tr_niuke.kbn_hin = @kbnShizai or dt_kigen >= @dt_search)
			AND (( @cd_niuke_basho = '') OR (tr_niuke.cd_niuke_basho = @cd_niuke_basho))
			AND (( @cd_bunrui = '') OR (mh.cd_bunrui = @cd_bunrui))
			AND (LEN(@print_status) = 0 OR ISNULL(tr_niuke.flg_print, @flg_mishiyo) = @st_print)
			AND su_nonyu_jitsu + su_nonyu_jitsu_hasu IS NOT NULL
		GROUP BY tr_niuke.no_niuke,dt_kigen
		ORDER BY dt_kigen--,no_niuke

		UPDATE info
			SET info.dt_niuke = tn.dt_niuke
		FROM #niukeinfo info
		LEFT OUTER JOIN tr_niuke tn
		ON tn.no_niuke = info.no_niuke
		WHERE
			tn.no_seq = 1

		--①対象データの全在庫数を取得する
		SELECT
			@zaikoAll = CASE WHEN @taniCode = @KgCode OR @taniCode = @LCode
						THEN
							SUM(tn.su_zaiko) * mh.su_iri + (SUM(tn.su_zaiko_hasu) * 1.00 / 1000)
						ELSE
							SUM(tn.su_zaiko) * mh.su_iri + SUM(tn.su_zaiko_hasu)
						END
		FROM tr_niuke tn
		INNER JOIN #niukeinfo
			ON tn.no_niuke = #niukeinfo.no_niuke
				AND tn.no_seq = #niukeinfo.no_seq
		INNER JOIN ma_hinmei mh
			ON tn.cd_hinmei = mh.cd_hinmei
		WHERE 
			tn.kbn_zaiko = @kbnZaiko
				AND tn.su_zaiko + tn.su_zaiko_hasu <> 0
		GROUP BY mh.su_iri

		--現在の荷受トラン.在庫数を全て取得
		DECLARE @zaikoAllNew DECIMAL(18,3) = 0
		SELECT 
			@zaikoAllNew = CASE WHEN @taniCode = @KgCode OR @taniCode = @LCode
						THEN
							SUM(tn.su_zaiko) * mh.su_iri + (SUM(tn.su_zaiko_hasu) * 1.00 / 1000)
						ELSE
							(SUM(tn.su_zaiko) * mh.su_iri) + SUM(tn.su_zaiko_hasu)
						END
		FROM tr_niuke tn
		INNER JOIN #niukeinfo
			ON tn.no_niuke = #niukeinfo.no_niuke
		INNER JOIN ma_hinmei mh
			ON tn.cd_hinmei = mh.cd_hinmei
		WHERE
			tn.no_seq =
			(SELECT MAX(no_seq)
				FROM tr_niuke
				WHERE no_niuke = #niukeinfo.no_niuke
					AND kbn_zaiko = 1
			)
			AND tn.kbn_zaiko = 1
		GROUP BY mh.su_iri

		IF (@kuradashiAll <= @zaikoAll AND @kuradashiAll <= @zaikoAllNew)
		--①の数が庫出依頼数よりも多い場合
		BEGIN
			--ワーク荷受テーブルの追加
			INSERT INTO wk_niuke_kuradashi (
				no_niuke
				,su_zaiko
				,su_zaiko_hasu
				,no_seq
				,cd_hinmei
				,dt_niuke
			)
			SELECT
				tr_niuke.no_niuke
				,tr_niuke.su_zaiko
				,tr_niuke.su_zaiko_hasu
				,tr_niuke.no_seq
				,tr_niuke.cd_hinmei
				,#niukeinfo.dt_niuke
			FROM tr_niuke
			INNER JOIN #niukeinfo
				ON tr_niuke.no_niuke = #niukeinfo.no_niuke
					AND tr_niuke.no_seq = #niukeinfo.no_seq
			--WHERE tr_niuke.dt_niuke <= @dt_search
			WHERE tr_niuke.cd_hinmei = @hinCode
				--AND tr_niuke.no_seq = #niukeinfo.no_seq
				AND tr_niuke.kbn_zaiko = @kbnZaiko
				AND tr_niuke.su_zaiko + tr_niuke.su_zaiko_hasu <> 0
				AND tr_niuke.su_zaiko + tr_niuke.su_zaiko_hasu IS NOT NULL
			ORDER BY
				tr_niuke.dt_kigen, #niukeinfo.dt_niuke, tr_niuke.no_niuke --, tr_niuke.dt_niuke, tr_niuke.tm_nonyu_jitsu

			DECLARE @niukeNo VARCHAR(14)
			DECLARE @seqNo DECIMAL(8,0)
			DECLARE @zaikoSu DECIMAL(9,2)
			DECLARE @zaikoHasu DECIMAL(9,2)
			DECLARE @iriSu DECIMAL(5,0)
			DECLARE @kuradashiZan DECIMAL(18,3)

			SELECT TOP(1)
				@niukeNo = tn1.no_niuke
				,@seqNo = tn1.no_seq
				,@zaikoSu = tn1.su_zaiko
				,@zaikoHasu = tn1.su_zaiko_hasu
				,@iriSu = mh.su_iri
			FROM tr_niuke tn1
			INNER JOIN wk_niuke_kuradashi wnk
				ON tn1.no_niuke = wnk.no_niuke
					AND tn1.no_seq = wnk.no_seq
					AND tn1.kbn_zaiko = @kbnZaiko
			INNER JOIN ma_hinmei mh
				ON tn1.cd_hinmei = mh.cd_hinmei
			ORDER BY tn1.dt_kigen, wnk.dt_niuke, tn1.no_niuke

			SELECT
				@kuradashiZan = su_kuradashi_zan
			FROM wk_kuradashi
			WHERE cd_hinmei = @hinCode
				AND dt_shukko = @dt_search
				AND dt_hizuke = @hizuke

			--荷受トラン.在庫数 + 在庫端数 < ワーク庫出.残庫出数の場合
			WHILE (
					CASE WHEN @taniCode = @KgCode OR @taniCode = @LCode
						THEN
						((@zaikoSu * @iriSu) + @zaikoHasu * 1.00 / 1000)
						ELSE
						((@zaikoSu * @iriSu) + @zaikoHasu)
						END
					< @kuradashiZan)
			BEGIN
				--同日の出庫データが存在するか確認
				SELECT
					@flgExist = COUNT(*)
				FROM tr_niuke
				WHERE no_niuke = @niukeNo
				AND dt_niuke = @dt_search
				AND kbn_nyushukko = @kbnShukko

				IF (@flgExist <> 0)
				BEGIN
					--画面.検索条件/日付の出庫データが既に存在する場合
					--荷受トランのデータを更新（在庫数は0
					UPDATE tr_niuke
					SET
						su_zaiko = 0
						,su_zaiko_hasu = 0
						,su_shukko = tn.su_shukko + tn.su_zaiko
						,su_shukko_hasu = tn.su_shukko_hasu + tn.su_zaiko_hasu
						,cd_update = @cd_update
						,dt_update = GETUTCDATE()
					FROM tr_niuke tn
					JOIN wk_niuke_kuradashi wnk
						ON tn.no_niuke = wnk.no_niuke
							AND tn.no_seq = wnk.no_seq
					JOIN ma_hinmei mh
						ON tn.cd_hinmei = mh.cd_hinmei
					WHERE
						tn.dt_niuke = @dt_search
							AND tn.kbn_nyushukko = @kbnShukko
							AND tn.kbn_zaiko = @kbnZaiko
							AND tn.no_niuke = @niukeNo

					--関連するデータの在庫数を更新
					EXEC usp_IdoShukkoShosai_update02
						@no_niuke = @niukeNo
						,@kbn_zaiko = @kbnZaiko
						,@kbn_nyushukko = @kbnKakozan
						,@cdNonyuTani = @taniCode
				END
				ELSE BEGIN
					--画面.検索条件/日付の出庫データが存在しない場合
					-- 後続データのシーケンス番号をずらします
					UPDATE tr_niuke
						SET no_seq = no_seq + 1
					WHERE no_niuke = @niukeNo
						--AND no_seq > @seqNo
						AND no_seq <> 1 and no_seq >= @seqNo and dt_niuke > @dt_search
					IF @@ROWCOUNT > 0
					BEGIN
						SET @newSeq = @seqNo - 1
						SET @incSeq = 1
					END 
					ELSE
					BEGIN
						SET @newSeq = @seqNo
						SET @incSeq = 0
					END 
					--荷受トランのデータを追加（在庫数は0）
					INSERT INTO tr_niuke
					(
						no_niuke
						, dt_niuke
						, cd_hinmei
						, kbn_hin
						, cd_niuke_basho
						, kbn_nyushukko
						, kbn_zaiko
						, tm_nonyu_yotei
						, su_nonyu_yotei
						, su_nonyu_yotei_hasu
						, tm_nonyu_jitsu
						, su_nonyu_jitsu
						, su_nonyu_jitsu_hasu
						, su_zaiko
						, su_zaiko_hasu
						, su_shukko
						, su_shukko_hasu
						, su_kakozan
						, su_kakozan_hasu
						, dt_seizo
						, dt_kigen
						, kin_kuraire
						, no_lot
						, no_denpyo
						, biko
						, cd_torihiki
						, flg_kakutei
						, cd_hinmei_maker
						, nm_kuni
						, cd_maker
						, nm_maker
						, cd_maker_kojo
						, nm_maker_kojo
						, nm_hyoji_nisugata
						, nm_tani_nonyu
						, dt_nonyu
						, dt_label_hakko
						, cd_update
						, dt_update
						, no_seq
					)
					SELECT TOP(1)
						tn1.no_niuke
						, @dt_search
						, tn1.cd_hinmei
						, tn1.kbn_hin
						, tn1.cd_niuke_basho
						, @kbnShukko
						, @kbnZaiko
						, tm_nonyu_yotei
						, su_nonyu_yotei
						, su_nonyu_yotei_hasu
						, GETUTCDATE()
						, 0
						, 0
						, 0
						, 0
						, tn1.su_zaiko
						, tn1.su_zaiko_hasu
						, 0
						, 0
						, tn1.dt_seizo
						, tn1.dt_kigen
						, tn1.kin_kuraire
						, tn1.no_lot
						, tn1.no_denpyo
						, tn1.biko
						, tn1.cd_torihiki
						, 1
						, tn1.cd_hinmei_maker
						, tn1.nm_kuni
						, tn1.cd_maker
						, tn1.nm_maker
						, tn1.cd_maker_kojo
						, tn1.nm_maker_kojo
						, tn1.nm_hyoji_nisugata
						, tn1.nm_tani_nonyu
						, tn1.dt_nonyu
						, tn1.dt_label_hakko
						, @cd_update
						, GETUTCDATE()
						, @newSeq + 1
					FROM tr_niuke tn1
					INNER JOIN wk_niuke_kuradashi wnk
						ON tn1.no_niuke = wnk.no_niuke
							AND tn1.no_seq = wnk.no_seq + @incSeq
					INNER JOIN ma_hinmei mh
						ON tn1.cd_hinmei = mh.cd_hinmei
					WHERE tn1.no_niuke = @niukeNo

					--関連するデータの在庫数を更新
					EXEC usp_IdoShukkoShosai_update02
						@no_niuke = @niukeNo
						,@kbn_zaiko = @kbnZaiko
						,@kbn_nyushukko = @kbnKakozan
						,@cdNonyuTani = @taniCode
				END
				--ワーク荷受テーブルの1件目を削除する
				DELETE TOP(1)
				FROM wk_niuke_kuradashi
				WHERE cd_hinmei = @hinCode
					AND no_niuke = @niukeNo
					AND no_seq = @seqNo

				--ワーク庫出テーブルの残庫出数を更新する
				UPDATE wk_kuradashi
					SET su_kuradashi_zan = su_kuradashi_zan - 
											(CASE WHEN @taniCode = @KgCode OR @taniCode = @LCode
												THEN
													((@zaikoSu * @iriSu) + (@zaikoHasu * 1.00 / 1000))
												ELSE
													((@zaikoSu * @iriSu) + @zaikoHasu)
											 END)

				WHERE cd_hinmei = @hinCode
					AND dt_shukko = @dt_search
					AND dt_hizuke = @hizuke

				SELECT TOP(1)
					@niukeNo = tn1.no_niuke
					,@seqNo = tn1.no_seq
					,@zaikoSu = tn1.su_zaiko
					,@zaikoHasu = tn1.su_zaiko_hasu
					,@iriSu = mh.su_iri
				FROM tr_niuke tn1
				INNER JOIN wk_niuke_kuradashi wnk
					ON tn1.no_niuke = wnk.no_niuke
						AND tn1.no_seq = wnk.no_seq
						AND tn1.kbn_zaiko = @kbnZaiko
				INNER JOIN ma_hinmei mh
					ON tn1.cd_hinmei = mh.cd_hinmei
				ORDER BY
					tn1.dt_kigen, wnk.dt_niuke, tn1.no_niuke

				SELECT 
					@kuradashiZan = su_kuradashi_zan
				FROM wk_kuradashi
				WHERE cd_hinmei = @hinCode
					AND dt_shukko = @dt_search
					AND dt_hizuke = @hizuke
			END
			--荷受トラン.在庫数 + 在庫端数 >= ワーク庫出.残庫出数になった場合
			--同日の出庫データが存在するか確認
			SELECT
				@flgExist = COUNT(*)
			FROM tr_niuke
			WHERE no_niuke = @niukeNo
				AND dt_niuke = @dt_search
				AND kbn_nyushukko = @kbnShukko

			IF (@flgExist <> 0)
			BEGIN
				--画面.検索条件/日付の出庫データが既に存在する場合
				--荷受トランのデータを更新（出庫数は計算する）
				UPDATE tr_niuke
				SET
					su_zaiko = (CASE WHEN @taniCode = @KgCode OR @taniCode = @LCode
									THEN
										ROUND((((tn.su_zaiko * mh.su_iri) + (tn.su_zaiko_hasu * 1.00 / 1000) - @kuradashiZan) / mh.su_iri), 0, 1)
									ELSE
										ROUND((((tn.su_zaiko * mh.su_iri) + tn.su_zaiko_hasu - @kuradashiZan) / mh.su_iri), 0, 1)
								END)
					,su_zaiko_hasu = (CASE WHEN @taniCode = @KgCode OR @taniCode = @LCode
									THEN
										((tn.su_zaiko * mh.su_iri) + (tn.su_zaiko_hasu * 1.00 / 1000) - @kuradashiZan) % mh.su_iri * 1000
									ELSE
										((tn.su_zaiko * mh.su_iri) + tn.su_zaiko_hasu - @kuradashiZan) % mh.su_iri
									END)
					,su_shukko = tn.su_shukko + (ROUND((@kuradashiZan / mh.su_iri), 0, 1))
					,su_shukko_hasu = tn.su_shukko_hasu + (CASE WHEN @taniCode = @KgCode OR @taniCode = @LCode
															THEN
															(@kuradashiZan % mh.su_iri) * 1000
															ELSE
															(@kuradashiZan % mh.su_iri)
															END)
					,cd_update = @cd_update
					,dt_update = GETUTCDATE()
				FROM tr_niuke tn
				JOIN wk_niuke_kuradashi wnk
					ON tn.no_niuke = wnk.no_niuke
						AND tn.no_seq = wnk.no_seq
				JOIN ma_hinmei mh
					ON tn.cd_hinmei = mh.cd_hinmei
				WHERE
					tn.dt_niuke = @dt_search
					AND tn.kbn_nyushukko = @kbnShukko
					AND tn.kbn_zaiko = @kbnZaiko
					AND tn.no_niuke = @niukeNo
					
				--関連するデータの在庫数を更新
				EXEC usp_IdoShukkoShosai_update02
					@no_niuke = @niukeNo
					,@kbn_zaiko = @kbnZaiko
					,@kbn_nyushukko = @kbnKakozan
					,@cdNonyuTani = @taniCode
			END
			ELSE BEGIN
				--画面.検索条件/日付の出庫データが存在しない場合
				-- 後続データのシーケンス番号をずらします
				UPDATE tr_niuke
					SET no_seq = no_seq + 1
				WHERE no_niuke = @niukeNo
					--AND no_seq > @seqNo
					AND no_seq <> 1 and no_seq >= @seqNo and dt_niuke > @dt_search
					IF @@ROWCOUNT > 0
					BEGIN
						SET @newSeq = @seqNo - 1
						SET @incSeq = 1
					END 
					ELSE
					BEGIN
						SET @newSeq = @seqNo
						SET @incSeq = 0
					END 

				--荷受トランのデータを追加（出庫数は計算する）
				INSERT INTO tr_niuke
				(
					no_niuke
					, dt_niuke
					, cd_hinmei
					, kbn_hin
					, cd_niuke_basho
					, kbn_nyushukko
					, kbn_zaiko
					, tm_nonyu_yotei
					, su_nonyu_yotei
					, su_nonyu_yotei_hasu
					, tm_nonyu_jitsu
					, su_nonyu_jitsu
					, su_nonyu_jitsu_hasu
					, su_zaiko
					, su_zaiko_hasu
					, su_shukko
					, su_shukko_hasu
					, su_kakozan
					, su_kakozan_hasu
					, dt_seizo
					, dt_kigen
					, kin_kuraire
					, no_lot
					, no_denpyo
					, biko
					, cd_torihiki
					, flg_kakutei
					, cd_hinmei_maker
					, nm_kuni
					, cd_maker
					, nm_maker
					, cd_maker_kojo
					, nm_maker_kojo
					, nm_hyoji_nisugata
					, nm_tani_nonyu
					, dt_nonyu
					, dt_label_hakko
					, cd_update
					, dt_update
					, no_seq
				)
				SELECT TOP(1)
					tn1.no_niuke
					, @dt_search
					, tn1.cd_hinmei
					, tn1.kbn_hin
					, tn1.cd_niuke_basho
					, @kbnShukko
					, @kbnZaiko
					, tm_nonyu_yotei
					, su_nonyu_yotei
					, su_nonyu_yotei_hasu
					, GETUTCDATE()
					, 0
					, 0
					, CASE WHEN @taniCode = @KgCode OR @taniCode = @LCode
						THEN
							ROUND((((tn1.su_zaiko * mh.su_iri) + (tn1.su_zaiko_hasu * 1.00 / 1000) - @kuradashiZan) / mh.su_iri), 0, 1)
						ELSE
							ROUND((((tn1.su_zaiko * mh.su_iri) + tn1.su_zaiko_hasu - @kuradashiZan) / mh.su_iri), 0, 1)
						END
					, CASE WHEN @taniCode = @KgCode OR @taniCode = @LCode
						THEN
							((tn1.su_zaiko * mh.su_iri) + (tn1.su_zaiko_hasu * 1.00 / 1000) - @kuradashiZan) % mh.su_iri * 1000
						ELSE
							((tn1.su_zaiko * mh.su_iri) + tn1.su_zaiko_hasu - @kuradashiZan) % mh.su_iri
						END
					, ROUND((@kuradashiZan / mh.su_iri), 0, 1)
					, CASE WHEN @taniCode = @KgCode OR @taniCode = @LCode
						THEN
							@kuradashiZan % mh.su_iri * 1000
						ELSE
							@kuradashiZan % mh.su_iri
						END
					, 0
					, 0
					, tn1.dt_seizo
					, tn1.dt_kigen
					, tn1.kin_kuraire
					, tn1.no_lot
					, tn1.no_denpyo
					, tn1.biko
					, tn1.cd_torihiki
					, 1
					, tn1.cd_hinmei_maker
					, tn1.nm_kuni
					, tn1.cd_maker
					, tn1.nm_maker
					, tn1.cd_maker_kojo
					, tn1.nm_maker_kojo
					, tn1.nm_hyoji_nisugata
					, tn1.nm_tani_nonyu
					, tn1.dt_nonyu
					, tn1.dt_label_hakko
					, @cd_update
					, GETUTCDATE()
					, @newSeq + 1
				FROM tr_niuke tn1
				INNER JOIN wk_niuke_kuradashi wnk
					ON tn1.no_niuke = wnk.no_niuke
						AND tn1.no_seq = wnk.no_seq + @incSeq
				INNER JOIN ma_hinmei mh
					ON tn1.cd_hinmei = mh.cd_hinmei
				WHERE tn1.no_niuke = @niukeNo

				--関連するデータの在庫数を更新
				EXEC usp_IdoShukkoShosai_update02
					@no_niuke = @niukeNo
					,@kbn_zaiko = @kbnZaiko
					,@kbn_nyushukko = @kbnKakozan
					,@cdNonyuTani = @taniCode

			END
			--ワーク荷受テーブルを削除する
			DELETE dbo.wk_niuke_kuradashi
			--tr_kuradashiの受信ステータスを受信済みにし、次の品名コードの処理に進む
			UPDATE tr_kuradashi
				SET kbn_status = @sumiJusin
				,cd_update = @cd_update
				,dt_update = GETUTCDATE()
			WHERE cd_hinmei = @hinCode
				AND dt_shukko = @dt_search
				AND flg_kakutei = @flg_kakutei
				AND kbn_status <> @sumiJusin
				AND dt_hizuke = @hizuke

			DELETE TOP(1)
			FROM wk_kuradashi
			WHERE dt_shukko = @dt_search
				AND cd_hinmei = @hinCode
				AND dt_hizuke = @hizuke
		END
	--カーソルを次の行へ
	FETCH NEXT FROM cursor_hinmei INTO
		@hinCode
		,@kuradashiAll
		,@hizuke
		,@taniCode
	END

	-- //////////// --
	--  終了処理
	-- //////////// --
CLOSECURSOR:
	CLOSE cursor_hinmei
	DEALLOCATE cursor_hinmei
	--ワーク庫出テーブルの削除
	DELETE dbo.wk_kuradashi
	--ワーク荷受テーブルの削除
	DELETE dbo.wk_niuke_kuradashi

END



GO
