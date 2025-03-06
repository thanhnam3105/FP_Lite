IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_keikaku_seihin_denso_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_keikaku_seihin_denso_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�����v�撊�oPOOL�e�[�u���捞����
�t�@�C����	�Fusp_sap_keikaku_seihin_denso_pool_create
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.08 ADMAX endo.y
�X�V��      �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_keikaku_seihin_denso_pool_create] 
AS
BEGIN
	--�����v�撊�oPOOL�e�[�u������1�N�ȏ�O�̃f�[�^���폜
	DELETE
	FROM tr_sap_keikaku_seihin_denso_pool
	WHERE dt_denso < (SELECT DATEADD(month,-18,GETUTCDATE()))
	
	--���M�Ώۂ̃f�[�^�𐻑��v�撊�oPOOL�e�[�u���Ɋi�[
	INSERT INTO tr_sap_keikaku_seihin_denso_pool (
		kbn_denso_SAP
		,no_lot_seihin
		,dt_seizo
		,cd_kojo
		,cd_hinmei
		,su_seizo_keikaku
		,cd_tani_SAP
		,dt_denso
	)
	SELECT
		kbn_denso_SAP
		,no_lot_seihin
		,dt_seizo
		,cd_kojo
		,cd_hinmei
		,COALESCE(su_seizo_keikaku,0)
		,cd_tani_SAP
		,GETUTCDATE()
	FROM tr_sap_keikaku_seihin_denso
END
GO
