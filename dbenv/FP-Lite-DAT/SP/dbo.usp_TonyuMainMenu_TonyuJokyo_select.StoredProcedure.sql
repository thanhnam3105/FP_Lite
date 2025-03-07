IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_TonyuMainMenu_TonyuJokyo_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_TonyuMainMenu_TonyuJokyo_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**********************************************************************
機能：投入メインメニュー　投入状況取得処理
ファイル名：usp_TonyuMainMenu_TonyuJokyo_select
入力引数：@FlgKakuteiKakutei, @dt_seizo, @cd_hinmei, @no_lot_seihin
出力引数：-
戻り値：-
作成日：2013.12.19 kasahara.a
更新日：
**********************************************************************/
CREATE PROCEDURE [dbo].[usp_TonyuMainMenu_TonyuJokyo_select]
    @cd_panel VARCHAR(3)
    ,@cd_shokuba VARCHAR(10)
    ,@FlagFalse VARCHAR(1)
    ,@KbnSeikiHasuSeiki VARCHAR(1)
AS
BEGIN

/*-----------------------------------------
    投入状況の取得
-----------------------------------------*/
SELECT
    tj.cd_line
    ,tj.nm_line
    ,tj.cd_haigo
    ,tj.nm_haigo
    ,tj.no_kotei
    ,tj.su_yotei_disp
    ,tj.su_kai_disp
    ,tj.su_yotei
    ,tj.su_kai
    ,tj.no_tonyu
    ,tj.mark
    ,tj.nm_hinmei
    ,tj.wt_kihon
    ,tj.no_lot_seihin
    ,tj.kbn_seikihasu
    ,tj.kbn_jokyo
FROM udf_TonyuJokyo(@cd_panel, @cd_Shokuba, @FlagFalse, @KbnSeikiHasuSeiki) tj

END
GO
