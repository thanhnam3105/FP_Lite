IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikakariKeikakuSummaryLabel_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikakariKeikakuSummaryLabel_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kobayashi.y>
-- Create date: <Create Date,,2014.01.10>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ShikakariKeikakuSummaryLabel_update]
    @no_lot_shikakari varchar(14)
    ,@trueFlag smallint
    ,@falseFlag smallint
AS
BEGIN


DECLARE @flg_label_update SMALLINT
DECLARE @flg_label_hasu_update SMALLINT

SELECT @flg_label_update =
	CASE WHEN su_batch_keikaku > 0 THEN @trueFlag
	ELSE @falseFlag END
	,@flg_label_hasu_update = CASE WHEN su_batch_keikaku_hasu  > 0 THEN @trueFlag 
	ELSE @falseFlag END
FROM su_keikaku_shikakari shikakari
WHERE
	no_lot_shikakari = @no_lot_shikakari

 
/********************************
	仕掛品計画サマリー　更新		
********************************/
UPDATE su_keikaku_shikakari
SET
   su_label_sumi = @flg_label_update
   ,flg_label = @flg_label_update
   ,su_label_sumi_hasu = @flg_label_hasu_update
   ,flg_label_hasu = @flg_label_hasu_update
WHERE no_lot_shikakari = @no_lot_shikakari

END
GO
