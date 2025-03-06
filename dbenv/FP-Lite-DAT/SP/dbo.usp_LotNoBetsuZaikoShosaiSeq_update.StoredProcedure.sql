IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LotNoBetsuZaikoShosaiSeq_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosaiSeq_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\        �F�݌ɋ敪�ύX �ǉ�
�t�@�C����  �F[usp_LotNoBetsuZaikoShosaiSeq_update]
���͈���    �F@no_niuke, @@no_seq_min, @@no_seq_update
�o�͈���    �F
�߂�l      �F
�쐬��      �F2018/09/14 Trinh.bd
�X�V��      �F
�X�V��      �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosaiSeq_update] 
	@no_niuke						VARCHAR(14)		--�׎�ԍ�
	, @no_seq_min					DECIMAL(8)		--����/�V�[�P���X�ԍ�
	, @no_seq_update				DECIMAL(8)
	, @dt_nitizi					DATETIME		--����/�׎��
	, @kbn_nyusyukko_henpin			SMALLINT		--���o�ɋ敪.�敪�ύX �ԕi
	, @kbn_Zaiko_Chosei_Henpin		NVARCHAR(10)	--�����������R�敪.�ԕi
AS
BEGIN

DECLARE @isZero							SMALLINT = 0
		, @cd_hinmei					VARCHAR(14)		--���.�i���R�[�h
		, @kbn_zaiko					SMALLINT		--����/�݌ɋ敪

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
		--�������g�����폜
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
