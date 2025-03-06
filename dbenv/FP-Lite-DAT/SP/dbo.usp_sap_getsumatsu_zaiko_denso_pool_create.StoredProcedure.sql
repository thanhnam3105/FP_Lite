IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_getsumatsu_zaiko_denso_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_getsumatsu_zaiko_denso_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�����݌ɓ`��POOL�e�[�u���쐬����
�t�@�C����	�F[usp_sap_getsumatsu_zaiko_denso_pool_create]
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.30 tsujita.s
�X�V��		�F2021.05.17 BRC.saito #1205�Ή�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_getsumatsu_zaiko_denso_pool_create] 
AS
BEGIN
	-- �o�b�`�R���g���[���}�X�^�X�V(�N��)
	UPDATE ma_batch_control
	SET flg_shori = 1
		,dt_start = GETUTCDATE()
	WHERE id_jobnet = 'GETSUMATSU_ZAIKO'
	AND flg_shori = 0

	-- ���M�e�[�u���ۑ������F���MPOOL�e�[�u������1�N���O�̃f�[�^���폜
	DELETE tr_sap_getsumatsu_zaiko_denso_pool
	WHERE dt_denso < DATEADD(month, -18, CONVERT(VARCHAR, GETUTCDATE(), 111))

	-- ���M�e�[�u���ۑ������F���M���o�e�[�u�����瑗�MPOOL�e�[�u����INSERT
	INSERT INTO tr_sap_getsumatsu_zaiko_denso_pool (
		kbn_denso_SAP
		,cd_hinmei
		,dt_tanaoroshi
		,cd_kojo
		,hokan_basho
		,su_tanaoroshi
		,cd_tani
		,dt_update
		,kbn_zaiko
		,dt_denso
	)
	SELECT 
		 kbn_denso_SAP
		,cd_hinmei
		,dt_tanaoroshi
		,cd_kojo
		,hokan_basho
		,su_tanaoroshi
		,cd_tani
		,dt_update
		,kbn_zaiko
		,GETUTCDATE() AS dt_denso
	FROM tr_sap_getsumatsu_zaiko_denso

END
GO
