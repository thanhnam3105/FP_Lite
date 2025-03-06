IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_Kakozan_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_Kakozan_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：加工残 保存
ファイル名	：usp_Kakozan_update
入力引数	：@kbn_zaiko, @no_niuke, @max_seq, @su_zaiko
			  , @su_zaiko_hasu, @su_iri, @max_dt_niuke
			  , @dt_zaiko_teisei, @kbn_nyushukko
			  , @kakozanNyushukkoKbn, @flg_kakutei, @cd_update
出力引数	：
戻り値		：
作成日		：2013.10.21  ADMAX kakuta.y
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_Kakozan_update] 
	@kbn_zaiko				SMALLINT		-- 明細.在庫区分
	,@no_niuke				VARCHAR(14)		-- 明細.荷受番号(非表示)
	,@max_seq				DECIMAL(8,0)	-- 明細.シーケンス番号最大値(非表示)
	,@su_zaiko				DECIMAL(9,2)	-- 明細.在庫数
	,@su_zaiko_hasu			DECIMAL(9,2)	-- 明細.在庫端数
	,@su_iri				DECIMAL(5,0)	-- 明細.入数(非表示)
	,@max_dt_niuke			DATETIME		-- 明細.荷受日の最大値(非表示)
	,@dt_zaiko_teisei		DATETIME		-- 検索条件.在庫訂正日
	,@kbn_nyushukko			SMALLINT		-- 明細.入出庫区分(非表示)
	,@kakozanNyushukkoKbn	SMALLINT		-- 入出庫区分.加工残
	,@flg_kakutei			SMALLINT		-- 明細.確定
	,@cd_update				VARCHAR(10)		-- ログイン者コード
	,@cd_tani				VARCHAR(10)		-- 納入単位コード
AS
BEGIN
SET NOCOUNT ON;
	DECLARE 
		@zaiko_max_seq		DECIMAL(8,0)	-- *1*
		,@niu_max_seq		DECIMAL(8,0)	-- *2*
		,@tm_nonyu_jitsu	DATETIME		-- *3* 現在の実納入時刻
		,@tm_nonyu_jisseki	DATETIME		-- *3* 更新用実納入時刻
		,@dt_bool			BIT				-- *3* 荷受日の最大値と在庫訂正日がイコールなら1(update)
		,@zaikokanzanhasu	DECIMAL(9,3)
		,@initStr			VARCHAR(2)
		,@initNum			DECIMAL(9,2)
		,@update			BIT
		,@insert			BIT
		
	SET @initStr	= ''
	SET @initNum	= 0
	SET @update		= 1
	SET @insert		= 0

	-- 行と同じ在庫区分の最新シーケンス番号取得処理 *1*
	SELECT
		@zaiko_max_seq = MAX(t_niu.no_seq)
	FROM tr_niuke t_niu
	WHERE
		t_niu.kbn_zaiko = @kbn_zaiko
	GROUP BY 
		t_niu.no_niuke
	HAVING
		t_niu.no_niuke = @no_niuke

	-- 行と同じ荷受番号の最新シーケンス番号取得処理 *2*
	IF @max_seq <> @zaiko_max_seq
	BEGIN
		--RETURN
		-- 後続データのシーケンス番号をずらします。
		UPDATE tr_niuke
			SET no_seq = no_seq + 1
		WHERE no_niuke = @no_niuke
			AND no_seq > @max_seq
		set @niu_max_seq = @max_seq
	END
	ELSE IF @max_seq = @zaiko_max_seq
	BEGIN
		SELECT 
			@niu_max_seq = MAX(t_niu.no_seq)
		FROM tr_niuke t_niu
		GROUP BY 
			t_niu.no_niuke
		HAVING t_niu.no_niuke = @no_niuke
	END

	IF (@cd_tani = '4' OR @cd_tani = '11')
	BEGIN
		SET @zaikokanzanhasu = (@su_zaiko_hasu / 1000) * 1.0
	END
	ELSE
	BEGIN
		SET @zaikokanzanhasu = @su_zaiko_hasu
	END
	-- 在庫数と端数の丸め処理を行います。
	IF @zaikokanzanhasu >= @su_iri
	BEGIN
		IF (@cd_tani = '4' OR @cd_tani = '11')
		BEGIN
			SET @su_zaiko = FLOOR(@su_zaiko + @zaikokanzanhasu / @su_iri)
			SET @zaikokanzanhasu = (@zaikokanzanhasu % @su_iri) * 1000
		END
		ELSE
		BEGIN
			SET @su_zaiko = FLOOR(@su_zaiko + @zaikokanzanhasu / @su_iri)
			SET @zaikokanzanhasu = @zaikokanzanhasu % @su_iri
		END
	END

	IF (@cd_tani = '4' OR @cd_tani = '11')
	BEGIN
		SET @su_zaiko_hasu = (@zaikokanzanhasu * 1000) * 1.0
	END
	ELSE
	BEGIN
		SET @su_zaiko_hasu = @zaikokanzanhasu
	END
	

	-- 納入実績時刻取得処理 *3*
	SELECT
		@tm_nonyu_jitsu = tm_nonyu_jitsu
	FROM tr_niuke
	WHERE
		no_niuke = @no_niuke
		AND kbn_zaiko = @kbn_zaiko
		AND no_seq = @max_seq

	IF CONVERT(VARCHAR(8),@max_dt_niuke,112) = CONVERT(VARCHAR(8),@dt_zaiko_teisei,112)
	BEGIN
		SET @tm_nonyu_jisseki = DATEADD(MINUTE,1,@tm_nonyu_jitsu)
		SET @dt_bool = @update
	END
	ELSE IF CONVERT(VARCHAR(8),@max_dt_niuke,112) <> CONVERT(VARCHAR(8),@dt_zaiko_teisei,112)
	BEGIN
		SET @tm_nonyu_jisseki = GETUTCDATE()
		SET @dt_bool = @insert
	END

	-- 更新・登録処理
	IF @dt_bool = @update
		AND @kbn_nyushukko = @kakozanNyushukkoKbn
	BEGIN
		UPDATE tr_niuke
		SET
			dt_niuke = @dt_zaiko_teisei
			,tm_nonyu_jitsu = @tm_nonyu_jisseki
			,su_zaiko = @su_zaiko
			,su_zaiko_hasu = @su_zaiko_hasu
			,su_kakozan = @su_zaiko
			,su_kakozan_hasu = @su_zaiko_hasu
			,flg_kakutei = @flg_kakutei
			,cd_update = @cd_update
			,dt_update = GETUTCDATE()
		WHERE
			no_niuke = @no_niuke
			AND no_seq = @max_seq
			AND kbn_zaiko = @kbn_zaiko
	END
	ELSE
	BEGIN
		-- 最新のシーケンス番号を取得します。
		SELECT @niu_max_seq = @niu_max_seq + 1

		INSERT INTO tr_niuke
			(
				no_niuke
				,dt_niuke
				,cd_hinmei
				,kbn_hin
				,cd_niuke_basho
				,kbn_nyushukko
				,kbn_zaiko
				,tm_nonyu_yotei
				,su_nonyu_yotei
				,su_nonyu_yotei_hasu
				,tm_nonyu_jitsu
				,su_nonyu_jitsu
				,su_nonyu_jitsu_hasu
				,su_zaiko
				,su_zaiko_hasu
				,su_shukko
				,su_shukko_hasu
				,su_kakozan
				,su_kakozan_hasu
				,dt_seizo
				,dt_kigen
				,kin_kuraire
				,no_lot
				,no_denpyo
				,biko
				,cd_torihiki
				,flg_kakutei
				,cd_hinmei_maker
				,nm_kuni
				,cd_maker
				,nm_maker
				,cd_maker_kojo
				,nm_maker_kojo
				,nm_hyoji_nisugata
				,nm_tani_nonyu
				,dt_nonyu
				,dt_label_hakko
				,cd_update
				,dt_update
				,no_seq
			)
		SELECT
			@no_niuke
			,@dt_zaiko_teisei
			,tr_niu.cd_hinmei
			,tr_niu.kbn_hin
			,tr_niu.cd_niuke_basho
			,@kakozanNyushukkoKbn
			,tr_niu.kbn_zaiko
			,tr_niu.tm_nonyu_yotei
			,tr_niu.su_nonyu_yotei
			,tr_niu.su_nonyu_yotei_hasu
			,@tm_nonyu_jisseki
			,@initNum
			,@initNum
			,@su_zaiko
			,@su_zaiko_hasu
			,@initNum
			,@initNum
			,@su_zaiko
			,@su_zaiko_hasu
			,tr_niu.dt_seizo
			,tr_niu.dt_kigen
			,tr_niu.kin_kuraire
			,tr_niu.no_lot
			,tr_niu.no_denpyo
			,@initStr
			,tr_niu.cd_torihiki
			,@flg_kakutei
			,tr_niu.cd_hinmei_maker
			,tr_niu.nm_kuni
			,tr_niu.cd_maker
			,tr_niu.nm_maker
			,tr_niu.cd_maker_kojo
			,tr_niu.nm_maker_kojo
			,tr_niu.nm_hyoji_nisugata
			,tr_niu.nm_tani_nonyu
			,tr_niu.dt_nonyu
			,tr_niu.dt_label_hakko
			,@cd_update
			,GETUTCDATE()
			,@niu_max_seq	
		FROM tr_niuke tr_niu		-- シーケンス番号を最新にしてインサート
		WHERE
			tr_niu.no_niuke = @no_niuke
			AND tr_niu.no_seq = @max_seq
			AND tr_niu.kbn_zaiko = @kbn_zaiko
	END
	
	--在庫更新処理
		EXEC usp_IdoShukkoShosai_update02  
		@no_niuke        = @no_niuke
		, @kbn_zaiko     = @kbn_zaiko
		, @kbn_nyushukko = @kakozanNyushukkoKbn
		,@cdNonyuTani = @cd_tani
	
END
GO
