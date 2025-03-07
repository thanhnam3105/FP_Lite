IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikakarihinKeikaku_DeleteLot_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikakarihinKeikaku_DeleteLot_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_ShikakarihinKeikaku_DeleteLot_select]
	@lot VARCHAR(14)
AS

	SELECT no_lot_shikakari
	FROM tr_keikaku_shikakari
	WHERE no_lot_shikakari_oya = @lot
	GROUP BY no_lot_shikakari
GO
