IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_YukoHaigoMeiSeihin_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_YukoHaigoMeiSeihin_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kobayashi.y>
-- Create date: <Create Date,,2014.01.20>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_YukoHaigoMeiSeihin_select]
	@haigoCode VARCHAR(14)	-- 配合コード
    ,@seizoDate DATETIME	-- 製造日（有効版取得のため）
    ,@falseFlag SMALLINT	-- 使用フラグ：使用
    ,@masterKbn SMALLINT	-- 品区分：仕掛品
AS

	SELECT TOP 1 
		 mei.cd_haigo
		,mei.dd_shomi
		,mei.nm_haigo_en
		,mei.nm_haigo_ja
		,mei.nm_haigo_zh
		,mei.nm_haigo_vi
		,mei.flg_shorihin
		,COALESCE(mei.su_kowake, 0) AS su_kowake
		,COALESCE(mei.wt_kowake, 0) AS wt_kowake
		,mei.kbn_hokan
		,hokan.nm_hokan_kbn
		,hinkbn.nm_kbn_hin
		,(select nm_kbn from udf_ChuiKankiShiyo(mei.cd_haigo, 1, 1, 0, @masterKbn))        AS kbnAllergy
		,(select nm_chui_kanki from udf_ChuiKankiShiyo(mei.cd_haigo, 1, 1, 0, @masterKbn)) AS nm_Allergy
		,(select nm_kbn from udf_ChuiKankiShiyo(mei.cd_haigo, 9, 1, 0, @masterKbn))        AS kbnOther
		,(select nm_chui_kanki from udf_ChuiKankiShiyo(mei.cd_haigo, 9, 1, 0, @masterKbn)) AS nm_Other
		,yuko.cd_mark
	FROM ma_haigo_mei mei

	INNER JOIN 
	(
		SELECT DISTINCT
			udf.cd_haigo
			,udf.no_han
			,udf.cd_mark
			FROM udf_HaigoRecipeYukoHan
			(
				@haigoCode, @falseFlag, @seizoDate
			) udf
	) yuko
	ON mei.cd_haigo = yuko.cd_haigo
	AND mei.no_han = yuko.no_han

	LEFT OUTER JOIN ma_kbn_hokan hokan
	ON mei.kbn_hokan = hokan.cd_hokan_kbn
	AND hokan.flg_mishiyo = @falseFlag

	LEFT OUTER JOIN ma_kbn_hin hinkbn
	ON hinkbn.kbn_hin = @masterKbn

	WHERE mei.dd_shomi IS NOT NULL
	ORDER BY 
		mei.dd_shomi
GO
