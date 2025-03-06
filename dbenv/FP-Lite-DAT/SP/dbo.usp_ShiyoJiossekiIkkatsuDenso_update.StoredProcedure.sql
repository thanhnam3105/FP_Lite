IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShiyoJiossekiIkkatsuDenso_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShiyoJiossekiIkkatsuDenso_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：使用実績一括伝送 更新
ファイル名	：usp_ShiyoJiossekiIkkatsuDenso_update
作成日		：2015.07.02  ADMAX tsujita.s
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_ShiyoJiossekiIkkatsuDenso_update]
	@dt_from			DATETIME	-- 検索条件：伝送開始日
	,@dt_to				DATETIME	-- 検索条件：伝送終了日
	,@kbn_denso_machi	SMALLINT	-- 固定値：伝送状態区分：伝送待ち
	,@kbn_denso_midenso	SMALLINT	-- 固定値：伝送状態区分：未伝送
AS
BEGIN
	SET NOCOUNT ON

	UPDATE
		tr_sap_shiyo_yojitsu_anbun
	SET
		kbn_jotai_denso = @kbn_denso_machi
	WHERE
		dt_shiyo_shikakari BETWEEN @dt_from AND @dt_to
	AND kbn_jotai_denso = @kbn_denso_midenso

END

GO
