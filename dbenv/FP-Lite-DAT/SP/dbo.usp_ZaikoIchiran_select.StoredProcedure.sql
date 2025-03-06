IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ZaikoIchiran_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ZaikoIchiran_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能       ：在庫一覧　在庫を検索します。
ファイル名 ：usp_ZaikoIchiran_select
入力引数   ：@cd_hinmei, @kbn_zaiko, @flg_keikoku
           　, @dtInitValue, @shiyoMishiyoFlg, @isExcel
           　, @skip, @top
出力引数   ：
戻り値     ：
作成日     ：2013.10.23  ADMAX kunii.h
更新日     ：2017.10.16  brycen yokota.t
更新日     ：2019.12.02  brycen saito.k
*****************************************************/
CREATE PROCEDURE [dbo].[usp_ZaikoIchiran_select] 
	@cd_hinmei			VARCHAR(14)		-- 品名コード
	,@kbn_zaiko			VARCHAR(1)		-- 在庫区分
	,@flg_keikoku		SMALLINT		-- 警告フラグ
	,@dtInitValue		VARCHAR(23)		-- 初期日付
	,@shiyoMishiyoFlg	SMALLINT		-- 未使用フラグ
	,@kigengireKigenFlg	SMALLINT		-- 期限フラグ.期限切れ
	,@chokuzenKigenFlg	SMALLINT		-- 期限フラグ.直前
	,@chikaiKigenFlg	SMALLINT		-- 期限フラグ.近い
	,@yoyuKigenFlg		SMALLINT		-- 期限フラグ.余裕
	,@dt_kigen_chikai	DECIMAL			-- 工場マスタ.kigen_chikai
	,@dt_kigen_chokuzen	DECIMAL			-- 工場マスタ.kigen_chokuzen
	,@dt_utc			DATETIME		-- システム「年月日」のUTC日時 EX)日本：yyyy/MM/dd 15:00:00.000
	,@isExcel			SMALLINT		-- Excel出力フラグ
	,@skip				DECIMAL(10)		-- スキップ
	,@top				DECIMAL(10)		-- 検索データ上限
AS
BEGIN

	DECLARE
		@start  DECIMAL(10)
		,@end   DECIMAL(10)
		,@true  BIT
		,@false BIT
		,@minSeqNo DECIMAL(8, 0)
		,@dt_default DATETIME
	
	SET @start = @skip + 1
	SET @end   = @skip + @top
    SET @true  = 1
    SET @false = 0;
    SET @dt_default = '1900-01-01 10:00:00.000'

	SELECT @minSeqNo = MIN(minS.no_seq) FROM tr_niuke minS;
    
    WITH cte AS
		(
			SELECT 
				*
--				,ROW_NUMBER() OVER (ORDER BY dt_niuke) AS RN
				,ROW_NUMBER() OVER (ORDER BY dt_niuke_jisseki) AS RN
			FROM 
				(
					SELECT
						t_niu_first.dt_niuke
						,t_niu_first.tm_nonyu_jitsu
						,t_niu.no_niuke AS no_niuke
						,ISNULL ( t_niu.no_lot, '' ) AS no_lot
						,ISNULL ( t_niu.dt_seizo, @dt_default ) AS dt_seizo
						,ISNULL ( t_niu.dt_kigen, @dt_default ) AS dt_kigen
						,ISNULL ( m_niu.nm_niuke, '' ) AS nm_niuke
						,ISNULL ( k_niu.nm_kbn_niuke, '' ) AS nm_kbn_niuke
						,ISNULL ( m_zaiko.nm_kbn_zaiko, '' ) AS nm_kbn_zaiko
						,ISNULL ( t_niu.su_zaiko, 0 ) AS su_zaiko
						,ISNULL ( t_niu.su_zaiko_hasu, 0 ) AS su_zaiko_hasu
						,ISNULL ( t_niu.cd_hinmei, '') AS cd_hinmei
						,CONVERT ( VARCHAR, t_niu.kbn_zaiko ) AS kbn_zaiko
						,ISNULL ( m_hin.nm_hinmei_ja, '' ) AS nm_hinmei_ja
						,ISNULL ( m_hin.nm_hinmei_en, '' ) AS nm_hinmei_en
						,ISNULL ( m_hin.nm_hinmei_zh, '' ) AS nm_hinmei_zh
						,ISNULL ( m_hin.nm_hinmei_vi, '' ) AS nm_hinmei_vi
						,CASE
							/*WHEN t_niu.dt_kigen IS NULL OR t_niu.dt_seizo IS NULL THEN '0'
							WHEN t_niu.dt_kigen - GETUTCDATE ( ) < 0 THEN '1'
							WHEN  CEILING((CONVERT (DECIMAL,(DATEDIFF(DAY , t_niu.dt_kigen , t_niu.dt_seizo)))* -1) / 3) > CONVERT (INT, (DATEDIFF(DAY, GETUTCDATE() , t_niu.dt_kigen))) THEN '2'
							ELSE '3'*/
							-- 使用期限切れ
							WHEN t_niu.dt_kigen < @dt_utc THEN @kigengireKigenFlg
							-- 使用期限直前
							WHEN t_niu.dt_kigen >=  @dt_utc
							AND t_niu.dt_kigen < DATEADD(DAY,@dt_kigen_chokuzen,@dt_utc) THEN @chokuzenKigenFlg
							-- 使用期限近い
							WHEN t_niu.dt_kigen >=  DATEADD(DAY,@dt_kigen_chokuzen,@dt_utc)
							AND t_niu.dt_kigen < DATEADD(DAY,@dt_kigen_chikai,@dt_utc) THEN @chikaiKigenFlg
							-- 使用期限まで余裕あり
							ELSE @yoyuKigenFlg
						END
						AS flg_keikoku
						,ISNULL ( m_konyu.cd_tani_nonyu, m_hin.cd_tani_nonyu ) AS cd_tani_nonyu
--						,CASE 
--							WHEN t_niu.no_seq = @minSeqNo THEN
--								t_niu2.dt_nonyu
--							ELSE
--								t_niu.dt_niuke
--						END
--						AS dt_niuke_jisseki
						,t_niu2.dt_nonyu AS dt_niuke_jisseki
					FROM tr_niuke t_niu
					INNER JOIN
						(
							SELECT
								MAX ( no_seq ) AS no_seq
								,no_niuke
								,kbn_zaiko
								,cd_niuke_basho
							FROM tr_niuke
							GROUP BY
								no_niuke
								,kbn_zaiko
								,cd_niuke_basho
						) t_niu_new
					ON t_niu.no_niuke = t_niu_new.no_niuke
					AND t_niu.no_seq = t_niu_new.no_seq
					AND t_niu.kbn_zaiko = t_niu_new.kbn_zaiko
					AND t_niu.cd_niuke_basho = t_niu_new.cd_niuke_basho
					INNER JOIN
						(
							SELECT
								dt_niuke
								,tm_nonyu_jitsu
								,no_niuke
								,kbn_zaiko
							FROM tr_niuke
							WHERE
								no_seq =
								(
									SELECT
										MIN ( no_seq ) AS no_seq
									FROM tr_niuke 
								)
						) AS t_niu_first
					ON t_niu.no_niuke = t_niu_first.no_niuke
					--
					INNER JOIN
						(
							--サブクエリ②
							SELECT
								dt_niuke
								, no_niuke
								, tm_nonyu_jitsu
								, dt_nonyu
							FROM tr_niuke
							WHERE no_seq = @minSeqNo
						) t_niu2
					ON t_niu.no_niuke  = t_niu2.no_niuke
					--
					LEFT OUTER JOIN ma_kbn_zaiko m_zaiko
					ON t_niu.kbn_zaiko = m_zaiko.kbn_zaiko
					LEFT OUTER JOIN ma_hinmei m_hin
					ON t_niu.cd_hinmei = m_hin.cd_hinmei
					AND m_hin.flg_mishiyo = 0
					LEFT OUTER JOIN ma_kbn_hokan m_hokan
					ON m_hin.kbn_hokan = m_hokan.cd_hokan_kbn
					AND m_hokan.flg_mishiyo = 0
					LEFT OUTER JOIN ma_konyu m_konyu
					ON t_niu.cd_hinmei = m_konyu.cd_hinmei
					AND t_niu.cd_torihiki = m_konyu.cd_torihiki
					LEFT OUTER JOIN ma_niuke m_niu
					ON t_niu.cd_niuke_basho = m_niu.cd_niuke_basho
					LEFT OUTER JOIN ma_kbn_niuke k_niu
					ON m_niu.kbn_niuke_basho = k_niu.kbn_niuke_basho
					WHERE
						t_niu.cd_hinmei = @cd_hinmei
						AND t_niu.kbn_zaiko LIKE( '%' + ISNULL (@kbn_zaiko, '' ) + '%') 
						AND ( t_niu.su_zaiko > 0 OR t_niu.su_zaiko_hasu > 0 )
						AND t_niu.tm_nonyu_jitsu <> @dtInitValue
						AND t_niu.tm_nonyu_jitsu IS NOT NULL
				) AS zaiko
			WHERE	
				(@flg_keikoku = @false ) 
				OR (@flg_keikoku = @true AND (zaiko.flg_keikoku = 1 OR zaiko.flg_keikoku = 2))
		)
		
		SELECT
			cte_row.cnt
			,cte_row.dt_niuke
			,cte_row.tm_nonyu_jitsu
			,cte_row.no_niuke
			,cte_row.no_lot
			,cte_row.dt_seizo
			,cte_row.dt_kigen
			,cte_row.nm_niuke
			,cte_row.nm_kbn_niuke
			,cte_row.nm_kbn_zaiko
			,cte_row.su_zaiko
			,cte_row.su_zaiko_hasu
			,cte_row.cd_hinmei
			,cte_row.kbn_zaiko
			,cte_row.nm_hinmei_ja
			,cte_row.nm_hinmei_en
			,cte_row.nm_hinmei_zh
			,cte_row.nm_hinmei_vi
			,cte_row.flg_keikoku
			,cte_row.cd_tani_nonyu
			,cte_row.dt_niuke_jisseki
		FROM
			(
				SELECT 
					MAX(RN) OVER() cnt
					,*
				FROM cte 
			) cte_row
		WHERE
			( 
				(
					@isExcel = @false
					AND RN BETWEEN @start AND @end
				)
				OR (
					@isExcel = @true
				)
			)
END
GO
