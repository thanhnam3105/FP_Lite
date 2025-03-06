IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LotBetsuJissekiJuryo_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LotBetsuJissekiJuryo_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：ロット別実績重量
ファイル名	：usp_LotBetsuJissekiJuryo_select
入力引数	：@no_lot_oya, @skip, @top
出力引数	：
戻り値		：
作成日		：2013.10.09  ADMAX kakuta.y
更新日		：2016.08.24  BRC   ieki.h		LB対応
更新日		：2017.02.13  BRC   matsumura.y		QBサポートNo.33対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LotBetsuJissekiJuryo_select] 
	@no_lot_oya	VARCHAR(14)		-- 小分実績確認画面.親ロット番号
	,@skip		DECIMAL(10)		-- スキップ
	,@top		DECIMAL(10)		-- 検索データ上限
AS
BEGIN							-- ロット切替を行ったデータのロット別重量を取得します。

	DECLARE @start	DECIMAL(10)
    DECLARE @end	DECIMAL(10)
    SET		@start	= @skip + 1
    SET		@end	= @skip + @top;

    WITH cte AS
		(
			SELECT
				t_lot.no_lot
				--,t_kowa.wt_jisseki
				,CASE --実績値(小数第3位まで表示。切捨て
				WHEN tani.cd_tani = '3' 
				THEN ROUND(t_kowa.wt_jisseki * 1000, 3, 1) --g変換
				ELSE ROUND(t_kowa.wt_jisseki, 3, 1) 
				END AS wt_jisseki
				,tani.nm_tani
				,ROW_NUMBER() OVER (ORDER BY t_lot.no_lot) AS RN
			FROM tr_kowake t_kowa
			INNER JOIN tr_lot t_lot
			ON t_kowa.no_lot_kowake = t_lot.no_lot_jisseki
			LEFT OUTER JOIN  ma_hakari hakari
			ON t_kowa.cd_hakari = hakari.cd_hakari
			LEFT OUTER JOIN ma_tani tani
			ON hakari.cd_tani = tani.cd_tani
			WHERE
				t_kowa.no_lot_oya = @no_lot_oya
		)
	SELECT
		cnt
		,cte_row.no_lot
		,cte_row.wt_jisseki
		,cte_row.nm_tani
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
