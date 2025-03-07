IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeihinKeikaku_SummaryLot_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeihinKeikaku_SummaryLot_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,sueyoshi.y>
-- Create date: <Create Date,,2013.12.09>
-- Description:	<Description,,仕掛ロット番号を元に関連データを削除>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeihinKeikaku_SummaryLot_delete]
	@lotNo varchar(14)
AS

-- 仕掛品計画サマリの削除
DELETE FROM su_keikaku_shikakari
WHERE no_lot_shikakari = @lotNo
GO
