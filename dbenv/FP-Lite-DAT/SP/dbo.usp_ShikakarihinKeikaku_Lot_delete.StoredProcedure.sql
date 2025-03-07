IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikakarihinKeikaku_Lot_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikakarihinKeikaku_Lot_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,sueyoshi.y>
-- Create date: <Create Date,,2013.12.03>
-- Update date: 2014.07.23 tsujita.s
-- Description:	<Description,,仕掛品ロット番号を元に関連データを削除>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ShikakarihinKeikaku_Lot_delete]
    @dataKey varchar(1000)
    ,@lotList varchar(1000)
    ,@oyaShikakariLot varchar(14)
    ,@seihinLot varchar(14)
AS

BEGIN

	-- ========================================
	--  パラメーターのロット番号に値がある場合
	-- ========================================
	IF @lotList IS NOT NULL
	BEGIN
		-- 仕掛品トランの削除
		DELETE FROM tr_keikaku_shikakari
		WHERE no_lot_shikakari
			IN (SELECT id FROM udf_SplitCommaValue(@lotList))
		AND no_lot_shikakari_oya = @oyaShikakariLot

		-- 使用予実トランの削除
		DELETE FROM tr_shiyo_yojitsu
		WHERE no_lot_shikakari 
			IN (SELECT id FROM udf_SplitCommaValue(@lotList))
		AND ((@seihinLot IS NULL AND no_lot_seihin IS NULL)
			  OR no_lot_seihin = @seihinLot)
	END

	-- ========================================================
	--  パラメーターのデータキー(シーケンス番号)に値がある場合
	-- ========================================================
	IF @dataKey IS NOT NULL
	BEGIN
		-- 仕掛品トランの削除
		DELETE FROM tr_keikaku_shikakari
		WHERE data_key
			IN (SELECT id FROM udf_SplitCommaValue(@dataKey))

		-- 使用予実トランの削除
		DELETE FROM tr_shiyo_yojitsu
		WHERE data_key_tr_shikakari 
			IN (SELECT id FROM udf_SplitCommaValue(@dataKey))
	END

END
GO
