IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�׎���́@���т�[���\���g�����ɓo�^�E�X�V���܂��B
�t�@�C����	�Fusp_NiukeNyuryoku_create
���͈���	�F@cd_hinmei, @cd_torihiki, @dt_niuke
			  , @cd_tani_nonyu, @kgTaniCode, @lTaniCode
			  , @su_iri, @nonyu_tanka, @nonyuSaibanNo, @nonyuSaibanPrefix
			  , @jissekiYojitsuFlg, @cd_torihiki2, @kbn_zei, @flg_create
�o�͈���	�F
�߂�l		�F
�쐬��		�F2013.11.12  ADMAX kakuta.y
�X�V��		�F2015.10.01  ADMAX kakuta.y �[���\��ԍ��Ή�
�X�V��		�F2019.01.13  BRC motojima.m �\��ꗗ�E�ϓ��\�̔[�����т�2�{�ɂȂ�s��C��
�X�V��		�F2019.02.18  BRC motojima.m �\��ꗗ�E�ϓ��\�̔[�����т�2�{�ɂȂ�s��C��(�ԕi�����O)
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_create] 
	@cd_hinmei				VARCHAR(14)		-- ����(�\��)�i���R�[�h
	,@cd_torihiki			VARCHAR(13)		-- ����(�\��)�����R�[�h
	--,@dt_niuke				DATETIME		-- ��������/�׎��
	,@dt_niuke				DATETIME		-- ����(����)�[����
	,@cd_tani_nonyu			VARCHAR(10)		-- ����(�\��)�[���P�ʃR�[�h
	,@kgTaniCode			VARCHAR(10)		-- �R�[�h�ꗗ/�[���P�ʃR�[�hK��
	,@lTaniCode				VARCHAR(10)		-- �R�[�h�ꗗ/�[���P�ʃR�[�hL
	,@su_iri				DECIMAL(8,0)	-- ����(�\��)����
	,@nonyu_tanka			DECIMAL(12,4)	-- �[���P��
	,@nonyuSaibanNo			VARCHAR(2)		-- �[���ԍ��̔ԗp�R�[�h
	,@nonyuSaibanPrefix		VARCHAR			-- �[���ԍ��̔ԗp�ړ���
	,@jissekiYojitsuFlg		SMALLINT		-- �R�[�h�ꗗ/�\���t���O.����
	,@cd_torihiki2			VARCHAR(13)		-- ����(�\��)�����R�[�h2
	,@kbn_zei				SMALLINT		-- ����(�\��)�ŋ敪
	,@flg_create			BIT				-- �X�V�t���O(create = true, update = false)
	,@kbn_nyuko				SMALLINT		-- ����/���ɋ敪
	,@no_nonyu				VARCHAR(13)		-- ����(����)/�[���ԍ�
	,@no_nonyu_yotei		VARCHAR(13)		-- ����(�\��)/�[���\��ԍ�

AS
BEGIN

	-- �ϐ��錾
	DECLARE @sum_nonyu				DECIMAL(18,2)
			, @sum_hasu				DECIMAL(18,2)
			, @su_nonyu				DECIMAL(10,2)
			, @su_hasu				DECIMAL(10,2)
			, @max_su				DECIMAL(9,2)
			, @flg_kakutei			SMALLINT
			, @flg_kakutei_nonyu	SMALLINT
			, @sum_kuraire			DECIMAL(18,4)
			--, @no_nonyu				VARCHAR(13)
			, @zeroNum				SMALLINT
			, @oneNum				SMALLINT
			, @thausandNum			SMALLINT
			, @true					BIT
			--, @nonyu				VARCHAR(13)
			, @no_nonyu_existcheck	VARCHAR(13)
			, @tan_nonyu_calc		DECIMAL(12,4)


	-- �l�i�[
	SET @max_su			= 9999999
	SET @zeroNum		= 0
	SET @oneNum			= 1
	SET @thausandNum	= 1000
	SET	@true			= 1


	-- ���[�������v�A���[���[�����v�̎擾
	SELECT
		@sum_nonyu	= ISNULL(SUM(t_n.su_nonyu_jitsu), @zeroNum)
		, @sum_hasu = ISNULL(SUM(t_n.su_nonyu_jitsu_hasu), @zeroNum)
		--, @nonyu = t_n.no_nonyu
	FROM tr_niuke t_n
	WHERE
		t_n.cd_hinmei = @cd_hinmei
		AND t_n.cd_torihiki = @cd_torihiki
		--AND @dt_niuke <= t_n.dt_niuke
		AND t_n.no_nonyu = @no_nonyu
		and (@kbn_nyuko is null or t_n.kbn_nyuko = @kbn_nyuko)
		--AND t_n.kbn_nyushukko NOT IN (11,12)
		AND t_n.kbn_nyushukko NOT IN (8,11,12)
		--AND t_n.kbn_nyuko = @kbn_nyuko
		--AND t_n.dt_niuke < (SELECT DATEADD(DD,1,@dt_niuke))
	GROUP BY t_n.no_nonyu


	-- �擾�������v�����ڂ̐����͈͂𒴂���ꍇ�͏���l���Z�b�g���܂��B
	IF @sum_nonyu > @max_su
	BEGIN
		SET @sum_nonyu = @max_su
	END
	IF @sum_hasu > @max_su
	BEGIN
		SET @sum_hasu = @max_su
	END


	-- �[�����A�[���[���Z�o����(�[���P�ʂ��uKg�v���uL�v�̏ꍇ�́ug�v�uml�v�ɍ��킹��)
	IF @cd_tani_nonyu = @kgTaniCode OR @cd_tani_nonyu = @lTaniCode
	BEGIN
		SET @su_iri = @su_iri * @thausandNum
	END

	SET @su_nonyu = FLOOR((@sum_nonyu * @su_iri + @sum_hasu) / @su_iri)
	SET @su_hasu = FLOOR(@sum_hasu % @su_iri)

	-- �Z�o�����������ڂ̐����͈͂𒴂���ꍇ�͏���l���Z�b�g���܂��B
	IF @su_nonyu > @max_su
	BEGIN
		SET @su_nonyu = @max_su
	END
	IF @su_hasu > @max_su
	BEGIN
		SET @su_hasu = @max_su
	END


	-- �m��t���O�̐ݒ�
	SELECT 
		@flg_kakutei = t_n.flg_kakutei
		,@sum_kuraire = SUM(t_n.kin_kuraire)
	FROM tr_niuke t_n
	WHERE
		t_n.cd_hinmei = @cd_hinmei
		AND t_n.cd_torihiki = @cd_torihiki
		AND t_n.no_nonyu = @no_nonyu
		--AND t_n.kbn_nyuko = @kbn_nyuko
		AND (@kbn_nyuko is null or t_n.kbn_nyuko = @kbn_nyuko)
		--AND @dt_niuke <= t_n.dt_niuke 
		--AND t_n.dt_niuke < (SELECT DATEADD(DD,1,@dt_niuke))
	GROUP BY
		t_n.cd_hinmei
		,cd_torihiki
		--,t_n.dt_niuke
		,t_n.flg_kakutei

		
	-- �[���\���g�����̊m��t���O���擾
	SELECT 
		@flg_kakutei_nonyu = flg_kakutei
	FROM tr_nonyu
	WHERE 
		cd_hinmei = @cd_hinmei
		AND cd_torihiki = @cd_torihiki
		--AND dt_nonyu	= @dt_niuke
		AND no_nonyu = @no_nonyu
		--AND kbn_nyuko = @kbn_nyuko
		AND (@kbn_nyuko is null or kbn_nyuko = @kbn_nyuko)
		AND flg_yojitsu	= @jissekiYojitsuFlg


	-- �[���\���g�����̔[���ԍ����擾(��U�ۗ���������)
	--SELECT 
	--	@no_nonyu = no_nonyu
	--FROM tr_nonyu
	--WHERE 
	--	cd_hinmei = @cd_hinmei
	--	AND cd_torihiki = @cd_torihiki
	--	AND dt_nonyu	= @dt_niuke
	--	AND flg_yojitsu	= 0
	-- �[���\���g�����̔[���ԍ����擾(��U�ۗ������܂�)


	-- �[���\���g�����̊m��t���O�������Ă���ꍇ�͊m����Z�b�g���܂��B
	-- ��L�ȊO�̏����B
	-- ����(����)�̋��z���v��1�ȏゾ�����ꍇ�ŁA�׎�g�����̊m��t���O�������Ă����ꍇ�A�[���\���g�����̊m��t���O�𗧂Ă܂��B
	IF @flg_kakutei_nonyu = 1
		OR (@sum_kuraire > 0 AND @flg_kakutei = 1)
	BEGIN
		SET @flg_kakutei = 1
	END
	ELSE
	BEGIN
		SET @flg_kakutei = 0
	END


	-- ���z�̎Z�o
	IF @sum_kuraire = 0 OR @sum_kuraire IS NULL
	BEGIN
		SET @sum_kuraire = FLOOR(@su_nonyu * @nonyu_tanka + @su_hasu * ( @nonyu_tanka / @su_iri))
	END

	-- ���z�̃I�[�o�[�t���[�Ή�
	IF @sum_kuraire > 99999999.9999
	BEGIN
		SET @sum_kuraire = 99999999.9999
	END



	-- �ǉ�����
	IF @flg_create = @true

	BEGIN
		----��U�ۗ���������
		--if @nonyu is null
		--begin
		---- �[���ԍ��̔ԏ���
		--	EXEC dbo.usp_cm_Saiban @nonyuSaibanNo, @nonyuSaibanPrefix, @no_nonyu OUTPUT
		--	set @nonyu = @no_nonyu
		--end
		----��U�ۗ������܂�

		-- �[���\���g�����ǉ�����
		INSERT INTO tr_nonyu
			(
				flg_yojitsu
				,no_nonyu
				,dt_nonyu
				,cd_hinmei
				,su_nonyu
				,su_nonyu_hasu
				,cd_torihiki
				,cd_torihiki2
				,tan_nonyu
				,kin_kingaku
				,kbn_zei
				,flg_kakutei
				,kbn_nyuko
				,no_nonyu_yotei
			)
		VALUES
			(
				@jissekiYojitsuFlg
				--,@nonyu
				,@no_nonyu
				,@dt_niuke
				,@cd_hinmei
				,@su_nonyu
				,@su_hasu
				,@cd_torihiki
				,@cd_torihiki2
				,@nonyu_tanka
				,@sum_kuraire
				,@kbn_zei
				,@flg_kakutei
				,@kbn_nyuko
				,@no_nonyu_yotei
			)
	END

	-- �X�V����(�����ޕϓ��\�ŕK�v�Ȃ��߁A�\��͍X�V���܂���B)
	ELSE

	BEGIN
		
		UPDATE tr_nonyu
		SET	
			su_nonyu = @su_nonyu
			,su_nonyu_hasu = @su_hasu
			,cd_torihiki2 = @cd_torihiki2
			,tan_nonyu = @nonyu_tanka
			,kin_kingaku = @sum_kuraire
			,flg_kakutei = @flg_kakutei
			,dt_nonyu = @dt_niuke
		WHERE
			cd_hinmei = @cd_hinmei
			--AND @dt_niuke <= dt_nonyu
			--AND dt_nonyu < (SELECT DATEADD(DD,1,@dt_niuke))
			AND cd_torihiki = @cd_torihiki
			AND no_nonyu = @no_nonyu
			--AND kbn_nyuko = @kbn_nyuko
			AND (@kbn_nyuko is null or kbn_nyuko = @kbn_nyuko)
			AND flg_yojitsu = @jissekiYojitsuFlg
	END
END
GO
