IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_update_02') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_update_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�׎���́@����(����)�̍X�V���׎�g�����ɏ������݂܂��B
�t�@�C����	�Fusp_NiukeNyuryoku_update_02
���͈���	�F@tm_nonyu_jitsu, @su_jitsu, @su_hasu
			  , @dt_seizo, @dt_kigen, @kingaku, @no_lot
			  , @no_nohinsho, @no_zeikan_shorui, @no_denpyo
			  , @biko, @user, @no_niuke_jisseki, @shiireNyushukoKbn
			  , @addKbn, @sotoinyuNyushukoKbn, @kakozanNyushukoKbn
			  , @ryohinZaikoKbn, @lotSaibanNo, @lotSaibanPrefix
			  , @kgKanzanKbn, @lkanzanKbn, @flg_shonin
�o�͈���	�F
�߂�l		�F
�쐬��		�F2013.11.13  ADMAX kakuta.y
�X�V��		�F2016.08.19  BRC   kanehira.d
�X�V��		�F2016.11.22  BRC   kanehira.d ���o�ɋ敪�ǉ�
�X�V��		�F2016.12.19  BRC   motojima.m �����Ή�
�X�V��		�F2019.07.11  BRC   kanehira.d ��ƈ˗�No.663 �׎����[�����ōX�V
�X�V��		�F2019.11.25  BRC   kanehira.d �׎���̍X�V���C��
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_update_02]
	@tm_nonyu_jitsu			DATETIME		-- ����(����)����
	,@su_jitsu				DECIMAL(9,2)	-- ����(����)C/S��
	,@su_hasu				DECIMAL(9,2)	-- ����(����)�[��
	,@dt_seizo				DATETIME		-- ����(����)������
	,@dt_kigen				DATETIME		-- ����(����)�ܖ�����
	,@kingaku				DECIMAL(12,4)	-- ����(����)���z
	,@no_lot				VARCHAR(14)		-- ����(����)���b�g�ԍ�
	--,@no_nohinsho			VARCHAR(16)		-- ����(����)�[�i���ԍ�
	,@no_nohinsho			NVARCHAR(16)	-- ����(����)�[�i���ԍ�
	--,@no_zeikan_shorui	VARCHAR(16)		-- ����(����)�Ŋ֏���No.
	,@no_zeikan_shorui		NVARCHAR(16)	-- ����(����)�Ŋ֏���No.
	,@no_denpyo				VARCHAR(30)		-- ����(����)�`�[No.
	--,@biko				VARCHAR(50)		-- ����(����)���l
	,@biko					NVARCHAR(50)	-- ����(����)���l
	,@user					VARCHAR(10)		-- ���O�C�����[�U�[�R�[�h
	,@no_niuke_jisseki		VARCHAR(14)		-- ����(����)�׎�ԍ�(��\��)
	,@shiireNyushukoKbn		SMALLINT		-- �R�[�h�ꗗ/���o�ɋ敪.�d��
	,@addKbn		        SMALLINT		-- �R�[�h�ꗗ/���o�ɋ敪.�ǉ�
	,@sotoinyuNyushukoKbn	SMALLINT		-- �R�[�h�ꗗ/���o�ɋ敪.�O�ړ� 
	,@kakozanNyushukoKbn	SMALLINT		-- �R�[�h�ꗗ/���o�ɋ敪.���H�c
	,@ryohinZaikoKbn		SMALLINT		-- �R�[�h�ꗗ/�݌ɋ敪.�Ǖi
	,@lotSaibanNo			VARCHAR(2)		-- �R�[�h�ꗗ/�̔ԋ敪.�׎󃍃b�g�ԍ�
	,@lotSaibanPrefix		VARCHAR			-- �R�[�h�ꗗ/�̔Ԑړ���.�׎󃍃b�g�ԍ�
	,@kgKanzanKbn			VARCHAR(2)		-- �R�[�h�ꗗ/���Z�敪�DKg
	,@lKanzanKbn			VARCHAR(2)		-- �R�[�h�ꗗ/���Z�敪�DL
	,@dt_nonyu				DATETIME		-- ����(����)�[����
	,@no_nonyu				VARCHAR(13)
	,@flg_shonin            SMALLINT        -- ���F�t���O
AS
BEGIN

		-- ����.���b�g�ԍ�����̏ꍇ�̍̔ԏ���
	IF @no_lot = '' 
	OR @no_lot IS NULL
	
	BEGIN

		EXEC dbo.usp_cm_Saiban 
			@lotSaibanNo, 
			@lotSaibanPrefix, 
			@no_lot OUTPUT
	END

	-- ���o�ɋ敪���d���ƊO�ړ��̂��̂ɑ΂��čX�V�������܂��B
	UPDATE tr_niuke
	SET
		dt_niuke = @dt_nonyu
		,dt_nonyu = @dt_nonyu
		,tm_nonyu_jitsu = @tm_nonyu_jitsu
		,su_nonyu_jitsu = @su_jitsu
		,su_nonyu_jitsu_hasu = @su_hasu
		,su_zaiko = @su_jitsu
		,su_zaiko_hasu = @su_hasu
		,dt_seizo = @dt_seizo
		,dt_kigen = @dt_kigen
		,kin_kuraire = @kingaku
		,no_lot = @no_lot
		,no_nohinsho = @no_nohinsho
		,no_zeikan_shorui = @no_zeikan_shorui
		,no_denpyo = @no_denpyo
		,cd_update = @user
		,dt_update = GETUTCDATE()
		,no_nonyu = @no_nonyu
		,flg_shonin = @flg_shonin
	WHERE
		no_niuke = @no_niuke_jisseki
		AND kbn_nyushukko IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)

	-- ���o�ɋ敪���d���ƊO�ړ��̂��̈ȊO�ɑ΂��čX�V�������܂��B
	-- �׎���̍X�V�͍s��Ȃ�
	UPDATE tr_niuke
	SET
		dt_nonyu = @dt_nonyu
		,dt_seizo = @dt_seizo
		,dt_kigen = @dt_kigen
		,no_lot = @no_lot
		,no_nohinsho = @no_nohinsho
		,no_zeikan_shorui = @no_zeikan_shorui
		,no_denpyo = @no_denpyo
		,cd_update = @user
		,dt_update = GETUTCDATE()
	WHERE
		no_niuke = @no_niuke_jisseki
		AND kbn_nyushukko NOT IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)

	UPDATE tr_niuke
	SET biko = @biko
	WHERE	
		no_niuke = @no_niuke_jisseki
		AND no_seq = 1

	-- �݌ɐ��������s���܂��B
	EXEC dbo.usp_NiukeNyuryoku_update_04 
		@no_niuke_jisseki, 
		@ryohinZaikoKbn, 
		@kakozanNyushukoKbn, 
		@kgKanzanKbn, 
		@lKanzanKbn

	/* �X�V�����������̂��߃R�����g�A�E�g
	
	-- ����.���b�g�ԍ�����̏ꍇ�̍̔ԏ���
	IF @no_lot = '' 
	OR @no_lot IS NULL
	
	BEGIN

		EXEC dbo.usp_cm_Saiban 
			@lotSaibanNo, 
			@lotSaibanPrefix, 
			@no_lot OUTPUT
	END

	-- ���o�ɋ敪���d���ƊO�ړ��̂��̂ɑ΂��čX�V�������܂��B
	UPDATE tr_niuke
	SET
		dt_niuke = @dt_nonyu
		,dt_nonyu = @dt_nonyu
		,tm_nonyu_jitsu = @tm_nonyu_jitsu
		,su_nonyu_jitsu = @su_jitsu
		,su_nonyu_jitsu_hasu = @su_hasu
		,su_zaiko = @su_jitsu
		,su_zaiko_hasu = @su_hasu
		,dt_seizo = @dt_seizo
		,dt_kigen = @dt_kigen
		,kin_kuraire = @kingaku
		,no_lot = @no_lot
		,no_nohinsho = @no_nohinsho
		,no_zeikan_shorui = @no_zeikan_shorui
		,no_denpyo = @no_denpyo
		--,biko = @biko
		,cd_update = @user
		,dt_update = GETUTCDATE()
		,no_nonyu = @no_nonyu
		,flg_shonin = @flg_shonin
	WHERE
		no_niuke = @no_niuke_jisseki
		--AND kbn_nyushukko IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn)
		AND kbn_nyushukko IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)

	-- ���o�ɋ敪���d���ƊO�ړ��̂��̂ɑ΂��čX�V�������܂��B
	UPDATE tr_niuke
	SET
		dt_niuke = @dt_nonyu
		,dt_nonyu = @dt_nonyu
		,tm_nonyu_jitsu = @tm_nonyu_jitsu
		,dt_seizo = @dt_seizo
		,dt_kigen = @dt_kigen
		--,kin_kuraire = @kingaku
		,no_lot = @no_lot
		,no_nohinsho = @no_nohinsho
		,no_zeikan_shorui = @no_zeikan_shorui
		,no_denpyo = @no_denpyo
		--,biko = @biko
		,cd_update = @user
		,dt_update = GETUTCDATE()
		--,no_nonyu = @no_nonyu
		--,flg_shonin = @flg_shonin
	WHERE
		no_niuke = @no_niuke_jisseki
		AND kbn_nyushukko NOT IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)

	UPDATE tr_niuke
	SET biko = @biko
	WHERE	
		no_niuke = @no_niuke_jisseki
		AND no_seq = 1

	-- ���o�ɋ敪���d���ƊO�ړ��łȂ����̂ɑ΂��čX�V�������܂��B
	UPDATE tr_niuke
	SET
		dt_seizo = @dt_seizo
		,dt_kigen = @dt_kigen
		,no_lot	= @no_lot
		,no_denpyo = @no_denpyo
		,cd_update = @user
		,dt_update = GETUTCDATE()
	WHERE
		no_niuke = @no_niuke_jisseki
		--AND kbn_nyushukko NOT IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn)
		--AND kbn_nyushukko NOT IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)

	-- �݌ɐ��������s���܂��B
	EXEC dbo.usp_NiukeNyuryoku_update_04 
		@no_niuke_jisseki, 
		@ryohinZaikoKbn, 
		@kakozanNyushukoKbn, 
		@kgKanzanKbn, 
		@lKanzanKbn
	*/
END
GO
