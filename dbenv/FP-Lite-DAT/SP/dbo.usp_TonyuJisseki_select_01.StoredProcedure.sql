IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_TonyuJisseki_select_01') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_TonyuJisseki_select_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：投入実績 計画明細を取得します。
ファイル名	：usp_TonyuJisseki_select01
入力引数	：@dt_seizo, @no_kotei, @cd_line
              , @kyoseishuryoKyoseiKbn, @skip, @top
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2013.11.26  ADMAX nakamura.m
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_TonyuJisseki_select_01] 
	@dt_seizo					DATETIME		-- 製造計画
	, @no_kotei					DECIMAL			-- 工程番号
	, @cd_line					VARCHAR(10)		-- ラインコード
	, @kyoseishuryoKyoseiKbn	SMALLINT		-- 強制歩進区分
	, @skip						DECIMAL(10)		-- スキップ
	, @top						DECIMAL(10)		-- 検索データ上限
AS

	DECLARE @start DECIMAL(10)
	DECLARE	@end   DECIMAL(10)
	SET @start = @skip + 1
	SET @end   = @skip + @top

BEGIN
	WITH cte AS
		(
			SELECT
				tts.su_yotei_seizo
				,tts.su_yotei_seizo_hasu
				,tts.cd_haigo
				,tts.nm_haigo
				,tts.no_kotei
				,tts.no_lot_seihin
				,ISNULL(tt.kbn_kyosei, 0) AS kbn_kyosei
				,ROW_NUMBER() OVER (ORDER BY tts.cd_haigo) AS RN
			FROM tr_tonyu_start tts
			LEFT OUTER JOIN tr_tonyu tt
			ON tts.no_lot_seihin = tt.no_lot_seihin
			AND tt.kbn_kyosei = @kyoseishuryoKyoseiKbn
			WHERE
				@dt_seizo <= tts.dt_seizo
				AND tts.dt_seizo <
					(
						SELECT DATEADD(DD,1,@dt_seizo)
					)
				AND (
						ISNULL(@cd_line, '') = ''
						OR tts.cd_line = @cd_line
					)
				AND tts.no_kotei = @no_kotei
			GROUP BY
				tts.su_yotei_seizo
				,tts.su_yotei_seizo_hasu
				,tts.cd_haigo
				,tts.nm_haigo
				,tts.no_kotei
				,tts.no_lot_seihin
				,tt.kbn_kyosei
		)
	SELECT
		cnt
		,cte_row.su_yotei_seizo
		,cte_row.su_yotei_seizo_hasu
		,cte_row.cd_haigo
		,cte_row.nm_haigo
		,cte_row.no_kotei
		,cte_row.no_lot_seihin
		,cte_row.kbn_kyosei
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
