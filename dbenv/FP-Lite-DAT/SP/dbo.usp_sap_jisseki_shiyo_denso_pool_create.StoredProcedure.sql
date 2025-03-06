IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_shiyo_denso_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�g�p���ѓ`��POOL�e�[�u���쐬����
�t�@�C����	�F[usp_sap_jisseki_shiyo_denso_pool_create]
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.07.15 kaneko.m
�X�V��      �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_pool_create] 
AS
BEGIN

	-- ���M�e�[�u���ۑ������F���MPOOL�e�[�u������1�N���O�̃f�[�^���폜
	DELETE tr_sap_jisseki_shiyo_denso_pool
	WHERE dt_denso < DATEADD(month, -18, CONVERT(VARCHAR, GETUTCDATE(), 111))

	-- ���M�e�[�u���ۑ������F���M���o�e�[�u�����瑗�MPOOL�e�[�u����INSERT
	INSERT INTO tr_sap_jisseki_shiyo_denso_pool (
		kbn_denso_SAP
		,no_seq
		,no_lot_seihin
		,dt_shiyo
		,cd_kojo
		,cd_hinmei
		,su_shiyo
		,cd_tani_SAP
		,type_ido
		,hokan_basho
		,dt_denso
	)
		SELECT 
			kbn_denso_SAP
			,no_seq
			,no_lot_seihin
			,dt_shiyo
			,cd_kojo
			,cd_hinmei
			,su_shiyo
			,cd_tani_SAP
			,type_ido
			,hokan_basho
			,GETUTCDATE() AS dt_denso
		FROM tr_sap_jisseki_shiyo_denso

END

GO
