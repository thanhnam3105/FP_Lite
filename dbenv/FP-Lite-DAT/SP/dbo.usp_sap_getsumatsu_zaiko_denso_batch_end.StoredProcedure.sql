IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_getsumatsu_zaiko_denso_batch_end') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_getsumatsu_zaiko_denso_batch_end]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：月末在庫伝送:バッチコントロールマスタ更新(終了)処理
ファイル名	：[usp_sap_getsumatsu_zaiko_denso_batch_end]
戻り値		：
作成日		：2021.05.15 BRC.saito #1205対応
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_getsumatsu_zaiko_denso_batch_end]
AS
BEGIN

	-- バッチコントロールマスタ更新(終了)
	UPDATE ma_batch_control
	SET flg_shori = 0
		,dt_end = GETUTCDATE()
	WHERE id_jobnet = 'GETSUMATSU_ZAIKO'
	AND flg_shori = 1

END
GO