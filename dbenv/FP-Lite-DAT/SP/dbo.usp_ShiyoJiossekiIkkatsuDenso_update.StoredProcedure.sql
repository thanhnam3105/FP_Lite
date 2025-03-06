IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShiyoJiossekiIkkatsuDenso_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShiyoJiossekiIkkatsuDenso_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�g�p���шꊇ�`�� �X�V
�t�@�C����	�Fusp_ShiyoJiossekiIkkatsuDenso_update
�쐬��		�F2015.07.02  ADMAX tsujita.s
�X�V��		�F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_ShiyoJiossekiIkkatsuDenso_update]
	@dt_from			DATETIME	-- ���������F�`���J�n��
	,@dt_to				DATETIME	-- ���������F�`���I����
	,@kbn_denso_machi	SMALLINT	-- �Œ�l�F�`����ԋ敪�F�`���҂�
	,@kbn_denso_midenso	SMALLINT	-- �Œ�l�F�`����ԋ敪�F���`��
AS
BEGIN
	SET NOCOUNT ON

	UPDATE
		tr_sap_shiyo_yojitsu_anbun
	SET
		kbn_jotai_denso = @kbn_denso_machi
	WHERE
		dt_shiyo_shikakari BETWEEN @dt_from AND @dt_to
	AND kbn_jotai_denso = @kbn_denso_midenso

END

GO
