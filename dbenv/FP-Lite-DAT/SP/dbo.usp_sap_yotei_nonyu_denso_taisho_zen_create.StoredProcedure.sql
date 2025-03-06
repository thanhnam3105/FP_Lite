IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_yotei_nonyu_denso_taisho_zen_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_yotei_nonyu_denso_taisho_zen_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�[���\�著�M�O��Ώۃe�[�u���捞����
�t�@�C����	�Fusp_sap_yotei_nonyu_denso_taisho_zen_create
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.08 ADMAX endo.y
�X�V��      �F2015.06.19 ADMAX tsujita.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_yotei_nonyu_denso_taisho_zen_create] 
AS
BEGIN
	-- �[���\�著�M�O��Ώۃe�[�u���̍폜
	TRUNCATE TABLE tr_sap_yotei_nonyu_denso_taisho_zen

	-- �[���\�著�M�Ώۃe�[�u���̃f�[�^��[���\�著�M�O��Ώۃe�[�u���ɃR�s�[
	INSERT INTO tr_sap_yotei_nonyu_denso_taisho_zen (
		flg_yojitsu
		,no_nonyu
		,dt_nonyu
		,cd_hinmei
		,su_nonyu
		,su_nonyu_hasu
		,cd_torihiki
		,cd_torihiki2
		,tan_nonyu
		,kin_kingaku
		,no_nonyusho
		,kbn_zei
		,kbn_denso
		,flg_kakutei
		,dt_seizo
		,kbn_nyuko
		,cd_tani_shiyo
	)
	SELECT
		flg_yojitsu
		,no_nonyu
		,dt_nonyu
		,cd_hinmei
		,su_nonyu
		,su_nonyu_hasu
		,cd_torihiki
		,cd_torihiki2
		,tan_nonyu
		,kin_kingaku
		,no_nonyusho
		,kbn_zei
		,kbn_denso
		,flg_kakutei
		,dt_seizo
		,kbn_nyuko
		,cd_tani_shiyo
	FROM tr_sap_yotei_nonyu_denso_taisho
END
GO
