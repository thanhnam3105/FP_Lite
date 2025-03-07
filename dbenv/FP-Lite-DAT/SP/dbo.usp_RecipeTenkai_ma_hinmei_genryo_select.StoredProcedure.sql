IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_RecipeTenkai_ma_hinmei_genryo_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_RecipeTenkai_ma_hinmei_genryo_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,sueyoshi.y>
-- Create date: <Create Date,,2013.11.27>
-- Description:	<Description,,計算時に使用する原料の歩留りを取得する>
-- =============================================
CREATE PROCEDURE [dbo].[usp_RecipeTenkai_ma_hinmei_genryo_select]
    @hinmeiCode VARCHAR(14) -- 品名コード
    ,@mishiyoFlag SMALLINT -- 未使用フラグ
    --,@budomari DECIMAL(5,2) OUTPUT -- 歩留り
AS

BEGIN
    SELECT 
        ritsu_budomari
    FROM 
        ma_hinmei
    WHERE 
        cd_hinmei = @hinmeiCode
        AND flg_mishiyo = @mishiyoFlag 


--DECLARE @var_budomari DECIMAL(5,2)
--DECLARE 
    --cur_budomari CURSOR FOR (
                        --SELECT 
                        --ISNULL(ritsu_budomari, '')
                        --FROM 
                            --ma_hinmei
                        --WHERE 
                            --cd_hinmei = @hinmeiCode
                            --AND flg_mishiyo = @mishiyoFlag 
        --)
    --OPEN cur_budomari
    --FETCH NEXT FROM cur_budomari
    --INTO @var_budomari
    --CLOSE cur_budomari
    --SET @budomari = @var_budomari


END
GO
