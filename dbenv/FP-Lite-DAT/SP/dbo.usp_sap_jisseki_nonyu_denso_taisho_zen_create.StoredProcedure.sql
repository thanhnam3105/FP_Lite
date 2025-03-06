IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_nonyu_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_nonyu_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�O��[�����ё��M�Ώۃe�[�u���쐬����
�t�@�C����	�F[[usp_sap_jisseki_nonyu_denso_taisho_zen_create]]
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.20 endo.y
�X�V��      �F2015.08.19 taira.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_nonyu_denso_taisho_zen_create] 
AS
BEGIN
	-- �O�񑗐M�Ώۃe�[�u���쐬�F�O�񑗐M�Ώۃe�[�u����trancate
	TRUNCATE TABLE tr_sap_jisseki_nonyu_denso_taisho_zen

	-- �O�񑗐M�Ώۃe�[�u���쐬�F���M�Ώۃe�[�u����O�񑗐M�Ώۃe�[�u����INSERT
	INSERT INTO tr_sap_jisseki_nonyu_denso_taisho_zen (
			no_nonyu
			,no_niuke
			,cd_kojo
			,cd_niuke_basho
			,dt_nonyu
			,cd_hinmei
			,su_nonyu_jitsu
			,cd_torihiki
			,cd_tani_nonyu
			,kbn_nyuko
			,flg_kakutei
			,no_nohinsho
			,no_zeikan_shorui
	)
		SELECT
			no_nonyu
			,no_niuke
			,cd_kojo
			,cd_niuke_basho
			,dt_nonyu
			,cd_hinmei
			,su_nonyu_jitsu
			,cd_torihiki
			,cd_tani_nonyu
			,kbn_nyuko
			,flg_kakutei
			,ISNULL(no_nohinsho,'')
			,ISNULL(no_zeikan_shorui,'')
		FROM
			tr_sap_jisseki_nonyu_denso_taisho
END
GO
