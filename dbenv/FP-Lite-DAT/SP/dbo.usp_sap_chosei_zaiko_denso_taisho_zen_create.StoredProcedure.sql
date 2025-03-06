IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_chosei_zaiko_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_chosei_zaiko_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�O�񒲐��݌ɑ��M�Ώۃe�[�u���쐬����
�t�@�C����	�F[usp_sap_chosei_zaiko_denso_taisho_zen_create]
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.28 endo.y
�X�V��      �F2015.07.16 kobayashi.y �������l��
�X�V��      �F2015.09.24 taira.s �[�i���ԍ��A�ԕi���R��ǉ�
�X�V��      �F2015.09.29 taira.s �����R�[�h��ǉ�
�X�V���@�@�@�F2022.11.01 echigo.r �ԕi�����ł͂Ȃ��A���l���e��SAP�ɓ`��
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_chosei_zaiko_denso_taisho_zen_create] 
AS
BEGIN
	-- �O�񑗐M�Ώۃe�[�u���쐬�F�O�񑗐M�Ώۃe�[�u����trancate
	TRUNCATE TABLE tr_sap_chosei_zaiko_denso_taisho_zen

	-- �O�񑗐M�Ώۃe�[�u���쐬�F���M�Ώۃe�[�u����O�񑗐M�Ώۃe�[�u����INSERT
	INSERT INTO tr_sap_chosei_zaiko_denso_taisho_zen (
			no_seq
			,cd_hinmei
			,dt_hizuke
			,cd_riyu
			,su_chosei
			,dt_update
			,cd_update
			,cd_genka_center
			,cd_soko
			,cd_torihiki
			,biko
			,no_nohinsho
	)
		SELECT
			no_seq
			,cd_hinmei
			,dt_hizuke
			,cd_riyu
			,su_chosei
			,dt_update
			,cd_update
			,cd_genka_center
			,cd_soko
			,cd_torihiki
			,biko
			,no_nohinsho
		FROM
			tr_sap_chosei_zaiko_denso_taisho


	-- �������O��e�[�u���쐬�F�������O��e�[�u����trancate
	TRUNCATE TABLE tr_sap_chosei_anbun_zen

	-- �������O��e�[�u���쐬�F�������e�[�u�����������O��e�[�u����INSERT
	INSERT INTO tr_sap_chosei_anbun_zen (
			no_seq
			,no_seq_anbun
			,no_lot_shikakari
			,cd_hinmei
			,dt_hizuke
			,cd_riyu
			,su_chosei
			,cd_genka_center
			,cd_soko
	)
		SELECT
			no_seq
			,no_seq_anbun
			,no_lot_shikakari
			,cd_hinmei
			,dt_hizuke
			,cd_riyu
			,su_chosei
			,cd_genka_center
			,cd_soko
		FROM
			tr_sap_chosei_anbun
END
GO
