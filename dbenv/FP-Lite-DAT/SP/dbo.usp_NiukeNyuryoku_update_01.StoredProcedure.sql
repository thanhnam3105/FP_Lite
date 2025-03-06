IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_update_01') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_update_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�׎���́@����(�\��)�̍X�V���׎�g�����ɏ������݂܂��B
�t�@�C����	�Fusp_NiukeNyuryoku_update_01
���͈���	�F@flg_kakutei, @kbn_nyushukko, @tm_nonyu_yotei
			  , @no_niuke, @addKbn, @shiireNyushukoKbn, @sotoinyuNyushukoKbn
			  , @user, @no_nonyu_yotei, @yojitusFlagYotei, @yojitsuFlagJisseki
�o�͈���	�F
�߂�l		�F
�쐬��		�F2013.11.13  ADMAX kakuta.y
�X�V��		�F2015.09.24  ADMAX kakuta.y �[���\��ԍ��Ή�
�X�V��		�F2016.11.15  BRC cho.k �׎�s�ǉ��Ή�
�X�V��		�F2016.11.22  BRC kanehira.d ���o�ɋ敪�ǉ�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_update_01]
	@flg_kakutei			SMALLINT	-- �m��t���O
	,@kbn_nyushukko			SMALLINT	-- ���o�ɋ敪(�d�� or �O�ړ�)
	,@tm_nonyu_yotei		DATETIME	-- �\�莞��
	,@no_niuke				VARCHAR(14)	-- �׎�ԍ�(�\��)
	,@shiireNyushukoKbn		SMALLINT	-- �R�[�h�ꗗ/���o�ɋ敪.�d��
	,@addKbn		        SMALLINT	-- �R�[�h�ꗗ/���o�ɋ敪.�ǉ�
	,@sotoinyuNyushukoKbn	SMALLINT	-- �R�[�h�ꗗ/���o�ɋ敪.�O�ړ�
	,@user					VARCHAR(10)	-- ���O�C�����[�U�R�[�h
	--,@no_nonyu				VARCHAR(13)	-- �[���ԍ�(�\��)
	,@no_nonyu_yotei		VARCHAR(13)	-- �[���\��ԍ�
	,@yojitsuFlagYotei		SMALLINT	-- �敪�^�R�[�h�ꗗ�D�\���t���O�D�\��
	,@yojitsuFlagJisseki	SMALLINT	-- �敪�^�R�[�h�ꗗ�D�\���t���O�D����
AS

BEGIN

	-- �׎�g�����X�V����
	UPDATE tr_niuke
	SET
		flg_kakutei = @flg_kakutei
		,kbn_nyushukko = @kbn_nyushukko
		,tm_nonyu_yotei	= @tm_nonyu_yotei
		,cd_update = @user
		,dt_update = GETUTCDATE()
	--WHERE
	--	no_niuke IN	
	--	(
	--		SELECT
	--			t_niu.no_niuke
	--		FROM tr_niuke t_niu
	--		INNER JOIN 
	--			(
	--				SELECT
	--					*
	--				FROM tr_niuke
	--				WHERE
	--					no_niuke = @no_niuke
	--			) t_n
	--		ON t_niu.dt_niuke = t_n.dt_niuke
	--		AND t_niu.cd_hinmei = t_n.cd_hinmei
	--		AND t_niu.cd_torihiki = t_n.cd_torihiki
	--		--AND t_niu.kbn_nyuko = t_n.kbn_nyuko
	--		AND ((t_niu.kbn_nyuko is null AND t_n.kbn_nyuko is null) or t_niu.kbn_nyuko = t_n.kbn_nyuko)
	--	)				
	--AND kbn_nyushukko IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn)
	--AND no_nonyu = @no_nonyu
	WHERE
		-- �[���\���g�����ƌ����ł���f�[�^��Ώ�
		--(no_nonyu IS NOT NULL
		--AND no_niuke IN
		( no_niuke IN
					(
						SELECT
							t_niu.no_niuke
						FROM tr_niuke t_niu
						INNER JOIN tr_nonyu t_nou
						ON t_niu.no_nonyu = t_nou.no_nonyu
						WHERE
							(t_nou.flg_yojitsu = @yojitsuFlagYotei
							AND t_nou.no_nonyu = @no_nonyu_yotei)
							OR 
							(t_nou.flg_yojitsu = @yojitsuFlagJisseki
							AND t_nou.no_nonyu_yotei = @no_nonyu_yotei)
		--			))
		)
		OR
		-- �[���\���g�����ƌ����ł��Ȃ��f�[�^��Ώ�
		--(no_nonyu IS NULL
		--	AND no_niuke = @no_niuke)
		no_niuke = @no_niuke
		OR no_nonyu = @no_nonyu_yotei )
		--AND kbn_nyushukko IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn)
		AND kbn_nyushukko IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)
END
GO
