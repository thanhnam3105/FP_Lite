IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KasaneLabelShogo_No_Jisseki_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KasaneLabelShogo_No_Jisseki_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ADMAX shibao.s
-- Create date: 2016.01.22
-- Description:	重ねラベル照合画面で小分けの実績がないかつ、端数小分けの場合に
--              重量を算出するための項目を取得するためのストアド
-- =============================================
CREATE PROCEDURE [dbo].[usp_KasaneLabelShogo_No_Jisseki_select]
	@haigoCode			  VARCHAR(14)	-- ラベル　配合コード
	,@seizoDay			  DATETIME	-- ラベル　製造予定日(比較対象のdt_fromと同様に時刻は10:00固定)
	,@shiyoMishiyoFlag	  SMALLINT	-- 区分／コード一覧.未使用フラグ.使用
	,@no_lot_shikakari    VARCHAR(14) -- 仕掛品ロット№
AS
BEGIN
	SET NOCOUNT ON;

SELECT
	haigo.cd_haigo 
	,haigo.no_han
	,haigo.wt_haigo_gokei
	,keikaku.wt_haigo_keikaku
	,keikaku.wt_haigo_keikaku_hasu
	,keikaku.su_batch_keikaku
	,keikaku.su_batch_keikaku_hasu
FROM 
	ma_haigo_mei haigo
	INNER JOIN 
		su_keikaku_shikakari keikaku
	ON 	haigo.cd_haigo =	keikaku.cd_shikakari_hin
WHERE
	haigo.cd_haigo = @haigoCode
	AND keikaku.dt_seizo = @seizoDay
	AND keikaku.no_lot_shikakari = @no_lot_shikakari
	AND haigo.no_han = (SELECT TOP 1 udf.no_han	FROM udf_HaigoRecipeYukoHan(@haigoCode, @shiyoMishiyoFlag, @seizoDay) udf	)
END
GO
