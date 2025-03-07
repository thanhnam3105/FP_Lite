IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikakarihinShikomi_ShiyoYojitsu_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikakarihinShikomi_ShiyoYojitsu_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2014.11.05>
-- Description:	仕掛品仕込計画の使用予実トランの削除処理
--   削除キーについて：ロット番号がNULLの場合はキーに含めない。
--     製品ロット番号がNULLで仕掛品ロットが値ありの場合
--     ・・・予実フラグ、使用日、仕掛品ロット番号が一致するものを削除する
-- ==========================================================================
CREATE PROCEDURE [dbo].[usp_ShikakarihinShikomi_ShiyoYojitsu_delete]
    @flg_yojitsu			SMALLINT      -- 予実フラグ
    ,@dt_shiyo				DATETIME      -- 使用日
    ,@no_lot_seihin			VARCHAR(14)   -- 旧製品ロット番号(削除対象)
    ,@no_lot_shikakari		VARCHAR(14)   -- 旧仕掛品ロット番号(削除対象)
AS

BEGIN

	-- どちらもNULLの場合は、更新処理を行わない
	IF (@no_lot_seihin IS NULL) AND (@no_lot_shikakari IS NULL)
		RETURN

	-- ========================
    --  使用予実トランDELETE
	-- ========================
	DELETE tr_shiyo_yojitsu
	WHERE dt_shiyo = @dt_shiyo
	AND flg_yojitsu = @flg_yojitsu
	AND ((@no_lot_seihin IS NULL) OR no_lot_seihin = @no_lot_seihin)
	AND ((@no_lot_shikakari IS NULL) OR no_lot_shikakari = @no_lot_shikakari)



END
GO
