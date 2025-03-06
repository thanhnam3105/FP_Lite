IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_shiyo_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�O��g�p���ё��M�Ώۃe�[�u���쐬����
�t�@�C����	�F[usp_sap_jisseki_shiyo_denso_taisho_zen_create]
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.07.15 kaneko.m
�X�V��      �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_taisho_zen_create] 
AS
BEGIN
	-- �O�񑗐M�Ώۃe�[�u���쐬�F�O�񑗐M�Ώۃe�[�u����trancate
	TRUNCATE TABLE tr_sap_jisseki_shiyo_denso_taisho_zen

	-- �O�񑗐M�Ώۃe�[�u���쐬�F���M�Ώۃe�[�u����O�񑗐M�Ώۃe�[�u����INSERT
	INSERT INTO tr_sap_jisseki_shiyo_denso_taisho_zen (
		no_seq
		,flg_yojitsu
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,no_lot_shikakari
		,su_shiyo
		,data_key_tr_shikakari
	)
		SELECT
			no_seq
			,flg_yojitsu
			,cd_hinmei
			,dt_shiyo
			,no_lot_seihin
			,no_lot_shikakari
			,su_shiyo
			,data_key_tr_shikakari
		FROM
			tr_sap_jisseki_shiyo_denso_taisho
END

GO
