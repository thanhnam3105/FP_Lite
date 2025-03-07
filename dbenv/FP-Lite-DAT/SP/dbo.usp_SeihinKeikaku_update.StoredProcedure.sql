IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeihinKeikaku_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeihinKeikaku_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,sueyoshi.y>
-- Create date: <Create Date,,2013.10.23>
-- Last Update: <2014.09.30, tsujita.s>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeihinKeikaku_update]
    @no_lot_seihin VARCHAR(14) -- 製品ロット番号
    ,@dt_seizo DATETIME -- 製造日
    ,@cd_shokuba VARCHAR(10) -- 職場コード
    ,@cd_line VARCHAR(10) -- ラインコード
    ,@cd_hinmei VARCHAR(14) -- 品名コード
    ,@su_seizo_yotei DECIMAl(10,0) -- 製造予定数
    ,@flg_jisseki SMALLINT -- 実績確定フラグ
    ,@kbn_denso SMALLINT -- 伝送区分
    ,@flg_denso SMALLINT -- 伝送フラグ
    ,@su_batch DECIMAl(4,0) -- バッチ数
AS
BEGIN

    DECLARE @updateCount int

    UPDATE tr_keikaku_seihin
    SET 
        no_lot_seihin = @no_lot_seihin
        ,dt_seizo = @dt_seizo
        ,cd_shokuba = @cd_shokuba
        ,cd_line = @cd_line
        ,cd_hinmei = @cd_hinmei
        ,su_seizo_yotei = @su_seizo_yotei
        ,dt_update = GETUTCDATE()
        ,su_batch_keikaku = @su_batch
    WHERE 
        no_lot_seihin = @no_lot_seihin
    
-- 更新件数が0件の場合は新規登録
    SET @updateCount = @@ROWCOUNT
    IF @updateCount = 0
    BEGIN
        INSERT INTO tr_keikaku_seihin
        (
            no_lot_seihin
            ,dt_seizo
            ,cd_shokuba
            ,cd_line
            ,cd_hinmei
            ,su_seizo_yotei
            ,su_seizo_jisseki
            ,flg_jisseki
            ,kbn_denso
            ,flg_denso
            ,dt_update
            ,su_batch_keikaku
        )
        VALUES
        (
            @no_lot_seihin
            ,@dt_seizo
            ,@cd_shokuba
            ,@cd_line
            ,@cd_hinmei
            ,@su_seizo_yotei
            ,null
            ,@flg_jisseki
            ,@kbn_denso
            ,@flg_denso
            ,GETUTCDATE()
            ,@su_batch
        )
    END

END
GO
