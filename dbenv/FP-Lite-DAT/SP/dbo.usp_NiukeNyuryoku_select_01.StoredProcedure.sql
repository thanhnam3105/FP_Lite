IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_select_01') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_select_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：荷受入力　荷受予定検索
ファイル名	：usp_NiukeNyuryoku_select_01
入力引数	：@dt_niuke, @cd_niuke, @flg_kakutei
			  , @shiyoMishiyoFlg, @yoteiYojitsuFlg, @jissekiYojitsuFlg
			  , @shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn, @skip
			  , @shiireName, @top, @isExcel
出力引数	：
戻り値		：
作成日		：2013.11.09  ADMAX kakute.y
更新日		：2015.10.13  MJ    ueno.k
更新日		：2016.05.26  BRC   motojima.m
更新日		：2016.09.01  BRC   motojima.m 荷受入力行追加対応
更新日		：2016.11.15  BRC   cho.k 荷受実績存在フラグ追加
更新日		：2016.11.22  BRC   kanehira.d 入出庫区分追加
更新日		：2016.12.13  BRC   motojima.m 中文対応
更新日		：2016.02.20  BRC   cho.k Q&BサポートNo.41対応
更新日		：2016.03.08  BRC   cho.k サポートNo.7対応
更新日		：2018.01.12  BRC   cho.k HQPサポートNo009対応
更新日		：2022.02.07  BRC   sato.t #1648対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_select_01]
	-- 検索条件
	@dt_niuke				DATETIME		-- 荷受日
	, @cd_niuke				VARCHAR(10)		-- 荷受場所コード
	, @flg_kakutei			SMALLINT		-- 未確定のみ
	-- コード
	, @shiyoMishiyoFlg		SMALLINT		-- 未使用フラグ.使用
	, @yoteiYojitsuFlg		SMALLINT		-- 納入予実フラグ.予定
	, @jissekiYojitsuFlg	SMALLINT		-- 納入予実フラグ.実績
	, @shiireNyushukoKbn	SMALLINT		-- 入出庫区分.仕入
	, @addKbn	            SMALLINT		-- 入出庫区分.追加
	, @sotoinyuNyushukoKbn	SMALLINT		-- 入出庫区分.外移入
	, @ryohinZaikoKbn		SMALLINT		-- 在庫区分.良品
	--, @shiireName			VARCHAR(50)		-- 入出庫区分名.仕入 -- 変動表から予定を立てた時に使用(EXCEL出力用) -- 使用しない
	, @shiireName			NVARCHAR(50)	-- 入出庫区分名.仕入 -- 変動表から予定を立てた時に使用(EXCEL出力用) -- 使用しない
	
	, @skip					DECIMAL(10)		-- スキップ
	, @top					DECIMAL(10)		-- 検索データ上限
	, @isExcel				BIT				-- エクセルフラグ
AS
BEGIN
	
	-- 初期化値
	DECLARE @initBlank	VARCHAR
	DECLARE @initZero	SMALLINT
	DECLARE @initTime	DATETIME
	-- フラグ値
	DECLARE @zeroToFlg	SMALLINT
	DECLARE @oneToFlg	SMALLINT
	 
	DECLARE @start		DECIMAL(10)
    DECLARE @end		DECIMAL(10)
	DECLARE @true		BIT
	DECLARE @false		BIT
	
	-- 値セット
	SET @initBlank	= ''
	SET @initZero	= 0
	SET @initTime	= '00:00:00.000'
	
	SET @zeroToFlg	= 0
	SET @oneToFlg	= 1
	
    SET	@start		= @skip + 1
    SET	@end		= @skip + @top
    SET	@true		= 1
    SET	@false		= 0;
    
    -- 検索
    WITH cte AS
    
		(
			SELECT
				*
				--,ROW_NUMBER() OVER (ORDER BY uni.tm_nonyu_yotei, uni.cd_hinmei) AS RN
				,ROW_NUMBER() OVER (ORDER BY uni.cd_torihiki, uni.cd_bunrui, uni.cd_hinmei) AS RN
			FROM
				(
					-- 生産管理（原資材変動表、納入予定リスト作成画面）で作成された荷受予定
					 SELECT
						-- 表示項目
						  ISNULL(niuke.flg_kakutei, @zeroToFlg) AS flg_kakutei						-- 確定(荷受トラン)
						, ISNULL(bunrui.nm_bunrui, '') AS nm_bunrui									-- 品分類
						, nonyu.cd_hinmei															-- 品名コード
						, ISNULL(hin.nm_hinmei_ja, '') AS nm_hinmei_ja
						, ISNULL(hin.nm_hinmei_en, '') AS nm_hinmei_en
						, ISNULL(hin.nm_hinmei_zh, '') AS nm_hinmei_zh
						, ISNULL(hin.nm_hinmei_vi, '') AS nm_hinmei_vi
						, ISNULL(hin.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji
						, ISNULL(nyushukko.nm_kbn_nyushukko, @initBlank) AS nm_kbn_nyushukko		-- 入庫区分		-- EXCEL出力用(画面では未使用)
						, ISNULL(torihiki_1.nm_torihiki, @initBlank) AS nm_torihiki
						, ISNULL(hokan.nm_hokan_kbn, @initBlank) AS nm_hokan_kbn
						, @initTime AS tm_nonyu_yotei												-- 予定時刻
						, ISNULL(nonyu.su_nonyu, @initZero)	AS su_nonyu_yotei						-- 予定C/S数
						, ISNULL(nonyu.su_nonyu_hasu, @initZero) AS su_nonyu_yotei_hasu				-- 予定端数
						-- 非表示項目
						, ISNULL(niuke.kbn_nyushukko, @shiireNyushukoKbn) AS kbn_nyushukko			-- 入出庫区分
						, nonyu.cd_torihiki															-- 取引先コード
						, hin.kbn_hokan
						, hin.biko
						, ISNULL(niuke.no_niuke, @zeroToFlg) AS no_niuke										-- 荷受番号
						, @oneToFlg AS flg_nonyu															-- 納入予実トラン有無フラグ
						, hin.cd_niuke_basho														-- 荷受場所コード
						, ISNULL(nonyu_jitsu.flg_yojitsu, @zeroToFlg) AS flg_jisseki							-- 納入実績有無フラグ
						, konyu.su_iri
						, konyu.wt_nonyu
						, ISNULL(nonyu.flg_kakutei, @zeroToFlg) AS flg_kakutei_nonyu							-- 確定フラグ(納入予実トラン)
						, hin.dd_shomi
						, konyu.cd_tani_nonyu
						, tani.nm_tani
						, hin.kbn_zei
						, hin.kbn_hin
						, konyu.cd_torihiki2														-- 取引先コード2
						, konyu.tan_nonyu
						, bunrui.cd_bunrui
						, konyu.cd_tani_nonyu_hasu
						, tani_hasu.nm_tani AS nm_tani_hasu
						, nonyu.kbn_nyuko AS kbn_nyuko												-- 入庫区分
						, nonyu.no_nonyu AS no_nonyu_yotei											-- 納入予定番号
						, nonyu.no_nonyu AS no_nonyu_yotei_disp										-- 表示用納入予定番号
						, CASE
							WHEN niuke.no_niuke IS NULL THEN 0
							ELSE 1
						  END AS flg_niuke_jisseki													-- 荷受実績有無フラグ 
						, nonyu.no_nonyusho															-- 納入書番号
					FROM 
						(
							SELECT
								*
							FROM tr_nonyu yotei
							WHERE yotei.flg_yojitsu = @yoteiYojitsuFlg
							  AND yotei.dt_nonyu >= @dt_niuke
							  AND yotei.dt_nonyu < DATEADD(DD,1,@dt_niuke)
						) nonyu
					LEFT OUTER JOIN tr_niuke niuke
					  ON niuke.no_nonyu = nonyu.no_nonyu
--					  AND niuke.flg_kakutei IN (ABS(ABS(@flg_kakutei)-1),0,NULL)
					 AND niuke.kbn_nyushukko = @shiireNyushukoKbn
					LEFT OUTER JOIN (
							SELECT
								no_nonyu_yotei
								, @jissekiYojitsuFlg AS flg_yojitsu
							FROM tr_nonyu jisseki
							WHERE jisseki.flg_yojitsu = @jissekiYojitsuFlg
							  AND jisseki.dt_nonyu >= @dt_niuke
							  AND jisseki.dt_nonyu < DATEADD(DD,1,@dt_niuke)
							GROUP BY no_nonyu_yotei
					  ) nonyu_jitsu
					  ON nonyu_jitsu.no_nonyu_yotei = nonyu.no_nonyu
					-- 品名マスタ
					INNER JOIN ma_hinmei hin
					  ON hin.cd_hinmei = nonyu.cd_hinmei
					  AND hin.cd_niuke_basho = @cd_niuke
					  AND hin.flg_mishiyo = @shiyoMishiyoFlg
					-- 分類マスタ
					LEFT OUTER JOIN ma_bunrui bunrui
					  ON bunrui.kbn_hin = hin.kbn_hin
					  AND bunrui.cd_bunrui = hin.cd_bunrui
					  AND bunrui.flg_mishiyo = @shiyoMishiyoFlg
					-- 保管区分マスタ
					LEFT OUTER JOIN ma_kbn_hokan hokan
					  ON hokan.cd_hokan_kbn = hin.kbn_hokan
					  AND hokan.flg_mishiyo = @shiyoMishiyoFlg
					-- 取引先マスタ（取引先１）
					LEFT OUTER JOIN	ma_torihiki torihiki_1
					  ON torihiki_1.cd_torihiki = nonyu.cd_torihiki
					  AND torihiki_1.flg_mishiyo = @shiyoMishiyoFlg
					-- 購入先マスタ
					LEFT OUTER JOIN ma_konyu konyu
					  ON konyu.cd_hinmei = nonyu.cd_hinmei
					  AND konyu.cd_torihiki = nonyu.cd_torihiki
					  AND konyu.flg_mishiyo = @shiyoMishiyoFlg
					-- 単位マスタ（納入単位）
					LEFT OUTER JOIN	ma_tani tani
					  ON tani.cd_tani = konyu.cd_tani_nonyu
					  AND tani.flg_mishiyo = @shiyoMishiyoFlg
					-- 単位マスタ（納入単位）
					LEFT OUTER JOIN	ma_tani tani_hasu
					  ON tani_hasu.cd_tani = konyu.cd_tani_nonyu_hasu
					  AND tani_hasu.flg_mishiyo = @shiyoMishiyoFlg
					-- 入出庫区分
					LEFT OUTER JOIN ma_kbn_nyushukko nyushukko
					  ON nyushukko.kbn_nyushukko = @shiireNyushukoKbn
					WHERE
						niuke.flg_kakutei IS NULL
					 OR niuke.flg_kakutei IN (ABS(ABS(@flg_kakutei)-1),0)

					UNION ALL

					-- 荷受（荷受入力画面）で追加した荷受予定
					SELECT
						-- 表示項目
						  ISNULL(niuke.flg_kakutei, @zeroToFlg) AS flg_kakutei						-- 確定(荷受トラン)
						, ISNULL(bunrui.nm_bunrui, '') AS nm_bunrui									-- 品分類
						, niuke.cd_hinmei															-- 品名コード
						, ISNULL(hin.nm_hinmei_ja, '') AS nm_hinmei_ja
						, ISNULL(hin.nm_hinmei_en, '') AS nm_hinmei_en
						, ISNULL(hin.nm_hinmei_zh, '') AS nm_hinmei_zh
						, ISNULL(hin.nm_hinmei_vi, '') AS nm_hinmei_vi
						, ISNULL(hin.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji
						, ISNULL(nyushukko.nm_kbn_nyushukko, @initBlank) AS nm_kbn_nyushukko		-- 入庫区分		-- EXCEL出力用(画面では未使用)
						, ISNULL(torihiki_1.nm_torihiki, @initBlank) AS nm_torihiki
						, ISNULL(hokan.nm_hokan_kbn, @initBlank) AS nm_hokan_kbn
						, niuke.tm_nonyu_yotei														-- 予定時刻
						, niuke.su_nonyu_yotei														-- 予定C/S数
						, niuke.su_nonyu_yotei_hasu													-- 予定端数
						-- 非表示項目
						, niuke.kbn_nyushukko AS kbn_nyushukko										-- 入出庫区分
						, niuke.cd_torihiki															-- 取引先コード
						, hin.kbn_hokan
						, hin.biko
						, niuke.no_niuke															-- 荷受番号
						, @zeroToFlg AS flg_nonyu													-- 納入予実トラン有無フラグ
						, hin.cd_niuke_basho														-- 荷受場所コード
						, @zeroToFlg AS flg_jisseki													-- 納入実績有無フラグ
						, konyu.su_iri
						, konyu.wt_nonyu
						, @zeroToFlg AS flg_kakutei_nonyu											-- 確定フラグ(納入予実トラン)
						, hin.dd_shomi
						, konyu.cd_tani_nonyu
						, tani.nm_tani
						, hin.kbn_zei
						, hin.kbn_hin
						, konyu.cd_torihiki2														-- 取引先コード2
						, konyu.tan_nonyu
						, bunrui.cd_bunrui
						, konyu.cd_tani_nonyu_hasu
						, tani_hasu.nm_tani AS nm_tani_hasu
						, niuke.kbn_nyuko AS kbn_nyuko												-- 入庫区分
						, niuke.no_nonyu AS no_nonyu_yotei											-- 納入予定番号
						, NULL AS no_nonyu_yotei_disp										-- 表示用納入予定番号
						, CASE
							WHEN niuke.su_nonyu_jitsu = 0 AND niuke.su_nonyu_jitsu_hasu = 0 THEN 0
							ELSE 1
						  END AS flg_niuke_jisseki													-- 荷受実績有無フラグ 
						, NULL AS no_nonyusho														-- 納入書番号
					FROM (
							-- 実績入力済みの荷受予定
							SELECT
								MIN(no_niuke) AS no_niuke
							FROM tr_niuke tr
							WHERE tr.tm_nonyu_yotei >= @dt_niuke
							  AND tr.tm_nonyu_yotei < DATEADD(DD,1,@dt_niuke)
							  AND tr.kbn_nyushukko = @addKbn
							  --AND tr.flg_kakutei IN (ABS(ABS(@flg_kakutei)-1),0,NULL)
							  AND tr.cd_niuke_basho = @cd_niuke
							  AND tr.no_nonyu IS NOT NULL
							GROUP BY no_nonyu
							
							UNION ALL
							
							-- 実績なしで保存した荷受予定
							SELECT
								no_niuke
							FROM tr_niuke tr
							WHERE tr.tm_nonyu_yotei >= @dt_niuke
							  AND tr.tm_nonyu_yotei < DATEADD(DD,1,@dt_niuke)
							  AND tr.kbn_nyushukko = @addKbn
							  --AND tr.flg_kakutei IN (ABS(ABS(@flg_kakutei)-1),0,NULL)
							  AND tr.cd_niuke_basho = @cd_niuke
							  AND tr.no_nonyu IS NULL
						) yotei
					INNER JOIN tr_niuke niuke
					  ON niuke.no_niuke = yotei.no_niuke
					  AND niuke.kbn_nyushukko = @addKbn
					  AND niuke.flg_kakutei IN (ABS(ABS(@flg_kakutei)-1),0,NULL)
					-- 品名マスタ
					LEFT OUTER JOIN ma_hinmei hin
					  ON hin.cd_hinmei = niuke.cd_hinmei
					  AND hin.flg_mishiyo = @shiyoMishiyoFlg
					-- 分類マスタ
					LEFT OUTER JOIN ma_bunrui bunrui
					  ON bunrui.kbn_hin = hin.kbn_hin
					  AND bunrui.cd_bunrui = hin.cd_bunrui
					  AND bunrui.flg_mishiyo = @shiyoMishiyoFlg
					-- 保管区分マスタ
					LEFT OUTER JOIN ma_kbn_hokan hokan
					  ON hokan.cd_hokan_kbn = hin.kbn_hokan
					  AND hokan.flg_mishiyo = @shiyoMishiyoFlg
					-- 取引先マスタ（取引先１）
					LEFT OUTER JOIN	ma_torihiki torihiki_1
					  ON torihiki_1.cd_torihiki = niuke.cd_torihiki
					  AND torihiki_1.flg_mishiyo = @shiyoMishiyoFlg
					-- 購入先マスタ
					LEFT OUTER JOIN ma_konyu konyu
					  ON konyu.cd_hinmei = niuke.cd_hinmei
					  AND konyu.cd_torihiki = niuke.cd_torihiki
					  AND konyu.flg_mishiyo = @shiyoMishiyoFlg
					-- 単位マスタ（納入単位）
					LEFT OUTER JOIN	ma_tani tani
					  ON tani.cd_tani = konyu.cd_tani_nonyu
					  AND tani.flg_mishiyo = @shiyoMishiyoFlg
					-- 単位マスタ（納入単位）
					LEFT OUTER JOIN	ma_tani tani_hasu
					  ON tani_hasu.cd_tani = konyu.cd_tani_nonyu_hasu
					  AND tani_hasu.flg_mishiyo = @shiyoMishiyoFlg
					-- 入出庫区分
					LEFT OUTER JOIN ma_kbn_nyushukko nyushukko
					  ON nyushukko.kbn_nyushukko = niuke.kbn_nyushukko
						
 
 /* ▼2017/02/20 Q&BサポートNo.41対応により削除▼
    				SELECT
    					DISTINCT						-- 荷受トラン(実績なし)
						--表示項目
						ISNULL(t_niu.flg_kakutei,@zeroToFlg) flg_kakutei							-- 確定(荷受トラン)
						,ISNULL(m_bunrui.nm_bunrui, '') nm_bunrui									-- 品分類
						,t_niu.cd_hinmei															-- 品名コード
						,ISNULL(m_hinmei.nm_hinmei_en, '') AS nm_hinmei_en							-- 品名(英語)
						,ISNULL(m_hinmei.nm_hinmei_ja, '') AS nm_hinmei_ja							-- 品名(日本語)
						,ISNULL(m_hinmei.nm_hinmei_zh, '') AS nm_hinmei_zh							-- 品名(中国語)
						,ISNULL(m_hinmei.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji				-- 荷姿
						,ISNULL(m_kbn_nyushukko.nm_kbn_nyushukko,@initBlank) AS nm_kbn_nyushukko	-- 入庫区分		-- EXCEL出力用(画面では未使用)
						,ISNULL(m_torihiki.nm_torihiki,@initBlank) AS nm_torihiki					-- 取引先
						,ISNULL(m_kbn_hokan.nm_hokan_kbn,@initBlank) AS nm_hokan_kbn				-- 品位状態
						,t_niu.tm_nonyu_yotei														-- 予定時刻
						,t_niu.su_nonyu_yotei														-- 予定C/S数
						,t_niu.su_nonyu_yotei_hasu													-- 予定端数
						--非表示項目
						,ISNULL(t_niu.kbn_nyushukko,0) AS kbn_nyushukko								-- 入出庫区分
						,t_niu.cd_torihiki															-- 取引先コード
						,m_hinmei.kbn_hokan															-- 保管区分
						,m_hinmei.biko																-- 備考(品名マスタ)
						,t_niu.no_niuke																-- 荷受番号
						,@zeroToFlg flg_nonyu														-- 納入予実トラン有無フラグ
						,t_niu.cd_niuke_basho														-- 荷受場所コード
						,@zeroToFlg flg_jisseki														-- 実績有無フラグ
						,m_konyu.su_iri																-- 入数
						,@zeroToFlg flg_kakutei_nonyu												-- 確定フラグ(納入予実トラン)
						,m_hinmei.dd_shomi															-- 賞味期間
						,m_konyu.cd_tani_nonyu														-- 納入単位コード
						,m_tani.nm_tani																-- 納入単位名
						,m_hinmei.kbn_zei															-- 税区分
						,m_hinmei.kbn_hin															-- 品区分
						,m_konyu.cd_torihiki2														-- 取引先コード2
						,m_konyu.tan_nonyu															-- 納入単価
						,m_bunrui.cd_bunrui
						,m_konyu.cd_tani_nonyu_hasu													-- 納入単位コード(端数)
						,m_tani_hasu.nm_tani AS nm_tani_hasu										-- 納入単位名(端数)
						,t_niu.kbn_nyuko AS kbn_nyuko
						,t_niu.no_nonyu AS no_nonyu_yotei
						,NULL AS no_nonyu_yotei_disp
						,CASE
							WHEN ISNULL(t_niu.su_nonyu_jitsu,0) = 0 AND ISNULL(t_niu.su_nonyu_jitsu_hasu,0) = 0 THEN 0
							ELSE 1
						 END AS flg_niuke_jisseki 
					FROM tr_niuke t_niu
					INNER JOIN
						(
							SELECT
								MIN(t_n.no_niuke) AS no_niuke
								,t_n.dt_niuke
								,t_n.cd_hinmei
								,t_n.cd_torihiki
								,t_n.kbn_nyuko
							FROM tr_niuke t_n
							WHERE
								t_n.no_seq = 
								(
									SELECT
										MIN(no_seq)
									FROM tr_niuke
								)
								AND NOT EXISTS
								(
									SELECT
										*
									FROM tr_nonyu t_nyu
									WHERE
										t_nyu.cd_hinmei = t_n.cd_hinmei
										AND t_nyu.cd_torihiki = t_n.cd_torihiki
										--AND t_nyu.dt_nonyu = t_n.dt_nonyu
										AND t_nyu.flg_yojitsu = @jissekiYojitsuFlg
										AND t_nyu.no_nonyu = t_n.no_nonyu
										AND ((t_nyu.kbn_nyuko is null AND t_n.kbn_nyuko is null) or t_nyu.kbn_nyuko = t_n.kbn_nyuko)
								)
							GROUP BY
								t_n.dt_niuke
								,t_n.cd_hinmei
								,t_n.cd_torihiki
								,t_n.kbn_nyuko
						) tr_nk
					ON t_niu.no_niuke = tr_nk.no_niuke
					AND t_niu.kbn_zaiko = @ryohinZaikoKbn
					AND t_niu.no_seq =	
					(
						SELECT
							MIN(no_seq) AS no_seq
						FROM tr_niuke
					)	
					INNER JOIN ma_hinmei m_hinmei
					ON t_niu.cd_hinmei = m_hinmei.cd_hinmei
					AND m_hinmei.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_bunrui m_bunrui
					ON m_hinmei.kbn_hin = m_bunrui.kbn_hin
					AND m_hinmei.cd_bunrui = m_bunrui.cd_bunrui
					AND m_bunrui.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_niuke m_niuke
					ON t_niu.cd_niuke_basho = m_niuke.cd_niuke_basho
					AND m_niuke.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_kbn_hokan m_kbn_hokan
					ON m_hinmei.kbn_hokan = m_kbn_hokan.cd_hokan_kbn
					AND m_kbn_hokan.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_torihiki m_torihiki
					ON t_niu.cd_torihiki = m_torihiki.cd_torihiki
					AND m_torihiki.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_kbn_nyushukko m_kbn_nyushukko
					ON t_niu.kbn_nyushukko = m_kbn_nyushukko.kbn_nyushukko
					LEFT OUTER JOIN ma_konyu m_konyu
					ON t_niu.cd_hinmei = m_konyu.cd_hinmei
					AND t_niu.cd_torihiki = m_konyu.cd_torihiki
					AND m_konyu.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_tani m_tani
					ON m_konyu.cd_tani_nonyu = m_tani.cd_tani
					AND m_tani.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_tani m_tani_hasu
					ON m_konyu.cd_tani_nonyu_hasu = m_tani_hasu.cd_tani
					AND m_tani_hasu.flg_mishiyo = @shiyoMishiyoFlg
					WHERE	
						--t_niu.kbn_nyushukko IN ( @shiireNyushukoKbn, @sotoinyuNyushukoKbn, 0) -- NULL用の0
						t_niu.kbn_nyushukko IN ( @shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn, 0) -- NULL用の0
						AND @dt_niuke <= t_niu.dt_niuke AND t_niu.dt_niuke < (SELECT DATEADD(DD,1,@dt_niuke))
						AND t_niu.cd_niuke_basho =	@cd_niuke
						AND	t_niu.flg_kakutei IN (ABS(ABS(@flg_kakutei)-1),0,NULL)

						AND	NOT EXISTS	
						(
							SELECT
								*
							FROM tr_nonyu t_nyu
							WHERE
								t_nyu.cd_hinmei = t_niu.cd_hinmei
								AND t_nyu.cd_torihiki = t_niu.cd_torihiki
--								AND t_nyu.dt_nonyu = t_niu.dt_niuke
								AND t_nyu.dt_nonyu = t_niu.dt_nonyu
								AND t_nyu.flg_yojitsu =	@jissekiYojitsuFlg
								--AND t_nyu.kbn_nyuko = t_niu.kbn_nyuko
								AND ((t_nyu.kbn_nyuko is null AND t_niu.kbn_nyuko is null) or t_nyu.kbn_nyuko = t_niu.kbn_nyuko)
						)

					UNION
				
					SELECT
						DISTINCT							-- 荷受トラン(実績あり)
						--表示項目
						ISNULL(t_niu.flg_kakutei,@zeroToFlg) AS flg_kakutei
						,ISNULL(m_bunrui.nm_bunrui, '') AS nm_bunrui
						,t_niu.cd_hinmei
						,ISNULL(m_hinmei.nm_hinmei_en, '') AS nm_hinmei_en
						,ISNULL(m_hinmei.nm_hinmei_ja, '') AS nm_hinmei_ja
						,ISNULL(m_hinmei.nm_hinmei_zh, '') AS nm_hinmei_zh
						,ISNULL(m_hinmei.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji
						,ISNULL(m_kbn_nyushukko.nm_kbn_nyushukko,@initBlank) AS nm_kbn_nyushukko
						,ISNULL(m_torihiki.nm_torihiki,@initBlank) AS nm_torihiki
						,ISNULL(m_kbn_hokan.nm_hokan_kbn,@initBlank) AS nm_hokan_kbn
						,t_niu.tm_nonyu_yotei
						,t_niu.su_nonyu_yotei
						,t_niu.su_nonyu_yotei_hasu
						--非表示項目
						,ISNULL(t_niu.kbn_nyushukko, 0) AS kbn_nyushukko
						,t_niu.cd_torihiki
						,m_hinmei.kbn_hokan
						,m_hinmei.biko
						,t_niu.no_niuke
						,@oneToFlg flg_nonyu
						,t_niu.cd_niuke_basho
						,@oneToFlg flg_jisseki
						,m_konyu.su_iri
						,t_nyu.flg_kakutei flg_kakutei_nonyu
						,m_hinmei.dd_shomi
						,m_konyu.cd_tani_nonyu
						,m_tani.nm_tani
						,m_hinmei.kbn_zei
						,m_hinmei.kbn_hin
						,m_konyu.cd_torihiki2
						,m_konyu.tan_nonyu
						,m_bunrui.cd_bunrui
						,m_konyu.cd_tani_nonyu_hasu
						,m_tani_hasu.nm_tani AS nm_tani_hasu
						,t_niu.kbn_nyuko AS kbn_nyuko
						,t_niu.no_nonyu AS no_nonyu_yotei
						,t_niu.no_nonyu AS no_nonyu_yotei_disp
						,CASE
							WHEN ISNULL(t_niu.su_nonyu_jitsu,0) = 0 AND ISNULL(t_niu.su_nonyu_jitsu_hasu,0) = 0 THEN 0
							ELSE 1
						 END AS flg_niuke_jisseki 
					FROM tr_niuke t_niu
					INNER JOIN
					(
						SELECT
							MIN(t_n.no_niuke) AS no_niuke
							,t_n.dt_niuke
							,t_n.cd_hinmei
							,t_n.cd_torihiki
							,t_n.kbn_nyuko
						FROM tr_niuke t_n
						WHERE
							t_n.no_seq =
							(
								SELECT
									MIN(no_seq) AS no_seq
								FROM tr_niuke
							)				
						GROUP BY
							t_n.dt_niuke
							,t_n.cd_hinmei
							,t_n.cd_torihiki
							,t_n.kbn_nyuko
							,t_n.no_nonyu
					) tr_nk
					ON t_niu.no_niuke = tr_nk.no_niuke
					AND t_niu.kbn_zaiko = @ryohinZaikoKbn
					AND t_niu.no_seq =	
					(
						SELECT
							MIN(no_seq) AS no_seq
						FROM tr_niuke
					)
					INNER JOIN ma_hinmei m_hinmei
					ON t_niu.cd_hinmei = m_hinmei.cd_hinmei
					AND m_hinmei.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_bunrui m_bunrui
					ON m_hinmei.kbn_hin = m_bunrui.kbn_hin
					AND m_hinmei.cd_bunrui = m_bunrui.cd_bunrui
					AND m_bunrui.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_niuke m_niuke
					ON t_niu.cd_niuke_basho = m_niuke.cd_niuke_basho
					AND m_niuke.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_kbn_hokan m_kbn_hokan
					ON m_hinmei.kbn_hokan = m_kbn_hokan.cd_hokan_kbn
					AND m_kbn_hokan.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_torihiki m_torihiki
					ON t_niu.cd_torihiki = m_torihiki.cd_torihiki
					AND m_torihiki.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_kbn_nyushukko m_kbn_nyushukko
					ON t_niu.kbn_nyushukko = m_kbn_nyushukko.kbn_nyushukko
					LEFT OUTER JOIN ma_konyu m_konyu
					ON t_niu.cd_hinmei = m_konyu.cd_hinmei
					AND t_niu.cd_torihiki = m_konyu.cd_torihiki
					AND m_konyu.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_tani m_tani
					ON m_konyu.cd_tani_nonyu = m_tani.cd_tani
					AND m_tani.flg_mishiyo = @shiyoMishiyoFlg
					INNER JOIN tr_nonyu t_nyu
					--ON t_niu.cd_hinmei = t_nyu.cd_hinmei
					--AND t_niu.cd_torihiki = t_nyu.cd_torihiki
					--AND t_niu.dt_niuke = t_nyu.dt_nonyu
					--AND t_nyu.flg_yojitsu = @jissekiYojitsuFlg
					ON t_niu.no_nonyu = t_nyu.no_nonyu
					AND t_niu.no_nonyu = t_nyu.no_nonyu_yotei
					LEFT OUTER JOIN ma_tani m_tani_hasu
					ON m_konyu.cd_tani_nonyu_hasu = m_tani_hasu.cd_tani
					AND m_tani_hasu.flg_mishiyo = @shiyoMishiyoFlg						
					WHERE
						t_niu.kbn_nyushukko IN ( @shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn, 0)
						AND @dt_niuke <= t_niu.dt_niuke AND t_niu.dt_niuke < (SELECT DATEADD(DD,1,@dt_niuke))
						AND t_niu.cd_niuke_basho = @cd_niuke
						AND t_niu.flg_kakutei IN (ABS(ABS(@flg_kakutei)-1),0,NULL)
						--AND EXISTS
						--(
						--	SELECT
						--		*
						--	FROM tr_nonyu t_nyu
						--	WHERE t_nyu.cd_hinmei =	t_niu.cd_hinmei
						--		AND	t_nyu.cd_torihiki = t_niu.cd_torihiki
						--		AND	t_nyu.dt_nonyu = t_niu.dt_niuke
						--		--AND	t_nyu.kbn_nyuko = t_niu.kbn_nyuko
						--		AND ((t_nyu.kbn_nyuko is null AND t_niu.kbn_nyuko is null) or t_nyu.kbn_nyuko = t_niu.kbn_nyuko)
						--		AND EXISTS	
						--		(
						--			SELECT
						--				*
						--			FROM tr_nonyu t_no
						--			WHERE
						--				t_no.flg_yojitsu = @jissekiYojitsuFlg
						--				AND t_no.no_nonyu = t_nyu.no_nonyu
						--		)
						--)
					UNION
			
					SELECT
						DISTINCT							-- 生産管理/原資材変動表で立てた予定				
						--表示項目
						@zeroToFlg flg_kakutei
						,m_bunrui.nm_bunrui
						,t_nyu.cd_hinmei
						,ISNULL(m_hinmei.nm_hinmei_en, '') AS nm_hinmei_en
						,ISNULL(m_hinmei.nm_hinmei_ja, '') AS nm_hinmei_ja
						,ISNULL(m_hinmei.nm_hinmei_zh, '') AS nm_hinmei_zh
						,ISNULL(m_hinmei.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji
						,ISNULL(m_kbn_nyushukko.nm_kbn_nyushukko,@initBlank) AS nm_kbn_nyushukko	-- 入庫区分		-- EXCEL出力用(画面では未使用)
						-- ,@shiireName nm_kbn_nyushukko
						,ISNULL(m_torihiki.nm_torihiki,@initBlank) AS nm_torihiki
						,ISNULL(m_kbn_hokan.nm_hokan_kbn,@initBlank) AS nm_hokan_kbn
						,@initTime tm_nonyu_yotei
						,ISNULL(t_nyu.su_nonyu,@initZero) AS su_nonyu
						,ISNULL(t_nyu.su_nonyu_hasu,@initZero) AS su_nonyu_hasu
						--非表示項目
						,@shiireNyushukoKbn kbn_nyushukko
						,ISNULL(t_nyu.cd_torihiki,@initBlank) AS cd_torihiki
						,m_hinmei.kbn_hokan
						,m_hinmei.biko
						,'0' no_niuke
						,@oneToFlg flg_nonyu
						,m_hinmei.cd_niuke_basho
						,@zeroToFlg flg_jisseki
						,m_konyu.su_iri
						,t_nyu.flg_kakutei flg_kakutei_nonyu
						,m_hinmei.dd_shomi
						,m_konyu.cd_tani_nonyu
						,m_tani.nm_tani
						,m_hinmei.kbn_zei
						,m_hinmei.kbn_hin
						,m_konyu.cd_torihiki2
						,m_konyu.tan_nonyu
						,m_bunrui.cd_bunrui
						,m_konyu.cd_tani_nonyu_hasu
						,m_tani_hasu.nm_tani AS nm_tani_hasu
						,t_nyu.kbn_nyuko AS kbn_nyuko
						,t_nyu.no_nonyu AS no_nonyu_yotei
						,t_nyu.no_nonyu AS no_nonyu_yotei_disp
						, 0 AS flg_niuke_jisseki
					FROM tr_nonyu t_nyu
					INNER JOIN ma_hinmei m_hinmei
					ON t_nyu.cd_hinmei = m_hinmei.cd_hinmei
					AND	m_hinmei.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_bunrui m_bunrui
					ON m_hinmei.kbn_hin = m_bunrui.kbn_hin
					AND	m_hinmei.cd_bunrui = m_bunrui.cd_bunrui
					AND	m_bunrui.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN	ma_kbn_hokan m_kbn_hokan
					ON m_hinmei.kbn_hokan = m_kbn_hokan.cd_hokan_kbn
					AND	m_kbn_hokan.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN	ma_torihiki m_torihiki
					ON t_nyu.cd_torihiki = m_torihiki.cd_torihiki
					AND	m_torihiki.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_konyu m_konyu
					ON t_nyu.cd_hinmei = m_konyu.cd_hinmei
					AND	t_nyu.cd_torihiki = m_konyu.cd_torihiki
					AND	m_konyu.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN	ma_tani m_tani
					ON m_konyu.cd_tani_nonyu = m_tani.cd_tani
					AND	m_tani.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN	ma_tani m_tani_hasu
					ON m_konyu.cd_tani_nonyu_hasu = m_tani_hasu.cd_tani
					AND	m_tani_hasu.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_kbn_nyushukko m_kbn_nyushukko
					ON m_kbn_nyushukko.kbn_nyushukko = 1
					WHERE
						t_nyu.flg_yojitsu =	@yoteiYojitsuFlg
						AND @dt_niuke <= t_nyu.dt_nonyu AND t_nyu.dt_nonyu < (SELECT DATEADD(DD,1,@dt_niuke))
						AND m_hinmei.cd_niuke_basho = @cd_niuke
						AND NOT EXISTS 
						(
							--SELECT
							--	*
							--FROM tr_niuke t_niu
							--WHERE
							--	t_nyu.cd_hinmei = t_niu.cd_hinmei
							--	AND t_nyu.cd_torihiki = t_niu.cd_torihiki
							--	AND t_nyu.dt_nonyu = t_niu.dt_niuke
							--	AND t_nyu.no_nonyu = t_niu.no_nonyu
							--	--AND t_nyu.kbn_nyuko = t_niu.kbn_nyuko
							--	AND ((t_nyu.kbn_nyuko is null AND t_niu.kbn_nyuko is null) or t_nyu.kbn_nyuko = t_niu.kbn_nyuko)
							--	AND t_niu.no_seq =
							--	(
							--		SELECT
							--			MIN(no_seq) AS no_seq
							--		FROM tr_niuke
							--	)

							SELECT
								niu.*
							FROM tr_niuke niu
							INNER JOIN
								(

									SELECT
										jisseki.no_nonyu
										,jisseki.no_nonyu_yotei
									FROM tr_nonyu yotei
									INNER JOIN tr_nonyu jisseki
									ON yotei.no_nonyu = jisseki.no_nonyu_yotei
									AND yotei.flg_yojitsu = @yoteiYojitsuFlg
								) subqueryNonyu
							ON t_nyu.no_nonyu = subqueryNonyu.no_nonyu_yotei
							AND niu.no_nonyu = subqueryNonyu.no_nonyu
							AND niu.no_seq = (
												SELECT
													MIN(no_seq) AS no_seq
												FROM tr_niuke
											)
						)
			▲ 2017/02/20 Q&BサポートNo.41対応により削除▲*/
				) uni
	)
	-- 画面に返却する値を取得
	SELECT
		cnt	-- 行総数
		,cte_row.flg_kakutei
		,cte_row.nm_bunrui
		,cte_row.cd_hinmei
		,cte_row.nm_hinmei_en
		,cte_row.nm_hinmei_ja
		,cte_row.nm_hinmei_zh
		,cte_row.nm_hinmei_vi
		,cte_row.nm_nisugata_hyoji
		,cte_row.nm_kbn_nyushukko
		,cte_row.nm_torihiki
		,cte_row.nm_hokan_kbn
		,cte_row.tm_nonyu_yotei
		,cte_row.su_nonyu_yotei
		,cte_row.su_nonyu_yotei_hasu
		--非表示項目			
		,cte_row.kbn_nyushukko
		,cte_row.cd_torihiki
		,cte_row.kbn_hokan
		,cte_row.biko
		,cte_row.no_niuke
		,cte_row.flg_nonyu
		,cte_row.cd_niuke_basho
		,cte_row.flg_jisseki
		,cte_row.su_iri
		,cte_row.wt_nonyu
		,cte_row.flg_kakutei_nonyu
		,cte_row.dd_shomi
		,cte_row.cd_tani_nonyu
		,cte_row.nm_tani
		,cte_row.kbn_zei
		,cte_row.kbn_hin
		,cte_row.cd_torihiki2
		,cte_row.tan_nonyu
		,cte_row.cd_tani_nonyu_hasu
		,cte_row.nm_tani_hasu
		,cte_row.kbn_nyuko
		,cte_row.no_nonyu_yotei
		,cte_row.no_nonyu_yotei_disp
		,cte_row.flg_niuke_jisseki
		,cte_row.no_nonyusho
	FROM
		(
			SELECT 
				MAX(RN) OVER() AS cnt
				,*
			FROM cte 
		) cte_row
	WHERE
		( 
			( 
			@isExcel = @false					-- 検索のみの場合は指定行数を抽出
			AND RN BETWEEN @start AND @end
			)
			OR @isExcel = @true					-- Excel出力は全行出力
		)
--	ORDER BY no_nonyu_yotei
	ORDER BY CASE WHEN no_nonyu_yotei_disp IS NULL THEN 1 ELSE 0 END, no_nonyu_yotei_disp
END
GO
