IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ZaikoChoseiDialog_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ZaikoChoseiDialog_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：加工残 保存
ファイル名	：[usp_ZaikoChoseiDialog_create]
入力引数	：	@kbn_zaiko, @no_niuke, @max_seq, @su_zaiko
			, @su_zaiko_hasu, @su_iri, @max_dt_niuke
			, @dt_zaiko_teisei, @kbn_nyushukko
			, @kakozanNyushukkoKbn, @flg_kakutei, @cd_update
出力引数	：
戻り値		：
作成日		：2018.07.27  thien.nh
更新日		：2018.08.24 thien.nh
*****************************************************/
CREATE PROCEDURE [dbo].[usp_ZaikoChoseiDialog_create] 
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
	,@cd_niuke_basho		VARCHAR(10)
	,@error					VARCHAR(50)		OUT
AS

SET NOCOUNT ON;

SET XACT_ABORT ON;

BEGIN TRAN
BEGIN TRY

	DECLARE 
		@zaiko_max_seq		DECIMAL(8,0)	-- *1*
		,@niu_max_seq		DECIMAL(8,0)	-- *2*
		,@initNum			DECIMAL(9,2)
		,@MS0236			VARCHAR(50)		= 'MS0236'
		
	SET @initNum	= 0

	-- get no_seq max with dt_niuke
	SELECT
		@zaiko_max_seq = MAX(t_max.no_seq)
	FROM tr_niuke t_max
	WHERE
		(
			(
				t_max.no_seq <> 1
				AND t_max.dt_niuke <= @dt_zaiko_teisei
			)
			OR
			(
				t_max.no_seq = 1
				AND t_max.dt_nonyu <= @dt_zaiko_teisei
			)
		)
		AND t_max.no_niuke = @no_niuke
	GROUP BY
		t_max.no_niuke

	SET	@niu_max_seq = @zaiko_max_seq
	
	-- update data
	UPDATE tr_niuke
		SET no_seq	 = no_seq + 1
	WHERE no_niuke	 = @no_niuke
		AND no_seq	 > @niu_max_seq

	PRINT @niu_max_seq
	-- insert tr_niuke	
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

			,kbn_nyuko
			,no_nonyu
			,flg_print
			,no_nohinsho
			,no_zeikan_shorui
			,flg_shonin
			,cd_niuke_basho_before
			,kbn_zaiko_before
		)
	SELECT
		@no_niuke
		,@dt_zaiko_teisei
		,tr_niu.cd_hinmei
		,tr_niu.kbn_hin
		,@cd_niuke_basho
		,@kakozanNyushukkoKbn
		,@kbn_zaiko
		,tr_niu.tm_nonyu_yotei
		,tr_niu.su_nonyu_yotei
		,tr_niu.su_nonyu_yotei_hasu
		,GETUTCDATE()
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
		,NULL
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
		,@niu_max_seq + 1
			
		,tr_niu.kbn_nyuko
		,tr_niu.no_nonyu
		,tr_niu.flg_print
		,tr_niu.no_nohinsho
		,tr_niu.no_zeikan_shorui
		,tr_niu.flg_shonin
		,NULL
		,NULL
	FROM tr_niuke tr_niu
	WHERE
		tr_niu.no_niuke				= @no_niuke
		AND tr_niu.no_seq			= 1

	-- update zaiko
		EXEC usp_IdoShukkoShosai_update03
		  @no_niuke			= @no_niuke
		, @kbn_zaiko		= @kbn_zaiko
		, @kbn_nyushukko	= @kakozanNyushukkoKbn
		, @cdNonyuTani		= @cd_tani
		, @cdNiuke_basho	= @cd_niuke_basho

	SELECT * FROM tr_niuke WHERE no_niuke = @no_niuke

	IF((SELECT COUNT(no_niuke) FROM tr_niuke WHERE no_niuke = @no_niuke AND (su_zaiko < 0 OR su_zaiko_hasu < 0)) > 0)
		BEGIN
			SET @error = @MS0236
		END
		COMMIT
	END TRY
BEGIN CATCH
	ROLLBACK
	SET @error = ERROR_MESSAGE()
	RAISERROR(@error, 16, 1)
END CATCH

GO