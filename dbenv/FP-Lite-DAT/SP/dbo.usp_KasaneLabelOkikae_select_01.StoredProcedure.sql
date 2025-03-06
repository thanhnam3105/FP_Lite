IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KasaneLabelOkikae_select_01') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KasaneLabelOkikae_select_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�d�˃��x���u����� �d�˃��x���\�֗pSQL
				�w�肳�ꂽ�z���R�[�h�A�����ԍ��A�H���ԍ��A�w����t�ȍ~�ɂ��āA
				�}�[�N�R�[�h�𒊏o����B
�t�@�C����	�Fusp_KasaneLabelOkikae_select
���͈���	�F@cd_haigo, @no_tonyu ,@no_kotei
              , @dt_hizuke, @flg_mishiyo
�o�͈���	�F
�߂�l		�F
�쐬��		�F2013.09.26  ADMAX okuda.k
�X�V��		�F2015.10.27  ADMAX taira.s	�L���ł��l������悤�ɏC��
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KasaneLabelOkikae_select_01]
(
	@cd_haigo		VARCHAR(14) --�z���R�[�h
	,@no_tonyu		NUMERIC(4)  --�����ԍ�
	,@no_kotei		NUMERIC(4)  --�H���ԍ�
	,@dt_hizuke		DATETIME    --���t
	,@flg_mishiyo	VARCHAR(1)  --���g�p�t���O
)
AS
BEGIN
	SELECT
		ISNULL(mhr.cd_mark, '00') AS cd_mark
	FROM ma_haigo_recipe mhr
    WHERE
    	mhr.cd_haigo = @cd_haigo
		AND mhr.no_tonyu = @no_tonyu
		AND mhr.no_kotei = @no_kotei
		AND mhr.no_han = (SELECT TOP 1 no_han FROM udf_HaigoRecipeYukoHan(@cd_haigo, @flg_mishiyo, @dt_hizuke))		
END
GO
