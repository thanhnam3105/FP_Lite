IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_IdoShukkoShosai_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_IdoShukkoShosai_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：移動出庫詳細　出庫データを追加します。
ファイル名  ：usp_IdoShukkoShosai_create
入力引数    ：@no_niuke, @dt_shukko, @kbn_nyushukko
			　, @kbn_zaiko, @tm_nonyu_jitsu, @su_zaiko
			　, @su_zaiko_hasu, @su_shukko, @su_shukko_hasu 
			　, @biko, @flg_kakutei, @cd_update 
			　, @no_seq, @su_iri, @flg_mishiyo
			　, @flg_out ,@NyushukoKakozan
出力引数    ：
戻り値      ：
作成日      ：2013.11.07  ADMAX endo.y
更新日      ：2019.5.20  nakamura.r KPM問い合わせ対応
更新日      ：2019.7.09  BRC saito.k
*****************************************************/
CREATE PROCEDURE [dbo].[usp_IdoShukkoShosai_create] 
	@no_niuke			VARCHAR(14)
	, @dt_shukko		DATETIME
	, @kbn_nyushukko	SMALLINT
	, @kbn_zaiko		SMALLINT
	, @tm_nonyu_jitsu	DATETIME
	, @su_zaiko			DECIMAL(9)
	, @su_zaiko_hasu	DECIMAL(9)
	, @su_shukko		DECIMAL(9)
	, @su_shukko_hasu	DECIMAL(9)
	--, @biko			VARCHAR(50)
	, @biko				NVARCHAR(50)
	, @flg_kakutei		SMALLINT
	, @cd_update		VARCHAR(10)
	, @no_seq			DECIMAL(8)
	, @su_iri			DECIMAL(5)
	, @flg_mishiyo		SMALLINT
	, @flg_out			SMALLINT
	, @NyushukoKakozan	SMALLINT
	, @tm_nonyu_default DATETIME
	, @cd_tani			VARCHAR(10)
	, @cd_niuke_basho	VARCHAR(10)
AS
BEGIN
	DECLARE
		@tm_nonyu		DATETIME
		,@day			SMALLINT
		,@minSeqNo		DECIMAL(8, 0)
		,@dt_addOne		DATETIME
		,@no_seq_create	DECIMAL(8, 0);

	SET @day = 1
	SELECT @minSeqNo = (SELECT MIN(niu.no_seq) FROM tr_niuke niu);
	SELECT @dt_addOne = DATEADD(DD,@day,@dt_shukko);
		
	IF SUBSTRING(CONVERT(VARCHAR,@tm_nonyu_default,8),0,6) = '00:00' BEGIN
		SELECT @tm_nonyu = DATEADD(MINUTE,1,tm_nonyu_jitsu)
		FROM tr_niuke
		WHERE no_niuke    = @no_niuke
			AND no_seq    = @no_seq
			AND kbn_zaiko = @kbn_zaiko
			--AND (@dt_shukko	<= dt_niuke AND dt_niuke < (SELECT DATEADD(DD,@day,@dt_shukko)))
			AND ((@no_seq = @minSeqNo AND @dt_shukko <= dt_nonyu AND dt_nonyu < @dt_addOne)
				OR (@no_seq <> @minSeqNo AND @dt_shukko <= dt_niuke AND dt_niuke < @dt_addOne))
			AND cd_niuke_basho = @cd_niuke_basho
		IF @tm_nonyu IS NOT NULL begin
			SET @tm_nonyu_jitsu = @tm_nonyu
		END
	END

	SELECT
		@no_seq_create = MAX(no_seq)
	FROM tr_niuke niuke
	WHERE 
		niuke.no_niuke = @no_niuke
		--AND (niuke.dt_nonyu <= @dt_shukko)
		AND (niuke.dt_niuke <= @dt_shukko)
	-- 後続データのシーケンス番号をずらします。
	UPDATE tr_niuke
		SET no_seq			= no_seq + 1
	WHERE no_niuke			= @no_niuke
		AND no_seq			> @no_seq_create
		--AND cd_niuke_basho	= @cd_niuke_basho

	IF @flg_out = 0 BEGIN
		SET @flg_kakutei = 1 
	END 

	INSERT INTO tr_niuke
		(
			no_niuke
			, dt_niuke
			, cd_hinmei
			, kbn_hin
			, cd_niuke_basho
			, kbn_nyushukko
			, kbn_zaiko
			, tm_nonyu_yotei
			, su_nonyu_yotei
			, su_nonyu_yotei_hasu
			, tm_nonyu_jitsu
			, su_nonyu_jitsu
			, su_nonyu_jitsu_hasu
			, su_zaiko
			, su_zaiko_hasu
			, su_shukko
			, su_shukko_hasu
			, su_kakozan
			, su_kakozan_hasu
			, dt_seizo
			, dt_kigen
			, kin_kuraire
			, no_lot
			, no_denpyo
			, biko
			, cd_torihiki
			, flg_kakutei
			, cd_hinmei_maker
			, nm_kuni
			, cd_maker
			, nm_maker
			, cd_maker_kojo
			, nm_maker_kojo
			, nm_hyoji_nisugata
			, nm_tani_nonyu
			, dt_nonyu
			, dt_label_hakko
			, cd_update
			, dt_update
			, no_seq		
		)
		 SELECT
			no_niuke
			, @dt_shukko	
			, cd_hinmei
			, kbn_hin
			, cd_niuke_basho
			, @kbn_nyushukko
			, kbn_zaiko
			, tm_nonyu_yotei
			, su_nonyu_yotei
			, su_nonyu_yotei_hasu
			, @tm_nonyu_jitsu
			, 0
			, 0
			, @su_zaiko
			, @su_zaiko_hasu
			, @su_shukko
			, @su_shukko_hasu
			, 0
			, 0
			, dt_seizo
			, dt_kigen
			, kin_kuraire
			, no_lot
			, no_denpyo
			, @biko
			, cd_torihiki
			, 1
			, cd_hinmei_maker
			, nm_kuni
			, cd_maker
			, nm_maker
			, cd_maker_kojo
			, nm_maker_kojo
			, nm_hyoji_nisugata
			, nm_tani_nonyu
			, dt_nonyu
			, dt_label_hakko
			, @cd_update
			, GETUTCDATE()
			, @no_seq_create + 1
		FROM
			tr_niuke
		WHERE no_niuke			= @no_niuke
			AND no_seq			= @no_seq
			AND kbn_zaiko		= @kbn_zaiko
			AND cd_niuke_basho	= @cd_niuke_basho
		
		EXEC usp_IdoShukkoShosai_update03  
			@no_niuke       = @no_niuke
		,	@kbn_zaiko		= @kbn_zaiko
		,	@kbn_nyushukko	= @NyushukoKakozan
		,	@cdNonyuTani	= @cd_tani
		,   @cdNiuke_basho = @cd_niuke_basho
	END
GO
