IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SokoIdoKanri_delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_SokoIdoKanri_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能			：Page SokoIdoKanri: delete data
ファイル名	：usp_SokoIdoKanri_delete
作成日		：2018.07.25  thien.nh
更新日		：2018.07.25  thien.nh
*****************************************************/
CREATE PROC [dbo].[usp_SokoIdoKanri_delete]
	-- primary key
	@no_niuke			VARCHAR(14)
	,@no_seq			DECIMAL(8)

	,@idodeKbn			SMALLINT		-- 【入出庫区分】　移動出 = 11
	,@idoiriKbn			SMALLINT		-- 【入出庫区分】　移動入 = 12
AS
	-- delete data selected
	DELETE FROM tr_niuke
	WHERE 
		no_niuke	= @no_niuke
		AND no_seq	= @no_seq
		AND kbn_nyushukko IN (@idodeKbn, @idoiriKbn)
	
	-- update data no_seq afer
	UPDATE tr_niuke
	SET
		no_seq = no_seq - 1
	WHERE
		no_niuke	= @no_niuke
		AND no_seq	> @no_seq

GO
