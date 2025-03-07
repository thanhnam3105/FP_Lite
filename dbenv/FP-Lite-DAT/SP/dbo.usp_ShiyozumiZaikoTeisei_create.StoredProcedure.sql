IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShiyozumiZaikoTeisei_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShiyozumiZaikoTeisei_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：使用済在庫訂正 追加
ファイル名	：usp_ShiyozumiZaikoTeisei_create
入力引数	：@no_niuke, @kbn_zaiko, @zaikosu, @hasu
			  , @su_kakozan, @su_kakozan_hasu, @no_seq
			  , @kbn_nyushukko, @tm_nonyu_jitsu, @flg_kakutei
			  , @cd_update, @dt_niuke
出力引数	：
戻り値		：
作成日		：2013.09.25  ADMAX endo.y
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_ShiyozumiZaikoTeisei_create] 
	@no_niuke			VARCHAR(14)
	,@kbn_zaiko			SMALLINT
	,@zaikosu			DECIMAL(9)
	,@hasu				DECIMAL(9)
	,@su_kakozan		DECIMAL(9)
	,@su_kakozan_hasu	DECIMAL(9)
	,@no_seq			DECIMAL(8)
	,@kbn_nyushukko		SMALLINT
	,@tm_nonyu_jitsu	DATETIME
	,@flg_kakutei		SMALLINT
	,@cd_update			VARCHAR(10)
	,@dt_niuke			DATETIME
AS
BEGIN
	INSERT INTO tr_niuke
		(
			[no_niuke]
			,[dt_niuke]
			,[cd_hinmei]
			,[kbn_hin]
			,[cd_niuke_basho]
			,[kbn_nyushukko]
			,[kbn_zaiko]
			,[tm_nonyu_yotei]
			,[su_nonyu_yotei]
			,[su_nonyu_yotei_hasu]
			,[tm_nonyu_jitsu]
			,[su_nonyu_jitsu]
			,[su_nonyu_jitsu_hasu]
			,[su_zaiko]
			,[su_zaiko_hasu]
			,[su_shukko]
			,[su_shukko_hasu]
			,[su_kakozan]
			,[su_kakozan_hasu]
			,[dt_seizo]
			,[dt_kigen]
			,[kin_kuraire]
			,[no_lot]
			,[no_denpyo]
			,[biko]
			,[cd_torihiki]
			,[flg_kakutei]
			,[cd_hinmei_maker]
			,[nm_kuni]
			,[cd_maker]
			,[nm_maker]
			,[cd_maker_kojo]
			,[nm_maker_kojo]
			,[nm_hyoji_nisugata]
			,[nm_tani_nonyu]
			,[dt_nonyu]
			,[dt_label_hakko]
			,[cd_update]
			,[dt_update]
			,[no_seq]
		)
	SELECT
		@no_niuke
		,@dt_niuke
		,cd_hinmei
		,kbn_hin
		,cd_niuke_basho
		,@kbn_nyushukko
		,@kbn_zaiko
		,tm_nonyu_yotei
		,su_nonyu_yotei
		,su_nonyu_yotei_hasu
		,@tm_nonyu_jitsu
		,0
		,0
		,@zaikosu
		,@hasu
		,0
		,0
		,@su_kakozan
		,@su_kakozan_hasu
		,dt_seizo
		,dt_kigen
		,kin_kuraire
		,no_lot
		,no_denpyo
		,''
		,cd_torihiki
		,@flg_kakutei
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
		,@cd_update
		,GETUTCDATE()
		,@no_seq + 1
	FROM tr_niuke
	WHERE
		no_niuke = @no_niuke
		AND no_seq = @no_seq
		AND kbn_zaiko = @kbn_zaiko
END
GO
