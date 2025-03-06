IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShiyoYojitsuAnbunTran_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShiyoYojitsuAnbunTran_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================
-- Author     :	tsujita.s
-- Create date: 2015.07.08
-- Last Update: 2015.07.09 tsujita.s
-- Description: 使用予実按分トランの削除処理：仕掛品ロット番号で一括削除
-- =======================================================================
CREATE PROCEDURE [dbo].[usp_ShiyoYojitsuAnbunTran_delete]
	@no_lot_shikakari	varchar(14)	-- 削除条件：仕掛品ロット番号
	,@no_lot_seihin		varchar(14)	-- 削除条件：製品ロット番号
AS
BEGIN

	-- 製品ロット番号が存在する場合：製造日報からの削除時
	IF LEN(@no_lot_seihin) > 0
	BEGIN
		-- 製品ロット番号から仕掛品ロット番号を取得し、関連する按分トランをすべて削除する
		DELETE
			tr_sap_shiyo_yojitsu_anbun
		WHERE
			no_lot_shikakari IN (
				SELECT no_lot_shikakari
				FROM vw_tr_sap_shiyo_yojitsu_anbun_02
				WHERE no_lot_seihin = @no_lot_seihin
				GROUP BY no_lot_shikakari

				--SELECT
				--	shikakari.no_lot_shikakari
				--FROM
				--	tr_sap_shiyo_yojitsu_anbun seihin
				--LEFT JOIN tr_sap_shiyo_yojitsu_anbun shikakari
				--ON seihin.no_lot_shikakari = shikakari.no_lot_shikakari
				--WHERE
				--	seihin.no_lot_seihin = @no_lot_seihin
				--GROUP BY shikakari.no_lot_shikakari
			)
	END
	ELSE BEGIN
		-- 仕込日報からの削除時：仕掛品ロット番号で一括削除
		DELETE
			tr_sap_shiyo_yojitsu_anbun
		WHERE
			no_lot_shikakari = @no_lot_shikakari
	END

END
GO
