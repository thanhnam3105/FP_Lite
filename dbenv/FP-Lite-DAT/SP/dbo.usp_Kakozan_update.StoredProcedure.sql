IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_Kakozan_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_Kakozan_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F���H�c �ۑ�
�t�@�C����	�Fusp_Kakozan_update
���͈���	�F@kbn_zaiko, @no_niuke, @max_seq, @su_zaiko
			  , @su_zaiko_hasu, @su_iri, @max_dt_niuke
			  , @dt_zaiko_teisei, @kbn_nyushukko
			  , @kakozanNyushukkoKbn, @flg_kakutei, @cd_update
�o�͈���	�F
�߂�l		�F
�쐬��		�F2013.10.21  ADMAX kakuta.y
�X�V��		�F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_Kakozan_update] 
	@kbn_zaiko				SMALLINT		-- ����.�݌ɋ敪
	,@no_niuke				VARCHAR(14)		-- ����.�׎�ԍ�(��\��)
	,@max_seq				DECIMAL(8,0)	-- ����.�V�[�P���X�ԍ��ő�l(��\��)
	,@su_zaiko				DECIMAL(9,2)	-- ����.�݌ɐ�
	,@su_zaiko_hasu			DECIMAL(9,2)	-- ����.�݌ɒ[��
	,@su_iri				DECIMAL(5,0)	-- ����.����(��\��)
	,@max_dt_niuke			DATETIME		-- ����.�׎���̍ő�l(��\��)
	,@dt_zaiko_teisei		DATETIME		-- ��������.�݌ɒ�����
	,@kbn_nyushukko			SMALLINT		-- ����.���o�ɋ敪(��\��)
	,@kakozanNyushukkoKbn	SMALLINT		-- ���o�ɋ敪.���H�c
	,@flg_kakutei			SMALLINT		-- ����.�m��
	,@cd_update				VARCHAR(10)		-- ���O�C���҃R�[�h
	,@cd_tani				VARCHAR(10)		-- �[���P�ʃR�[�h
AS
BEGIN
SET NOCOUNT ON;
	DECLARE 
		@zaiko_max_seq		DECIMAL(8,0)	-- *1*
		,@niu_max_seq		DECIMAL(8,0)	-- *2*
		,@tm_nonyu_jitsu	DATETIME		-- *3* ���݂̎��[������
		,@tm_nonyu_jisseki	DATETIME		-- *3* �X�V�p���[������
		,@dt_bool			BIT				-- *3* �׎���̍ő�l�ƍ݌ɒ��������C�R�[���Ȃ�1(update)
		,@zaikokanzanhasu	DECIMAL(9,3)
		,@initStr			VARCHAR(2)
		,@initNum			DECIMAL(9,2)
		,@update			BIT
		,@insert			BIT
		
	SET @initStr	= ''
	SET @initNum	= 0
	SET @update		= 1
	SET @insert		= 0

	-- �s�Ɠ����݌ɋ敪�̍ŐV�V�[�P���X�ԍ��擾���� *1*
	SELECT
		@zaiko_max_seq = MAX(t_niu.no_seq)
	FROM tr_niuke t_niu
	WHERE
		t_niu.kbn_zaiko = @kbn_zaiko
	GROUP BY 
		t_niu.no_niuke
	HAVING
		t_niu.no_niuke = @no_niuke

	-- �s�Ɠ����׎�ԍ��̍ŐV�V�[�P���X�ԍ��擾���� *2*
	IF @max_seq <> @zaiko_max_seq
	BEGIN
		--RETURN
		-- �㑱�f�[�^�̃V�[�P���X�ԍ������炵�܂��B
		UPDATE tr_niuke
			SET no_seq = no_seq + 1
		WHERE no_niuke = @no_niuke
			AND no_seq > @max_seq
		set @niu_max_seq = @max_seq
	END
	ELSE IF @max_seq = @zaiko_max_seq
	BEGIN
		SELECT 
			@niu_max_seq = MAX(t_niu.no_seq)
		FROM tr_niuke t_niu
		GROUP BY 
			t_niu.no_niuke
		HAVING t_niu.no_niuke = @no_niuke
	END

	IF (@cd_tani = '4' OR @cd_tani = '11')
	BEGIN
		SET @zaikokanzanhasu = (@su_zaiko_hasu / 1000) * 1.0
	END
	ELSE
	BEGIN
		SET @zaikokanzanhasu = @su_zaiko_hasu
	END
	-- �݌ɐ��ƒ[���̊ۂߏ������s���܂��B
	IF @zaikokanzanhasu >= @su_iri
	BEGIN
		IF (@cd_tani = '4' OR @cd_tani = '11')
		BEGIN
			SET @su_zaiko = FLOOR(@su_zaiko + @zaikokanzanhasu / @su_iri)
			SET @zaikokanzanhasu = (@zaikokanzanhasu % @su_iri) * 1000
		END
		ELSE
		BEGIN
			SET @su_zaiko = FLOOR(@su_zaiko + @zaikokanzanhasu / @su_iri)
			SET @zaikokanzanhasu = @zaikokanzanhasu % @su_iri
		END
	END

	IF (@cd_tani = '4' OR @cd_tani = '11')
	BEGIN
		SET @su_zaiko_hasu = (@zaikokanzanhasu * 1000) * 1.0
	END
	ELSE
	BEGIN
		SET @su_zaiko_hasu = @zaikokanzanhasu
	END
	

	-- �[�����ю����擾���� *3*
	SELECT
		@tm_nonyu_jitsu = tm_nonyu_jitsu
	FROM tr_niuke
	WHERE
		no_niuke = @no_niuke
		AND kbn_zaiko = @kbn_zaiko
		AND no_seq = @max_seq

	IF CONVERT(VARCHAR(8),@max_dt_niuke,112) = CONVERT(VARCHAR(8),@dt_zaiko_teisei,112)
	BEGIN
		SET @tm_nonyu_jisseki = DATEADD(MINUTE,1,@tm_nonyu_jitsu)
		SET @dt_bool = @update
	END
	ELSE IF CONVERT(VARCHAR(8),@max_dt_niuke,112) <> CONVERT(VARCHAR(8),@dt_zaiko_teisei,112)
	BEGIN
		SET @tm_nonyu_jisseki = GETUTCDATE()
		SET @dt_bool = @insert
	END

	-- �X�V�E�o�^����
	IF @dt_bool = @update
		AND @kbn_nyushukko = @kakozanNyushukkoKbn
	BEGIN
		UPDATE tr_niuke
		SET
			dt_niuke = @dt_zaiko_teisei
			,tm_nonyu_jitsu = @tm_nonyu_jisseki
			,su_zaiko = @su_zaiko
			,su_zaiko_hasu = @su_zaiko_hasu
			,su_kakozan = @su_zaiko
			,su_kakozan_hasu = @su_zaiko_hasu
			,flg_kakutei = @flg_kakutei
			,cd_update = @cd_update
			,dt_update = GETUTCDATE()
		WHERE
			no_niuke = @no_niuke
			AND no_seq = @max_seq
			AND kbn_zaiko = @kbn_zaiko
	END
	ELSE
	BEGIN
		-- �ŐV�̃V�[�P���X�ԍ����擾���܂��B
		SELECT @niu_max_seq = @niu_max_seq + 1

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
			)
		SELECT
			@no_niuke
			,@dt_zaiko_teisei
			,tr_niu.cd_hinmei
			,tr_niu.kbn_hin
			,tr_niu.cd_niuke_basho
			,@kakozanNyushukkoKbn
			,tr_niu.kbn_zaiko
			,tr_niu.tm_nonyu_yotei
			,tr_niu.su_nonyu_yotei
			,tr_niu.su_nonyu_yotei_hasu
			,@tm_nonyu_jisseki
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
			,@initStr
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
			,@niu_max_seq	
		FROM tr_niuke tr_niu		-- �V�[�P���X�ԍ����ŐV�ɂ��ăC���T�[�g
		WHERE
			tr_niu.no_niuke = @no_niuke
			AND tr_niu.no_seq = @max_seq
			AND tr_niu.kbn_zaiko = @kbn_zaiko
	END
	
	--�݌ɍX�V����
		EXEC usp_IdoShukkoShosai_update02  
		@no_niuke        = @no_niuke
		, @kbn_zaiko     = @kbn_zaiko
		, @kbn_nyushukko = @kakozanNyushukkoKbn
		,@cdNonyuTani = @cd_tani
	
END
GO
