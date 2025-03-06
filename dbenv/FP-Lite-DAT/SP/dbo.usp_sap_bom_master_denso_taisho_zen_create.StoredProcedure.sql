IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_bom_master_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_bom_master_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�FBOM�}�X�^���M�O��Ώۃe�[�u���쐬����
�t�@�C����	�F[usp_sap_bom_master_denso_taisho_zen_create]
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.23 tsujita.s
�X�V��      �F2015.01.27 tsujita.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_bom_master_denso_taisho_zen_create] 
AS
BEGIN
	-- �O�񑗐M�Ώۃe�[�u���쐬�F�O�񑗐M�Ώۃe�[�u�����N���A
	DELETE ma_sap_bom_denso_taisho_zen

	-- �O�񑗐M�Ώۃe�[�u���쐬�F���M�Ώۃe�[�u����O�񑗐M�Ώۃe�[�u����INSERT
	INSERT INTO ma_sap_bom_denso_taisho_zen (
		cd_seihin
		,no_han
		,cd_kojo
		,dt_from
		,su_kihon
		,cd_hinmei
		,su_hinmoku
		,cd_tani
		,su_kaiso
		,cd_haigo
		,no_kotei
		,no_tonyu
		,flg_mishiyo
	)
	SELECT
		cd_seihin
		,no_han
		,cd_kojo
		,dt_from
		,su_kihon
		,cd_hinmei
		,su_hinmoku
		,cd_tani
		,su_kaiso
		,cd_haigo
		,no_kotei
		,no_tonyu
		,flg_mishiyo
	FROM
		ma_sap_bom_denso_taisho
END
GO
