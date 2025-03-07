IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HendoHyoSimulationShizai_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HendoHyoSimulationShizai_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================
-- Author:		tsujita.s
-- Create date: 2014.01.15
-- Last Update: 2016.10.13 matsumura.y
-- Description:	変動表シミュレーション：
--              資材スプレッドの情報を取得します
-- ===================================================
CREATE PROCEDURE [dbo].[usp_HendoHyoSimulationShizai_select]
	 @con_dt_hizuke datetime
	,@con_cd_hinmei varchar(14)
	,@flg_shiyo smallint

AS
BEGIN
	SET NOCOUNT ON

	SELECT
		shiyo.cd_shizai AS cd_shizai
		--,shiyo.su_shiyo AS su_shiyo
		,CEILING(shiyo.su_shiyo * 1000) / 1000 AS su_shiyo --小数第四位を切り上げ
	FROM udf_ShizaiShiyoYukoHan(
		@con_cd_hinmei
		,@flg_shiyo
		,@con_dt_hizuke ) shiyo
	
	ORDER BY shiyo.cd_shizai


END
GO
