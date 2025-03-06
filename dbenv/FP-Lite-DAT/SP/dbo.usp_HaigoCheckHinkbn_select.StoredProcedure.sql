IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoCheckHinkbn_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoCheckHinkbn_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：配合チェック　品区分を検索する
ファイル名  ：usp_HaigoCheckHinkbn_select
入力引数    ：@cd_haigo, @no_kotei, @dt_from
出力引数    ：
戻り値      ：成功時[0] 失敗時[0以外のエラーコード]
作成日      ：2014.08.01 ADMAX endo.y
更新日      ：2015.10.20 MJ ueno.k    引数に仕込日追加、仕込日から有効版情報を取得し抽出
*****************************************************/
CREATE PROCEDURE [dbo].[usp_HaigoCheckHinkbn_select]
    @cd_haigo varchar(14)
    ,@no_kotei decimal(4,0)
    ,@dt_from DATETIME
AS
BEGIN

	SELECT  
		udf.cd_hinmei
		,udf.kbn_hin
	FROM udf_HaigoRecipeYukoHan(@cd_haigo, 0, @dt_from) udf
	WHERE no_kotei = @no_kotei
	ORDER BY udf.no_tonyu
END
GO
