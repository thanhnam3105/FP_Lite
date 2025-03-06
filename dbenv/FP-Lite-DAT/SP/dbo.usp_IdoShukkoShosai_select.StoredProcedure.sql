IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_IdoShukkoShosai_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_IdoShukkoShosai_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能       ：移動出庫詳細　検索
ファイル名 ：usp_IdoShukkoShosai_select
入力引数   ：@dt_shukko,　@cd_hinmei
             , @cd_torihiki, @kbn_nyushukko
             , @flg_zaiko, @skip, @top
出力引数   ：
戻り値     ：
作成日     ：2013.11.01  ADMAX endo.y
更新日     ：2019.07.03  BRC saito.k
更新日     ：2019.08.08  BRC kanehira
更新日     ：2021.10.20  BRC saito #1492対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_IdoShukkoShosai_select]
	@dt_shukko			DATETIME
	,@cd_hinmei			VARCHAR(14)
	,@cd_torihiki		VARCHAR(13)
	,@kbn_hin			SMALLINT
	,@kbn_nyushukko		SMALLINT
	,@flg_zaiko			SMALLINT
	,@su_iri			DECIMAL(5)
	,@cd_niuke_basho	VARCHAR(10)
	,@shiyoMishiyoFlg	SMALLINT
	,@keShukkoFlg		SMALLINT
	--TOsVN 17035 2020/04/17 Start -->
	,@dt_niuke_fr		DATETIME
	,@dt_niuke_to		DATETIME
	--TOsVN 17035 2020/04/17 End <--
	,@skip				DECIMAL(10)
	,@top				DECIMAL(10)
WITH RECOMPILE
AS
BEGIN
	DECLARE
		@start	DECIMAL(10)
		,@end	DECIMAL(10)
		,@true	BIT
		,@false	BIT
		,@day	SMALLINT
		,@minSeqNo DECIMAL(8, 0)
		,@dt_addOne DATETIME
	SET @start = @skip + 1
	SET @end   = @skip + @top
	SET @true  = 1
	SET @false = 0
	SET @day = 1;
	SELECT @minSeqNo = MIN(minS.no_seq) FROM tr_niuke minS;
	SELECT @dt_addOne = DATEADD(DD,@day,@dt_shukko);
	
	BEGIN

		WITH cte AS
		(
			SELECT 
				*
				,CASE WHEN cd_tani_nonyu = '4' OR cd_tani_nonyu = '11'
					THEN (su_zaiko + su_shukko) * @su_iri + ((su_zaiko_hasu + su_shukko_hasu)* 1.0 / 1000)
					ELSE (su_zaiko + su_shukko) * @su_iri + su_zaiko_hasu + su_shukko_hasu
				 END AS zaikoAll
				,CASE WHEN cd_tani_nonyu = '4' OR cd_tani_nonyu = '11'
					THEN (saishinZaiko + su_shukko) * @su_iri + ((saishinZaikoHasu + su_shukko_hasu)* 1.0 / 1000)
					ELSE (saishinZaiko + su_shukko) * @su_iri + saishinZaikoHasu + su_shukko_hasu
				 END AS zaikoSaishin
				--,(su_zaiko + su_shukko) * @su_iri + su_zaiko_hasu + su_shukko_hasu AS zaikoAll
				--,ROW_NUMBER() OVER (ORDER BY dt_niuke) AS RN
				,ROW_NUMBER() OVER (ORDER BY dt_niuke_jisseki) AS RN
			FROM 
				(
					SELECT 
						tr2.dt_niuke dt_niuke
						,ISNULL(tr2.tm_nonyu_jitsu,'00:00') AS tm_nonyu_jitsu
						,ISNULL(tr.no_lot,'') AS no_lot
						,ISNULL(tr.dt_seizo,'') AS dt_seizo
						,ISNULL(tr.dt_kigen,'') AS dt_kigen
						,mkz.nm_kbn_zaiko nm_kbn_zaiko
						,tr.kbn_zaiko kbn_zaiko
						,ISNULL(tr.su_zaiko,0) AS su_zaiko
						,ISNULL(tr.su_zaiko_hasu,0) AS su_zaiko_hasu
						,0 su_shukko
						,0 su_shukko_hasu
						,'' tm_shukko
						,'' biko
						,tr.no_niuke no_niuke
						,tr.no_seq no_seq
						,'0' flg_zaiko_rireki
						,tr.dt_niuke max_dt_niuke
						,ISNULL ( m_konyu.cd_tani_nonyu, ma_hin.cd_tani_nonyu ) AS cd_tani_nonyu
						,maxzaiko.su_zaiko AS saishinZaiko
						,maxzaiko.su_zaiko_hasu AS saishinZaikoHasu
						,tr2.dt_nonyu AS dt_niuke_jisseki
						,tr.cd_niuke_basho
						,tr.no_seq AS new_no_seq
					FROM
						tr_niuke tr
					INNER JOIN
						(
							--サブクエリ①
							SELECT 
								MAX(trNiuke.no_seq) AS no_seq
								,trNiuke.no_niuke
								,trNiuke.cd_niuke_basho
								,trNiuke.kbn_zaiko
							FROM
								tr_niuke 					AS trNiuke

								INNER JOIN ma_niuke 		AS maNiuke
								ON trNiuke.cd_niuke_basho 	= 	maNiuke.cd_niuke_basho
								AND maNiuke.flg_mishiyo		= 	@shiyoMishiyoFlg

								INNER JOIN ma_kbn_niuke		AS kbnNiuke
								ON maNiuke.kbn_niuke_basho 	= 	kbnNiuke.kbn_niuke_basho
								AND kbnNiuke.flg_shukko		= 	@keShukkoFlg
								AND kbnNiuke.flg_mishiyo	=	@shiyoMishiyoFlg
							WHERE
								(trNiuke.no_seq = @minSeqNo AND trNiuke.dt_nonyu < @dt_addOne)
								OR (trNiuke.no_seq <> @minSeqNo AND trNiuke.dt_niuke < @dt_addOne)
							GROUP BY
								trNiuke.no_niuke, trNiuke.kbn_zaiko, trNiuke.cd_niuke_basho
						) tr1
					ON tr.no_niuke 			= tr1.no_niuke
					AND tr.no_seq 			= tr1.no_seq
					AND tr.kbn_zaiko 		= tr1.kbn_zaiko
					AND tr.cd_niuke_basho 	= tr1.cd_niuke_basho
					INNER JOIN
						(
							--サブクエリ②
							SELECT
								dt_niuke
								, no_niuke
								, tm_nonyu_jitsu
								, dt_nonyu
							FROM tr_niuke
							--WHERE no_seq = (SELECT MIN(no_seq) FROM tr_niuke)
							WHERE no_seq = @minSeqNo
								--TOsVN 17035 2020/04/17 Start -->
								AND (@dt_niuke_fr IS NULL OR dt_niuke >= @dt_niuke_fr)
								AND (@dt_niuke_to IS NULL OR dt_niuke <= @dt_niuke_to)
								--TOsVN 17035 2020/04/17 End <--
						) tr2
					ON tr.no_niuke  = tr2.no_niuke
					LEFT JOIN ma_kbn_zaiko mkz
					ON tr.kbn_zaiko = mkz.kbn_zaiko
					LEFT JOIN ma_hinmei ma_hin
					ON tr.cd_hinmei = ma_hin.cd_hinmei
					LEFT JOIN ma_konyu m_konyu
					ON tr.cd_hinmei = m_konyu.cd_hinmei
					AND tr.cd_torihiki = m_konyu.cd_torihiki
					LEFT JOIN (
						select su_zaiko
								,su_zaiko_hasu
								,maxtn.no_niuke
								,kbn_zaiko
								,maxtn.cd_niuke_basho
						from tr_niuke maxtn
						inner join (
							select max(no_seq) maxseq
									,no_niuke
									,cd_niuke_basho 
							from tr_niuke
							group by no_niuke, cd_niuke_basho
						)max_niu
						on maxtn.no_niuke = max_niu.no_niuke
							and maxtn.no_seq = max_niu.maxseq
							and maxtn.cd_niuke_basho = max_niu.cd_niuke_basho
					)maxzaiko
					on tr.no_niuke = maxzaiko.no_niuke
						and tr.kbn_zaiko = maxzaiko.kbn_zaiko
						and tr.cd_niuke_basho = maxzaiko.cd_niuke_basho
					WHERE 
						tr.cd_hinmei = @cd_hinmei
						AND tr.tm_nonyu_jitsu <> ''
						AND tr.tm_nonyu_jitsu IS NOT NULL
						AND tr.cd_torihiki = @cd_torihiki
						AND tr.kbn_hin = @kbn_hin
						AND NOT EXISTS(
										SELECT
											* 
										FROM
											tr_niuke
										WHERE
											no_niuke = tr.no_niuke
											AND cd_niuke_basho = tr.cd_niuke_basho
											--AND kbn_zaiko = tr.kbn_zaiko
											--AND no_seq = tr.no_seq
											--AND (@dt_shukko	<= dt_niuke AND dt_niuke < (SELECT DATEADD(DD,@day,@dt_shukko)))
											AND ((no_seq = @minSeqNo AND @dt_shukko <= dt_nonyu AND dt_nonyu < @dt_addOne)
												 OR (no_seq <> @minSeqNo AND @dt_shukko <= dt_niuke AND dt_niuke < @dt_addOne))
											AND kbn_nyushukko = @kbn_nyushukko
										)
						AND ((@flg_zaiko = @true AND (tr.su_zaiko > 0 OR tr.su_zaiko_hasu > 0)) OR (@flg_zaiko = @false))
						AND tr.cd_niuke_basho = @cd_niuke_basho
	
					UNION
					SELECT
						tr2.dt_niuke
						,ISNULL(tr2.tm_nonyu_jitsu,'00:00') AS tm_nonyu_jitsu
						,ISNULL(tr.no_lot,'') AS no_lot
						,ISNULL(tr.dt_seizo,'') AS dt_seizo
						,ISNULL(tr.dt_kigen,'') AS dt_kigen
						,mkz.nm_kbn_zaiko
						,tr.kbn_zaiko
						--,ISNULL(tr.su_zaiko,0) AS su_zaiko
						--,ISNULL(tr.su_zaiko_hasu,0) AS su_zaiko_hasu
						,COALESCE(new_zaiko.su_zaiko,tr.su_zaiko,0) AS su_zaiko
						,COALESCE(new_zaiko.su_zaiko_hasu,tr.su_zaiko_hasu,0) AS su_zaiko_hasu
						--,ISNULL(tr.su_shukko,0) AS su_shukko
						,CASE ma_hin.cd_tani_nonyu
							-- 単位コード:4
							WHEN 4 THEN  ISNULL (tr.su_shukko, 0) 
									+	ROUND(ISNULL(tr.su_shukko_hasu, 0)/(ma_hin.su_iri * 1000),0,1)
							-- 単位コード：11
							WHEN 11 THEN ISNULL (tr.su_shukko, 0)
									+	ROUND(ISNULL(tr.su_shukko_hasu, 0)/(ma_hin.su_iri * 1000),0,1)	
							-- 単位コード：その他
							ELSE ISNULL(tr.su_shukko, 0)
									+ ROUND(ISNULL(tr.su_shukko_hasu, 0)/ ma_hin.su_iri,0,1)
						 END su_shukko
						--,ISNULL(tr.su_shukko_hasu,0) AS su_shukko_hasu
						,CASE ma_hin.cd_tani_nonyu
							-- 単位コード:4
							WHEN 4 THEN  
									ROUND(ISNULL(tr.su_shukko_hasu, 0.000)%(ma_hin.su_iri * 1000),0,1)
							-- 単位コード：11
							WHEN 11 THEN
									ROUND(ISNULL(tr.su_shukko_hasu, 0.000)%(ma_hin.su_iri * 1000),0,1)
							--  単位コード：その他
							ELSE ROUND(ISNULL(tr.su_shukko_hasu, 0.000)% ma_hin.su_iri,0,1)
						 END su_shukko_hasu
						,tr.tm_nonyu_jitsu
						,ISNULL(tr.biko,'') AS biko
						,tr.no_niuke
						,tr.no_seq
						,'1' flg_zaiko_rireki
						,tr.dt_niuke
						,ISNULL ( m_konyu.cd_tani_nonyu, ma_hin.cd_tani_nonyu ) AS cd_tani_nonyu
						,maxzaiko.su_zaiko AS saishinZaiko
						,maxzaiko.su_zaiko_hasu AS saishinZaikoHasu
						,tr2.dt_nonyu AS dt_niuke_jisseki
						,tr.cd_niuke_basho
						,new_zaiko.no_seq AS new_no_seq
					FROM
						tr_niuke tr
					INNER JOIN
						(
							--サブクエリ②
							SELECT
								dt_niuke
								,no_niuke
								,tm_nonyu_jitsu
								,dt_nonyu
							FROM
								tr_niuke
							WHERE
								--no_seq = (SELECT MIN(no_seq) FROM tr_niuke)	
								no_seq = @minSeqNo
								--TOsVN 17035 2020/04/17 Start -->
								AND (@dt_niuke_fr IS NULL OR dt_niuke >= @dt_niuke_fr)
								AND (@dt_niuke_to IS NULL OR dt_niuke <= @dt_niuke_to)
								--TOsVN 17035 2020/04/17 End <--
						) tr2
					ON tr.no_niuke = tr2.no_niuke
					LEFT JOIN ma_kbn_zaiko mkz
					ON tr.kbn_zaiko = mkz.kbn_zaiko
					LEFT JOIN ma_hinmei ma_hin
					ON tr.cd_hinmei = ma_hin.cd_hinmei
					LEFT JOIN ma_konyu m_konyu
					ON tr.cd_hinmei = m_konyu.cd_hinmei
					AND tr.cd_torihiki = m_konyu.cd_torihiki
					--LEFT JOIN ( SELECT TOP 1 no_niuke,kbn_zaiko,su_zaiko,su_zaiko_hasu
								--FROM tr_niuke
								--WHERE cd_hinmei = @cd_hinmei
								--AND kbn_nyushukko <> @kbn_nyushukko
								--AND kbn_nyushukko <> 12 AND kbn_nyushukko <> 11 AND kbn_nyushukko <> 1 AND kbn_nyushukko <> 9
								--AND kbn_nyushukko <> 1 AND kbn_nyushukko <> 9
								--AND cd_niuke_basho = @cd_niuke_basho
								--AND cd_torihiki = @cd_torihiki
								--AND kbn_hin = @kbn_hin
								--AND (@dt_shukko <= dt_niuke AND dt_niuke < (SELECT DATEADD(DD,@day,@dt_shukko)))
								--AND ((no_seq = @minSeqNo AND @dt_shukko <= dt_nonyu AND dt_nonyu < @dt_addOne)
									--OR (no_seq <> @minSeqNo AND @dt_shukko <= dt_niuke AND dt_niuke < @dt_addOne))
								--AND tm_nonyu_jitsu > ( SELECT TOP 1 tm_nonyu_jitsu 
								--					   FROM tr_niuke 
								--					   WHERE cd_hinmei = @cd_hinmei
								--						AND kbn_nyushukko = @kbn_nyushukko 
								--						AND cd_torihiki = @cd_torihiki
								--						AND kbn_hin = @kbn_hin
								--						--AND (@dt_shukko <= dt_niuke AND dt_niuke < (SELECT DATEADD(DD,@day,@dt_shukko)))
								--						AND ((no_seq = @minSeqNo AND @dt_shukko <= dt_nonyu AND dt_nonyu < @dt_addOne)
								--							OR (no_seq <> @minSeqNo AND @dt_shukko <= dt_niuke AND dt_niuke < @dt_addOne))
								--					 )
								--AND no_seq >= (
												--SELECT
													--MAX(no_seq)
												--FROM
													--tr_niuke
												--WHERE
													--d_hinmei = @cd_hinmei
													--AND kbn_nyushukko = @kbn_nyushukko
													--AND cd_torihiki = @cd_torihiki
													--AND kbn_hin = @kbn_hin
													--AND ((no_seq = @minSeqNo AND @dt_shukko <= dt_nonyu AND dt_nonyu < @dt_addOne)
													--OR (no_seq <> @minSeqNo AND @dt_shukko <= dt_niuke AND dt_niuke < @dt_addOne))
													--AND cd_niuke_basho = @cd_niuke_basho
											   --)
								--ORDER BY tm_nonyu_jitsu DESC
								--ORDER BY no_seq DESC
							--) new_zaiko
						--ON tr.no_niuke = new_zaiko.no_niuke
						--AND tr.kbn_zaiko = new_zaiko.kbn_zaiko
					LEFT JOIN (
								SELECT
									sz.no_niuke
									,sz.kbn_zaiko
									,sz.su_zaiko
									,sz.su_zaiko_hasu
									,sq.no_seq
								FROM
									tr_niuke sz
								INNER JOIN (
												SELECT
													MAX(no_seq) AS no_seq
													,no_niuke
													,cd_niuke_basho
												FROM
													tr_niuke
												WHERE
													cd_hinmei = @cd_hinmei
													AND kbn_nyushukko <> 1 AND kbn_nyushukko <> 9
													AND cd_niuke_basho = @cd_niuke_basho
													AND cd_torihiki = @cd_torihiki
													AND kbn_hin = @kbn_hin
													AND ((no_seq = @minSeqNo AND @dt_shukko <= dt_nonyu AND dt_nonyu < @dt_addOne)
													OR  (no_seq <> @minSeqNo AND @dt_shukko <= dt_niuke AND dt_niuke < @dt_addOne))
													GROUP BY
														no_niuke, cd_niuke_basho
										   ) sq
								ON 
									sq.no_niuke = sz.no_niuke
									AND sq.cd_niuke_basho = sz.cd_niuke_basho
									AND sq.no_seq = sz.no_seq
							  ) new_zaiko
					ON
						tr.no_niuke = new_zaiko.no_niuke
						AND tr.kbn_zaiko = new_zaiko.kbn_zaiko
					LEFT JOIN (
						select su_zaiko
								,su_zaiko_hasu
								,maxtn.no_niuke
								,kbn_zaiko
								,maxtn.cd_niuke_basho
						from tr_niuke maxtn
						inner join (
							select max(no_seq) maxseq
									,no_niuke
									,cd_niuke_basho 
							from tr_niuke
							group by no_niuke, cd_niuke_basho
						)max_niu
						on maxtn.no_niuke = max_niu.no_niuke
							and maxtn.no_seq = max_niu.maxseq
							and maxtn.cd_niuke_basho = max_niu.cd_niuke_basho
					)maxzaiko
					on tr.no_niuke = maxzaiko.no_niuke
						and tr.kbn_zaiko = maxzaiko.kbn_zaiko
						and tr.cd_niuke_basho = maxzaiko.cd_niuke_basho
					WHERE 
						tr.cd_hinmei = @cd_hinmei
						--AND (@dt_shukko	<= tr.dt_niuke AND tr.dt_niuke < (SELECT DATEADD(DD,@day,@dt_shukko)))
						AND ((tr.no_seq = @minSeqNo AND @dt_shukko <= tr.dt_nonyu AND tr.dt_nonyu < @dt_addOne)
							OR (tr.no_seq <> @minSeqNo AND @dt_shukko <= tr.dt_niuke AND tr.dt_niuke < @dt_addOne))
						AND tr.kbn_nyushukko = @kbn_nyushukko
						AND tr.cd_torihiki = @cd_torihiki
						AND tr.kbn_hin = @kbn_hin
						--AND ((@flg_zaiko = @true AND (tr.su_zaiko > 0 OR tr.su_zaiko_hasu > 0)) OR (@flg_zaiko = @false))
						AND ((@flg_zaiko = @true AND (new_zaiko.su_zaiko > 0 OR new_zaiko.su_zaiko_hasu > 0))or(@flg_zaiko = @true AND (tr.su_zaiko > 0 OR tr.su_zaiko_hasu > 0)) OR (@flg_zaiko = @false))
						AND tr.cd_niuke_basho = @cd_niuke_basho
				) shukko 
		)
		SELECT
			cte_row.cnt
			,cte_row.dt_niuke
			,cte_row.tm_nonyu_jitsu
			,cte_row.no_lot
			,cte_row.dt_seizo
			,cte_row.dt_kigen
			,cte_row.nm_kbn_zaiko
			,cte_row.kbn_zaiko
			,cte_row.su_zaiko
			,cte_row.su_zaiko_hasu
			,cte_row.su_shukko
			,cte_row.su_shukko			AS	su_shukko_old
			,cte_row.su_shukko_hasu
			,cte_row.su_shukko_hasu		AS  su_shukko_hasu_old
			,cte_row.tm_shukko
			,cte_row.biko
			,cte_row.no_niuke
			,cte_row.no_seq
			,cte_row.flg_zaiko_rireki
			,cte_row.max_dt_niuke
			,cte_row.cd_tani_nonyu
			,cte_row.zaikoAll
			,cte_row.zaikoSaishin
			,cte_row.dt_niuke_jisseki
			,cte_row.cd_niuke_basho
			,cte_row.new_no_seq
		FROM(
				SELECT 
					MAX(RN) OVER() cnt
					,*
				FROM
					cte 
			) cte_row
		WHERE
			RN BETWEEN @start AND @end
	END
END
GO
