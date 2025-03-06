IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KasaneLabelOkikae_select_02') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KasaneLabelOkikae_select_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�d�˃��x���u����� �d�˃��x���\�֗pSQL
				�w�肳�ꂽ�z���R�[�h�A�}�[�N�R�[�h�A�H���ԍ��A�w����t�ȍ~�ɂ��āA
              �}�[�N�R�[�h�𒊏o����B
�t�@�C����	�Fusp_KasaneLabelOkikae_select_02
���͈���	�F@cd_haigo, @cd_mark, @no_kotei
			  ,@dt_hizuke ,@flg_mishiyo
�o�͈���	�F
�߂�l		�F
�쐬��		�F2013.09.26  ADMAX okuda.k
�X�V��		�F2015.10.27  ADMAX taira.s	�L���ł��l������悤�ɏC��
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KasaneLabelOkikae_select_02]
(
	@cd_haigo		VARCHAR(14) --�z���R�[�h
	,@cd_mark		VARCHAR(2)  --�����ԍ�
	,@no_kotei		NUMERIC(4)  --�H���ԍ�
	,@dt_hizuke		DATETIME    --���t
	,@flg_mishiyo	VARCHAR(1)  --���g�p�t���O
)
AS
BEGIN
	SELECT 
		MAX(mhr.no_tonyu) AS max_no_tonyu
	    ,MIN(mhr.no_tonyu) AS min_no_tonyu
	FROM ma_haigo_recipe mhr
	WHERE
		mhr.cd_haigo = @cd_haigo
		AND mhr.cd_mark = @cd_mark
		AND mhr.no_kotei = @no_kotei
		AND mhr.no_han = (SELECT TOP 1 no_han FROM udf_HaigoRecipeYukoHan(@cd_haigo, @flg_mishiyo, @dt_hizuke))
END
GO
