IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HakariTenkenKakunin_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HakariTenkenKakunin_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：秤点検確認画面 検索
ファイル名	：usp_HakariTenkenKakunin_select
入力引数	：@dt_check, @cd_shokuba, @shiyoMishiyoFlg
			  , @skip, @top, @isExcel
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2013.09.25 ADMAX onodera.s
更新日      ：2016.08.25 BRC	ieki.h	LB対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_HakariTenkenKakunin_select] 
	@dt_check			DATETIME      --秤点検日
	,@cd_shokuba		VARCHAR(10)   --職場コード
	,@shiyoMishiyoFlg	SMALLINT      --未使用フラグ（使用）
    ,@skip				DECIMAL(10)   --読込開始位置
    ,@top				DECIMAL(10)   --表示件数
	,@isExcel			BIT           --Excel出力用
AS
    DECLARE @start		DECIMAL(10)
    DECLARE @end		DECIMAL(10)
	DECLARE @true		BIT
	DECLARE @false		BIT
    SET @start	= @skip + 1
    SET @end	= @skip + @top
    SET @true	= 1
    SET @false	= 0

BEGIN
	WITH cte AS
		(    
			SELECT
				thc.wt_jisseki wt_jisseki
				,ISNULL(mtn.nm_tani,'') AS nm_tani_jisseki
				,ISNULL(mf.wt_fundo,0) AS wt_fundo
				,ISNULL(mtn2.nm_tani,'') AS nm_tani_fundo
				,thc.dt_check dt_check
				,ISNULL(mt.nm_tanto,'') AS nm_tanto
				,mp.cd_panel cd_panel
				,ISNULL(mh.nm_hakari,'') AS nm_hakari
				,ROW_NUMBER() OVER (ORDER BY thc.dt_check) AS RN
			FROM tr_hakari_check thc
			LEFT OUTER JOIN ma_fundo mf
			ON thc.cd_fundo = mf.cd_fundo
			LEFT OUTER JOIN ma_hakari mh
			ON thc.cd_hakari = mh.cd_hakari
			LEFT OUTER JOIN ma_tanto mt
			ON thc.cd_tanto = mt.cd_tanto
			LEFT OUTER JOIN ma_panel mp
			ON thc.cd_panel = mp.cd_panel
			LEFT OUTER JOIN ma_shokuba ms
			ON mp.cd_shokuba = ms.cd_shokuba
			AND ms.flg_mishiyo = @shiyoMishiyoFlg
			LEFT OUTER JOIN ma_tani mtn
			ON mh.cd_tani = mtn.cd_tani
			LEFT OUTER JOIN ma_tani mtn2
			ON mf.cd_tani = mtn2.cd_tani
			WHERE
				@dt_check <= thc.dt_check
				AND thc.dt_check <
					(
						SELECT DATEADD(DD,1,@dt_check)
					)
				AND ms.cd_shokuba = @cd_shokuba
		)
		-- 画面に返却する値を取得
	SELECT
		cnt
		,cte_row.wt_jisseki
		,cte_row.nm_tani_jisseki
		,cte_row.wt_fundo
		,cte_row.nm_tani_fundo
		,cte_row.dt_check
		,cte_row.nm_tanto
		,cte_row.cd_panel
		,cte_row.nm_hakari
	FROM
		(
			SELECT
				MAX(RN) OVER() AS cnt
				,*
			FROM cte
		) cte_row
	WHERE
		(
			(
				@isExcel = @false
				AND RN BETWEEN @start AND @end
			)
			OR @isExcel = @true
		)
END
GO
