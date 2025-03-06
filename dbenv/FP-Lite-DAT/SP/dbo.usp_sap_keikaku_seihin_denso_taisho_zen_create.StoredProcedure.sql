IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_keikaku_seihin_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_keikaku_seihin_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F���i�v�摗�M�O��Ώۃe�[�u���捞����
�t�@�C����	�Fusp_sap_keikaku_seihin_denso_taisho_zen_create
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.08 ADMAX endo.y
�X�V��      �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_keikaku_seihin_denso_taisho_zen_create] 
	--@hoge1 smallint
	--,@hoge2 smallint
	--,@hoge3 smallint
AS
BEGIN
	-- ���i�v�摗�M�O��Ώۃe�[�u���̍폜
	TRUNCATE TABLE tr_sap_keikaku_seihin_denso_taisho_zen

	-- ���i�v�摗�M�Ώۃe�[�u���̃f�[�^�𐻕i�v�摗�M�O��Ώۃe�[�u���ɃR�s�[
	INSERT INTO tr_sap_keikaku_seihin_denso_taisho_zen (
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
	FROM tr_sap_keikaku_seihin_denso_taisho
END
GO
