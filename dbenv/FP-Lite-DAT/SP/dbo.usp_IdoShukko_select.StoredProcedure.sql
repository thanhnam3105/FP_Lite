IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_IdoShukko_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_IdoShukko_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：移動出庫  一覧検索
ファイル名	：usp_IdoShukko_select
作成日		：2013.09.19  ADMAX onodera.s
更新日		：2016.10.25  inoue.k
*****************************************************/
CREATE PROCEDURE [dbo].[usp_IdoShukko_select] 
	 @dt_out			DATETIME
	,@cd_niuke			VARCHAR(10)
	,@cd_hinmei			VARCHAR(14)			--品名コード
	,@kbn_hin			SMALLINT
	,@flg_zaiko			SMALLINT
	,@ryohinZaikoKbn	SMALLINT
	,@shukoNyushukoKbn	SMALLINT
	,@shiyoMishiyoFlg	SMALLINT
	,@cd_bunrui         VARCHAR(10)
	,@jikagenHinKbn		SMALLINT
    ,@skip				DECIMAL(10)
    ,@top				DECIMAL(10)
	,@isExcel			BIT
	,@print_status		VARCHAR(1)
	,@keShukkoFlg		SMALLINT

AS
BEGIN
	SET ARITHABORT ON
	DECLARE		@start  DECIMAL(10)
	DECLARE		@end    DECIMAL(10)
	DECLARE		@true   BIT
	DECLARE		@false  BIT
	DECLARE		@day    SMALLINT
	SET			@start	= @skip + 1
	SET			@end	= @skip + @top
	SET			@true	= 1
	SET			@false	= 0
	SET			@day	= 1

	-- 検索条件/印刷ステータスの設定
	DECLARE @st_print SMALLINT
			,@minSeqNo DECIMAL(8, 0)
			,@dt_addOne DATETIME

	SELECT @minSeqNo = (SELECT MIN(niu.no_seq) FROM tr_niuke niu)
	SELECT @dt_addOne = DATEADD(DD, @day, @dt_out)


	IF LEN(@print_status) > 0
	BEGIN
		SET @st_print = CAST(@print_status AS SMALLINT)
	END

    
	BEGIN

		WITH cte AS
			(
				SELECT	
					ISNULL(tn_shukko.flg_kakutei, '') AS flg_kakutei
					,tn_zaiko.cd_niuke_basho
					,ISNULL(mn.nm_niuke, '') AS nm_niuke
					,ISNULL(tn_zaiko.cd_hinmei, '') AS cd_hinmei
					,ISNULL(mh.nm_hinmei_en, '') AS nm_hinmei_en
					,ISNULL(mh.nm_hinmei_ja, '') AS nm_hinmei_ja
					,ISNULL(mh.nm_hinmei_zh, '') AS nm_hinmei_zh
					,ISNULL(mh.nm_hinmei_vi, '') AS nm_hinmei_vi
					,ISNULL(mh.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji
					,ISNULL(mt.nm_torihiki, '') AS nm_torihiki
					,ISNULL(mkho.nm_hokan_kbn, '') AS nm_hokan_kbn
					,CASE mh.kbn_hin 
						WHEN @jikagenHinKbn THEN ISNULL(mkhi.nm_kbn_hin, '')
						ELSE ISNULL(mb.nm_bunrui, '')
					END nm_kbn_hin
					--,ISNULL(tn_zaiko.su_zaiko, 0) AS su_zaiko
					,CASE mh.cd_tani_nonyu
						-- 単位コード:4
						WHEN 4 THEN  ISNULL (tn_zaiko.su_zaiko, 0) 
								+	ROUND(ISNULL(tn_zaiko.su_zaiko_hasu, 0)/(mh.su_iri * 1000),0,1)
						-- 単位コード：11
						WHEN 11 THEN ISNULL (tn_zaiko.su_zaiko, 0)
								+	ROUND(ISNULL(tn_zaiko.su_zaiko_hasu, 0)/(mh.su_iri * 1000),0,1)
						-- 単位コード：その他
						ELSE ISNULL(tn_zaiko.su_zaiko, 0)
							    + ROUND(ISNULL(tn_zaiko.su_zaiko_hasu, 0)/ mh.su_iri,0,1)
					END su_zaiko
					--,ISNULL(tn_zaiko.su_zaiko_hasu, 0) AS su_zaiko_hasu
					,CASE mh.cd_tani_nonyu
						-- 単位コード:4
						WHEN 4 THEN  
								ROUND(ISNULL(tn_zaiko.su_zaiko_hasu, 0.000)%(mh.su_iri * 1000),0,1)
						-- 単位コード：11
						WHEN 11 THEN
								ROUND(ISNULL(tn_zaiko.su_zaiko_hasu, 0.000)%(mh.su_iri * 1000),0,1)
						-- 単位コード：その他
						ELSE ROUND(ISNULL(tn_zaiko.su_zaiko_hasu, 0.000)% mh.su_iri,0,1)
					END su_zaiko_hasu
					--,ISNULL(tn_shukko.su_shukko, 0) AS su_shukko
					,CASE mh.cd_tani_nonyu
						-- 単位コード:4
						WHEN 4 THEN  ISNULL (tn_shukko.su_shukko, 0) 
								+	ROUND(ISNULL(tn_shukko.su_shukko_hasu, 0)/(mh.su_iri * 1000),0,1)
						-- 単位コード：11
						WHEN 11 THEN ISNULL (tn_shukko.su_shukko, 0)
								+	ROUND(ISNULL(tn_shukko.su_shukko_hasu, 0)/(mh.su_iri * 1000),0,1)	
						-- 単位コード：その他
						ELSE ISNULL(tn_shukko.su_shukko, 0)
							    + ROUND(ISNULL(tn_shukko.su_shukko_hasu, 0)/ mh.su_iri,0,1)
					END su_shukko
					--,ISNULL(tn_shukko.su_shukko_hasu, 0) AS su_shukko_hasu
					,CASE mh.cd_tani_nonyu
						-- 単位コード:4
						WHEN 4 THEN  
								ROUND(ISNULL(tn_shukko.su_shukko_hasu, 0.000)%(mh.su_iri * 1000),0,1)
						-- 単位コード：11
						WHEN 11 THEN
								ROUND(ISNULL(tn_shukko.su_shukko_hasu, 0.000)%(mh.su_iri * 1000),0,1)
						--  単位コード：その他
						ELSE ROUND(ISNULL(tn_shukko.su_shukko_hasu, 0.000)% mh.su_iri,0,1)
					END su_shukko_hasu
					,CASE tn_zaiko.kbn_hin 
						WHEN @jikagenHinKbn THEN ISNULL(mh.su_iri, 1)
						ELSE ISNULL(mk.su_iri, 1)
					END su_iri
					,ISNULL(tn_zaiko.cd_torihiki, '') AS cd_torihiki
					,ISNULL(tn_shukko.flg_out, 0) AS flg_out
					,ISNULL ( m_konyu.cd_tani_nonyu, mh.cd_tani_nonyu ) AS cd_tani_nonyu
					,ROW_NUMBER() OVER (ORDER BY tn_zaiko.cd_hinmei) AS RN
					--,tn_zaiko.flg_print
				FROM
					(
						SELECT	
							tn.cd_hinmei
							,tn.cd_niuke_basho
							,tn.kbn_hin
							,@dt_out AS dt_out
							,SUM(tn.su_zaiko) AS su_zaiko
							,SUM(su_zaiko_hasu) AS su_zaiko_hasu
							,tn.kbn_zaiko
							,tn.cd_torihiki
							--,tn.flg_print
						FROM
							tr_niuke tn
						INNER JOIN
							(
								SELECT
									MAX(niuke.no_seq) no_seq
									,niuke.no_niuke
									,niuke.kbn_zaiko
									,niuke.cd_niuke_basho
								FROM tr_niuke niuke

								-- 荷受場所マスタ
								INNER JOIN ma_niuke mn
								ON niuke.cd_niuke_basho = mn.cd_niuke_basho
								AND mn.flg_mishiyo = @shiyoMishiyoFlg

								--荷受場所区分マスタ
								INNER JOIN ma_kbn_niuke mkn
								ON mn.kbn_niuke_basho = mkn.kbn_niuke_basho
								AND mkn.flg_shukko = @keShukkoFlg
								AND mkn.flg_mishiyo = @shiyoMishiyoFlg

								WHERE
									((niuke.no_seq = @minSeqNo AND niuke.dt_nonyu < @dt_addOne)
									 OR(niuke.no_seq <> @minSeqNo AND niuke.dt_niuke < @dt_addOne))
									--dt_niuke < (SELECT DATEADD(DD, @day, @dt_out))
									AND niuke.kbn_zaiko = @ryohinZaikoKbn

								GROUP BY
									niuke.no_niuke
									,niuke.kbn_zaiko
									,niuke.cd_niuke_basho
							) tn_new
						ON tn.no_niuke = tn_new.no_niuke
						AND tn.no_seq = tn_new.no_seq
						AND tn.kbn_zaiko = tn_new.kbn_zaiko
						AND tn.cd_niuke_basho = tn_new.cd_niuke_basho

						-- 荷受場所マスタ
						INNER JOIN ma_niuke mn
						ON tn.cd_niuke_basho = mn.cd_niuke_basho
						AND mn.flg_mishiyo = @shiyoMishiyoFlg

						--荷受場所区分マスタ
						INNER JOIN ma_kbn_niuke mkn
						ON mn.kbn_niuke_basho = mkn.kbn_niuke_basho
						AND mkn.flg_shukko = @keShukkoFlg
						AND mkn.flg_mishiyo = @shiyoMishiyoFlg

						WHERE
							tn.tm_nonyu_jitsu <> ''
							AND tn.tm_nonyu_jitsu IS NOT NULL
							--Add new condition
							AND ( tn.cd_hinmei = @cd_hinmei OR @cd_hinmei IS NULL )
							--AND (LEN(@print_status) = 0 OR ISNULL(tn.flg_print, @false) = @st_print)
							AND (( @flg_zaiko = 1) OR (tn.su_zaiko + tn.su_zaiko_hasu  > 0))

						GROUP BY
							tn.cd_hinmei
							,tn.cd_niuke_basho
							,tn.kbn_hin
							,tn.kbn_zaiko
							,tn.cd_torihiki
							--,tn.flg_print
					) tn_zaiko

				LEFT OUTER JOIN
					(
						SELECT
							t_ni.cd_hinmei
							,t_ni.flg_kakutei
							,CASE t_ni.no_seq
								WHEN @minSeqNo THEN t_ni.dt_nonyu
								ELSE t_ni.dt_niuke
							END AS dt_niuke
							,SUM(t_ni.su_shukko) AS su_shukko
							,SUM(su_shukko_hasu) su_shukko_hasu
							,t_ni.kbn_zaiko
							,t_ni.cd_torihiki
							,1 AS flg_out
							,t_ni.cd_niuke_basho
						FROM tr_niuke t_ni

						-- 荷受場所マスタ
						INNER JOIN ma_niuke mn
						ON t_ni.cd_niuke_basho = mn.cd_niuke_basho
						AND mn.flg_mishiyo = @shiyoMishiyoFlg

						--荷受場所区分マスタ
						INNER JOIN ma_kbn_niuke mkn
						ON mn.kbn_niuke_basho = mkn.kbn_niuke_basho
						AND mkn.flg_shukko = @keShukkoFlg
						AND mkn.flg_mishiyo = @shiyoMishiyoFlg

						WHERE
							--@dt_out <= t_ni.dt_niuke 
							--AND t_ni.dt_niuke < (SELECT DATEADD(DD, @day, @dt_out))
							((t_ni.no_seq = @minSeqNo AND @dt_out <= t_ni.dt_nonyu AND t_ni.dt_nonyu < @dt_addOne)
							 OR (t_ni.no_seq <> @minSeqNo AND @dt_out <= t_ni.dt_niuke AND t_ni.dt_niuke < @dt_addOne))
							AND t_ni.kbn_nyushukko = @shukoNyushukoKbn
							AND t_ni.kbn_zaiko = @ryohinZaikoKbn
							--Add new condition
							AND ( t_ni.cd_hinmei = @cd_hinmei OR @cd_hinmei IS NULL )
						GROUP BY
							t_ni.cd_hinmei
							,t_ni.flg_kakutei
							,CASE t_ni.no_seq
								WHEN @minSeqNo THEN t_ni.dt_nonyu
								ELSE t_ni.dt_niuke
							END
							,t_ni.kbn_zaiko
							,t_ni.cd_torihiki
							,t_ni.cd_niuke_basho
					) tn_shukko
				ON tn_zaiko.cd_hinmei = tn_shukko.cd_hinmei
				AND (tn_zaiko.dt_out <= tn_shukko.dt_niuke 
				AND tn_shukko.dt_niuke < (SELECT DATEADD(DD, @day, tn_zaiko.dt_out)))
				AND tn_zaiko.kbn_zaiko = tn_shukko.kbn_zaiko
				AND tn_zaiko.cd_torihiki = tn_shukko.cd_torihiki
				AND tn_zaiko.cd_niuke_basho = tn_shukko.cd_niuke_basho

				-- 品名マスタ
				INNER JOIN ma_hinmei mh
				ON tn_zaiko.cd_hinmei = mh.cd_hinmei
				AND mh.flg_mishiyo = @shiyoMishiyoFlg

				-- 荷受場所マスタ
				INNER JOIN ma_niuke mn
				ON tn_zaiko.cd_niuke_basho = mn.cd_niuke_basho
				AND mn.flg_mishiyo = @shiyoMishiyoFlg

				--荷受場所区分マスタ
				INNER JOIN ma_kbn_niuke mkn
				ON mn.kbn_niuke_basho = mkn.kbn_niuke_basho
				AND mkn.flg_shukko = @keShukkoFlg
				AND mkn.flg_mishiyo = @shiyoMishiyoFlg

				-- 保管区分マスタ
				LEFT OUTER JOIN ma_kbn_hokan mkho
				ON mkho.cd_hokan_kbn = mh.kbn_hokan
				AND mkho.flg_mishiyo = @shiyoMishiyoFlg

				-- 原資材購入先マスタ
				LEFT JOIN ma_konyu mk
				ON tn_zaiko.cd_hinmei = mk.cd_hinmei
				AND tn_zaiko.cd_torihiki = mk.cd_torihiki
				AND mk.flg_mishiyo = @shiyoMishiyoFlg

				-- 分類マスタ
				LEFT OUTER JOIN ma_bunrui mb
				ON mb.cd_bunrui = mh.cd_bunrui
				AND tn_zaiko.kbn_hin = mb.kbn_hin
				AND mb.flg_mishiyo = @shiyoMishiyoFlg

				-- 取引先マスタ
				LEFT OUTER JOIN ma_torihiki mt
				ON tn_zaiko.cd_torihiki = mt.cd_torihiki

				-- 品区分マスタ
				LEFT OUTER JOIN	ma_kbn_hin mkhi
				ON mh.kbn_hin = mkhi.kbn_hin

				LEFT OUTER JOIN ma_konyu m_konyu
				ON tn_zaiko.cd_hinmei = m_konyu.cd_hinmei
				AND tn_zaiko.cd_torihiki = m_konyu.cd_torihiki

				WHERE
					tn_zaiko.cd_niuke_basho LIKE '%' + @cd_niuke + '%'
					AND tn_zaiko.kbn_hin = @kbn_hin
					AND (( @cd_bunrui = '') OR (mh.cd_bunrui LIKE '%' + @cd_bunrui + '%'))
					AND (( @flg_zaiko = 1) OR (tn_zaiko.su_zaiko + tn_zaiko.su_zaiko_hasu  > 0))

			)
		--SET @count = @@ROWCOUNT
		-- 画面に返却する値を取得
		SELECT
			cnt
			,cte_row.flg_kakutei
			,cte_row.nm_niuke
			,cte_row.cd_hinmei
			,cte_row.nm_hinmei_en
			,cte_row.nm_hinmei_ja
			,cte_row.nm_hinmei_zh
			,cte_row.nm_hinmei_vi
			,cte_row.nm_nisugata_hyoji
			,cte_row.nm_torihiki
			,cte_row.nm_hokan_kbn
			,cte_row.nm_kbn_hin
			,cte_row.su_zaiko
			,cte_row.su_zaiko_hasu
			,cte_row.su_shukko
			,cte_row.su_shukko_hasu
			,cte_row.su_iri
			,cte_row.cd_torihiki
			,cte_row.flg_out
			,cte_row.cd_tani_nonyu
			,cte_row.cd_niuke_basho
			,tr.flg_print
		FROM
			(
				SELECT 
					MAX(RN) OVER() cnt
					,*
				FROM
					cte 
			) cte_row

		LEFT JOIN (
			SELECT
				cd_hinmei
				,cd_torihiki
				,flg_print
			FROM
				tr_niuke
			WHERE
				--dt_niuke < DATEADD(DD, @day, @dt_out)
				--dt_niuke = @dt_out
				((no_seq = @minSeqNo AND dt_nonyu = @dt_out)
				 OR (no_seq <> @minSeqNo AND dt_niuke = @dt_out))
			AND flg_print = @true
			GROUP BY
				cd_hinmei
				,cd_torihiki
				,flg_print
				,dt_niuke
		) tr
		ON cte_row.cd_hinmei = tr.cd_hinmei
		AND cte_row.cd_torihiki = tr.cd_torihiki

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
		AND
			(LEN(@print_status) = 0 OR ISNULL(tr.flg_print, @false) = @st_print)
	END
END
GO