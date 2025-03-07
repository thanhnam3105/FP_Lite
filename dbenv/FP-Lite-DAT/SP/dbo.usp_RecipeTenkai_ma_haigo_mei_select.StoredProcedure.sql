IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_RecipeTenkai_ma_haigo_mei_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_RecipeTenkai_ma_haigo_mei_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,sueyoshi.y>
-- Create date: <Create Date,,2013.11.222>
-- Description:	<Description,,配合名マスタの項目なので一件になる>
-- =============================================
CREATE PROCEDURE [dbo].[usp_RecipeTenkai_ma_haigo_mei_select]
    @haigoCode VARCHAR(14)  -- 配合コード
    ,@seizoDate DATETIME    -- 製造日（有効版取得のため）
    ,@falseFlag SMALLINT
AS

SELECT 
DISTINCT
    cd_haigo
    ,ritsu_budomari_mei
    ,ritsu_kihon
    ,wt_haigo_gokei
    ,flg_gassan_shikomi
    ,no_han
FROM 
    udf_HaigoRecipeYukoHan(@haigoCode, @falseFlag, @seizoDate)
GO
