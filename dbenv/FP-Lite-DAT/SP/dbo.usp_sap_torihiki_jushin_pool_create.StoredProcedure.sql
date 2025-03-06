IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_torihiki_jushin_pool_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_torihiki_jushin_pool_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�����}�X�^��MPOOL�e�[�u���쐬����
�t�@�C����	�F[usp_sap_torihiki_jushin_pool_create]
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.22 endo.y
�X�V��      �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_torihiki_jushin_pool_create] 
AS
BEGIN

	-- ��M�e�[�u���폜�����F�����}�X�^��MPOOL�e�[�u������1�N���O�̃f�[�^���폜
	DELETE tr_sap_torihiki_jushin_pool
	WHERE dt_create < DATEADD(year, -1, CONVERT(VARCHAR, GETUTCDATE(), 111))

	-- ��MPOOL�e�[�u���ۑ������F�����}�X�^��M�e�[�u����������}�X�^��MPOOL�e�[�u����INSERT
	INSERT INTO tr_sap_torihiki_jushin_pool (
			 kbn_denso_SAP
			,kbn_torihiki
			,nm_torihiki
			,cd_torihiki
			,nm_torihiki_ryaku
			,no_yubin
			,nm_jusho
			,no_tel
			,no_fax
			,e_mail
			,flg_mishiyo
			,dt_jushin
			,dt_create
	)
		SELECT 
			 kbn_denso_SAP
			,kbn_torihiki
			,nm_torihiki
			,cd_torihiki
			,nm_torihiki_ryaku
			,no_yubin
			,nm_jusho
			,no_tel
			,no_fax
			,e_mail
			,flg_mishiyo
			,dt_jushin
			,GETUTCDATE() AS dt_create
		FROM tr_sap_torihiki_jushin

END
GO
