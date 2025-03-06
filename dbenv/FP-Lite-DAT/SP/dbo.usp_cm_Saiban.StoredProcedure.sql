IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_cm_Saiban') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_cm_Saiban]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kasahara.a>
-- Create date: <Create Date,,2013.05.27>
-- Last Update: 2015.05.11 tsujita.s
-- Description:	採番処理
-- =============================================
CREATE PROCEDURE [dbo].[usp_cm_Saiban]
	@kbn_saiban VARCHAR(2)
	,@kbn_prefix VARCHAR(1)
	,@no_saiban VARCHAR(14) output
AS
BEGIN

	DECLARE @no VARCHAR(14)
		,@no_tmp DECIMAL(4, 0)
		,@sysdate VARCHAR(8) = CONVERT(VARCHAR, GETDATE(), 112)

	/********************************
		採番処理 (行ロック)
	********************************/
	SELECT
		--@no = CASE SUBSTRING(CAST(no AS VARCHAR(18)), 0, 9)
		--		WHEN CONVERT(VARCHAR, GETDATE(), 112) THEN CAST(no + 1 AS DECIMAL(18))
		--		ELSE CAST(CONVERT(VARCHAR, GETDATE(), 112) + '0001' AS DECIMAL(18)) END
		@no = no
		,@no_tmp = CASE SUBSTRING(cast(no AS VARCHAR(18)), 0, 9)
				  WHEN @sysdate
				  THEN CAST(
						SUBSTRING(cast(no AS VARCHAR(18)), 9, 4)
							+ 1 AS DECIMAL(18)
					   )
				  ELSE 1 END
	FROM cn_saiban WITH(ROWLOCK, UPDLOCK)
	WHERE
		kbn_saiban = @kbn_saiban
		AND (kbn_prefix IS NULL OR kbn_prefix = @kbn_prefix)

    IF @@ERROR = 0
    BEGIN
		-- エラーではない場合、採番テーブルを更新する
		SET @no = @sysdate + RIGHT('0000' + CONVERT(VARCHAR, @no_tmp), 4)

		-- 採番テーブル更新
		UPDATE cn_saiban
			SET no = @no
		WHERE
			kbn_saiban = @kbn_saiban
			AND (kbn_prefix IS NULL OR kbn_prefix = @kbn_prefix)
	END

	SET @no_saiban = @kbn_prefix + @no

	SELECT ISNULL(kbn_prefix, '') + CAST(no AS VARCHAR) AS no_saiban
	FROM cn_saiban
	WHERE
		kbn_saiban = @kbn_saiban
		AND (kbn_prefix IS NULL OR kbn_prefix = @kbn_prefix)
	
END
GO
