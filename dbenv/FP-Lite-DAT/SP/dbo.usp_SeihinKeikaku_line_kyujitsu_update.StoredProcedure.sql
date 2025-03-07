IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeihinKeikaku_line_kyujitsu_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeihinKeikaku_line_kyujitsu_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,sueyoshi.y>
-- Create date: <Create Date,,2013.12.16>
-- Description:	<Description,,>
-- Update date：2018.07.30 nakamura.r
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeihinKeikaku_line_kyujitsu_update]
    @cd_line	VARCHAR(10)     --	ラインコード
    ,@dt_seizo	DATETIME		--	製造日
    ,@cd_riyu	VARCHAR(10)     --	理由コード
    ,@cd_update	VARCHAR(10)      --	更新者
	,@kbn_riyu_kaijo VARCHAR(1) -- 理由解除区分

AS

BEGIN
    --DECLARE @updateCount int

    -- ライン、日付ごとに削除
    DELETE tr_line_kyujitsu
    WHERE 
        cd_line = @cd_line
        AND dt_seizo = @dt_seizo

    BEGIN
    IF @cd_riyu <> @kbn_riyu_kaijo 
        INSERT INTO tr_line_kyujitsu(
        	cd_line
        	,dt_seizo
        	,cd_riyu
        	,cd_update
        	,dt_update
        )
        VALUES (
            @cd_line
            ,@dt_seizo
            ,@cd_riyu
            ,@cd_update
            ,GETUTCDATE()
        )
    END

END
GO
