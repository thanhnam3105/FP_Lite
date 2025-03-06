IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_update_05') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_update_05]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�׎���́@����(�\��)�̍X�V���׎�g�����ɏ������݂܂��B�i�ǉ��\��p�j
�t�@�C����	�Fusp_NiukeNyuryoku_update_05
���͈���	�F@flg_kakutei, @kbn_nyushukko, @tm_nonyu_yotei
			  , @su_nonyu_yotei, @su_nonyu_yotei_hasu
			  , @no_niuke, @shiireNyushukoKbn, @sotoinyuNyushukoKbn, @addKbn
			  , @user, @no_nonyu_yotei, @yojitusFlagYotei, @yojitsuFlagJisseki
�o�͈���	�F--
�߂�l		�F--
�쐬��		�F2016.11.30  BRC cho.k
�X�V��		�F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_update_05]
	@flg_kakutei			SMALLINT		-- �m��t���O
	, @kbn_nyushukko		SMALLINT		-- ���o�ɋ敪(�d�� or �O�ړ�)
	, @tm_nonyu_yotei		DATETIME		-- �\�莞��
	, @su_nonyu_yotei		DECIMAL(9,2)	-- �[���\�萔
	, @su_nonyu_yotei_hasu	DECIMAL(9,2)	-- �[���\�萔(�[��)
	, @no_niuke				VARCHAR(14)		-- �׎�ԍ�(�\��)
	, @shiireNyushukoKbn	SMALLINT		-- �R�[�h�ꗗ/���o�ɋ敪.�d��
	, @sotoinyuNyushukoKbn	SMALLINT		-- �R�[�h�ꗗ/���o�ɋ敪.�O�ړ�
	, @addKbn		        SMALLINT		-- �R�[�h�ꗗ/���o�ɋ敪.�ǉ�
	, @user					VARCHAR(10)		-- ���O�C�����[�U�R�[�h
	, @no_nonyu_yotei		VARCHAR(13)		-- �[���\��ԍ�
	, @yojitsuFlagYotei		SMALLINT		-- �敪�^�R�[�h�ꗗ�D�\���t���O�D�\��
	, @yojitsuFlagJisseki	SMALLINT		-- �敪�^�R�[�h�ꗗ�D�\���t���O�D����
AS

BEGIN

	-- �׎�g�����X�V����
	UPDATE tr_niuke
	SET
		flg_kakutei = @flg_kakutei
		, kbn_nyushukko = @kbn_nyushukko
		, tm_nonyu_yotei = @tm_nonyu_yotei
		, su_nonyu_yotei = @su_nonyu_yotei
		, su_nonyu_yotei_hasu = @su_nonyu_yotei_hasu
		, cd_update = @user
		, dt_update = GETUTCDATE()
	WHERE
		( 
			no_niuke IN
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
					)
			OR no_niuke = @no_niuke
			OR no_nonyu = @no_nonyu_yotei
		)
		AND kbn_nyushukko IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn, @addKbn)
END
GO
