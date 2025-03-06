IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GetsumatsuZaikoDensoTaishoZen_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GetsumatsuZaikoDensoTaishoZen_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：月末在庫送信前回対象 削除
ファイル名  ：usp_GetsumatsuZaikoDensoTaishoZen_delete
入力引数    ：@con_dt_zaiko
出力引数    ：
戻り値      ：
作成日      ：2016.05.13  BRC motojima.m
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GetsumatsuZaikoDensoTaishoZen_delete]
	 @con_dt_zaiko			datetime		-- 削除条件：在庫日付

AS
BEGIN

	-- 月末在庫送信前回対象のデータを削除します。
	DELETE FROM tr_sap_getsumatsu_zaiko_denso_taisho_zen
	WHERE
		CONVERT(NVARCHAR, dt_tanaoroshi, 111) = CONVERT(NVARCHAR, @con_dt_zaiko, 111)

END
GO
