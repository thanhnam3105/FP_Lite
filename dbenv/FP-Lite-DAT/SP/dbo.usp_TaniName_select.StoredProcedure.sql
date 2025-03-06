IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_TaniName_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_TaniName_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：単位名取得
ファイル名	：usp_TaniName_select
入力引数	：@cd_panel, @cd_shokuba, @flg_hakari, @flg_kinshi, @flg_mishiyo, @kbn_kino, @tani_LB, @tani_KG
出力引数	：
戻り値		：
作成日		：2016.07.21  BRC motojima.m
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_TaniName_select]
(
	@cd_panel			AS VARCHAR(3)		-- パネルコード
	,@cd_shokuba		AS VARCHAR(10)		-- 職場コード
	,@flg_hakari		AS SMALLINT			-- 定数：使用可否フラグ：使用可
	,@flg_kinshi		AS SMALLINT			-- 定数：禁止フラグ：許可
	,@flg_mishiyo		AS SMALLINT			-- 定数：未使用フラグ：使用
	,@kbn_kino			AS SMALLINT			-- 機能区分：単位区分
	,@tani_LB			AS VARCHAR(2)		-- 固定：単位名：LB
	,@tani_KG			AS VARCHAR(2)		-- 固定：単位名：Kg
)
AS 
BEGIN
	SELECT
		tani.nm_tani AS hakariTaniName
		,CASE WHEN kino.kbn_kino_naiyo = 1 THEN @tani_LB ELSE @tani_KG END AS taniName
	FROM
		ma_panel panel
		LEFT JOIN ma_hakari hakari ON
			panel.cd_hakari_1 = hakari.cd_hakari
			AND hakari.flg_mishiyo = @flg_mishiyo
		LEFT JOIN ma_shokuba shokuba ON
			panel.cd_shokuba = shokuba.cd_shokuba
			AND shokuba.flg_mishiyo = @flg_mishiyo
		LEFT JOIN ma_tani tani ON
			hakari.cd_tani = tani.cd_tani
			AND tani.flg_kinshi = @flg_kinshi
			AND tani.flg_mishiyo = @flg_mishiyo
		LEFT JOIN cn_kino_sentaku kino ON
			kino.kbn_kino = @kbn_kino
	WHERE
		panel.cd_panel = @cd_panel
		AND panel.cd_shokuba = @cd_shokuba
		AND panel.flg_hakari_1 = @flg_hakari
		AND panel.flg_mishiyo = @flg_mishiyo
END
GO
