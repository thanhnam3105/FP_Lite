IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_Hyoryo_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_Hyoryo_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：秤量画面　実績登録
ファイル名	：usp_Hyoryo_create
入力引数	：@no_lot_jisseki, @no_lot, @wt_jisseki, @dt_shomi
			  , @dt_shomi_kaifu, @dt_seizo, @dt_seizo_genryo
			  , @cd_panel, @cd_hakari, @cd_seihin, @nm_seihin
			  , @cd_hinmei, @nm_hinmei, @no_kotei, @su_ko
			  , @su_kai, @no_tonyu, @qty_haigo, @cd_line
			  , @cd_maker, @cd_tanto_kowake, @no_lot_oya
			  , @no_lot_seihin, @kbn_saiban, @kbn_prefix
			  , @ritsu_kihon
出力引数	：なし
戻り値		：
作成日		：2013.10.31  ADMAX okuda.k
更新日		：2015.08.05  ADMAX kakuta.y 品区分を追加
更新日		：2016.12.13  BRC   motojima.m 中文対応
更新日		：2017.04.26  BRC   kanehira.d Q&Bサポート対応No.56
更新日  	：2018.02.26  BRC   yokota.t   解凍ラベル対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_Hyoryo_create]
	@no_lot_jisseki		VARCHAR(14)
	,@no_lot			VARCHAR(14)
	,@wt_jisseki		DECIMAL(12,6)
	,@dt_shomi			DATETIME
	,@dt_shomi_kaifu	DATETIME
	,@dt_seizo			DATETIME
	,@dt_seizo_genryo	DATETIME
	,@cd_panel			VARCHAR(3)
	,@cd_hakari			VARCHAR(10)
	,@cd_seihin			VARCHAR(14)
	--,@nm_seihin		VARCHAR(50)
	,@nm_seihin			NVARCHAR(50)
	,@cd_hinmei			VARCHAR(14)
	--,@nm_hinmei		VARCHAR(50)
	,@nm_hinmei			NVARCHAR(50)
	,@no_kotei			DECIMAL(4)
	,@su_ko				DECIMAL(4)
	,@su_kai			DECIMAL(4)
	,@no_tonyu			DECIMAL(4)
	,@qty_haigo			DECIMAL(12,6)
	,@cd_line			VARCHAR(10)
	,@cd_maker			VARCHAR(20)
	,@cd_tanto_kowake	VARCHAR(10)
	,@no_lot_oya		VARCHAR(14)
	,@no_lot_seihin		VARCHAR(14)
	,@kbn_saiban		VARCHAR(2)
	,@kbn_prefix		VARCHAR(1)
	,@kbn_seikihasu		SMALLINT
	,@kbn_hin			SMALLINT
	,@kbn_kowakehasu	SMALLINT
	,@ritsu_kihon       DECIMAL(5,2)
	,@dt_shomi_kaito	DATETIME
	
AS
BEGIN

	INSERT INTO tr_lot
	    (
			no_lot_jisseki
			,no_lot
		    ,wt_jisseki
			,dt_shomi
			,dt_shomi_kaifu
			,dt_seizo_genryo
			,dt_shomi_kaito
		)
	VALUES
		(
		    @no_lot_jisseki
		    ,@no_lot
		    ,@wt_jisseki
	    	,@dt_shomi
	    	,@dt_shomi_kaifu
			,@dt_seizo_genryo
			,@dt_shomi_kaito
		)

    INSERT INTO tr_kowake
	    (
		    no_lot_kowake
		    ,dt_kowake
		    ,cd_panel
		    ,cd_hakari
		    ,cd_seihin
		    ,nm_seihin
		    ,cd_hinmei
		    ,nm_hinmei
		    ,no_kotei
		    ,su_ko
		    ,su_kai
		    ,no_tonyu
		    ,wt_haigo
		    ,wt_jisseki
		    ,cd_line
		    ,ritsu_kihon
		    ,cd_maker
		    ,cd_tanto_kowake
		    ,dt_chikan
		    ,cd_tanto_chikan
		    ,dt_shomi
		    ,dt_shomi_kaifu
		    ,dt_seizo
		    ,flg_kanryo_tonyu
		    ,dt_tonyu
		    ,no_lot_oya
		    ,no_lot_seihin
		    ,kbn_seikihasu
			,kbn_hin
			,kbn_kowakehasu
			,dt_shomi_kaito
		)
	VALUES
	    (
			@no_lot_jisseki
		    ,GETUTCDATE()
	    	,@cd_panel
			,@cd_hakari
		    ,@cd_seihin
			,@nm_seihin
			,@cd_hinmei
		    ,@nm_hinmei
			,@no_kotei
		    ,@su_ko
	       	,@su_kai
			,@no_tonyu
			,@qty_haigo
			,@wt_jisseki
			,@cd_line
		    ,@ritsu_kihon
			,''
			,@cd_tanto_kowake
			,NULL
			,NULL
			,@dt_shomi
			,@dt_shomi_kaifu
			,@dt_seizo
			,0
		    ,NULL
			,@no_lot_oya
		    ,@no_lot_seihin
		    ,@kbn_seikihasu
			,@kbn_hin
			,@kbn_kowakehasu
			,@dt_shomi_kaito
	    )

 --   DECLARE @deciNo DECIMAL(18,0) -- cn_saibanのnoに登録するための変数
 --   SET @deciNo = CONVERT(DECIMAL(18,0),SUBSTRING(@no_lot_jisseki,2,18));

	--UPDATE cn_saiban
	--SET
	--  NO = @deciNo
	--WHERE
	--	kbn_saiban = @kbn_saiban
	--	AND kbn_prefix = @kbn_prefix

END
GO
