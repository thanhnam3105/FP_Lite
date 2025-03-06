IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KasaneLabelShogo_select_02') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KasaneLabelShogo_select_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�d�˃��x���ƍ� ����02
�t�@�C����	�Fusp_KasaneLabelShogo_select02
���͈���	�F@mark, @cd_haigo, @no_kotei
              , @no_han, @flg_mishiyo
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2013.11.06  ADMAX okuda.k
�X�V��		�F2015.01.18  ADMAX shibao.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KasaneLabelShogo_select_02]
(
	@mark			VARCHAR(2)    --�}�[�N
	,@cd_haigo		VARCHAR(14)   --�z���R�[�h
	,@no_kotei		DECIMAL(4,0)  --�����ԍ�
	,@no_han		DECIMAL(4,0)  --�Ŕԍ�
	,@flg_mishiyo	SMALLINT      --���g�p�t���O
)
AS
BEGIN
	SELECT 
		mhr.no_tonyu
		,mhr.cd_hinmei
		,mhr.nm_hinmei
		,mhr.wt_haigo
		,mhr.wt_shikomi
		,mhr.wt_kowake
	FROM ma_haigo_mei mhm
	INNER JOIN ma_haigo_recipe mhr
	ON mhm.cd_haigo = mhr.cd_haigo
	AND mhm.no_han = mhr.no_han
	AND mhm.flg_mishiyo = @flg_mishiyo
	INNER JOIN ma_mark mm
	ON mhr.cd_mark = mm.cd_mark
	WHERE
		mm.mark = @mark
		AND mhr.cd_haigo = @cd_haigo
		AND mhr.no_kotei = @no_kotei
		AND mhm.no_han = @no_han
END
GO
