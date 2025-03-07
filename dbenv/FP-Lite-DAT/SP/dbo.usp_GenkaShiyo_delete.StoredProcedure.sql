IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenkaShiyo_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenkaShiyo_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:      tsujita.s
-- Create date: 2014.08.26
-- Description: 原価使用トランの削除処理
-- ===============================================
CREATE PROCEDURE [dbo].[usp_GenkaShiyo_delete]
	@no_lot_seihin		varchar(14)		-- 削除キー：製品ロット番号
	,@no_seq			varchar(14)		-- 削除キー：シーケンス番号
AS
BEGIN

	SET NOCOUNT ON

	-- 製品ロット番号に値があれば、製品ロット番号で削除する
	IF @no_lot_seihin IS NOT NULL
	BEGIN
		DELETE tr_shiyo_genka
		WHERE no_lot_seihin = @no_lot_seihin
	END

	-- 上記以外はシーケンス番号で削除する
	ELSE BEGIN
		DELETE tr_shiyo_genka
		WHERE no_seq = @no_seq
	END

END
GO
