IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SokoIdoKanri_update_seq]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_SokoIdoKanri_update_seq]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能			：Page SokoIdoKanri: update no_seq
ファイル名	：usp_SokoIdoKanri_update_seq
作成日		：2018.07.15  thien.nh
更新日		：2018.07.24  thien.nh
*****************************************************/
CREATE PROC [dbo].[usp_SokoIdoKanri_update_seq]
	@kbn_zaiko				SMALLINT		-- 明細.在庫区分
	,@no_niuke				VARCHAR(14)		-- 明細.荷受番号(非表示)
	,@max_seq				DECIMAL(8,0)	-- 明細.シーケンス番号最大値(非表示)
	,@max_dt_niuke			DATETIME		-- 明細.荷受日の最大値(非表示)
	,@count_no_seq			DECIMAL(8,0)	-- row count data
	,@flg_ido				SMALLINT		-- value = 0, 1
AS 
	-- 後続データのシーケンス番号をずらします。
	
DECLARE  @flgTrue		SMALLINT = 1
		,@flgFlase		SMALLINT = 0
	UPDATE tr_niuke
		SET no_seq = no_seq  + @count_no_seq
	WHERE no_niuke = @no_niuke
		AND 
		(
			no_seq > @max_seq  AND @flg_ido = @flgTrue
			OR
			no_seq >= @max_seq  AND @flg_ido = @flgFlase
		)

GO
