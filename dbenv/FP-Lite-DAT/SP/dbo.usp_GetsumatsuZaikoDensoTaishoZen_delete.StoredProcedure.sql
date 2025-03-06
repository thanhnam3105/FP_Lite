IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GetsumatsuZaikoDensoTaishoZen_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GetsumatsuZaikoDensoTaishoZen_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\        �F�����݌ɑ��M�O��Ώ� �폜
�t�@�C����  �Fusp_GetsumatsuZaikoDensoTaishoZen_delete
���͈���    �F@con_dt_zaiko
�o�͈���    �F
�߂�l      �F
�쐬��      �F2016.05.13  BRC motojima.m
�X�V��      �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GetsumatsuZaikoDensoTaishoZen_delete]
	 @con_dt_zaiko			datetime		-- �폜�����F�݌ɓ��t

AS
BEGIN

	-- �����݌ɑ��M�O��Ώۂ̃f�[�^���폜���܂��B
	DELETE FROM tr_sap_getsumatsu_zaiko_denso_taisho_zen
	WHERE
		CONVERT(NVARCHAR, dt_tanaoroshi, 111) = CONVERT(NVARCHAR, @con_dt_zaiko, 111)

END
GO
