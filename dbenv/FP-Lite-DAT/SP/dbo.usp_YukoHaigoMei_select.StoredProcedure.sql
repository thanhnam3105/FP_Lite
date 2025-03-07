IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_YukoHaigoMei_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_YukoHaigoMei_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kobayashi.y>
-- Create date: <Create Date,,2013.12.11>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_YukoHaigoMei_select]
    @haigoCode VARCHAR(14)  -- 配合コード
    ,@seizoDate DATETIME    -- 製造日（有効版取得のため）
    ,@falseFlag SMALLINT
AS

SELECT 
DISTINCT
    udf.cd_haigo
    ,udf.nm_haigo_ja
    ,udf.nm_haigo_en
    ,udf.nm_haigo_zh
	,udf.nm_haigo_vi
    ,udf.ritsu_budomari_mei
    ,udf.ritsu_kihon
    ,udf.wt_haigo_gokei
    ,udf.flg_gassan_shikomi
    ,udf.kbn_kanzan
    ,tani.nm_tani
FROM 
    udf_HaigoRecipeYukoHan(@haigoCode, @falseFlag, @seizoDate) udf
    LEFT OUTER JOIN ma_tani tani
    ON udf.kbn_kanzan = tani.cd_tani
    AND tani.flg_mishiyo = @falseFlag
GO
