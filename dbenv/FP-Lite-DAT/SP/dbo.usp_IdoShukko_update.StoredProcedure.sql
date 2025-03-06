IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_IdoShukko_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_IdoShukko_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：移動出庫  更新
ファイル名	：usp_IdoShukko_update
入力引数	：@cd_hinmei, @dt_niuke, @kbn_nyushukko
			  , @flg_kakutei, @cd_update
出力引数	：
戻り値		：
作成日		：2013.10.16  ADMAX endo.y
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_IdoShukko_update] 
    @cd_hinmei			VARCHAR(14)
    ,@dt_niuke			DATETIME
    ,@kbn_nyushukko		SMALLINT
    ,@flg_kakutei		SMALLINT
	,@cd_niuke_basho	VARCHAR(10)
    ,@cd_update			VARCHAR(10)
AS
BEGIN
	DECLARE	@day	SMALLINT
	SET		@day	= 1
	
	UPDATE tr_niuke 
	SET	
		flg_kakutei  = @flg_kakutei
		,cd_update  = @cd_update
		,dt_update  = GETUTCDATE()
	WHERE 
		cd_hinmei = @cd_hinmei 
		AND (@dt_niuke <= dt_niuke AND dt_niuke < (SELECT DATEADD(DD,@day,@dt_niuke)))
		AND kbn_nyushukko = @kbn_nyushukko
		AND cd_niuke_basho = @cd_niuke_basho
END
GO
