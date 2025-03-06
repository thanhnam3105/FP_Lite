IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_yotei_nonyu_denso_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_yotei_nonyu_denso_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�[���\�蒊�oPOOL�e�[�u���捞����
�t�@�C����	�Fusp_sap_keikaku_yotei_nonyu_pool_create
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.08 ADMAX endo.y
�X�V��      �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_yotei_nonyu_denso_pool_create] 
AS
BEGIN
	--�[���\�蒊�oPOOL�e�[�u������1�N�ȏ�O�̃f�[�^���폜
	DELETE
	FROM tr_sap_yotei_nonyu_denso_pool
	WHERE dt_denso < (SELECT DATEADD(month,-18,GETUTCDATE()))
	
	--���M�Ώۂ̃f�[�^�𐻑��v�撊�oPOOL�e�[�u���Ɋi�[
	INSERT INTO tr_sap_yotei_nonyu_denso_pool (
		kbn_denso_SAP
		,no_nonyu
		,cd_kojo
		,dt_nonyu
		,cd_hinmei
		,su_nonyu
		,cd_torihiki
		,cd_tani_SAP
		,kbn_nyuko
		,dt_denso
	)
	SELECT
		kbn_denso_SAP
		,no_nonyu
		,cd_kojo
		,dt_nonyu
		,cd_hinmei
		,COALESCE(su_nonyu,0)
		,cd_torihiki
		,cd_tani_SAP
		,kbn_nyuko
		,GETUTCDATE()
	FROM tr_sap_yotei_nonyu_denso
END
GO
