IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SokoIdoKanri_update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_SokoIdoKanri_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能			：Page SokoIdoKanri: calculator zaiko
ファイル名	：usp_SokoIdoKanri_update
作成日		：2018.07.15  thien.nh
更新日		：2018.08.27  thien.nh
*****************************************************/
CREATE PROC [dbo].[usp_SokoIdoKanri_update]
	-- primary key
	@no_niuke			VARCHAR(14)
	,@cd_niuke_basho	VARCHAR(10)
	,@kbn_zaiko			SMALLINT
	,@no_seq			DECIMAL(8)

	,@cd_tani_nonyu		VARCHAR(10)
	,@flg_insert		SMALLINT		-- 1: insert data, 0: update data

	-- const
	,@NyushukoKakozan	SMALLINT		-- kbn_nyushukko kakozan = 4
	,@idodeKbn			SMALLINT		-- 【入出庫区分】　移動出 = 11
	,@idoiriKbn			SMALLINT		-- 【入出庫区分】　移動入 = 12
	,@error				VARCHAR(50)		OUT
AS
SET XACT_ABORT ON;
DECLARE  @flgInsert		SMALLINT = 1
		,@flgUpdate		SMALLINT = 0
		,@MS0236		VARCHAR(50) = 'MS0236';

BEGIN TRY

	UPDATE tr_niuke
	SET  tr_niuke.su_zaiko		= ROUND((su_zaiko_kanzan / su_iri),0,1)
		,tr_niuke.su_zaiko_hasu = CASE WHEN @cd_tani_nonyu = '4' OR @cd_tani_nonyu = '11'
										THEN 
											su_zaiko_kanzan % su_iri * 1000
										ELSE
											su_zaiko_kanzan % su_iri 
										END 
	FROM	
		(SELECT
			  t_niu_sum.no_niuke	AS no_niuke	
			, t_niu_sum.no_seq		AS no_seq
			, CASE WHEN @cd_tani_nonyu = '4' OR @cd_tani_nonyu = '11'
					THEN
						(	(t_niu_sum.sum_in * t_niu_sum.su_iri)      + (t_niu_sum.sum_hasu_in / 1000)	) -
							(t_niu_sum.sum_out * t_niu_sum.su_iri      + (t_niu_sum.sum_hasu_out / 1000)) +
						(	(t_niu_sum.su_kakozan * t_niu_sum.su_iri)  + (t_niu_sum.su_kakozan_hasu / 1000)	)
					ELSE
						(	t_niu_sum.sum_in * t_niu_sum.su_iri)      + t_niu_sum.sum_hasu_in   -
							(t_niu_sum.sum_out * t_niu_sum.su_iri     + t_niu_sum.sum_hasu_out) +
						(	t_niu_sum.su_kakozan * t_niu_sum.su_iri)  + t_niu_sum.su_kakozan_hasu 
				 END AS su_zaiko_kanzan	
			, t_niu_sum.su_iri		AS su_iri
		FROM
			(SELECT 
				T_NIU.no_niuke 
				, T_NIU.no_seq

				--実納入数の合計を算出
				, (SELECT SUM(ISNULL(t_niu2.su_nonyu_jitsu,0)) * 1.00
				   FROM tr_niuke t_niu2
				   WHERE t_niu2.no_seq     <= T_NIU.no_seq 
					   AND t_niu2.kbn_zaiko = @kbn_zaiko
					   AND t_niu2.no_niuke  = @no_niuke
					   AND t_niu2.cd_niuke_basho = @cd_niuke_basho
					   AND t_niu2.no_seq    > ISNULL((SELECT MAX(no_seq) 
													  FROM tr_niuke 
													  WHERE no_niuke        = @no_niuke 
														 AND cd_niuke_basho = @cd_niuke_basho
														 AND no_seq         < T_NIU.no_seq 
														 AND kbn_nyushukko  = @NyushukoKakozan 
														 AND kbn_zaiko      = @kbn_zaiko),0)
				) AS sum_in

				--実納入端数の合計を算出					
				, (SELECT SUM(ISNULL(t_niu2.su_nonyu_jitsu_hasu,0)) * 1.00
				   FROM tr_niuke t_niu2 
				   WHERE t_niu2.no_seq     <= T_NIU.no_seq 
					   AND t_niu2.kbn_zaiko = @kbn_zaiko
					   AND t_niu2.no_niuke  = @no_niuke
					   AND t_niu2.cd_niuke_basho = @cd_niuke_basho
					   AND t_niu2.no_seq    > ISNULL((SELECT MAX(no_seq) 
													  FROM tr_niuke 
													  WHERE no_niuke        = @no_niuke 
														AND cd_niuke_basho  = @cd_niuke_basho
														AND no_seq          < T_NIU.no_seq 
														AND kbn_nyushukko   = @NyushukoKakozan 
														AND kbn_zaiko       = @kbn_zaiko),0)
				) AS sum_hasu_in

				--出庫数の合計を算出
				, (SELECT SUM(ISNULL(t_niu2.su_shukko,0)) * 1.00
				   FROM tr_niuke t_niu2 
				   WHERE t_niu2.no_seq     <= T_NIU.no_seq 
					   AND t_niu2.kbn_zaiko = @kbn_zaiko
					   AND t_niu2.no_niuke  = @no_niuke
					   AND t_niu2.cd_niuke_basho = @cd_niuke_basho
					   AND t_niu2.no_seq    > ISNULL((SELECT MAX(no_seq) 
													  FROM tr_niuke 
													  WHERE no_niuke          = @no_niuke 
														  AND cd_niuke_basho  = @cd_niuke_basho
														  AND no_seq          < T_NIU.no_seq 
														  AND kbn_nyushukko   = @NyushukoKakozan 
														  AND kbn_zaiko       = @kbn_zaiko),0)
				) AS sum_out

				, (SELECT SUM(ISNULL(t_niu2.su_shukko_hasu,0)) * 1.00
				   FROM tr_niuke t_niu2 
				   WHERE t_niu2.no_seq     <= T_NIU.no_seq 
					   AND t_niu2.kbn_zaiko = @kbn_zaiko
					   AND t_niu2.no_niuke  = @no_niuke
					   AND t_niu2.cd_niuke_basho = @cd_niuke_basho
					   AND t_niu2.no_seq    > ISNULL((SELECT MAX(no_seq) 
													  FROM tr_niuke 
													  WHERE no_niuke          = @no_niuke 
														  AND cd_niuke_basho  = @cd_niuke_basho
														  AND no_seq          < T_NIU.no_seq 
														  AND kbn_nyushukko   = @NyushukoKakozan 
														  AND kbn_zaiko       = @kbn_zaiko),0)
				) AS sum_hasu_out

				, ISNULL((SELECT TOP 1 su_kakozan * 1.00
						  FROM tr_niuke 
						  WHERE no_niuke           = T_NIU.no_niuke
								AND no_seq         < T_NIU.no_seq
								AND cd_niuke_basho = @cd_niuke_basho
								AND kbn_nyushukko  = @NyushukoKakozan 
								AND kbn_zaiko      = @kbn_zaiko 
						  ORDER BY no_seq DESC),0
				) AS su_kakozan
				, ISNULL((SELECT TOP 1 su_kakozan_hasu * 1.00
						  FROM tr_niuke 
						  WHERE no_niuke		   = T_NIU.no_niuke 
								AND no_seq         < T_NIU.no_seq 
								AND cd_niuke_basho = @cd_niuke_basho
								AND kbn_nyushukko  = @NyushukoKakozan
								AND kbn_zaiko      = @kbn_zaiko 
						  ORDER BY 
						  no_seq DESC
						 ),0
				) AS su_kakozan_hasu
				, ISNULL(m_ko.su_iri,1)		AS su_iri

			FROM tr_niuke T_NIU
			LEFT JOIN ma_konyu m_ko
				ON m_ko.cd_hinmei    = T_NIU.cd_hinmei 
				AND m_ko.cd_torihiki = T_NIU.cd_torihiki

			WHERE T_NIU.no_niuke         = @no_niuke
				AND T_NIU.cd_niuke_basho = @cd_niuke_basho
				AND T_NIU.kbn_nyushukko  <> @NyushukoKakozan
			GROUP BY
				T_NIU.no_niuke
				,T_NIU.no_seq
				,T_NIU.cd_niuke_basho
				,T_NIU.kbn_zaiko
				,m_ko.su_iri
			) t_niu_sum
		) t_niu_zaiko_kanzan
	WHERE	t_niu_zaiko_kanzan.no_niuke = tr_niuke.no_niuke 
		AND t_niu_zaiko_kanzan.no_seq   = tr_niuke.no_seq
		AND tr_niuke.kbn_zaiko          = @kbn_zaiko
		AND tr_niuke.cd_niuke_basho		= @cd_niuke_basho
		AND 
		(
			( tr_niuke.no_seq			>= @no_seq  AND @flg_insert = @flgUpdate)  -- update
			OR 
			( tr_niuke.no_seq			>= @no_seq  AND @flg_insert = @flgInsert)  -- insert
		)

	IF((SELECT COUNT(no_niuke) FROM tr_niuke WHERE no_niuke = @no_niuke AND (su_zaiko < 0 OR su_zaiko_hasu < 0)) > 0)
	BEGIN
		SET @error = @MS0236
		RETURN
	END

END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	RAISERROR(@error, 16, 1)
END CATCH
GO
