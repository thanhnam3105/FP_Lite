IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoCheck_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoCheck_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能  ：配合チェック ラベル読込済の個数を取得します。
ファイル名 ：usp_HaigoCheck_select
入力引数 ：@cd_shokuba, @cd_line, @cd_panel, @no_tonyu
           @kbn_seikihasu, @su_kai
出力引数 ：
戻り値   ：
作成日   ：2013.11.30  ADMAX kunii.h
更新日   ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_HaigoCheck_select]
	@cd_shokuba		VARCHAR(10)		-- 職場コード
	,@cd_line		VARCHAR(10)		-- ラインコード
	,@cd_panel		VARCHAR(3)		-- パネルコード
	,@no_tonyu		DECIMAL(4,0)	-- 投入番号
	,@kbn_seikihasu	INT				-- 正規、端数区分
	,@su_kai		DECIMAL(4,0)	-- 回数
	--追加
	,@no_lot_seihin VARCHAR(14)		-- 製品ロット番号
	,@no_kotei		DECIMAL(4,0)	-- 工程
AS
BEGIN
	SELECT
		ISNULL(tt.su_nisugata, 0) AS su_nisugata				-- 荷姿数
		,ISNULL(tt.su_kowake, 0) AS su_kowake					-- 小分数
		,ISNULL(tt.su_kowake_hasu, 0) AS su_kowake_hasu			-- 小分数量端数
		,ISNULL(tt.wt_nisugata, 0) AS wt_nisugata				-- 荷姿重量
		,ISNULL(tt.wt_kowake, 0) AS wt_kowake					-- 小分重量
		,ISNULL(tt.wt_kowake_hasu, 0) AS wt_kowake_hasu			-- 小分重量端数
		,ISNULL(tt.nm_naiyo_jisseki, '') AS nm_naiyo_jisseki	-- 実績内容
	FROM tr_tonyu_jokyo ttj
	LEFT OUTER JOIN tr_tonyu_keikaku ttk
	ON  ttj.dt_seizo = ttk.dt_seizo
	AND ttj.cd_panel = ttk.cd_panel
	AND ttj.cd_shokuba = ttk.cd_shokuba
	AND ttj.cd_line = ttk.cd_line
	AND ttj.no_kotei = ttk.no_kotei
	LEFT OUTER JOIN tr_tonyu tt
	ON  ttk.dt_seizo = tt.dt_seizo
	AND ttk.cd_shokuba = tt.cd_shokuba
	AND ttk.cd_line = tt.cd_line
	AND ttj.cd_haigo = tt.cd_haigo
	--AND ttk.cd_hinmei = tt.cd_hinmei
	AND ttk.no_tonyu = tt.no_tonyu
	--追加
	AND tt.no_lot_seihin = @no_lot_seihin
	WHERE
		ttj.cd_shokuba = @cd_shokuba
		AND ttj.cd_line = @cd_line
		AND ttj.cd_panel = @cd_panel
		AND ttk.no_tonyu = @no_tonyu
		AND tt.kbn_seikihasu = @kbn_seikihasu
		AND tt.su_kai = @su_kai
		AND tt.no_kotei = @no_kotei
		--追加
		--AND ttj.no_lot_seihin = @no_lot_seihin
END
GO
