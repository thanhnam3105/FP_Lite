IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikakariKeikakuSummaryDelete_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikakariKeikakuSummaryDelete_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2014.03.12>
-- 月間仕掛品計画：削除後の再計算結果の設定処理
-- =============================================
CREATE PROCEDURE [dbo].[usp_ShikakariKeikakuSummaryDelete_update]
	@dt_seizo DATETIME
    ,@cd_shikakari	varchar(14)
	,@cd_shokuba VARCHAR(10)
	,@cd_line VARCHAR(10)
	,@no_lot_shikakari VARCHAR(14)
	,@wt_haigo_keikaku DECIMAL(12,6)
	,@wt_haigo_keikaku_hasu DECIMAL(12,6)
	,@ritsu_keikaku  DECIMAL(12,6)
	,@ritsu_keikaku_hasu  DECIMAL(12,6)
	,@su_batch_keikaku  DECIMAL(12,6)
	,@su_batch_keikaku_hasu DECIMAL(12,6)
AS
BEGIN

/******************************************************************
	仕掛品仕込サマリ　計画配合重量・計画バッチ数・計画倍率の更新
*******************************************************************/
UPDATE su_keikaku_shikakari
SET wt_haigo_keikaku = @wt_haigo_keikaku
	,wt_haigo_keikaku_hasu = @wt_haigo_keikaku_hasu
	,ritsu_keikaku = @ritsu_keikaku
	,ritsu_keikaku_hasu = @ritsu_keikaku_hasu
	,su_batch_keikaku = @su_batch_keikaku
	,su_batch_keikaku_hasu = @su_batch_keikaku_hasu
WHERE 
	dt_seizo = @dt_seizo
	AND no_lot_shikakari = @no_lot_shikakari
	AND cd_shikakari_hin = @cd_shikakari
	AND cd_shokuba = @cd_shokuba
	AND cd_line = @cd_line
	
END
GO
