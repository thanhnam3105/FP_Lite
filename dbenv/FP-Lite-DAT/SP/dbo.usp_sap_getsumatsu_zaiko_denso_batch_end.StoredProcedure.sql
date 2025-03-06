IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_getsumatsu_zaiko_denso_batch_end') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_getsumatsu_zaiko_denso_batch_end]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�����݌ɓ`��:�o�b�`�R���g���[���}�X�^�X�V(�I��)����
�t�@�C����	�F[usp_sap_getsumatsu_zaiko_denso_batch_end]
�߂�l		�F
�쐬��		�F2021.05.15 BRC.saito #1205�Ή�
�X�V��		�F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_getsumatsu_zaiko_denso_batch_end]
AS
BEGIN

	-- �o�b�`�R���g���[���}�X�^�X�V(�I��)
	UPDATE ma_batch_control
	SET flg_shori = 0
		,dt_end = GETUTCDATE()
	WHERE id_jobnet = 'GETSUMATSU_ZAIKO'
	AND flg_shori = 1

END
GO