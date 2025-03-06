IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LotNoBetsuZaikoShosaiChoseiHenpin_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosaiChoseiHenpin_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\        �F�����g���� �ǉ�(�ԕi��)
�t�@�C����  �F[usp_LotNoBetsuZaikoShosaiChoseiHenpin_create]
���͈���    �F@no_niuke, @dt_nitizi, @su_chosei, @cd_update, @kbn_zaiko, @cd_genka_center, @cd_soko, @biko, @kbn_Zaiko_Chosei_Henpin
�o�͈���    �F
�߂�l      �F
�쐬��      �F2015.09.25 MJ ueno.k 
�X�V��      �F2016.12.13 BRC motojima.m �����Ή�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosaiChoseiHenpin_create]
	@no_niuke					VARCHAR(14)		--�׎�ԍ�
	, @cd_hinmei				VARCHAR(14)		--���.�i���R�[�h
	, @dt_nitizi				DATETIME		--(���b�gNo.�ʍ݌ɏڍׂ���n���ꂽ�l)
	, @su_chosei				DECIMAL(12,6)	--������
	, @cd_update				VARCHAR(10)		--�Z�b�V������񃍃O�C�����[�U�[�R�[�h
    , @kbn_zaiko				SMALLINT		--����/�݌ɋ敪
	, @cd_genka_center			VARCHAR(10)		--�H��}�X�^/�����Z���^�[�R�[�h
	, @cd_soko					VARCHAR(10)		--�H��}�X�^/�q�ɃR�[�h
	--, @biko					VARCHAR(100)	--����/���l
	, @biko						NVARCHAR(100)	--����/���l
	, @kbn_Zaiko_Chosei_Henpin	VARCHAR(10)		--�����������R�敪.�ԕi

AS 

BEGIN

	--�����g�����ǉ�����(�X�V)
		--�����g�����ǉ�
		UPDATE tr_chosei 
		SET 
			--TOsVN 17035 nt.toan 2023/03/16(Request #480) Start -->
			--su_chosei = @su_chosei
			biko = @biko
			--TOsVN 17035 nt.toan 2023/03/16(Request #480) End -->
			,nm_henpin = @biko
			,dt_update = GETUTCDATE()
			,cd_update = @cd_update
			,cd_genka_center = @cd_genka_center
			,cd_soko = @cd_soko
		WHERE 
			cd_hinmei = @cd_hinmei 
			AND dt_hizuke = @dt_nitizi
			AND no_niuke = @no_niuke
			AND kbn_zaiko = @kbn_zaiko
			AND cd_riyu = @kbn_Zaiko_Chosei_Henpin

END
GO
