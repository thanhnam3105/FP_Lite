IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShiyoYojitsu_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShiyoYojitsu_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================
-- Author:		<Author,,cho.K>
-- Create date: <Create Date,,2016.11.22>
-- Description:	使用予実トランの削除
-- ==========================================================================
CREATE PROCEDURE [dbo].[usp_ShiyoYojitsu_delete]
    @flg_yojitsu		SMALLINT      -- 予実フラグ
    ,@no_lot_shikakari	VARCHAR(14)   -- 仕掛品ロット番号

AS

BEGIN

	-- どちらもNULLの場合は、更新処理を行わない
	IF (@no_lot_shikakari IS NULL)
		RETURN

	-- ========================
    --  使用予実トランDELETE
	-- ========================
	DELETE FROM tr_shiyo_yojitsu
	WHERE flg_yojitsu = @flg_yojitsu
	AND no_lot_shikakari = @no_lot_shikakari

END
GO
