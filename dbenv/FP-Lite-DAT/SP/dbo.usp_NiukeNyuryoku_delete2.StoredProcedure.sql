IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_delete2') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_delete2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�׎���́@�׎�g����(���тȂ�)�̏ꍇ�A���уf�[�^���X�V���܂��B
�t�@�C����	�Fusp_NiukeNyuryoku_delete2
���͈���	�F@no_niuke_yotei, @no_niuke_jisseki, @no_nonyu, @shiireNyushukoKbn
			  , @addKbn, @sotoinyuNyushukoKbn, @cd_update
�o�͈���	�F
�߂�l		�F
�쐬��		�F2016.09.07  BRC motojima.m	�׎���͍s�ǉ��Ή�
�X�V��		�F2016.11.28  BRC cho.k	�X�V�E�폜�̔�������C��
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_delete2]
	@no_niuke_yotei			VARCHAR(14)	 -- ����(�\��)�׎�ԍ�
	,@no_niuke_jisseki		VARCHAR(14)	 -- ����(����)�׎�ԍ�
	,@no_nonyu				VARCHAR(14)	 -- �׎�ԍ�
	,@shiireNyushukoKbn		SMALLINT	 -- �R�[�h�ꗗ/���o�ɋ敪.�d��
	,@addKbn				SMALLINT	 -- �R�[�h�ꗗ/���o�ɋ敪.�ǉ�
	,@sotoinyuNyushukoKbn	SMALLINT	 -- �R�[�h�ꗗ/���o�ɋ敪.�O�ړ�
	,@cd_update				VARCHAR(10)	 -- ���O�C�����[�U�[�R�[�h

AS
BEGIN
	-- NULL�i�[�p�ϐ��錾�Ɗi�[
	DECLARE @null VARCHAR = NULL
	
	DECLARE @jissekiCount smallint
	
	-- DB�Ɏc���Ă�����ѐ����J�E���g����
	select @jissekiCount = COUNT(*)
	FROM tr_niuke
	where no_nonyu in (SELECT no_nonyu
						FROM tr_niuke
						where no_niuke = @no_niuke_jisseki)

--	IF @no_niuke_jisseki = @no_niuke_yotei
	-- �Ō�̈ꌏ�̏ꍇ�͗\�肾���c���B
	IF @jissekiCount = 1
		BEGIN
			UPDATE tr_niuke
			SET
				tm_nonyu_jitsu = @null
				,su_nonyu_jitsu = @null
				,su_nonyu_jitsu_hasu = @null
				,su_zaiko = @null
				,su_zaiko_hasu = @null
				,dt_seizo = @null
				,dt_kigen = @null
				,kin_kuraire = @null
				,no_lot = @null
				,no_nohinsho = @null
				,no_zeikan_shorui = @null
				,no_denpyo = @null
				,biko = @null
				,cd_hinmei_maker = @null
				,nm_kuni = @null
				,cd_maker_kojo = @null
				,nm_maker_kojo = @null
				,nm_tani_nonyu = @null
				,dt_nonyu = @null
				,dt_label_hakko = @null
				,cd_update = @cd_update
				,dt_update = GETUTCDATE()
			WHERE
--				no_niuke = @no_niuke_yotei
				no_niuke = @no_niuke_jisseki
				--AND kbn_nyushukko IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn)
				AND kbn_nyushukko IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)
		END	
	ELSE 
		BEGIN
			DELETE FROM tr_niuke WHERE no_niuke = @no_niuke_jisseki
		END
END
GO
