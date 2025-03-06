IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_IdoShukkoShosai_update03') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_IdoShukkoShosai_update03]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能       ：移動出庫詳細　後続データの在庫数を更新します。
ファイル名 ：usp_IdoShukkoShosai_update02
入力引数   ：@no_niuke, @kbn_zaiko, @kbn_nyushukko	
出力引数   ：
戻り値     ：
作成日     ：2013.11.07  ADMAX endo.y
更新日     ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_IdoShukkoShosai_update03] 
	@no_niuke			VARCHAR(14)
	, @kbn_zaiko		SMALLINT
	, @kbn_nyushukko	SMALLINT
	, @cdNonyuTani	    VARCHAR(10)
	, @cdNiuke_basho	VARCHAR(10)
AS
BEGIN
UPDATE tr_niuke
	SET  tr_niuke.su_zaiko = ROUND((su_zaiko_kanzan / su_iri),0,1)
		,tr_niuke.su_zaiko_hasu = CASE WHEN @cdNonyuTani = '4' OR @cdNonyuTani = '11'
									THEN 
										su_zaiko_kanzan % su_iri * 1000
									ELSE
										su_zaiko_kanzan % su_iri 
									END 
FROM	
	(SELECT
		t_niu_sum.no_niuke AS no_niuke	
		, t_niu_sum.no_seq AS no_seq
		--, (t_niu_sum.sum_in * t_niu_sum.su_iri)     + t_niu_sum.sum_hasu_in   -
		--  (t_niu_sum.sum_out * t_niu_sum.su_iri     + t_niu_sum.sum_hasu_out) +
		--  (t_niu_sum.su_kakozan * t_niu_sum.su_iri) + t_niu_sum.su_kakozan_hasu AS su_zaiko_kanzan
		,CASE WHEN @cdNonyuTani = '4' OR @cdNonyuTani = '11'
			THEN
				((t_niu_sum.sum_in * t_niu_sum.su_iri)     + (t_niu_sum.sum_hasu_in / 1000)) -
				(t_niu_sum.sum_out * t_niu_sum.su_iri     + (t_niu_sum.sum_hasu_out / 1000)) +
				((t_niu_sum.su_kakozan * t_niu_sum.su_iri) + (t_niu_sum.su_kakozan_hasu / 1000))
			ELSE
				(t_niu_sum.sum_in * t_niu_sum.su_iri)     + t_niu_sum.sum_hasu_in   -
				(t_niu_sum.sum_out * t_niu_sum.su_iri     + t_niu_sum.sum_hasu_out) +
				(t_niu_sum.su_kakozan * t_niu_sum.su_iri) + t_niu_sum.su_kakozan_hasu 
		 END AS su_zaiko_kanzan	
		, t_niu_sum.su_iri su_iri
	FROM
		(SELECT 
			t_niu.no_niuke 
			, t_niu.no_seq
			--実納入数の合計を算出
			, (SELECT SUM(ISNULL(t_niu2.su_nonyu_jitsu,0)) * 1.00
			   FROM tr_niuke t_niu2
			   WHERE t_niu2.no_seq     <= t_niu.no_seq 
				   AND t_niu2.kbn_zaiko = @kbn_zaiko
				   AND t_niu2.no_niuke  = @no_niuke 
				   AND t_niu2.cd_niuke_basho = @cdNiuke_basho
				   AND t_niu2.no_seq    > ISNULL((SELECT MAX(no_seq) 
												  FROM tr_niuke 
												  WHERE no_niuke        = @no_niuke
													  AND cd_niuke_basho = @cdNiuke_basho 
													  AND no_seq        < t_niu.no_seq 
													  AND kbn_nyushukko = @kbn_nyushukko 
													  AND kbn_zaiko     = @kbn_zaiko),0)
			) sum_in
			--実納入端数の合計を算出					
			, (SELECT SUM(ISNULL(t_niu2.su_nonyu_jitsu_hasu,0)) * 1.00
			   FROM tr_niuke t_niu2 
			   WHERE t_niu2.no_seq     <= t_niu.no_seq 
				   AND t_niu2.kbn_zaiko = @kbn_zaiko
				   AND t_niu2.no_niuke  = @no_niuke 
				   AND t_niu2.cd_niuke_basho = @cdNiuke_basho
				   AND t_niu2.no_seq    > ISNULL((SELECT MAX(no_seq) 
												  FROM tr_niuke 
												  WHERE no_niuke        = @no_niuke
													  AND cd_niuke_basho = @cdNiuke_basho
													  AND no_seq        < t_niu.no_seq 
													  AND kbn_nyushukko = @kbn_nyushukko 
													  AND kbn_zaiko     = @kbn_zaiko),0)
			) sum_hasu_in
			--出庫数の合計を算出
			, (SELECT SUM(ISNULL(t_niu2.su_shukko,0)) * 1.00
			   FROM tr_niuke t_niu2 
			   WHERE t_niu2.no_seq     <= t_niu.no_seq 
				   AND t_niu2.kbn_zaiko = @kbn_zaiko
				   AND t_niu2.no_niuke  = @no_niuke 
				   AND t_niu2.cd_niuke_basho = @cdNiuke_basho
				   AND t_niu2.no_seq    > ISNULL((SELECT MAX(no_seq) 
												  FROM tr_niuke 
												  WHERE no_niuke         = @no_niuke
													  AND cd_niuke_basho = @cdNiuke_basho 
													  AND no_seq         < t_niu.no_seq 
													  AND kbn_nyushukko  = @kbn_nyushukko 
													  AND kbn_zaiko      = @kbn_zaiko),0)
			) sum_out
			, (SELECT SUM(ISNULL(t_niu2.su_shukko_hasu,0)) * 1.00
			   FROM tr_niuke t_niu2 
			   WHERE t_niu2.no_seq     <= t_niu.no_seq 
				   AND t_niu2.kbn_zaiko = @kbn_zaiko
				   AND t_niu2.no_niuke  = @no_niuke
				   AND t_niu2.cd_niuke_basho = @cdNiuke_basho 
				   AND t_niu2.no_seq    > ISNULL((SELECT MAX(no_seq) 
												  FROM tr_niuke 
												  WHERE no_niuke         = @no_niuke
													  AND cd_niuke_basho = @cdNiuke_basho  
													  AND no_seq         < t_niu.no_seq 
													  AND kbn_nyushukko  = @kbn_nyushukko 
													  AND kbn_zaiko      = @kbn_zaiko),0)
			) sum_hasu_out
			, ISNULL((SELECT TOP 1 su_kakozan * 1.00
					  FROM tr_niuke 
					  WHERE no_niuke			= t_niu.no_niuke 
						  AND no_seq			< t_niu.no_seq 
						  AND kbn_nyushukko		= @kbn_nyushukko 
						  AND kbn_zaiko			= @kbn_zaiko
						  AND cd_niuke_basho	= @cdNiuke_basho  
					  ORDER BY no_seq DESC),0
			) su_kakozan
			, ISNULL((SELECT TOP 1 su_kakozan_hasu * 1.00
					  FROM tr_niuke 
					  WHERE no_niuke        = t_niu.no_niuke 
						  AND no_seq        < t_niu.no_seq 
						  AND kbn_nyushukko = @kbn_nyushukko
						  AND kbn_zaiko     = @kbn_zaiko
						  AND cd_niuke_basho	= @cdNiuke_basho 
					  ORDER BY no_seq DESC),0
			) su_kakozan_hasu
			, ISNULL(m_ko.su_iri,1) su_iri
		FROM tr_niuke t_niu
			LEFT JOIN ma_konyu m_ko
				ON m_ko.cd_hinmei    = t_niu.cd_hinmei 
				AND m_ko.cd_torihiki = t_niu.cd_torihiki
		WHERE t_niu.no_niuke         = @no_niuke
			AND t_niu.kbn_nyushukko <> @kbn_nyushukko
		GROUP BY t_niu.no_niuke, t_niu.no_seq, m_ko.su_iri, t_niu.cd_niuke_basho
		) t_niu_sum
	) t_niu_zaiko_kanzan
WHERE	t_niu_zaiko_kanzan.no_niuke = tr_niuke.no_niuke 
	AND t_niu_zaiko_kanzan.no_seq   = tr_niuke.no_seq
	AND tr_niuke.kbn_zaiko          = @kbn_zaiko
	AND tr_niuke.cd_niuke_basho		= @cdNiuke_basho
END
GO
