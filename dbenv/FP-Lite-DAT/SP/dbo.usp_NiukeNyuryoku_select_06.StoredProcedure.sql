IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_select_06') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_select_06]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*****************************************************
機能        ：荷受入力　返品済みを検索する
ファイル名  ：usp_NiukeNyuryoku_select_06
入力引数    ：@no_niuke
出力引数    ：
戻り値      ：
作成日      ：2020.03.02  BRC Sato.t
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_select_06] 
    @no_niuke        VARCHAR(14)
AS
BEGIN
    SELECT
       no_niuke
    FROM
        tr_niuke
    WHERE
        no_niuke = @no_niuke
        AND kbn_nyushukko = '8'
END

GO
