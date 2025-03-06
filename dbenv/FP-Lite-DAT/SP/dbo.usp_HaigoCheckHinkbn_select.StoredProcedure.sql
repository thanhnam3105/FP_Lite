IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoCheckHinkbn_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoCheckHinkbn_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\        �F�z���`�F�b�N�@�i�敪����������
�t�@�C����  �Fusp_HaigoCheckHinkbn_select
���͈���    �F@cd_haigo, @no_kotei, @dt_from
�o�͈���    �F
�߂�l      �F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��      �F2014.08.01 ADMAX endo.y
�X�V��      �F2015.10.20 MJ ueno.k    �����Ɏd�����ǉ��A�d��������L���ŏ����擾�����o
*****************************************************/
CREATE PROCEDURE [dbo].[usp_HaigoCheckHinkbn_select]
    @cd_haigo varchar(14)
    ,@no_kotei decimal(4,0)
    ,@dt_from DATETIME
AS
BEGIN

	SELECT  
		udf.cd_hinmei
		,udf.kbn_hin
	FROM udf_HaigoRecipeYukoHan(@cd_haigo, 0, @dt_from) udf
	WHERE no_kotei = @no_kotei
	ORDER BY udf.no_tonyu
END
GO
