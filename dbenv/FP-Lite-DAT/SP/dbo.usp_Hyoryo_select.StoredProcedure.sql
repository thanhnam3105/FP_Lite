IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_Hyoryo_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_Hyoryo_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F���ʉ�� ���ʌ���
�t�@�C����	�Fusp_Hyoryo_select
���͈���	�Fno_tonyu, dt_hiduke, no_kotei ,cd_haigo
              ,cd_mark_from ,cd_mark_to, flg_mishiyo
�o�͈���	�F
�߂�l		�F���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2013.10.23  ADMAX okuda.k
�X�V��		�F2015.10.27  ADMAX taira.s	�L���ł��l������悤�ɏC��
*****************************************************/
CREATE PROCEDURE [dbo].[usp_Hyoryo_select]
(
	@no_tonyu		INT          --�����ԍ�
	,@dt_hiduke		DATETIME     --���t
	,@no_kotei		INT          --�H���ԍ�
	,@cd_haigo		VARCHAR(14)  --�z���R�[�h
	,@cd_mark_from	VARCHAR(3)   --�d�˃}�[�N�R�[�hmin
	,@cd_mark_to	VARCHAR(3)   --�d�˃}�[�N�R�[�hmax
	,@flg_mishiyo	INT          --���g�p�t���O
)
AS 
BEGIN
	SELECT
		mm.cd_mark
	FROM ma_mark mm
	INNER JOIN ma_haigo_recipe mhr
	ON mhr.cd_mark = mm.cd_mark
	INNER JOIN ma_haigo_mei mhm
	ON mhr.cd_haigo = mhm.cd_haigo
	AND mhr.no_han = (SELECT TOP 1 no_han FROM udf_HaigoRecipeYukoHan(@cd_haigo, @flg_mishiyo, @dt_hiduke))
	AND mhr.wt_haigo = mhm.wt_haigo
	WHERE mhr.no_tonyu = @no_tonyu
	  AND mhr.cd_haigo = @cd_haigo
	  AND mhr.no_kotei = @no_kotei
	  AND mm.cd_mark BETWEEN @cd_mark_from AND @cd_mark_to
END
GO
