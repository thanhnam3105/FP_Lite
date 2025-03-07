IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeihinKeikaku_Shikakari_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeihinKeikaku_Shikakari_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,sueyoshi.y>
-- Create date: <Create Date,,2013.10.28>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeihinKeikaku_Shikakari_update]
    @data_key VARCHAR(14) -- データ用キー番号(仕掛品トランデータキー)
    ,@dt_seizo DATETIME -- 製造日
    ,@dt_hitsuyo DATETIME -- 必要日
    ,@no_lot_seihin VARCHAR(14) -- 製品ロット番号
    ,@no_lot_shikakari VARCHAR(14) -- 仕掛品ロット番号
    ,@no_lot_shikakari_oya VARCHAR(14) -- 親仕掛品ロット番号
    ,@cd_shokuba VARCHAR(10) -- 職場コード
    ,@cd_line VARCHAR(10) -- ラインコード
    ,@cd_shikakari_hin VARCHAR(14) -- 仕掛品コード
    ,@wt_shikomi_keikaku DECIMAL(12,6) -- 計画仕込重量
    ,@wt_shikomi_jisseki DECIMAL(12,6) -- 実績仕込重量
    ,@su_kaiso_shikomi DECIMAL(4,0) -- 仕込階層数
    --,@dt_update DATETIME -- 更新日時
    ,@wt_haigo_keikaku DECIMAL(12,6) -- 計画配合重量
    ,@wt_haigo_jisseki DECIMAL(12,6) -- 実績配合重量
    ,@su_batch_yotei DECIMAL(12,6) -- 予定バッチ数
    ,@su_batch_jisseki DECIMAL(12,6) -- 実績バッチ数
    ,@ritsu_bai DECIMAL(12,6) -- 倍率
    ,@cd_hinmei VARCHAR(14) -- 品名コード
    ,@wt_hitsuyo DECIMAL(12,6) -- 必要量
    --,@kbn_saiban VARCHAR(2) -- 採番区分(仕掛品計画）
    --,@kbn_prefix VARCHAR(1) -- プリフィックス（仕掛品計画）
    ,@data_key_oya VARCHAR(14) -- 親仕掛データ用キー番号

AS

BEGIN

-- 採番取得
--DECLARE @no_shikakari VARCHAR(14)
--EXEC dbo.usp_cm_Saiban @kbn_saiban, @kbn_prefix, @no_saiban = @no_shikakari OUTPUT

    INSERT INTO tr_keikaku_shikakari
        (data_key
        ,dt_seizo
        ,dt_hitsuyo
        ,no_lot_seihin
        ,no_lot_shikakari
        ,no_lot_shikakari_oya
        ,cd_shokuba
        ,cd_line
        ,cd_shikakari_hin
        ,wt_shikomi_keikaku
        ,wt_shikomi_jisseki
        ,su_kaiso_shikomi
        ,dt_update
        ,wt_haigo_keikaku
        ,wt_haigo_jisseki
        ,su_batch_yotei
        ,su_batch_jisseki
        ,ritsu_bai
        ,cd_hinmei
        ,wt_hitsuyo
        ,data_key_oya)
    VALUES
        (@data_key
        ,@dt_seizo
        ,@dt_hitsuyo
        ,@no_lot_seihin
        ,@no_lot_shikakari
        ,@no_lot_shikakari_oya
        ,@cd_shokuba
        ,@cd_line
        ,@cd_shikakari_hin
        ,@wt_shikomi_keikaku
        ,@wt_shikomi_jisseki
        ,@su_kaiso_shikomi
        ,GETUTCDATE()
        ,@wt_haigo_keikaku
        ,@wt_haigo_jisseki
        ,@su_batch_yotei
        ,@su_batch_jisseki
        ,@ritsu_bai
        ,@cd_hinmei
        ,@wt_hitsuyo
        ,@data_key_oya)

END
GO
