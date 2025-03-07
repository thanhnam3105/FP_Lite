IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HakariTenken_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HakariTenken_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：秤点検　秤点検実績を取得する　
ファイル名	：usp_HakariTenken_select02
入力引数	：@cd_panel, @cd_hakari, @shiyoMishiyoFlg
			  , @sysDate, @skip, @top
出力引数	：	
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2013.12.06  ADMAX nakamura.m
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_HakariTenken_select] 
	@cd_panel			VARCHAR(3)		-- パネルコード
	,@cd_hakari			VARCHAR(10)		-- 秤コード
	,@shiyoMishiyoFlg	SMALLINT		-- 未使用フラグ．使用
	,@sysDate			DATETIME		-- システム日付
	,@skip				DECIMAL(10)		-- スキップ
	,@top				DECIMAL(10)		-- 検索データ上限
AS

	DECLARE @start  DECIMAL(10)
	DECLARE	@end    DECIMAL(10)

	SET @start  = @skip + 1
	SET @end    = @skip + @top

BEGIN
	WITH cte AS
		(
			SELECT
				thc.cd_panel
				,thc.wt_jisseki
				,thc.dt_check
				,mt.nm_tanto
				,mf.wt_fundo
				,ROW_NUMBER() OVER (ORDER BY thc.dt_check) AS RN
			FROM tr_hakari_check thc
			LEFT OUTER JOIN ma_tanto mt
			ON thc.cd_tanto = mt.cd_tanto
			LEFT OUTER JOIN ma_fundo mf
			ON thc.cd_fundo = mf.cd_fundo
			WHERE
				mt.flg_mishiyo = @shiyoMishiyoFlg
				AND	mf.flg_mishiyo = @shiyoMishiyoFlg
				AND thc.cd_panel = @cd_panel
				AND thc.cd_hakari = @cd_hakari
				AND @sysDate <= thc.dt_check
				AND thc.dt_check <
					(
						SELECT DATEADD(DD,1,@sysDate)
					)
		)
	SELECT
		cnt
		,cte_row.cd_panel
		,cte_row.wt_jisseki
		,cte_row.dt_check
		,cte_row.nm_tanto
		,cte_row.wt_fundo
	FROM
		(
			SELECT
				MAX(RN) OVER() AS cnt
				,*
			FROM cte
		) cte_row
	WHERE
		RN BETWEEN @start AND @end
END
GO
