IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_YukoHaigoMeiCommon_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_YukoHaigoMeiCommon_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\        �F�L���ł̔z�����}�X�^�擾����
�t�@�C����  �Fusp_YukoHaigoMeiCommon_select
���͈���    �F@cd_haigo
            �F@flg_mishiyo
            �F@dt_from
�o�͈���    �F
�߂�l      �F
�쐬��      �F2019.01.15  BRC motojima.m
�X�V��      �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_YukoHaigoMeiCommon_select] 
	@cd_haigo				VARCHAR(14)		-- �z���R�[�h
	,@flg_mishiyo			SMALLINT		-- ���g�p�t���O
	,@dt_from				DATETIME		-- ���

AS
BEGIN
	SELECT DISTINCT
		ma.cd_haigo
		, ma.nm_haigo_ja
		, ma.nm_haigo_en
		, ma.nm_haigo_zh
		, ma.nm_haigo_vi
		, ma.nm_haigo_ryaku
		, ma.ritsu_budomari
		, ma.wt_kihon
		, ma.ritsu_kihon
		, ma.flg_gassan_shikomi
		, ma.wt_saidai_shikomi
		, ma.no_han
		, ma.wt_haigo
		, ma.wt_haigo_gokei
		, ma.biko
		, ma.no_seiho
		, ma.cd_tanto_seizo
		, ma.dt_seizo_koshin
		, ma.cd_tanto_hinkan
		, ma.dt_hinkan_koshin
		, ma.dt_from
		, ma.kbn_kanzan
		, ma.ritsu_hiju
		, ma.flg_shorihin
		, ma.flg_tanto_hinkan
		, ma.flg_tanto_seizo
		, ma.kbn_shiagari
		, ma.cd_bunrui
		, ma.flg_mishiyo
		, ma.dt_create
		, ma.cd_create
		, ma.dt_update
		, ma.cd_update
		, ma.wt_kowake
		, ma.su_kowake
		, ma.ts
		, ma.flg_tenkai
		, ma.dd_shomi
		, ma.kbn_hokan
	FROM
		ma_haigo_mei ma
		INNER JOIN udf_HaigoRecipeYukoHan(@cd_haigo, @flg_mishiyo, @dt_from) udf ON
			ma.cd_haigo = udf.cd_haigo	
			AND ma.no_han = udf.no_han

END
