IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_chosei_zaiko_denso_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_chosei_zaiko_denso_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�݌ɒ����`��POOL�e�[�u���쐬����
�t�@�C����	�F[usp_sap_chosei_zaiko_denso_pool_create]
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.28 endo.y
�X�V��      �F2015.09.24 taira.s  �[�i���ԍ��A�ԕi���R��ǉ�
�X�V��      �F2015.09.29 taira.s  �����R�[�h��ǉ�
�X�V���@�@�@�F2022.11.01 echigo.r �ԕi�����ł͂Ȃ��A���l���e��SAP�ɓ`��
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_chosei_zaiko_denso_pool_create] 
AS
BEGIN

	-- ���M�e�[�u���ۑ������F���MPOOL�e�[�u������1�N���O�̃f�[�^���폜
	DELETE tr_sap_chosei_zaiko_denso_pool
	WHERE dt_denso < DATEADD(month, -18, CONVERT(VARCHAR, GETUTCDATE(), 111))

	-- ���M�e�[�u���ۑ������F���M���o�e�[�u�����瑗�MPOOL�e�[�u����INSERT
	INSERT INTO tr_sap_chosei_zaiko_denso_pool (
			 kbn_denso_SAP
			,no_seq
			,cd_hinmei
			,cd_kojo
			,cd_soko
			,cd_riyu
			,su_chosei
			,cd_tani_SAP
			,cd_genka_center
			,dt_denpyo
			,dt_hizuke
			,dt_denso
			,kbn_ido
			,cd_torihiki
			,biko
			,no_nohinsho
	)
		SELECT 
			 kbn_denso_SAP
			,no_seq
			,cd_hinmei
			,cd_kojo
			,cd_soko
			,cd_riyu
			,su_chosei
			,cd_tani_SAP
			,cd_genka_center
			,dt_denpyo
			,dt_hizuke
			,GETUTCDATE() AS dt_denso
			,kbn_ido
			,cd_torihiki
			,biko
			,no_nohinsho
		FROM tr_sap_chosei_zaiko_denso

END
GO
