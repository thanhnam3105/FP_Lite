IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_IdoShukkoShosai_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_IdoShukkoShosai_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能       ：移動出庫詳細　出庫履歴を更新・削除します。
ファイル名 ：usp_IdoShukkoShosai_update
入力引数   ：@no_niuke, @kbn_zaiko, @tm_nonyu_jitsu
			, @su_zaiko, @su_zaiko_hasu
			, @su_shukko, @su_shukko_hasu 
			, @biko, @cd_update, @no_seq ,@NyushukoKakozan
出力引数   ：
戻り値     ：
作成日     ：2013.11.07  ADMAX endo.y
更新日     ：2016.12.13  BRC   motojima.m 中文対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_IdoShukkoShosai_update] 
	@no_niuke			VARCHAR(14)
	,@kbn_zaiko			SMALLINT
	,@tm_nonyu_jitsu	DATETIME
	,@su_zaiko			DECIMAL(9)
	,@su_zaiko_hasu		DECIMAL(9)
	,@su_shukko			DECIMAL(9)
	,@su_shukko_hasu	DECIMAL(9)
	--,@biko			VARCHAR(50)
	,@biko				NVARCHAR(50)
	,@cd_update			VARCHAR(10)
	,@no_seq			DECIMAL(8)
	,@NyushukoKakozan	SMALLINT
	,@cd_tani			VARCHAR(10)
	,@cd_niuke_basho	VARCHAR(10)
AS
BEGIN
	IF @su_shukko + @su_shukko_hasu = 0 
	BEGIN
		--削除処理を行う
		DELETE FROM tr_niuke
		WHERE
			no_niuke = @no_niuke
			AND no_seq = @no_seq
			AND kbn_zaiko = @kbn_zaiko
			AND cd_niuke_basho = @cd_niuke_basho

		-- 後続データのシーケンス番号をずらします。
		UPDATE tr_niuke
			SET no_seq			= no_seq - 1
		WHERE no_niuke			= @no_niuke
			AND no_seq			> @no_seq
	END
	ELSE 
	BEGIN
		--更新処理を行う
		UPDATE tr_niuke
		SET
			tm_nonyu_jitsu = @tm_nonyu_jitsu
			,su_zaiko = @su_zaiko
			,su_zaiko_hasu = @su_zaiko_hasu
			,su_shukko = @su_shukko
			,su_shukko_hasu = @su_shukko_hasu
			,biko = @biko
			,cd_update = @cd_update
			,dt_update = GETUTCDATE()
		WHERE
			no_niuke = @no_niuke
			AND no_seq = @no_seq
			AND kbn_zaiko = @kbn_zaiko
			AND cd_niuke_basho = @cd_niuke_basho
	END
	
	EXEC usp_IdoShukkoShosai_update03
		@no_niuke			= @no_niuke
		,@kbn_zaiko			= @kbn_zaiko
		,@kbn_nyushukko		= @NyushukoKakozan
		,@cdNonyuTani		= @cd_tani
		,@cdNiuke_basho		= @cd_niuke_basho
	
END
GO
