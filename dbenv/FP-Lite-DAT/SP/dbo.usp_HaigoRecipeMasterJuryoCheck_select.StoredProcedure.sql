IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoRecipeMasterJuryoCheck_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoRecipeMasterJuryoCheck_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,okada.k>
-- Create date: <Create Date,,2013.05.30>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_HaigoRecipeMasterJuryoCheck_select]
	@cd_hinmei		AS VARCHAR(14)	-- 品名コード
	,@kbn_hin		AS SMALLINT		-- 品区分	
	,@kbn_jotai_sonota	AS SMALLINT		-- 状態区分(その他)
	,@kbn_jotai_shikakari	AS SMALLINT	-- 状態区分(仕掛品)
	,@kbn_hin_genryo	AS SMALLINT		-- 品区分(原料)
	,@kbn_hin_shikakari	AS SMALLINT		-- 品区分(仕掛品)
AS
BEGIN
	
DECLARE @result_juryo AS DECIMAL(12,6)
	
	--個別の小分け重量設定を取得
		SET @result_juryo = 
		(
			SELECT 
				juryo.wt_kowake
			FROM 
				ma_juryo AS juryo
			WHERE 
				juryo.cd_hinmei = @cd_hinmei
				AND juryo.kbn_hin = @kbn_hin
				AND juryo.kbn_jotai = @kbn_jotai_sonota
		)
	
	--個別の小分重量設定が無かった場合、共通設定から取得
	IF @result_juryo IS NULL
	BEGIN
		IF @kbn_hin = @kbn_hin_shikakari BEGIN
			SET @result_juryo = 
			(
				SELECT 
					juryo.wt_kowake
				FROM 
					ma_juryo AS juryo
				WHERE
					juryo.cd_hinmei = '-'
					AND juryo.kbn_hin = @kbn_hin
					AND juryo.kbn_jotai = @kbn_jotai_shikakari
			)
		END
		ELSE IF @kbn_hin = @kbn_hin_genryo BEGIN
			SET @result_juryo = 
			(
				SELECT 
					juryo.wt_kowake
				FROM 
					ma_juryo AS juryo
				INNER JOIN 
					ma_hinmei AS hin 
				ON (
					hin.cd_hinmei = @cd_hinmei
					AND hin.kbn_hin = juryo.kbn_hin				
					AND hin.kbn_hin = juryo.kbn_hin
					AND hin.kbn_jotai = juryo.kbn_jotai
				)
				WHERE
					juryo.cd_hinmei = '-'
					AND juryo.kbn_hin = @kbn_hin
			)
		END
	END

	--設定がなかった場合、小分重量のデフォルト値1kgを設定
	IF @result_juryo IS NULL
	BEGIN
		SET @result_juryo = 1
	END
	
	select @result_juryo AS wt_kowake

END
GO
