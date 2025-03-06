IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LotNoBetsuZaikoShosaiChosei_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosaiChosei_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\        �F�����g���� �ǉ�
�t�@�C����  �Fusp_LotNoBetsuZaikoShosaiChosei_create
���͈���    �F@no_niuke, @dt_niuke, @dt_nitizi,@cd_riyu
            �F@cd_riyu2, @su_chosei, @su_moto_chosei,@biko
            �F@cd_update,@cd_location,@cd_genka_center,@cd_soko
            �F@no_nohinsho,@no_niuke,@kbn_zaiko,@cd_tirihiki
�o�͈���    �F
�߂�l      �F
�쐬��      �F2013.11.21  ADMAX endo.y
�X�V��      �F2015.12.21  ADMAX s.shibao
�X�V��      �F2016.12.19  BRC   motojima.m �����Ή�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosaiChosei_create]
	 @no_seq_chosei		 VARCHAR(14)		--�����g�����p�V�[�P���X�ԍ� 
	, @no_seq_chosei2	 VARCHAR(14)		--�����g�����p�V�[�P���X�ԍ� 
	, @cd_hinmei		 VARCHAR(14)		--���.�i���R�[�h
	, @dt_nitizi         DATETIME		    --(���b�gNo.�ʍ݌ɏڍׂ���n���ꂽ�l)
	, @cd_riyu			 VARCHAR(10)		--���R�R�[�h�i���E�p�j
	, @cd_riyu2			 VARCHAR(10)		--���R�R�[�h�i�V�K�p�j
	, @su_chosei		 DECIMAL(12,6)	    --������
	, @su_moto_chosei	 DECIMAL(12,6)	    --������	 
	--, @biko            VARCHAR(50)		--���.���l
	, @biko              NVARCHAR(50)		--���.���l
	, @cd_update         VARCHAR(10)		--�Z�b�V������񃍃O�C�����[�U�[�R�[�h
	, @cd_location       VARCHAR(10)		--���P�[�V�����R�[�h
	, @cd_genka_center	 VARCHAR(10)	    --�����Z���^�[�R�[�h
	, @cd_soko			 VARCHAR(10)	    --�q�ɃR�[�h
	--, @no_nohinsho	 VARCHAR(14)	    --�[�i���ԍ�
	, @no_nohinsho		 NVARCHAR(14)	    --�[�i���ԍ�
	, @no_niuke          VARCHAR(14)        --�׎�ԍ�
	, @kbn_zaiko         SMALLINT           --�݌ɋ敪
	, @cd_tirihiki       VARCHAR(13)        --�����R�[�h
AS	
BEGIN

	--�����g�����ǉ�����(�ύX�O�������o�^)
		INSERT INTO tr_chosei
		(
			[no_seq]
			, [cd_hinmei]
			, [dt_hizuke]
			, [cd_riyu]
			, [su_chosei]
			, [biko]
			, [cd_seihin]
			, [dt_update]
			, [cd_update]
			--, [cd_kura]
			, [cd_genka_center] 
            , [cd_soko] 
            , [no_nohinsho] 
            , [no_niuke] 
            , [kbn_zaiko] 
            , [cd_torihiki] 
		)
		VALUES
		(
			@no_seq_chosei
			, @cd_hinmei
			, @dt_nitizi
			, @cd_riyu
			, @su_moto_chosei
			, @biko
			, ''
			, GETUTCDATE()
			, @cd_update
			--, @cd_location
			, @cd_genka_center
			, @cd_soko
			, @no_nohinsho
			, @no_niuke 
			, @kbn_zaiko
			, @cd_tirihiki

		)
	--�����g�����ǉ�����(�ύX�㒲�����o�^)	
		INSERT INTO tr_chosei
		(
			[no_seq]
			, [cd_hinmei]
			, [dt_hizuke]
			, [cd_riyu]
			, [su_chosei]
			, [biko]
			, [cd_seihin]
			, [dt_update]
			, [cd_update]
			--, [cd_kura]
			, [cd_genka_center] 
            , [cd_soko] 
            , [no_nohinsho] 
            , [no_niuke] 
            , [kbn_zaiko] 
            , [cd_torihiki] 

		)
		VALUES
		(
			@no_seq_chosei2
			, @cd_hinmei
			, @dt_nitizi
			, @cd_riyu2
			, @su_chosei
			, @biko
			, ''
			, GETUTCDATE()
			, @cd_update
			--, @cd_location
			, @cd_genka_center
			, @cd_soko
			, @no_nohinsho
			, @no_niuke 
			, @kbn_zaiko
			, @cd_tirihiki
		)

END
GO
