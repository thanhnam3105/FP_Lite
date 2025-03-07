IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KeikakuShogo_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KeikakuShogo_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：計画照合 投入計画トラン削除
ファイル名	：usp_KeikakuShogo_delete01
入力引数	：@cd_panel, @cd_shokuba, @cd_line
出力引数	：
戻り値		：
作成日		：2013.11.21  ADMAX endo.y
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KeikakuShogo_delete]
	@cd_panel		VARCHAR(3)
	,@cd_shokuba	VARCHAR(10)
	,@cd_line		VARCHAR(10)

AS
BEGIN
	DELETE FROM tr_tonyu_keikaku
	WHERE
		cd_panel = @cd_panel
		AND cd_shokuba = @cd_shokuba
		AND cd_line = @cd_line
END
GO
