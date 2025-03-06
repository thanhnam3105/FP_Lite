IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LotNoBetsuZaikoShosaiSeq_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosaiSeq_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：在庫区分変更 追加
ファイル名  ：[usp_LotNoBetsuZaikoShosaiSeq_update]
入力引数    ：@no_niuke, @@no_seq_min, @@no_seq_update
出力引数    ：
戻り値      ：
作成日      ：2018/09/14 Trinh.bd
更新日      ：
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosaiSeq_update] 
	@no_niuke						VARCHAR(14)		--荷受番号
	, @no_seq_min					DECIMAL(8)		--明細/シーケンス番号
	, @no_seq_update				DECIMAL(8)
	, @dt_nitizi					DATETIME		--明細/荷受日
	, @kbn_nyusyukko_henpin			SMALLINT		--入出庫区分.区分変更 返品
	, @kbn_Zaiko_Chosei_Henpin		NVARCHAR(10)	--自動調整理由区分.返品
AS
BEGIN

DECLARE @isZero							SMALLINT = 0
		, @cd_hinmei					VARCHAR(14)		--画面.品名コード
		, @kbn_zaiko					SMALLINT		--明細/在庫区分

	SELECT TOP 1
		@cd_hinmei = cd_hinmei
		, @kbn_zaiko = kbn_zaiko
	FROM tr_niuke 
	WHERE
		no_niuke = @no_niuke
		AND su_zaiko = @isZero
		AND su_zaiko_hasu = @isZero
		AND su_nonyu_jitsu = @isZero
		AND su_nonyu_jitsu_hasu = @isZero
		AND su_shukko = @isZero
		AND su_shukko_hasu = @isZero
		AND kbn_nyushukko = @kbn_nyusyukko_henpin

	IF (@cd_hinmei IS NOT NULL)
	BEGIN
		--旧調整トラン削除
		DELETE FROM tr_chosei
		WHERE
			cd_hinmei = @cd_hinmei 
			AND dt_hizuke = @dt_nitizi
			AND no_niuke = @no_niuke
			AND kbn_zaiko = @kbn_zaiko
			AND cd_riyu = @kbn_Zaiko_Chosei_Henpin
	END

	DELETE tr_niuke
	WHERE
		no_niuke = @no_niuke
		AND su_zaiko = @isZero
		AND su_zaiko_hasu = @isZero
		AND su_nonyu_jitsu = @isZero
		AND su_nonyu_jitsu_hasu = @isZero
		AND su_shukko = @isZero
		AND su_shukko_hasu = @isZero
		AND kbn_nyushukko = @kbn_nyusyukko_henpin
	
	UPDATE tr_niuke
	SET no_seq = no_seq - @no_seq_update
	WHERE
		no_niuke = @no_niuke
		AND no_seq > @no_seq_min
END
GO
