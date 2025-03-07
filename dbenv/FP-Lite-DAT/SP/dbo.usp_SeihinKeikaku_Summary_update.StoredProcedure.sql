IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeihinKeikaku_Summary_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeihinKeikaku_Summary_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,sueyoshi.y>
-- Create date: <Create Date,,2013.10.23>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeihinKeikaku_Summary_update]
    @dt_seizo DATETIME                      -- 製造日
    ,@cd_shikakari_hin VARCHAR(14)          -- 仕掛品コード
    ,@cd_shokuba VARCHAR(10)                -- 職場コード
    ,@cd_line VARCHAR(10)                   -- ラインコード
    ,@wt_hitsuyo DECIMAL(12,6)              -- 必要重量
    ,@wt_shikomi_keikaku DECIMAL(12,6)      -- 計画仕込重量
    ,@wt_shikomi_jisseki DECIMAL(12,6)      -- 実績仕込重量
    ,@wt_zaiko_keikaku DECIMAL(12,6)        -- 計画在庫重量
    ,@wt_zaiko_jisseki DECIMAL(12,6)        -- 実績在庫重量
    ,@wt_shikomi_zan DECIMAL(12,6)          -- 残仕込重量
    ,@wt_haigo_keikaku DECIMAL(12,6)        -- 計画配合重量
    ,@wt_haigo_keikaku_hasu DECIMAL(12,6)   -- 計画配合重量端数
    ,@su_batch_keikaku DECIMAL(12,6)        -- 計画バッチ数
    ,@su_batch_keikaku_hasu DECIMAL(12,6)   -- 計画バッチ端数
    ,@ritsu_keikaku DECIMAL(12,6)           -- 計画倍率
    ,@ritsu_keikaku_hasu DECIMAL(12,6)      -- 計画倍率端数
    ,@wt_haigo_jisseki DECIMAL(12,6)        -- 実績配合重量
    ,@wt_haigo_jisseki_hasu DECIMAL(12,6)   -- 実績配合重量端数
    ,@su_batch_jisseki DECIMAL(12,6)        -- 実績バッチ数
    ,@su_batch_jisseki_hasu DECIMAL(12,6)   -- 実績バッチ端数
    ,@ritsu_jisseki DECIMAL(12,6)           -- 実績倍率
    ,@ritsu_jisseki_hasu DECIMAL(12,6)      -- 実績倍率端数
    ,@su_label_sumi DECIMAL(4,0)            -- 印刷済ラベル数
    ,@flg_label SMALLINT                    -- ラベル発行フラグ
    ,@su_label_sumi_hasu DECIMAL(4,0)       -- 印刷済ラベル端数
    ,@flg_label_hasu SMALLINT               -- ラベル発行フラグ(端数)
    ,@flg_keikaku SMALLINT                  -- 計画確定フラグ
    ,@flg_jisseki SMALLINT                  -- 実績確定フラグ
    ,@flg_shusei SMALLINT                   -- 修正フラグ
    ,@no_lot_shikakari VARCHAR(14)          -- 仕掛品ロット番号
    ,@flg_shikomi SMALLINT                  -- 仕込フラグ
AS

BEGIN
    INSERT INTO su_keikaku_shikakari
    (
    dt_seizo
    ,cd_shikakari_hin
    ,cd_shokuba
    ,cd_line
    ,wt_hitsuyo
    ,wt_shikomi_keikaku
    ,wt_shikomi_jisseki
    ,wt_zaiko_keikaku
    ,wt_zaiko_jisseki
    ,wt_shikomi_zan
    ,wt_haigo_keikaku
    ,wt_haigo_keikaku_hasu
    ,su_batch_keikaku
    ,su_batch_keikaku_hasu
    ,ritsu_keikaku
    ,ritsu_keikaku_hasu
    ,wt_haigo_jisseki
    ,wt_haigo_jisseki_hasu
    ,su_batch_jisseki
    ,su_batch_jisseki_hasu
    ,ritsu_jisseki
    ,ritsu_jisseki_hasu
    ,su_label_sumi
    ,flg_label
    ,su_label_sumi_hasu
    ,flg_label_hasu
    ,flg_keikaku
    ,flg_jisseki
    ,flg_shusei
    ,no_lot_shikakari
    ,flg_shikomi
    )   
    VALUES (
    @dt_seizo
    ,@cd_shikakari_hin
    ,@cd_shokuba
    ,@cd_line
    ,@wt_hitsuyo
    ,@wt_shikomi_keikaku
    ,@wt_shikomi_jisseki
    ,@wt_zaiko_keikaku
    ,@wt_zaiko_jisseki
    ,@wt_shikomi_zan
    ,@wt_haigo_keikaku
    ,@wt_haigo_keikaku_hasu
    ,@su_batch_keikaku
    ,@su_batch_keikaku_hasu
    ,@ritsu_keikaku
    ,@ritsu_keikaku_hasu
    ,@wt_haigo_jisseki
    ,@wt_haigo_jisseki_hasu
    ,@su_batch_jisseki
    ,@su_batch_jisseki_hasu
    ,@ritsu_jisseki
    ,@ritsu_jisseki_hasu
    ,@su_label_sumi
    ,@flg_label
    ,@su_label_sumi_hasu
    ,@flg_label_hasu
    ,@flg_keikaku
    ,@flg_jisseki
    ,@flg_shusei
    ,@no_lot_shikakari
    ,@flg_shikomi)

END
GO
