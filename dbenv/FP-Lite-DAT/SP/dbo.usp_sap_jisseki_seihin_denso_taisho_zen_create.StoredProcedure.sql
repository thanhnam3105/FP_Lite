IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_seihin_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_seihin_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�O�񐻕i���ё��M�Ώۃe�[�u���쐬����
�t�@�C����	�F[[usp_sap_jisseki_seihin_denso_taisho_zen_create]]
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.07 kaneko.m
�X�V��      �F2015.03.06 tsujita.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_seihin_denso_taisho_zen_create] 
AS
BEGIN
	-- �O�񑗐M�Ώۃe�[�u���쐬�F�O�񑗐M�Ώۃe�[�u����trancate
	TRUNCATE TABLE tr_sap_jisseki_seihin_denso_taisho_zen

	-- �O�񑗐M�Ώۃe�[�u���쐬�F���M�Ώۃe�[�u����O�񑗐M�Ώۃe�[�u����INSERT
	INSERT INTO tr_sap_jisseki_seihin_denso_taisho_zen (
		no_lot_seihin
		,dt_seizo
		,cd_shokuba
		,cd_line
		,cd_hinmei
		,su_seizo_yotei
		,su_seizo_jisseki
		,flg_jisseki
		,kbn_denso
		,flg_denso
		,dt_update
		,su_batch_keikaku
		,su_batch_jisseki
		,dt_shomi
		,no_lot_hyoji
	)
		SELECT
			no_lot_seihin
			,dt_seizo
			,cd_shokuba
			,cd_line
			,cd_hinmei
			,su_seizo_yotei
			,su_seizo_jisseki
			,flg_jisseki
			,kbn_denso
			,flg_denso
			,dt_update
			,su_batch_keikaku
			,su_batch_jisseki
			,dt_shomi
			,no_lot_hyoji
		FROM
			tr_sap_jisseki_seihin_denso_taisho
END
GO
