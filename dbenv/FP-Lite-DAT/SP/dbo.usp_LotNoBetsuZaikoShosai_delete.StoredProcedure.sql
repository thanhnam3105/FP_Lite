IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LotNoBetsuZaikoShosai_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosai_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：在庫区分変更 追加
ファイル名  ：usp_LotNoBetsuZaikoShosai_delete
入力引数    ：@no_niuke, @dt_nitizi, @cd_update,
			  @no_seq, @kbnChosei, @kbnChosei_ari, @no_seq_chosei,
			  @cd_hinmei, @cd_riyu, @su_moto_chosei, @cd_location,
			  @kbn_nyusyukko, @kbn_nyusyukko_horyu, @kbn_nyusyukko_ryohin,
			  @kbn_nyusyukko_henpin, @kbn_zaiko, @kbn_Zaiko_Chosei_Henpin,
			  @kbn_Zaiko_Chosei_Horyu, @kbn_Zaiko_Chosei_Ryohin, @cd_genka_center,
			  @cd_soko, @ryohinZaikoKbn, @kbn_nyusyukko_kakozan, @kbn_sokoidokanri
出力引数    ：
戻り値      ：
作成日      ：2014.11.25  ADMAX endo.y
更新日      ：2015.09.25  MJ ueno.k
更新日      ：2016.12.13  BRC motojima.m 中文対応
			　2019.02.21　BRC takaki.r ニアショア作業依頼No.497
			：2023.07.12　BRC hashimoto ニアショア作業 #2158
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosai_delete] 
	@no_niuke						VARCHAR(14)		--荷受番号
	, @dt_nitizi					DATETIME		--明細/荷受日
	, @cd_update					VARCHAR(10)		--セッション情報ログインユーザーコード
	, @no_seq						DECIMAL(8)		--明細/シーケンス番号
	, @kbnChosei					SMALLINT		--調整数反映区分
	, @kbnChosei_ari				SMALLINT		--調整数反映.する
	, @no_seq_chosei				VARCHAR(14)		--調整トラン用シーケンス番号
	, @cd_hinmei					VARCHAR(14)		--画面.品名コード
	, @cd_riyu						VARCHAR(10)		--理由コード
	, @su_moto_chosei				DECIMAL(12,6)	--基調整数
	, @cd_location					VARCHAR(10)		--ロケーションコード
	, @kbn_nyusyukko				SMALLINT		--明細/入出庫区分
	, @kbn_nyusyukko_horyu			SMALLINT		--入出庫区分.区分変更 保留
	, @kbn_nyusyukko_ryohin			SMALLINT		--入出庫区分.区分変更 良品
    , @kbn_nyusyukko_henpin			SMALLINT		--入出庫区分.区分変更 返品
    , @kbn_zaiko					SMALLINT		--明細/在庫区分
	, @kbn_Zaiko_Chosei_Henpin		NVARCHAR(10)	--自動調整理由区分.返品
	, @kbn_Zaiko_Chosei_Horyu		NVARCHAR(10)	--自動調整理由区分.保留→良品
	, @kbn_Zaiko_Chosei_Ryohin		NVARCHAR(10)	--自動調整理由区分.良品→保留
	, @cd_genka_center				VARCHAR(10)		--原価センターコード
	, @cd_soko						VARCHAR(10)		--倉庫コード
	, @ryohinZaikoKbn				SMALLINT
	, @kbn_nyusyukko_kakozan		SMALLINT
	, @kbn_sokoidokanri				SMALLINT		--倉庫移動管理機能切替区分
AS

BEGIN

DECLARE @isZero			SMALLINT = 0;

DECLARE @su_iri			DECIMAL(5,0)
		, @tani_nonyu   DECIMAL(4,0)
		, @shiyoMishiyoFlg	SMALLINT = 0;
			
--品名マスタ.
SELECT TOP 1
	@tani_nonyu = CASE WHEN hinmei.cd_tani_nonyu IN (4,11)
				THEN 1000
				ELSE 1 END
	, @su_iri = ISNULL(hinmei.su_iri, 0)
FROM ma_hinmei hinmei
WHERE
	hinmei.cd_hinmei = @cd_hinmei
	AND hinmei.flg_mishiyo = @shiyoMishiyoFlg

DECLARE @su_nonyu_jitsu_cur		DECIMAL(9)		-- 実納入数
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
	, @cd_niuke_basho			VARCHAR(10)
	, @su_nonyu_jitsu			DECIMAL(9)		-- 在庫数
	, @su_nonyu_jitsu_hasu		DECIMAL(9)		-- 在庫数端数
	, @dt_niuke					DATETIME
	, @no_seq_delete			DECIMAL(8,0)


SELECT 
	@cd_niuke_basho = cd_niuke_basho
	, @su_nonyu_jitsu = su_nonyu_jitsu
	, @su_nonyu_jitsu_hasu = su_nonyu_jitsu_hasu
	, @dt_niuke = dt_niuke

FROM tr_niuke
WHERE 
	no_niuke		  = @no_niuke
	AND no_seq		  = @no_seq
	AND kbn_nyushukko = @kbn_nyusyukko_ryohin
	AND kbn_zaiko     = @ryohinZaikoKbn

SELECT 
	@no_seq_delete = no_seq
FROM tr_niuke
WHERE no_niuke = @no_niuke
	AND no_seq > @no_seq
	AND dt_niuke = @dt_niuke
	AND kbn_zaiko = @ryohinZaikoKbn
	AND kbn_nyushukko = @kbn_nyusyukko_henpin
	AND su_shukko = @su_nonyu_jitsu
	AND su_shukko_hasu = @su_nonyu_jitsu_hasu
	AND cd_niuke_basho = @cd_niuke_basho

IF(@no_seq_delete IS NULL)
BEGIN

	UPDATE tr_niuke
	SET su_shukko = ROUND(((((su_shukko - @su_nonyu_jitsu)*@su_iri*@tani_nonyu) + (su_shukko_hasu - @su_nonyu_jitsu_hasu))/(@su_iri*@tani_nonyu)),1)
	, su_shukko_hasu =  ROUND(((((su_shukko - @su_nonyu_jitsu)*@su_iri*@tani_nonyu) + (su_shukko_hasu - @su_nonyu_jitsu_hasu))%(@su_iri*@tani_nonyu)),1)
	WHERE no_niuke = @no_niuke
		AND dt_niuke = @dt_niuke
		AND kbn_zaiko = @ryohinZaikoKbn
		AND kbn_nyushukko = @kbn_nyusyukko_henpin
		AND cd_niuke_basho = @cd_niuke_basho
		AND no_seq = (
				SELECT TOP 1 
					MIN(no_seq)
				FROM tr_niuke tr
				WHERE
					tr.no_niuke      = @no_niuke
					AND tr.kbn_zaiko = @ryohinZaikoKbn
					AND tr.cd_niuke_basho = @cd_niuke_basho
					AND tr.dt_niuke = @dt_niuke
					AND tr.kbn_nyushukko = @kbn_nyusyukko_henpin
					AND tr.no_seq > @no_seq
			)
		
END ELSE BEGIN
	--Delete row.
	UPDATE tr_niuke
		SET  su_zaiko = @isZero
		, su_zaiko_hasu = @isZero
		, su_nonyu_jitsu = @isZero
		, su_nonyu_jitsu_hasu = @isZero
		, su_shukko = @isZero
		, su_shukko_hasu = @isZero
	WHERE no_niuke = @no_niuke
		AND no_seq = @no_seq_delete

END

SET ROWCOUNT 0;

--Delete row.
	DELETE 
	FROM tr_niuke
	WHERE no_niuke = @no_niuke
		AND no_seq = @no_seq

DECLARE @ROWCOUNT INT = @@ROWCOUNT;

SELECT 
		@su_zaiko_total = su_zaiko
		, @su_zaiko_hasu_total = su_zaiko_hasu
FROM tr_niuke
WHERE 
	no_niuke      = @no_niuke
	AND kbn_zaiko = @ryohinZaikoKbn
	AND cd_niuke_basho = @cd_niuke_basho
	AND no_seq < @no_seq


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
		SET @su_zaiko_total = ROUND((((@su_zaiko_total - @su_shukko_cur + @su_nonyu_jitsu_cur)*@su_iri*@tani_nonyu) + (@su_zaiko_hasu_total - @su_shukko_hasu_cur + @su_nonyu_jitsu_hasu_cur))/(@su_iri*@tani_nonyu), 1);
		SET @su_zaiko_hasu_total = ROUND((((@su_zaiko_total - @su_shukko_cur + @su_nonyu_jitsu_cur)*@su_iri*@tani_nonyu) + (@su_zaiko_hasu_total - @su_shukko_hasu_cur + @su_nonyu_jitsu_hasu_cur))%(@su_iri*@tani_nonyu), 1);
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

			
	IF @ROWCOUNT >= 1 BEGIN

		IF @kbn_sokoidokanri = 0 OR @kbn_sokoidokanri IS NULL BEGIN
			IF @kbnChosei = @kbnChosei_ari AND (@kbn_nyusyukko = @kbn_nyusyukko_horyu or @kbn_nyusyukko = @kbn_nyusyukko_ryohin) BEGIN
			--調整トラン追加処理	
			INSERT INTO tr_chosei
			(
				[no_seq]
				, [cd_hinmei]
				, [dt_hizuke]
				, [cd_riyu]
				, [su_chosei]
				, [biko]
				, [cd_seihin]
				, [dt_update]
				, [cd_update]
				, [cd_genka_center] 
				, [cd_soko] 
				--, [cd_kura]
			)
			VALUES
			(
				@no_seq_chosei
				, @cd_hinmei
				, @dt_nitizi
				, @cd_riyu
				, @su_moto_chosei
				, ''
				, ''
				, GETUTCDATE()
				, @cd_update
				, @cd_genka_center
				, @cd_soko
				--, @cd_location
			)

				--変更履歴トランに調整トランへの登録履歴を挿入 #2158
		    	INSERT INTO tr_henko_rireki
			    (
				     kbn_data
					,kbn_shori
					,dt_hizuke
					,cd_hinmei
					,su_henko
					,su_henko_hasu
					,no_lot
					,biko
					,dt_update
					,cd_update
				)
				VALUES
				(
					 1
					,0
					,@dt_nitizi
					,@cd_hinmei
					,@su_moto_chosei
					,0
					,@no_seq_chosei
					,''
					,GETUTCDATE()
					,@cd_update
				)						

			END
		END

		--削除対象の入出庫区分が返品の場合の調整トラン削除処理
		IF @kbn_nyusyukko = @kbn_nyusyukko_henpin BEGIN			

			--変更履歴トランに調整トランを削除する前に履歴を挿入
			INSERT INTO tr_henko_rireki
		    (
			     kbn_data
				,kbn_shori
				,dt_hizuke
				,cd_hinmei
				,su_henko
				,su_henko_hasu
				,no_lot
				,biko
				,dt_update
				,cd_update
			)
			SELECT
				 1
				,2
				,dt_hizuke
				,cd_hinmei
				,su_chosei
				,0
				,no_seq
				,''
				,GETUTCDATE()
				,@cd_update
			FROM tr_chosei
			WHERE 
				cd_hinmei = @cd_hinmei 
				AND dt_hizuke = @dt_nitizi
				AND no_niuke = @no_niuke
				AND kbn_zaiko = @kbn_zaiko
				AND cd_riyu = @kbn_Zaiko_Chosei_Henpin

			--旧調整トラン削除
			DELETE FROM tr_chosei
			WHERE 
				cd_hinmei = @cd_hinmei 
				AND dt_hizuke = @dt_nitizi
				AND no_niuke = @no_niuke
				AND kbn_zaiko = @kbn_zaiko
				AND cd_riyu = @kbn_Zaiko_Chosei_Henpin
		END

	END

	SELECT ISNULL(@no_seq_delete, 0) AS no_seq_delete

END
GO
