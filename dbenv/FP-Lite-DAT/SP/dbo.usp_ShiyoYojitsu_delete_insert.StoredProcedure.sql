IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShiyoYojitsu_delete_insert') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShiyoYojitsu_delete_insert]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2014.07.22>
-- Description:	使用予実トランの更新処理
--   古いロット番号でDELETEし、新しいロット番号でINSERTする
--   削除キーについて：ロット番号がNULLの場合はキーに含めない。
--     旧製品ロット番号がNULLで旧仕掛品ロットが値ありの場合
--     ・・・予実フラグ、使用日、旧仕掛品ロット番号が一致するものを削除する
-- ==========================================================================
CREATE PROCEDURE [dbo].[usp_ShiyoYojitsu_delete_insert]
    @flg_yojitsu			SMALLINT      -- 予実フラグ
    ,@cd_hinmei				VARCHAR(14)   -- 品名コード
    ,@dt_shiyo				DATETIME      -- 使用日
    ,@old_no_lot_seihin		VARCHAR(14)   -- 旧製品ロット番号(削除対象)
    ,@old_no_lot_shikakari	VARCHAR(14)   -- 旧仕掛品ロット番号(削除対象)
    ,@new_no_lot_seihin		VARCHAR(14)   -- 新製品ロット番号
    ,@new_no_lot_shikakari	VARCHAR(14)   -- 新仕掛品ロット番号
    ,@su_shiyo				DECIMAL(12,6) -- 使用数
    ,@kbn_saiban			VARCHAR(2)    -- 採番区分(使用予実)
    ,@kbn_prefix			VARCHAR(1)    -- プリフィックス(使用予実)

AS

BEGIN

	-- どちらもNULLの場合は、更新処理を行わない
	IF (@old_no_lot_seihin IS NULL) AND (@old_no_lot_shikakari IS NULL)
		RETURN

	-- ==============================
    --  使用予実シーケンス番号を取得
	-- ==============================
    DECLARE @no VARCHAR(14)
    EXEC dbo.usp_cm_Saiban @kbn_saiban, @kbn_prefix, @no_saiban = @no OUTPUT


	-- ========================
    --  使用予実トランDELETE
	-- ========================
	DELETE tr_shiyo_yojitsu
	WHERE dt_shiyo = @dt_shiyo
	AND flg_yojitsu = @flg_yojitsu
	AND cd_hinmei = @cd_hinmei
	AND ((@old_no_lot_seihin IS NULL) OR no_lot_seihin = @old_no_lot_seihin)
	AND ((@old_no_lot_shikakari IS NULL) OR no_lot_shikakari = @old_no_lot_shikakari)


	-- ========================
    --  使用予実トランINSERT
	-- ========================
    INSERT INTO tr_shiyo_yojitsu (
		no_seq
		,flg_yojitsu
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,no_lot_shikakari
		,su_shiyo
	)
    VALUES (
		@no
		,@flg_yojitsu
		,@cd_hinmei
		,@dt_shiyo
		,@new_no_lot_seihin
		,@new_no_lot_shikakari
		,@su_shiyo
	)

END
GO
