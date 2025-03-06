IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_bom_master_denso_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_bom_master_denso_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�[�����ѓ`��POOL�e�[�u���쐬����
�t�@�C����	�F[usp_sap_bom_master_denso_pool_create]
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.23 tsujita.s
�X�V��      �F2015.02.17 tsujita.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_bom_master_denso_pool_create] 
AS
BEGIN
	SET NOCOUNT ON

	-- ���M�e�[�u���ۑ������F���MPOOL�e�[�u������1�N���O�̃f�[�^���폜
	DELETE ma_sap_bom_denso_pool
	WHERE dt_denso < DATEADD(month, -18, CONVERT(VARCHAR, GETUTCDATE(), 111))

	-- ���M�e�[�u���ۑ������F���M���o�e�[�u�����瑗�MPOOL�e�[�u����INSERT
	INSERT INTO ma_sap_bom_denso_pool (
		kbn_denso_SAP
		,cd_seihin
		--,no_han
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
		,dt_denso
	)
	SELECT 
		kbn_denso_SAP
		,cd_seihin
		--,no_han
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
		,GETUTCDATE() AS dt_denso
	FROM ma_sap_bom_denso

END
GO
