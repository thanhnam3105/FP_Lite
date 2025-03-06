IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_TonyuJissekiKakunin_select_02') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_TonyuJissekiKakunin_select_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：投入実績確認 実績明細を取得する 
ファイル名	：usp_TonyuJissekiKakunin_select02
入力引数	：@cd_haigo, @dt_shori, @no_lot_seihin, @no_kotei
			  , @su_kai, @su_kai_ha, seikiKbnSeikihasu
			  , @hasuKbnSeikihasu, @skip, @top, @isExcel
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2013.11.21 ADMAX nakamura.m
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_TonyuJissekiKakunin_select_02] 
    @cd_haigo				VARCHAR(14)		-- 配合コード
	,@dt_shori	 			DATETIME		-- 処理日
	,@no_lot_seihin			VARCHAR(14)		-- 製品ロットNo
	,@no_kotei 				DECIMAL			-- 工程番号
	,@su_kai  				DECIMAL			-- 正規/回目
	,@su_kai_ha				DECIMAL			-- 端数/回目
	,@seikiKbnSeikihasu		SMALLINT		-- 正規、端数区分.正規
	,@hasuKbnSeikihasu		SMALLINT		-- 正規、端数区分.端数
	,@skip					DECIMAL(10)		-- スキップ
	,@top					DECIMAL(10)		-- 検索データ上限
	,@isExcel				BIT				-- エクセルフラグ
AS

	DECLARE @start  DECIMAL(10)
	DECLARE	@end    DECIMAL(10)
	DECLARE @true	BIT
	DECLARE @false	BIT
	SET @start  = @skip + 1
	SET @end    = @skip + @top
    SET	@true	= 1
    SET	@false	= 0

BEGIN
	WITH cte AS
		(
			SELECT
				tt.no_tonyu
				,tt.cd_hinmei
				,tt.nm_mark
				,ISNULL(tt.nm_hinmei, '') AS nm_hinmei
				,tt.wt_haigo
				,tt.nm_tani
				,tt.nm_naiyo_jisseki
				,tt.dt_shori
				,ISNULL(mt.nm_tanto, '') AS nm_tanto
				,tt.dt_label_hakko
				,ISNULL(tt.su_kai_label, 0) AS su_kai_label
				,ISNULL(tt.su_ko_label, 0) AS su_ko_label
				,ISNULL(ISNULL(tl.no_lot,tt.no_lot),'') AS no_lot
				,ISNULL(tt.dt_shomi,tk.dt_shomi_kaifu) AS dt_shomi
				,ISNULL(tt.kbn_kyosei, 0) AS kbn_kyosei
				,ROW_NUMBER() OVER (ORDER BY tt.dt_shori,tt.no_tonyu) AS RN
				,0.00 AS wt_sum
				,0.00 AS su_sum
			FROM tr_tonyu tt
			LEFT OUTER JOIN ma_tanto mt
			ON tt.cd_tanto = mt.cd_tanto
			LEFT OUTER JOIN tr_kowake tk
			ON tt.no_lot_seihin = tk.no_lot_seihin
			AND tt.no_kotei = tk.no_kotei
			AND tt.no_tonyu = tk.no_tonyu
			AND tt.dt_shori = tk.dt_tonyu	
			AND tt.su_ko_label = tk.su_ko		
			AND tt.su_kai = tk.su_kai
			AND tt.cd_hinmei = tk.cd_hinmei
			AND tt.cd_line = tk.cd_line
			AND tt.kbn_seikihasu = tk.kbn_seikihasu		
			LEFT OUTER JOIN tr_lot tl
			ON tk.no_lot_kowake = tl.no_lot_jisseki		
			WHERE
				@dt_shori <= tt.dt_seizo 
				AND tt.dt_seizo < (SELECT DATEADD(DD,1,@dt_shori))
				AND tt.no_lot_seihin = @no_lot_seihin
				AND tt.no_kotei = @no_kotei
 				AND ((@su_kai_ha =  1
				AND tt.kbn_seikihasu = @hasuKbnSeikihasu)
				OR (@su_kai_ha	<> 1
				AND tt.su_kai = @su_kai
				AND tt.kbn_seikihasu = @seikiKbnSeikihasu))
		)
	SELECT
		cnt
		,cte_row.no_tonyu
		,cte_row.cd_hinmei
		,cte_row.nm_mark
		,cte_row.nm_hinmei
		,cte_row.wt_haigo
		,cte_row.nm_tani
		,cte_row.nm_naiyo_jisseki
		,cte_row.dt_shori
		,cte_row.nm_tanto
		,cte_row.dt_label_hakko
		,cte_row.su_kai_label
		,cte_row.su_ko_label
		,cte_row.no_lot
		,cte_row.dt_shomi
		,cte_row.kbn_kyosei
		,wt_sum
		,su_sum
	FROM
		(
			SELECT
				MAX(RN) OVER() AS cnt
				,*
			FROM cte
		) cte_row
	WHERE
		(
			@isExcel = @false
			AND RN BETWEEN @start AND @end
		)
		OR @isExcel = @true
END




GO
