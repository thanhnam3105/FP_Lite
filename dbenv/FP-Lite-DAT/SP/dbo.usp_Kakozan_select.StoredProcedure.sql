IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_Kakozan_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_Kakozan_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：加工残 検索
ファイル名  ：usp_Kakozan_select
入力引数    ：@dt_hizuke, @isKeikoku, @cd_niuke
			  , @kbn_hin, @cd_bunrui, @zaikoZeroFlg
			  , @lang, @con_hinmei, @dt_niuke_from
			  , @dt_niuke_to,  @isNiukeDateFrom
			  , @isNiukeDateTo, @shiyoMishiyoFlg
			  , @jikagenryoHinKbn, @ryohinZaikoKbn, @horyuZaikoKbn
			  , @kakozanNyushuko, @mikakuteiKakuteiFlg, @skip	
			  , @top, @isExcel
出力引数    ：
戻り値      ：
作成日      ：2013.09.20  ADMAX onodera.s
更新日      ：2015.08.20  ADMAX taira.s
更新日      ：2015.10.05  MJ    ueno.k
更新日      ：2015.10.16  MJ    ueno.k  抽出条件を初回荷受け実績日のみに修正
更新日      ：2015.10.19  MJ    ueno.k  表示項目は訂正日時点での表示に修正
更新日      ：2016.12.13  BRC   motojima.m 中文対応
更新日      ：2017.11.14  BRC   sato.s 中文対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_Kakozan_select] 
	@dt_hizuke				DATETIME	  -- 在庫訂正日
	, @isKeikoku			BIT			  -- 警告チェックボックス
	, @cd_niuke				VARCHAR(14)	  -- 荷受場所コード
	, @kbn_hin				SMALLINT	  -- 品区分
	, @cd_bunrui			VARCHAR(10)	  -- 分類コード
	, @isZaikoZero			BIT			  -- 在庫0表示チェックボックス
	, @lang					varchar(2)	  -- ブラウザ言語
	--, @con_hinmei			varchar(50)	  -- 品名
	, @con_hinmei			nvarchar(50)  -- 品名
	, @dt_niuke_from		DATETIME	  -- 荷受日(FROM)
	, @dt_niuke_to			DATETIME	  -- 荷受日(TO)
	, @isNiukeDateFrom		BIT			  -- 荷受日(FROM)あり/なし判定
	, @isNiukeDateTo		BIT			  -- 荷受日(TO)あり/なし判定
	, @shiyoMishiyoFlg		SMALLINT	  -- 未使用フラグ.使用
	, @jikagenryoHinKbn		SMALLINT	  -- 品区分.自家原料
	, @ryohinZaikoKbn		SMALLINT	  -- 在庫区分.良品
	, @horyuZaikoKbn		SMALLINT	  -- 在庫区分.保留
	, @kakozanNyushuko		SMALLINT	  -- 入出庫区分.加工残
	, @mikakuteiKakuteiFlg	SMALLINT	  -- 確定フラグ.未確定
	, @kigengireKigenFlg	SMALLINT	  -- 期限フラグ.期限切れ
	, @chokuzenKigenFlg		SMALLINT	  -- 期限フラグ.直前
	, @chikaiKigenFlg		SMALLINT	  -- 期限フラグ.近い
	, @yoyuKigenFlg			SMALLINT	  -- 期限フラグ.余裕
	, @dt_kigen_chikai		DECIMAL		  -- 工場マスタ.kigen_chikai
	, @dt_kigen_chokuzen	DECIMAL		  -- 工場マスタ.kigen_chokuzen
	, @dt_utc				DATETIME	  -- システム「年月日」のUTC日時 EX)日本：yyyy/MM/dd 15:00:00.000
	, @skip					DECIMAL(10)	  -- スキップ(後続データ検索用)
	, @top					DECIMAL(10)	  -- 検索データ上限(後続データ検索用)
	, @isExcel				BIT			  -- エクセルフラグ
AS
BEGIN
	
	DECLARE @start			DECIMAL(10)
    DECLARE @end			DECIMAL(10)
	DECLARE @true			BIT
	DECLARE @false			BIT
	DECLARE @keikoku		SMALLINT
	DECLARE @misetteiKigen	VARCHAR
	DECLARE @kireKigen		VARCHAR
	DECLARE @majikaKigen	VARCHAR
	DECLARE @yoyuKigen		VARCHAR
	DECLARE @one			SMALLINT
	DECLARE @minSeqNo DECIMAL(8, 0)
	DECLARE @taniKg SMALLINT
	DECLARE @taniL SMALLINT
	
	SET		@mikakuteiKakuteiFlg = '0'
	SET		@kireKigen			 = '1'
	SET		@majikaKigen		 = '2'
	SET		@yoyuKigen			 = '3'
    SET		@start	             =	@skip + 1
    SET		@end	             =	@skip + @top
    SET		@true	             =	1
    SET		@false	             =	0
    SET		@one	             =	1
    SET		@taniKg	             =	4
    SET		@taniL	             =	11
    
	SELECT @minSeqNo = MIN(minS.no_seq) FROM tr_niuke minS;	

	WITH cte AS	(
				SELECT	*
						, ROW_NUMBER() OVER (ORDER BY no_niuke) AS RN
				
				FROM	(
						SELECT		-- 表示項目
								CASE t_niu.kbn_nyushukko
									WHEN @kakozanNyushuko THEN t_niu.flg_kakutei
									ELSE @mikakuteiKakuteiFlg
								END flg_kakutei													-- 確定
								, ISNULL(ma_niuke.nm_niuke, '')	nm_niuke						-- 荷受場所
								, t_niu.cd_hinmei												-- 品名コード
								, ISNULL(ma_hinmei.nm_hinmei_en, '')	nm_hinmei_en			-- 品名(英語)
								, ISNULL(ma_hinmei.nm_hinmei_ja, '')	nm_hinmei_ja			-- 品名(日本語)
								, ISNULL(ma_hinmei.nm_hinmei_zh, '')	nm_hinmei_zh			-- 品名(中国語)
								, ISNULL(ma_hinmei.nm_hinmei_vi, '')	nm_hinmei_vi
								, ISNULL(ma_hinmei.nm_nisugata_hyoji, '')	nm_nisugata_hyoji	-- 荷姿
								, tn_min.dt_niuke		AS	min_dt_niuke						-- 荷受日
								, tn_min.tm_nonyu_jitsu	AS	min_tm_nonyu_jitsu					-- 時刻
								, t_niu.no_lot													-- ロットNo.
								, t_niu.dt_seizo												-- 製造日
								, t_niu.dt_kigen												-- 賞味期限
								, ma_kbn_zaiko.nm_kbn_zaiko										-- 在庫区分(名称)
								, ISNULL(t_niu.su_zaiko, 0) su_zaiko							-- 在庫C/S数
								, ISNULL(t_niu.su_zaiko_hasu, 0) su_zaiko_hasu					-- 在庫端数
								, CASE 
									WHEN ISNULL ( ma_konyu.cd_tani_nonyu, ma_hinmei.cd_tani_nonyu ) IN (@taniKg,@taniL)
										THEN
											CASE t_niu.kbn_hin
												WHEN  @jikagenryoHinKbn  THEN ISNUll(ma_hinmei.su_iri,1) * ISNULL(FLOOR(ma_hinmei.wt_ko * 1000) / 1000,1) * ISNULL(t_niu.su_zaiko, 0) + ISNULL(t_niu.su_zaiko_hasu, 0) / 1000
												ELSE ISNUll(ma_konyu.su_iri,1) * ISNUll(FLOOR(ma_konyu.wt_nonyu * 1000) / 1000,1) * ISNULL(t_niu.su_zaiko, 0) + ISNULL(t_niu.su_zaiko_hasu, 0) / 1000
										 	END
									ELSE
											CASE t_niu.kbn_hin
												WHEN  @jikagenryoHinKbn  THEN ISNUll(ma_hinmei.su_iri,1) * ISNULL(FLOOR(ma_hinmei.wt_ko * 1000) / 1000,1) * ISNULL(t_niu.su_zaiko, 0) + ISNULL(t_niu.su_zaiko_hasu, 0)
												ELSE ISNUll(ma_konyu.su_iri,1) * ISNUll(FLOOR(ma_konyu.wt_nonyu * 1000) / 1000,1) * ISNULL(t_niu.su_zaiko, 0) + ISNULL(t_niu.su_zaiko_hasu, 0)
										 	END
								  END AS su_shiyo												-- 在庫数（使用単位）
								, t_niu.cd_update												-- 更新者ID
								--非表示項目
								, t_niu.no_niuke												-- 荷受番号
								, t_niu.kbn_zaiko												-- 在庫区分(コード)
								, t_niu.kbn_nyushukko											-- 入出庫区分
								, t_niu.dt_niuke		AS	niuke_dt_niuke
								, tn_max.dt_niuke		AS	max_dt_niuke						-- 荷受日(最新)
								, tn_max.no_seq			AS	max_no_seq							-- シーケンス番号(最新)
								, ISNULL ( ma_konyu.cd_tani_nonyu, ma_hinmei.cd_tani_nonyu ) AS cd_tani_nonyu
								, CASE t_niu.kbn_hin
										WHEN  @jikagenryoHinKbn  THEN ma_hinmei.su_iri
										ELSE ma_konyu.su_iri
								END AS su_iri													-- 入数
								, CASE t_niu.kbn_hin
										WHEN  @jikagenryoHinKbn  THEN FLOOR(ma_hinmei.wt_ko * 1000) / 1000
										ELSE  FLOOR(ma_konyu.wt_nonyu * 1000) / 1000
								END AS wt_ko													-- 個重量
								, CASE
										/*WHEN t_niu.dt_kigen IS NULL
												OR t_niu.dt_seizo IS NULL THEN @mikakuteiKakuteiFlg
										WHEN t_niu.dt_kigen - GETUTCDATE ( ) < 0 THEN @kireKigen
										WHEN  CEILING((CONVERT (DECIMAL,(DATEDIFF(DAY , t_niu.dt_kigen , t_niu.dt_seizo)))* -1) / 3) > CONVERT (INT, (DATEDIFF(DAY, GETUTCDATE() , t_niu.dt_kigen))) THEN @majikaKigen
										ELSE @yoyuKigen*/
										-- 使用期限切れ
										WHEN t_niu.dt_kigen < @dt_utc THEN @kigengireKigenFlg
										-- 使用期限直前
										WHEN t_niu.dt_kigen >= @dt_utc
										AND t_niu.dt_kigen < DATEADD(DAY,@dt_kigen_chokuzen,@dt_utc) THEN @chokuzenKigenFlg
										-- 使用期限近い
										WHEN t_niu.dt_kigen >=  DATEADD(DAY,@dt_kigen_chokuzen,@dt_utc)
										AND t_niu.dt_kigen < DATEADD(DAY,@dt_kigen_chikai,@dt_utc) THEN @chikaiKigenFlg
										-- 使用期限まで余裕あり
										ELSE @yoyuKigenFlg
								END AS flg_keikoku
								,maxzaiko.su_shukko AS saishinZaiko
								,maxzaiko.su_shukko_hasu AS saishinZaikoHasu
								,maxzaiko.flgSaishin AS flgSaishin
								,tn_min.dt_nonyu		AS	min_dt_nonyu	-- 初回納入日
								
						FROM	tr_niuke t_niu
							LEFT JOIN	ma_niuke
									ON	t_niu.cd_niuke_basho	= ma_niuke.cd_niuke_basho
									AND	ma_niuke.flg_mishiyo	= @shiyoMishiyoFlg
							INNER JOIN	ma_kbn_zaiko
									ON	t_niu.kbn_zaiko			= ma_kbn_zaiko.kbn_zaiko
							INNER JOIN	ma_konyu
									ON t_niu.cd_torihiki		= ma_konyu.cd_torihiki
									AND t_niu.cd_hinmei			= ma_konyu.cd_hinmei
									--AND ma_konyu.flg_mishiyo	= @shiyoMishiyoFlg
									--ON CASE
									--		WHEN	@kbn_hin				<> @jikagenryoHinKbn
									--			AND t_niu.cd_torihiki		= ma_konyu.cd_torihiki
									--			AND	t_niu.cd_hinmei			= ma_konyu.cd_hinmei
									--			AND	ma_konyu.flg_mishiyo	= @shiyoMishiyoFlg		THEN 1
									--		WHEN	@kbn_hin				= @jikagenryoHinKbn		THEN 1
									--		ELSE 0
									--	END = 1
							INNER JOIN	( 
										SELECT	
												t_min.dt_niuke
												, t_min.tm_nonyu_jitsu
												, t_min.no_niuke
												, t_min.dt_nonyu 
										FROM	tr_niuke t_min
										WHERE	
											t_min.no_seq = (
																SELECT
																	MIN(no_seq)
																FROM tr_niuke
															)
										) tn_min
									ON	t_niu.no_niuke	=	tn_min.no_niuke
--
							INNER JOIN	(	
											SELECT
												t_max.no_niuke
												, t_max.kbn_zaiko
												, MAX(t_max.no_seq) no_seq
												, MAX(t_max.dt_niuke) dt_niuke
												, MAX(t_max.dt_nonyu) dt_nonyu
											FROM tr_niuke t_max
											WHERE
												(
													(
														(t_max.kbn_zaiko = @ryohinZaikoKbn OR t_max.kbn_zaiko = @horyuZaikoKbn)
														and t_max.dt_niuke < (SELECT DATEADD(DD,1,@dt_hizuke))
														and t_max.no_seq <> @minSeqNo
													)
												OR
													(
														(t_max.kbn_zaiko = @ryohinZaikoKbn OR t_max.kbn_zaiko = @horyuZaikoKbn)
														and t_max.dt_nonyu < (SELECT DATEADD(DD,1,@dt_hizuke))
														and t_max.no_seq = @minSeqNo
													)
												)

--												(t_max.kbn_zaiko = @ryohinZaikoKbn OR t_max.kbn_zaiko = @horyuZaikoKbn)
--												and t_max.dt_niuke < (SELECT DATEADD(DD,1,@dt_hizuke))
											GROUP BY
												t_max.no_niuke
												, t_max.kbn_zaiko
										) tn_max
									ON	t_niu.no_niuke			= tn_max.no_niuke
									AND	t_niu.kbn_zaiko			= tn_max.kbn_zaiko
--
							LEFT JOIN	ma_hinmei
									ON	t_niu.cd_hinmei			= ma_hinmei.cd_hinmei
							LEFT JOIN	ma_bunrui
									ON	ma_bunrui.cd_bunrui		= ma_hinmei.cd_bunrui
									AND	t_niu.kbn_hin			= ma_bunrui.kbn_hin
							LEFT JOIN	ma_kbn_hin
									ON	ma_kbn_hin.kbn_hin		= ma_hinmei.kbn_hin
							left join (
								select su_shukko
										,su_shukko_hasu
										,maxtn.no_niuke
										,kbn_zaiko
										,1 AS flgSaishin
								from tr_niuke maxtn
								inner join (
									select max(no_seq) maxseq
											,no_niuke 
									from tr_niuke
									group by no_niuke
								)max_niu
								on maxtn.no_niuke = max_niu.no_niuke
									and maxtn.no_seq = max_niu.maxseq

									and (
											(maxtn.dt_niuke > (SELECT DATEADD(DD,0,@dt_hizuke)) 
											AND 
											maxtn.no_seq <> @minSeqNo)
										OR 
										(
											(maxtn.dt_nonyu > (SELECT DATEADD(DD,0,@dt_hizuke)) 
											AND 
											maxtn.no_seq = @minSeqNo)
										)
									)
--									and maxtn.dt_niuke > (SELECT DATEADD(DD,0,@dt_hizuke))
							)maxzaiko
							on t_niu.no_niuke = maxzaiko.no_niuke
							and t_niu.kbn_zaiko = maxzaiko.kbn_zaiko
--									
							--荷受実績日(from,to)
							INNER JOIN tr_niuke t_niuke_jisseki
							ON (
									(@isNiukeDateFrom = @false OR t_niuke_jisseki.dt_nonyu >= @dt_niuke_from)
									AND (@isNiukeDateTo = @false OR t_niuke_jisseki.dt_nonyu <= @dt_niuke_to)	
									AND t_niuke_jisseki.no_seq = @minSeqNo
									AND t_niuke_jisseki.no_niuke = t_niu.no_niuke
							)
						WHERE
							(
								(
									t_niu.dt_niuke < (SELECT DATEADD(DD,1,@dt_hizuke))
									AND 
									t_niu.no_seq <> @minSeqNo
								)
								OR 
								(
									t_niu.dt_nonyu < (SELECT DATEADD(DD,1,@dt_hizuke))
									AND 
									t_niu.no_seq = @minSeqNo
								)
							)
--						WHERE		t_niu.dt_niuke < (SELECT DATEADD(DD,1,@dt_hizuke))
							AND		t_niu.kbn_hin			=	@kbn_hin
							--在庫0表示チェックで抽出条件を変更							
							AND 
							(
								CASE 
									WHEN @isZaikoZero = @false THEN t_niu.su_zaiko 
									ELSE 1 
								END > 0
								OR 
								CASE 
									WHEN @isZaikoZero = @false THEN t_niu.su_zaiko_hasu 
									ELSE 1 
								END > 0 								
							)														
							AND		(t_niu.kbn_zaiko = @ryohinZaikoKbn OR t_niu.kbn_zaiko = @horyuZaikoKbn)
							AND		(LEN(@cd_niuke) = 0 OR t_niu.cd_niuke_basho = @cd_niuke)
							AND		(LEN(@cd_bunrui) = 0 OR ma_hinmei.cd_bunrui = @cd_bunrui)
							-- 多言語対応：言語によって検索対象の品名カラムを変更する
							AND (LEN(ISNULL(@con_hinmei, '')) = 0 OR
									(@lang = 'en' OR @lang = 'zh') OR
										t_niu.cd_hinmei like '%' + @con_hinmei + '%' OR ma_hinmei.nm_hinmei_ja like '%' + @con_hinmei + '%'
								)
							AND (LEN(ISNULL(@con_hinmei, '')) = 0 OR
									(@lang = 'ja' OR @lang = 'zh') OR
										t_niu.cd_hinmei like '%' + @con_hinmei + '%' OR ma_hinmei.nm_hinmei_en like '%' + @con_hinmei + '%'
								)
							AND (LEN(ISNULL(@con_hinmei, '')) = 0 OR
									(@lang = 'ja' OR @lang = 'en') OR
										t_niu.cd_hinmei like '%' + @con_hinmei + '%' OR ma_hinmei.nm_hinmei_zh like '%' + @con_hinmei + '%'
								)
							AND (LEN(ISNULL(@con_hinmei, '')) = 0 OR
									(@lang = 'ja' OR @lang = 'zh') OR
										t_niu.cd_hinmei like '%' + @con_hinmei + '%' OR ma_hinmei.nm_hinmei_vi like '%' + @con_hinmei + '%'
								)
							--荷受日(From,To) 荷受実績日条件設定は上へ移動。ここではシーケンスNoのみ条件に。
--

							AND (
									(
----									(@isNiukeDateFrom = @false OR t_niu.dt_niuke >= @dt_niuke_from)
----									AND (@isNiukeDateTo = @false OR t_niu.dt_niuke <= @dt_niuke_to)											
									 t_niu.no_seq <> @minSeqNo
									AND t_niu.no_seq = tn_max.no_seq
									)
								OR 
									(
----									(@isNiukeDateFrom = @false OR t_niu.dt_nonyu >= @dt_niuke_from)
----									AND (@isNiukeDateTo = @false OR t_niu.dt_nonyu <= @dt_niuke_to)	
										tn_max.no_seq = @minSeqNo
									AND t_niu.no_seq = @minSeqNo
									)
							)
--							AND (@isNiukeDateFrom = @false OR t_niu.dt_niuke >= @dt_niuke_from)
--							AND (@isNiukeDateTo = @false OR t_niu.dt_niuke <= @dt_niuke_to)											
--							AND		t_niu.no_seq			=	tn_max.no_seq

						) rowNum

				WHERE	(@isKeikoku = @false )
						OR 
						(
						@isKeikoku = @true 
							AND (
									rowNum.flg_keikoku		= @kireKigen 
									OR rowNum.flg_keikoku	= @majikaKigen
								)
						)
			GROUP BY rowNum.flg_kakutei
					, rowNum.nm_niuke
					, rowNum.cd_hinmei
					, rowNum.nm_hinmei_en
					, rowNum.nm_hinmei_ja
					, rowNum.nm_hinmei_zh
					, rowNum.nm_hinmei_vi
					, rowNum.nm_nisugata_hyoji
					, rowNum.min_dt_niuke
					, rowNum.no_lot
					, rowNum.min_tm_nonyu_jitsu
					, rowNum.dt_seizo
					, rowNum.dt_kigen
					, rowNum.nm_kbn_zaiko
					, rowNum.su_zaiko
					, rowNum.su_zaiko_hasu
					, rowNum.su_shiyo
					, rowNum.cd_update
					, rowNum.min_dt_nonyu
					--非表示項目
					, rowNum.no_niuke
					, rowNum.kbn_zaiko
					, rowNum.kbn_nyushukko
					, rowNum.niuke_dt_niuke
					, rowNum.max_dt_niuke
					, rowNum.max_no_seq
					, rowNum.cd_tani_nonyu
					, rowNum.su_iri
					, rowNum.wt_ko
					, rowNum.flg_keikoku
					, rowNum.saishinZaiko
					, rowNum.saishinZaikoHasu
					, rowNum.flgSaishin
		)
		-- 画面に返却する値を取得
		SELECT
			cnt
			, cte_row.flg_kakutei
			, cte_row.nm_niuke
			, cte_row.cd_hinmei
			, cte_row.nm_hinmei_en
			, cte_row.nm_hinmei_ja
			, cte_row.nm_hinmei_zh
			, cte_row.nm_hinmei_vi
			, cte_row.nm_nisugata_hyoji
			, cte_row.min_dt_niuke
			, cte_row.no_lot
			, cte_row.min_tm_nonyu_jitsu
			, cte_row.dt_seizo
			, cte_row.dt_kigen
			, cte_row.nm_kbn_zaiko
			, cte_row.su_zaiko
			, cte_row.su_zaiko_hasu
			, cte_row.su_shiyo
			, cte_row.cd_update
			--非表示項目
			, cte_row.no_niuke
			, cte_row.kbn_zaiko
			, cte_row.kbn_nyushukko
			, cte_row.niuke_dt_niuke
			, cte_row.max_dt_niuke
			, cte_row.max_no_seq
			, cte_row.cd_tani_nonyu
			, cte_row.su_iri
			, cte_row.wt_ko
			, cte_row.flg_keikoku
			, cte_row.saishinZaiko
			, cte_row.saishinZaikoHasu
			, cte_row.flgSaishin
			, cte_row.min_dt_nonyu
		FROM(
				SELECT 
					MAX(RN) OVER() cnt
					,*
				FROM
					cte 
			) cte_row
		WHERE
		( 
			(
				@isExcel = @false
				AND RN BETWEEN @start AND @end
			)
			OR 
			(
				@isExcel = @true
			)
		)
END
GO
