IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryozanHyoryoKeikaku_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryozanHyoryoKeikaku_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�����c���ʁi�v��ύX�j �o�^����
�t�@�C����	�Fusp_GenryozanHyoryoKeikaku_create
���͈���	�F@dt_label_hakko, @cd_panel, @cd_hakari
			  , @cd_hinmei, @nm_hinmei, @wt_zan
			  , @wt_futai, @cd_user, @kaifuMikaifuFlg
			  , @dt_system, @dt_shomi_kaifugo
			  , @shiyoHakiFlg, @cd_label, @no_lot
			  , @dt_shomi_kaifumae, @dt_seizo, @no_lot_kowake
			  , @no_lot_oya, @zanlotKbnSaiban, @zanlotPrefixSaiban
�o�͈���	�F
�߂�l		�F
�쐬��		�F2014.02.12  ADMAX kakuta.y
�X�V��		�F2015.09.18  ADMAX taira.s
�X�V��		�F2016.12.13  BRC   motojima.m  �����Ή�
�X�V��		�F2018.03.15  BRC   yokota.t    �𓀃��x���Ή�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GenryozanHyoryoKeikaku_create]
	@dt_label_hakko			DATETIME		-- ���x�����s����
	,@cd_panel				VARCHAR(3)		-- �Z�b�V�������D�p�l���R�[�h
	,@cd_hakari				VARCHAR(10)		-- ���}�X�^�D���R�[�h
	,@cd_hinmei				VARCHAR(14)		-- ��ʁD�R�[�h
	--,@nm_hinmei			VARCHAR(50)		-- ��ʁD������
	,@nm_hinmei				NVARCHAR(50)	-- ��ʁD������
	,@wt_zan				DECIMAL(12,6)	-- ��ʁD�c�d��
	,@wt_futai				DECIMAL(12,6)	-- ��ʁD���܏d��
	,@cd_user				VARCHAR(10)		-- �Z�b�V�������D���O�C�����[�U�[�R�[�h
	,@kaifuMikaifuFlg		SMALLINT		-- �敪/�R�[�h�ꗗ�D���J���t���O�D�J��
	,@dt_system				DATETIME		-- �V�X�e�����t
	,@dt_shomi_kaifugo		DATETIME		-- ��ʁD�J����
	,@shiyoHakiFlg			SMALLINT		-- �敪/�R�[�h�ꗗ�D�j���t���O�D�g�p
	,@cd_label				TEXT			-- ���x���R�[�h
	,@no_lot				VARCHAR(14)		-- ��ʁD���b�g
	,@dt_shomi_kaifumae		DATETIME		-- ��ʁD�J���O
	,@dt_seizo				DATETIME		-- ���x�����D������
	,@no_lot_kowake			VARCHAR(14)		-- �������уg�����D�������b�g�ԍ�
	,@no_lot_oya			VARCHAR(14)		-- �������уg�����D�e���b�g�ԍ�
	--,@zanlotKbnSaiban		VARCHAR(1)		-- �敪/�R�[�h�ꗗ�D�̔ԋ敪�D�c���b�g
	--,@zanlotPrefixSaiban	VARCHAR(1)		-- �敪/�R�[�h�ꗗ�D�̔Ԑړ����敪�D�c���b�g
	,@kbn_label				SMALLINT		-- ���x���敪
	,@no_lot_zan			VARCHAR(14)		-- �N���C�A���g�ō̔Ԃ��ꂽ�c���b�g�ԍ�
	,@dt_shomi_kaitogo		DATETIME		-- ��ʁD�𓀌�
AS
BEGIN

	DECLARE @no_saiban VARCHAR(14)
	SET @no_saiban = @no_lot_zan;
	--EXEC dbo.usp_cm_Saiban
	--	@zanlotKbnSaiban
	--	,@zanlotPrefixSaiban
	--	,@no_saiban OUTPUT

	-- �c���уg�����ǉ�����
	INSERT INTO tr_zan_jiseki
		(
			no_lot_zan
			,dt_hyoryo_zan
			,cd_panel
			,cd_hakari
			,cd_hinmei
			,nm_hinmei
			,wt_jisseki
			,wt_jisseki_futai
			,cd_tanto
			,dt_read
			,flg_mikaifu
			,dt_kaifu
			,dt_kigen
			,flg_ido
			,flg_haki
			,cd_maker
			,cd_label
			,kbn_label
			,dt_shomi_kaito
		)
	VALUES
		(
			@no_saiban
			,@dt_label_hakko
			,@cd_panel
			,@cd_hakari
			,@cd_hinmei
			,@nm_hinmei
			,@wt_zan
			,@wt_futai
			,@cd_user
			,NULL
			,@kaifuMikaifuFlg
			,@dt_system
			,@dt_shomi_kaifugo
			,NULL
			,@shiyoHakiFlg
			,NULL
			,@cd_label
			,@kbn_label
			,@dt_shomi_kaitogo
		)

	-- �������b�g���уg�����ǉ�����
	INSERT INTO tr_lot
		(
			no_lot_jisseki
			,no_lot
			,wt_jisseki
			,dt_shomi
			,dt_shomi_kaifu
			,dt_seizo_genryo
			,dt_shomi_kaito
		)
	VALUES
		(
			@no_saiban
			,@no_lot
			,@wt_zan
			,@dt_shomi_kaifumae
			,@dt_shomi_kaifugo
			,@dt_seizo
			,@dt_shomi_kaitogo
		)

	-- �����׎p�g�����ǉ�����
	INSERT INTO tr_kongo_nisugata
		(
			dt_kowake
			,no_lot_jisseki
			,no_lot
			,old_no_lot_jisseki
			,old_no_lot
			,old_wt_jisseki
			,old_dt_shomi
			,old_dt_shomi_kaifu
			,old_dt_seizo_genryo
			,cd_maker
			,old_dt_shomi_kaito
		)
	SELECT
		tk.dt_kowake
		,@no_saiban
		,@no_lot
		,tl.no_lot_jisseki
		,tl.no_lot
		,tl.wt_jisseki
		,tl.dt_shomi
		,tl.dt_shomi_kaifu
		,tl.dt_seizo_genryo
		,''
		,tl.dt_shomi_kaito
	FROM 
		(
			SELECT 
				no_lot_kowake
				,dt_kowake
			FROM tr_kowake
			WHERE ((@no_lot_oya IS NULL
				OR @no_lot_oya = '')			-- ���b�g�ؑւ��Ă��Ȃ��ꍇ
  				AND no_lot_kowake = @no_lot_kowake
  				)
				OR((@no_lot_oya IS NOT NULL
				AND @no_lot_oya <> '')		-- ���b�g�ؑւ��Ă���ꍇ
				AND no_lot_oya = @no_lot_oya				
				)
		) tk
	INNER JOIN 
		(
			SELECT 
				no_lot_jisseki
				,no_lot
				,wt_jisseki
				,dt_shomi
				,dt_shomi_kaifu
				,dt_seizo_genryo
				,dt_shomi_kaito
			FROM tr_lot
			WHERE ((@no_lot_oya IS NULL
				OR @no_lot_oya = '')			-- ���b�g�ؑւ��Ă��Ȃ��ꍇ
  				AND no_lot_jisseki = @no_lot_kowake
  				)
				OR((@no_lot_oya IS NOT NULL
				AND @no_lot_oya <> '')		-- ���b�g�ؑւ��Ă���ꍇ
				AND no_lot_jisseki IN
				(
					SELECT
						tk2.no_lot_kowake
					FROM tr_kowake tk2
					WHERE
						tk2.no_lot_oya = @no_lot_oya
				))
		) tl
	ON tk.no_lot_kowake = tl.no_lot_jisseki

END
GO
