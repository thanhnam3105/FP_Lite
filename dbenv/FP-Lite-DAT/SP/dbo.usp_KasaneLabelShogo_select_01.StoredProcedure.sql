IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KasaneLabelShogo_select_01') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KasaneLabelShogo_select_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�d�˃��x���ƍ� ����
�t�@�C����	�Fusp_KasaneLabelShogo_select
���͈���	�F@markfrom, @markto, @cd_haigo, @no_tonyu
              , @no_kotei, @dt_seizo, @flg_mishiyo
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2013.11.06  ADMAX okuda.k
�X�V��		�F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KasaneLabelShogo_select_01]
(
	@markfrom		VARCHAR(2)    --�}�[�N�R�[�hfrom
	,@markto		VARCHAR(2)    --�}�[�N�R�[�hto
	,@cd_haigo		VARCHAR(14)   --�z���R�[�h
	,@no_tonyu		DECIMAL(4,0)  --�����ԍ�
	,@no_kotei		DECIMAL(4,0)  --�H���ԍ�
	,@dt_seizo		DATETIME      --������
	,@flg_mishiyo	SMALLINT      --���g�p�t���O
)
AS
BEGIN
    SELECT
		mm.mark
		,mhm.nm_haigo_ja
		,mhm.nm_haigo_en
		,mhm.nm_haigo_zh
		,mhm.nm_haigo_vi
		,MAX(mhm.no_han) AS no_han
    FROM ma_haigo_mei mhm
	INNER JOIN ma_haigo_recipe mhr
	ON mhm.cd_haigo = mhr.cd_haigo
	AND mhm.no_han = mhr.no_han
	AND mhm.flg_mishiyo = @flg_mishiyo
	INNER JOIN ma_mark mm
	ON mhr.cd_mark = mm.cd_mark
    WHERE
        mm.cd_mark BETWEEN @markfrom AND @markto
		AND mhr.cd_haigo = @cd_haigo
		AND mhr.no_tonyu = @no_tonyu
		AND mhr.no_kotei = @no_kotei
		AND CONVERT(VARCHAR(10), mhm.dt_from, 111) <= CONVERT(VARCHAR(10), @dt_seizo, 111)
		AND mhr.no_han = (
			SELECT TOP 1
				udf.no_han
			FROM 
				udf_HaigoRecipeYukoHan(@cd_haigo, @flg_mishiyo, @dt_seizo) udf
		) 
	GROUP BY
	    mm.mark
	    ,mhm.nm_haigo_ja
	    ,mhm.nm_haigo_en
	    ,mhm.nm_haigo_zh
		,mhm.nm_haigo_vi
END
GO
