IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_torihiki_jushin_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_torihiki_jushin_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�����}�X�^��M�e�[�u���폜����
�t�@�C����	�F[usp_sap_torihiki_jushin_delete]
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.22 endo.y
�X�V��      �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_torihiki_jushin_delete] 
AS
BEGIN

	-- �����}�X�^��M�e�[�u���̍폜
	TRUNCATE TABLE tr_sap_torihiki_jushin

END
GO
