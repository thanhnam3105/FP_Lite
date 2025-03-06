IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LotNoBetsuZaikoShosai_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosai_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：ロットNo.別在庫詳細検索処理  更新処理
ファイル名  ：usp_LotNoBetsuZaikoShosai_update
入力引数 　 ：@no_niuke, @kbn_zaiko, @no_seq, @kbn_nyushukko
			  , @su_nonyu_jitsu, @su_nonyu_jitsu_hasu, @su_zaiko
			  , @su_zaiko_hasu, @su_shukko, @su_shukko_hasu
			  , @su_kakozan, @su_kakozan_hasu, @biko
			  , @cd_torihiki, @cd_update, @cd_hinmei_search
			  , @dt_niuke_search, @jissekiYojitsuFlg
			  , @shiyoMishiyoFlg, @ryohinZaikoKbn, @horyuZaikoKbn
			  , @nyushukoShiire, @nyushukoSotoInyu
			  , @nyushukoHenkoHoryu, @nyushukoHenkoRyohin
出力引数 　 ：
戻り値   　 ：
作成日   　 ：2013.11.06 ADMAX kunii.h
更新日   　 ：2015.09.10 ADMAX kakuta.y 複数社購買対応
更新日   　 ：2016.12.13 BRC   motojima.m 中文対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosai_update]
	@no_niuke				VARCHAR(14)  -- 荷受番号
	,@kbn_zaiko				SMALLINT     -- 在庫区分
	,@no_seq				DECIMAL(8)   -- シーケンス番号
	,@kbn_nyushukko			SMALLINT     -- 入出庫区分
	,@su_nonyu_jitsu		DECIMAL(9)   -- 実納入数
	,@su_nonyu_jitsu_hasu	DECIMAL(9)   -- 実納入端数
	,@su_zaiko				DECIMAL(9)   -- 在庫数
	,@su_zaiko_hasu			DECIMAL(9)   -- 在庫数端数
	,@su_shukko				DECIMAL(9)   -- 出庫数
	,@su_shukko_hasu		DECIMAL(9)   -- 出庫端数
	,@su_kakozan			DECIMAL(9)   -- 加工残数
	,@su_kakozan_hasu		DECIMAL(9)   -- 加工残端数
	--,@biko				VARCHAR(50)  -- 備考
	,@biko					NVARCHAR(50) -- 備考
	,@cd_torihiki			VARCHAR(13)  -- 明細/取引先コード（非表示項目）
	,@cd_update				VARCHAR(10)  -- 更新者
	,@cd_hinmei_search		VARCHAR(14)  -- 検索条件/品名コード
	,@dt_niuke_search		DATETIME     -- 検索条件/荷受日
	,@jissekiYojitsuFlg		VARCHAR      -- 予実フラグ：実績
	,@shiyoMishiyoFlg		SMALLINT     -- 使用未使用フラグ：使用
	,@ryohinZaikoKbn		SMALLINT     -- 在庫区分：良品
	,@horyuZaikoKbn			SMALLINT     -- 在庫区分：保留
	--,@nyushukoShiire		VARCHAR      -- 入出庫区分：仕入
	,@nyushukoShiire		NVARCHAR     -- 入出庫区分：仕入
	--,@nyushukoSotoInyu	VARCHAR      -- 入出庫区分：外移入
	,@nyushukoSotoInyu		NVARCHAR     -- 入出庫区分：外移入
	--,@nyushukoHenkoHoryu	VARCHAR      -- 入出庫区分：区分変更 保留
	,@nyushukoHenkoHoryu	NVARCHAR     -- 入出庫区分：区分変更 保留
	--,@nyushukoHenkoRyohin	VARCHAR      -- 入出庫区分：区分変更 良品
	,@nyushukoHenkoRyohin	NVARCHAR     -- 入出庫区分：区分変更 良品
	,@cd_niuke_basho		VARCHAR(10)
	,@kbn_nyusyukko_henpin_8 SMALLINT
	,@kbn_nyusyukko_kakozan SMALLINT
	,@kbn_zaiko_search		SMALLINT     -- 在庫区分
	,@is_nyushukoHenkoRyohin SMALLINT
AS
BEGIN
	DECLARE @su_nonyu        DECIMAL(9)  -- 納入数（納入予実トラン更新用）
	DECLARE @su_nonyu_hasu   DECIMAL(9)  -- 納入端数（納入予実トラン更新用）
	DECLARE @no_seq_min		 DECIMAL(8)	 -- 最小シーケンス番号
	DECLARE @no_nonyu		 VARCHAR(13) -- 納入番号（納入予実トラン更新用）

	-- 最小シーケンス番号取得
	SET @no_seq_min = (
						SELECT
							MIN(niu.no_seq)
						FROM tr_niuke niu
						WHERE
							niu.no_niuke = @no_niuke
					  )

	-- 納入番号
	SET @no_nonyu = (
						SELECT
							niu.no_nonyu
						FROM tr_niuke niu
						WHERE
							niu.no_niuke = @no_niuke
							AND kbn_zaiko = @ryohinZaikoKbn
							AND no_seq = @no_seq_min
							AND cd_niuke_basho = @cd_niuke_basho
					  )

	DECLARE @kbn_nyushukko_henpin			SMALLINT
			, @dt_niuke_henpin				DATETIME
			, @su_nonyu_jitsu_henpin		DECIMAL(9,2)
			, @su_nonyu_jitsu_hasu_henpin	DECIMAL(9,2);

	SELECT 
		@kbn_nyushukko_henpin = kbn_nyushukko
		, @dt_niuke_henpin = dt_niuke
		, @su_nonyu_jitsu_henpin = su_nonyu_jitsu
		, @su_nonyu_jitsu_hasu_henpin = su_nonyu_jitsu_hasu
	FROM tr_niuke
	WHERE
		no_niuke      = @no_niuke
		AND kbn_zaiko = @ryohinZaikoKbn
		AND no_seq    = @no_seq
		AND cd_niuke_basho = @cd_niuke_basho

	DECLARE @su_iri			DECIMAL(5,0)
			, @tani_nonyu   DECIMAL(4,0);			
	--品名マスタ.
	SELECT TOP 1
		@tani_nonyu = CASE WHEN hinmei.cd_tani_nonyu IN (4,11)
						THEN 1000
						ELSE 1 END
		, @su_iri = ISNULL(hinmei.su_iri, 0)
	FROM ma_hinmei hinmei
	WHERE
		 hinmei.cd_hinmei = @cd_hinmei_search
		AND hinmei.flg_mishiyo = @shiyoMishiyoFlg

	IF( @kbn_nyushukko_henpin = @nyushukoHenkoRyohin AND @is_nyushukoHenkoRyohin = 1 AND @kbn_zaiko = @ryohinZaikoKbn)
	BEGIN
		
		UPDATE tr_niuke
		SET su_shukko = ROUND((((ISNULL(su_shukko, 0) - @su_nonyu_jitsu_henpin + @su_nonyu_jitsu)* @su_iri*@tani_nonyu) + ISNULL(su_shukko_hasu, 0) - @su_nonyu_jitsu_hasu_henpin + @su_nonyu_jitsu_hasu)/(@su_iri*@tani_nonyu), 1)
			, su_shukko_hasu = ROUND((((ISNULL(su_shukko, 0) - @su_nonyu_jitsu_henpin + @su_nonyu_jitsu)* @su_iri*@tani_nonyu) + ISNULL(su_shukko_hasu, 0) - @su_nonyu_jitsu_hasu_henpin + @su_nonyu_jitsu_hasu)%(@su_iri*@tani_nonyu), 1)

		WHERE 
			no_niuke      = @no_niuke
			AND kbn_zaiko = @ryohinZaikoKbn
			AND cd_niuke_basho = @cd_niuke_basho
			AND dt_niuke = @dt_niuke_henpin
			AND kbn_nyushukko = @kbn_nyusyukko_henpin_8
			AND no_seq = (
				SELECT TOP 1 
					MIN(no_seq)
				FROM tr_niuke tr
				WHERE
					tr.no_niuke      = @no_niuke
					AND tr.kbn_zaiko = @ryohinZaikoKbn
					AND tr.cd_niuke_basho = @cd_niuke_basho
					AND tr.dt_niuke = @dt_niuke_henpin
					AND tr.kbn_nyushukko = @kbn_nyusyukko_henpin_8
					AND tr.no_seq > @no_seq
			)

	END

	IF(@kbn_zaiko <> @kbn_zaiko_search)
	BEGIN 
		SELECT 
			@su_zaiko = ROUND((((su_zaiko + @su_nonyu_jitsu - @su_shukko)*@su_iri*@tani_nonyu) + (su_zaiko_hasu + @su_nonyu_jitsu_hasu - @su_shukko_hasu))/(@su_iri*@tani_nonyu), 1)
			, @su_zaiko_hasu = ROUND((((su_zaiko + @su_nonyu_jitsu - @su_shukko)*@su_iri*@tani_nonyu) + (su_zaiko_hasu + @su_nonyu_jitsu_hasu - @su_shukko_hasu))%(@su_iri*@tani_nonyu), 1)
		FROM tr_niuke
		WHERE 
			no_niuke      = @no_niuke
			AND kbn_zaiko <> @kbn_zaiko_search
			AND cd_niuke_basho = @cd_niuke_basho
			AND no_seq < @no_seq
	END
	
	-- 荷受トラン更新
	UPDATE tr_niuke
	SET 
		su_nonyu_jitsu        = @su_nonyu_jitsu			-- 実納入数
		,su_nonyu_jitsu_hasu = @su_nonyu_jitsu_hasu		-- 実納入端数
		,su_zaiko            = @su_zaiko				-- 在庫数
		,su_zaiko_hasu       = @su_zaiko_hasu			-- 在庫数端数
		,su_shukko           = @su_shukko				-- 出庫数
		,su_shukko_hasu      = @su_shukko_hasu			-- 出庫端数
		,su_kakozan          = @su_kakozan				-- 加工残数
		,su_kakozan_hasu     = @su_kakozan_hasu			-- 加工残端数
		,biko                = @biko					-- 備考
		,cd_update           = @cd_update				-- 更新者
		,dt_update           = GETUTCDATE()				-- 更新日	
	WHERE
		no_niuke      = @no_niuke
		AND kbn_zaiko = @kbn_zaiko
		AND no_seq    = @no_seq
		AND cd_niuke_basho = @cd_niuke_basho

DECLARE @su_nonyu_jitsu_cur			DECIMAL(9)		-- 実納入数
		, @su_nonyu_jitsu_hasu_cur	DECIMAL(9)		-- 実納入端数
		, @su_zaiko_cur				DECIMAL(9)		-- 在庫数
		, @su_zaiko_hasu_cur		DECIMAL(9)		-- 在庫数端数
		, @su_shukko_cur			DECIMAL(9)		-- 出庫数
		, @su_shukko_hasu_cur		DECIMAL(9)		-- 出庫端数
		, @su_zaiko_total			DECIMAL(9)
		, @su_zaiko_hasu_total		DECIMAL(9)	
		, @no_seq_cur				DECIMAL(8)		-- シーケンス番号
		, @kbn_nyushukko_cur		SMALLINT		-- 入出庫区分
		, @su_kakozan_cur			DECIMAL(9)		-- 加工残数
		, @su_kakozan_hasu_cur		DECIMAL(9)		-- 加工残端数

		
SET @su_zaiko_total = @su_zaiko;
SET @su_zaiko_hasu_total = @su_zaiko_hasu;

DECLARE db_cursor CURSOR FOR 
SELECT
	 su_nonyu_jitsu        
	, su_nonyu_jitsu_hasu 
	, su_zaiko          
	, su_zaiko_hasu     
	, su_shukko         
	, su_shukko_hasu 
	, no_seq   
	, kbn_nyushukko
	, su_kakozan
	, su_kakozan_hasu
FROM tr_niuke
WHERE 
	no_niuke      = @no_niuke
	AND kbn_zaiko = @kbn_zaiko
	AND no_seq    > @no_seq
	AND cd_niuke_basho = @cd_niuke_basho
	

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @su_nonyu_jitsu_cur			
							   , @su_nonyu_jitsu_hasu_cur	
							   , @su_zaiko_cur				
							   , @su_zaiko_hasu_cur		
							   , @su_shukko_cur			
 							   , @su_shukko_hasu_cur
							   , @no_seq_cur
							   , @kbn_nyushukko_cur	
							   , @su_kakozan_cur		
							   , @su_kakozan_hasu_cur	

WHILE @@FETCH_STATUS = 0  
BEGIN  

    IF(@kbn_nyushukko_cur = @kbn_nyusyukko_kakozan)
	BEGIN
		SET @su_zaiko_total = @su_kakozan_cur;
		SET @su_zaiko_hasu_total = @su_kakozan_hasu_cur;
	END
	ELSE
	BEGIN
		SET @su_zaiko_total = ROUND((((@su_zaiko_total - @su_shukko_cur + @su_nonyu_jitsu_cur)*@su_iri*@tani_nonyu) + (@su_zaiko_hasu_total - @su_shukko_hasu_cur + @su_nonyu_jitsu_hasu_cur)) /(@su_iri*@tani_nonyu), 1);
		SET @su_zaiko_hasu_total = ROUND((((@su_zaiko_total - @su_shukko_cur + @su_nonyu_jitsu_cur)*@su_iri*@tani_nonyu) + (@su_zaiko_hasu_total - @su_shukko_hasu_cur + @su_nonyu_jitsu_hasu_cur)) %(@su_iri*@tani_nonyu), 1);
	END

	  	-- 荷受トラン更新
	UPDATE tr_niuke
	SET 
		su_zaiko            = @su_zaiko_total				-- 在庫数
		,su_zaiko_hasu       = @su_zaiko_hasu_total			-- 在庫数端数
	
	WHERE
		no_niuke      = @no_niuke
		AND kbn_zaiko = @kbn_zaiko
		AND no_seq    = @no_seq_cur
		AND cd_niuke_basho = @cd_niuke_basho

      FETCH NEXT FROM db_cursor INTO @su_nonyu_jitsu_cur			 
									 , @su_nonyu_jitsu_hasu_cur	
									 , @su_zaiko_cur				
									 , @su_zaiko_hasu_cur		
									 , @su_shukko_cur			
									 , @su_shukko_hasu_cur	
									 , @no_seq_cur
									 , @kbn_nyushukko_cur	
									 , @su_kakozan_cur		
									 , @su_kakozan_hasu_cur	


END 

CLOSE db_cursor  
DEALLOCATE db_cursor 
		
	IF @@ROWCOUNT > 0
	
		IF (@kbn_nyushukko = @nyushukoShiire 
			OR @kbn_nyushukko = @nyushukoSotoInyu)
			
		-- 入出庫区分が「仕入」、「外移入」の場合、納入予実トランを更新
		BEGIN
					
			-- 納入数、納入端数を算出
					
			SELECT 
				@su_nonyu = SUM(cs)
				,@su_nonyu_hasu = SUM(hasu)
				FROM
					(
						SELECT
							ROUND(((ISNULL(tn.su_nonyu_jitsu, 0) * ISNULL(mk.su_iri,0) + ISNULL(tn.su_nonyu_jitsu_hasu, 0)) /  ISNULL(mk.su_iri,0)),0,1) AS cs
							,ROUND(((ISNULL(tn.su_nonyu_jitsu, 0) * ISNULL(mk.su_iri,0) + ISNULL(tn.su_nonyu_jitsu_hasu, 0)) %  ISNULL(mk.su_iri,0)),0,1) AS hasu
						FROM tr_niuke tn 
						LEFT OUTER JOIN ma_konyu mk 
						ON tn.cd_hinmei = mk.cd_hinmei
						AND mk.no_juni_yusen = 
						(
							SELECT
								MIN(mk.no_juni_yusen) 
							FROM tr_niuke tn 
							LEFT JOIN ma_konyu mk 
							ON tn.cd_hinmei = mk.cd_hinmei
							AND tn.cd_torihiki = mk.cd_torihiki
							AND mk.flg_mishiyo = @shiyoMishiyoFlg
							WHERE 
								tn.cd_hinmei = @cd_hinmei_search
						)
						AND mk.flg_mishiyo = @shiyoMishiyoFlg
						WHERE
							--tn.cd_hinmei = @cd_hinmei_search
							--AND tn.dt_niuke = @dt_niuke_search
							--AND (tn.kbn_nyushukko = @nyushukoShiire OR tn.kbn_nyushukko = @nyushukoSotoInyu)
							tn.no_niuke = @no_niuke
							AND tn.kbn_zaiko = @ryohinZaikoKbn
							AND tn.no_seq = @no_seq_min
							AND tn.cd_niuke_basho = @cd_niuke_basho
						GROUP BY
							tn.su_nonyu_jitsu
							,tn.su_nonyu_jitsu_hasu
							,mk.su_iri
					) nonyu
			-- 納入予実トラン更新
			UPDATE tr_nonyu
			SET
				dt_nonyu = @dt_niuke_search		-- 納入日
				,su_nonyu = @su_nonyu			-- 納入数
				,su_nonyu_hasu = @su_nonyu_hasu	-- 納入端数
			WHERE
				--cd_hinmei = @cd_hinmei_search
				--AND dt_nonyu = @dt_niuke_search
				--AND flg_yojitsu = @jissekiYojitsuFlg
				--AND cd_torihiki = @cd_torihiki
				no_nonyu = @no_nonyu
				AND flg_yojitsu = @jissekiYojitsuFlg
		END
END



GO
