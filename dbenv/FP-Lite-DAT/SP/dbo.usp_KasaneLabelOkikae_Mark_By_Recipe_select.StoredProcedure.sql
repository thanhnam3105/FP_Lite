IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KasaneLabelOkikae_Mark_By_Recipe_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KasaneLabelOkikae_Mark_By_Recipe_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ADMAX shibao.s
-- Create date: 2016.01.26
-- Description:	重ねラベル置き換え画面でラベルに紐づく投入順が
--              何個続いているか確認するためのストアド
-- =============================================
CREATE PROCEDURE [dbo].[usp_KasaneLabelOkikae_Mark_By_Recipe_select]
	@haigoCode			  VARCHAR(14)	-- ラベル　配合コード
	,@seizoDay			  DATETIME	    -- ラベル　製造予定日(時刻は10:00固定)
	,@shiyoMishiyoFlag	  SMALLINT	    -- 区分／コード一覧.未使用フラグ.使用
	,@no_kotei            DECIMAL       -- 工程番号
	,@no_tonyu            DECIMAL       -- 投入番号
	--,@count               SMALLINT  OUT -- 戻り値
AS
BEGIN
	DECLARE @cd_mark varchar(2)
	DECLARE @no_han decimal

--マークと有効版を取得する
SELECT 
	@cd_mark = ma_haigo_recipe.cd_mark
	,@no_han = ma_haigo_recipe.no_han
FROM ma_haigo_recipe
WHERE 
	cd_haigo = @haigoCode
	AND no_han = (SELECT TOP 1 udf.no_han	FROM udf_HaigoRecipeYukoHan(@haigoCode, @shiyoMishiyoFlag, @seizoDay) udf	)
	AND no_kotei = @no_kotei
	AND no_tonyu = @no_tonyu

--マークに紐づく投入番号を取得する
SELECT 
	no_tonyu
FROM ma_haigo_recipe
WHERE 
	cd_haigo = @haigoCode
	AND no_han = @no_han
	AND no_kotei = @no_kotei
	AND cd_mark = @cd_mark

END
GO
