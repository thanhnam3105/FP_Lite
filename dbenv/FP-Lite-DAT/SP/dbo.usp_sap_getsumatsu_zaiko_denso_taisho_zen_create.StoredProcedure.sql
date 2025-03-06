IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_getsumatsu_zaiko_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_getsumatsu_zaiko_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�����݌ɑ��M�O��Ώۃe�[�u���쐬����
�t�@�C����	�F[usp_sap_getsumatsu_zaiko_denso_taisho_zen_create]
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.28 endo.y
�X�V��      �F2018.08.07 kanehira.d �����݌ɒ��o�e�[�u���ƌ����݌ɑ��M�Ώۃe�[�u�����g�����P�[�g����B
�X�V��      �F2018.12.13 motojima �Ώۃe�[�u����TRUNCATE����DELETE�ɕύX�B
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_getsumatsu_zaiko_denso_taisho_zen_create] 
AS
BEGIN
/*
	-- �O�񑗐M�Ώۃe�[�u���쐬�F�O�񑗐M�Ώۃe�[�u�����N���A
	DELETE tr_sap_getsumatsu_zaiko_denso_taisho_zen

	-- �O�񑗐M�Ώۃe�[�u���쐬�F���M�Ώۃe�[�u����O�񑗐M�Ώۃe�[�u����INSERT
	INSERT INTO tr_sap_getsumatsu_zaiko_denso_taisho_zen (
		cd_hinmei
		,dt_tanaoroshi
		,cd_kojo
		,hokan_basho
		,su_tanaoroshi
		,cd_tani
		,dt_update
		,kbn_zaiko
	)
	SELECT
		cd_hinmei
		,dt_tanaoroshi
		,cd_kojo
		,hokan_basho
		,su_tanaoroshi
		,cd_tani
		,dt_update
		,kbn_zaiko
	FROM
		tr_sap_getsumatsu_zaiko_denso_taisho
*/
	
	-- �����݌ɑ��M�Ώۃe�[�u���A�����݌ɒ��o�e�[�u�����폜	
/*
	TRUNCATE TABLE tr_sap_getsumatsu_zaiko_denso_taisho
	
	TRUNCATE TABLE tr_sap_getsumatsu_zaiko_denso
*/
	DELETE tr_sap_getsumatsu_zaiko_denso_taisho
	DELETE tr_sap_getsumatsu_zaiko_denso

END
GO
