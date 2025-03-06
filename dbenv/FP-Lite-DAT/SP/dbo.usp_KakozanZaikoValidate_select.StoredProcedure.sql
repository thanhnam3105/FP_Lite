IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_KakozanZaikoValidate_select]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_KakozanZaikoValidate_select]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*****************************************************
�@�\        �F���H�c �o���f�[�V���� �K�v�݌ɐ��̎擾
�t�@�C����  �Fusp_KakozanZaikoValidate_select
���͈���    �F@no_niuke,@kbn_zaiko,@dt_hizuke,@kbn_nyushukko_kakozan
�o�͈���    �F
�߂�l      �Fhitsuyo_zaiko,hitsuyo_zaiko_hasu
�쐬��      �F2019.02.20  brc kanehira
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KakozanZaikoValidate_select]
	@no_niuke					VARCHAR(14)		-- �׎󃍃b�g�ԍ�
	,@kbn_zaiko					SMALLINT		-- �݌ɋ敪
	,@dt_hizuke					DATETIME		-- �݌ɒ�����
	,@kbn_nyushukko_kakozan		SMALLINT		-- ���o�ɋ敪�i���H�c�j
AS
BEGIN
	
	-- �ϐ���`
	DECLARE
		@no_seq_min_kakozan		DECIMAL(8,0)
		,@no_seq_max_kakozan	DECIMAL(8,0)
	
	-- �Ώۃf�[�^�̍ŏ��̃V�[�P���XNo.
	SELECT
		@no_seq_min_kakozan = MIN(no_seq)
	FROM
		tr_niuke
	WHERE
		no_niuke = @no_niuke
		AND dt_niuke > @dt_hizuke
	
	-- �Ώۉ��H�c�f�[�^�̍ő�̃V�[�P���XNo.
	SELECT
		@no_seq_max_kakozan = MIN(no_seq)
	FROM
		tr_niuke
	WHERE
		no_niuke = @no_niuke
		AND kbn_zaiko = @kbn_zaiko
		AND kbn_nyushukko = @kbn_nyushukko_kakozan
		AND dt_niuke > @dt_hizuke
	
	-- ���H�c�f�[�^�̍ő�̃V�[�P���XNo.���擾�ł��Ȃ��ꍇ
	IF @no_seq_max_kakozan IS NULL
	BEGIN
	
		-- �Ώۃf�[�^�̍ő�̃V�[�P���XNo.���擾
		SELECT
			@no_seq_max_kakozan = MAX(no_seq)
		FROM
			tr_niuke
		WHERE
			no_niuke = @no_niuke
			
	END
	
	-- �ő�̃V�[�P���XNo.��NULL�̏ꍇ
	IF @no_seq_min_kakozan IS NULL
	BEGIN
	
		-- �K�v�݌ɂ�0�ŕԂ�
		SELECT 
			CONVERT(DECIMAL(9,2), 0) AS hitsuyo_zaiko
			,CONVERT(DECIMAL(9,2), 0) AS hitsuyo_zaiko_hasu
		RETURN
		
	END
	
	-- �o�ɐ����v���擾����
	SELECT
		CONVERT(DECIMAL(9,2), SUM(su_shukko)) AS hitsuyo_zaiko
		,CONVERT(DECIMAL(9,2), SUM(su_shukko_hasu)) AS hitsuyo_zaiko_hasu
	FROM
		tr_niuke
	WHERE
		no_niuke = @no_niuke
		AND kbn_zaiko = @kbn_zaiko
		AND no_seq BETWEEN @no_seq_min_kakozan AND @no_seq_max_kakozan
	RETURN  
END

GO

