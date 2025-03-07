IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeihinKeikaku_Shizai_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeihinKeikaku_Shizai_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:		sueyoshi.y
-- Create date: 2013.09.05
-- Description:	品名コードから使用資材一覧取得
-- args:	@hinmeiCode,@suryo,@shokubaCode,@seizoDate 画面の項目
-- =======================================================
CREATE PROCEDURE [dbo].[usp_SeihinKeikaku_Shizai_select]
    @hinmeiCode varchar(14)
    ,@suryo decimal
    ,@shokubaCode varchar(10)
    ,@seizoDate datetime
	,@falseFlag smallint
AS

    SELECT  
        @hinmeiCode cd_hinmei
        ,@shokubaCode cd_shokuba
        ,@seizoDate dt_seizo
        ,@suryo su_suryo
        ,shiyo.cd_shizai 
        ,shiyo.su_shiyo
        ,0 AS su_kaiso
        ,COALESCE(shizai.ritsu_budomari, 0.00) AS ritsu_budomari
    FROM
		ma_hinmei seihin
    LEFT OUTER JOIN udf_ShizaiShiyoYukoHan(@hinmeiCode, @falseFlag ,@seizoDate) shiyo
    ON seihin.cd_hinmei = shiyo.cd_hinmei
    
    LEFT OUTER JOIN ma_hinmei shizai
    ON shiyo.cd_shizai = shizai.cd_hinmei
    
    WHERE seihin.flg_mishiyo = @falseFlag
    AND seihin.cd_hinmei = @hinmeiCode
GO
