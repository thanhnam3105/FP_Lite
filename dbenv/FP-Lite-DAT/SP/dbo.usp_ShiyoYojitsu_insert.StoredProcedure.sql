IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShiyoYojitsu_insert') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShiyoYojitsu_insert]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================
-- Author:		<Author,,cho.k>
-- Create date: <Create Date,,2016.11.22>
-- Description:	使用予実トランの登録処理
-- ==========================================================================
CREATE PROCEDURE [dbo].[usp_ShiyoYojitsu_insert]
    @flg_yojitsu			SMALLINT      -- 予実フラグ
    ,@cd_hinmei				VARCHAR(14)   -- 品名コード
    ,@dt_shiyo				DATETIME      -- 使用日
    ,@no_lot_seihin			VARCHAR(14)   -- 製品ロット番号
    ,@no_lot_shikakari		VARCHAR(14)   -- 仕掛品ロット番号
    ,@su_shiyo				DECIMAL(12,6) -- 使用数
    ,@kbn_saiban			VARCHAR(2)    -- 採番区分(使用予実)
    ,@kbn_prefix			VARCHAR(1)    -- プリフィックス(使用予実)

AS

BEGIN

	-- どちらもNULLの場合は、更新処理を行わない
	IF (@no_lot_shikakari IS NULL)
		RETURN

	-- ==============================
    --  使用予実シーケンス番号を取得
	-- ==============================
    DECLARE @no VARCHAR(14)
    EXEC dbo.usp_cm_Saiban @kbn_saiban, @kbn_prefix, @no_saiban = @no OUTPUT


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
		,@no_lot_seihin
		,@no_lot_shikakari
		,@su_shiyo
	)

END
GO
