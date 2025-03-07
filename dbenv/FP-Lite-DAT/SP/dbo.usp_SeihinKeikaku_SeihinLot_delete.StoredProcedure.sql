IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeihinKeikaku_SeihinLot_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeihinKeikaku_SeihinLot_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,sueyoshi.y>
-- Create date: <Create Date,,2014.1.1>
-- Description:	<Description,,製品ロット番号で製品計画を削除>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeihinKeikaku_SeihinLot_delete]
	@lotNo VARCHAR(14)
AS

-- 製品計画トランの削除
DELETE FROM tr_keikaku_seihin
WHERE 
    no_lot_seihin = @lotNo
GO
