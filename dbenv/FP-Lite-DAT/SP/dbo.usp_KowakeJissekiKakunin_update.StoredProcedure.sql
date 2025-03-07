IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KowakeJissekiKakunin_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KowakeJissekiKakunin_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：小分実績確認 更新
ファイル名	：usp_KowakeJissekiKakunin_update
入力引数	：@no_lot_kowake, @no_lot_oya, @flg_haki
出力引数	：	
戻り値		：
作成日		：2013.10.15  ADMAX kakuta.y
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KowakeJissekiKakunin_update] 
	@no_lot_kowake	VARCHAR(14)
	,@no_lot_oya	VARCHAR(14)
	,@flg_haki		SMALLINT		-- 投入完了フラグ
AS
BEGIN
	SET NOCOUNT ON;
	IF @no_lot_oya IS NULL -- ロット切り替えなし
	OR @no_lot_oya = ''
	BEGIN
		UPDATE tr_kowake
		SET
			flg_kanryo_tonyu = @flg_haki
		WHERE
			no_lot_kowake = @no_lot_kowake
	END
	ELSE -- ロット切り替えあり
	BEGIN
		UPDATE tr_kowake
		SET
			flg_kanryo_tonyu = @flg_haki
		WHERE
			no_lot_oya = @no_lot_oya -- 親ロット番号が同じもの全てに更新をかける
	END
END
GO
