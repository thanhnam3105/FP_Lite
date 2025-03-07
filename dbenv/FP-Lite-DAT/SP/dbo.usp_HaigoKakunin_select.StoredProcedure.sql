IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoKakunin_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoKakunin_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：配合確認 投入計画データ検索
ファイル名	：usp_HaigoKakunin_select
入力引数	：@cd_shokuba, @cd_line, @cd_panel ,@no_kotei
              , @kbn_seikihasu, @mark, @skip, @top
出力引数	：
戻り値		：
作成日		：2013.11.23  ADMAX endo.y
更新日		：2013.12.02  ADMAX sato.m  後続データ検索の対応
　　		：2018.02.02  BRC kanehira  g換算の条件を修正
*****************************************************/
CREATE PROCEDURE [dbo].[usp_HaigoKakunin_select] 
	@cd_shokuba		VARCHAR(10)
	,@cd_line		VARCHAR(10)
	,@cd_panel		VARCHAR(3)
	,@no_kotei		DECIMAL(4,0)
	,@kbn_seikihasu	SMALLINT
	,@mark			VARCHAR(2)
	,@skip			DECIMAL(10)
	,@top			DECIMAL(10)
	,@nm_taniG		VARCHAR(1)

AS
BEGIN
    DECLARE @start DECIMAL(10)
    DECLARE @end   DECIMAL(10)
    SET @start = @skip + 1
    SET @end   = @skip + @top

    BEGIN
		WITH cte AS
			(
				SELECT
					ttk.no_tonyu
					,ttk.mark
					,ttk.cd_hinmei
					,ttk.nm_hinmei
					--,CASE
					--	WHEN ttk.mark = @mark THEN ttk.wt_haigo * 1000
					--	ELSE ttk.wt_haigo
					--END AS wt_haigo
					,ttk.wt_haigo
					--,CASE
					--	WHEN ttk.mark = @mark THEN @nm_taniG
					--	ELSE ttk.nm_tani
					--END AS nm_tani
					,ttk.nm_tani
					--,ttk.wt_nisugata
					,CASE
						--WHEN ttk.mark = @mark THEN ttk.wt_nisugata * 1000
						WHEN ttk.nm_tani = @nm_taniG THEN ttk.wt_nisugata * 1000
						ELSE ttk.wt_nisugata
					END AS wt_nisugata
					,ttk.su_nisugata
					,CASE
						--WHEN ttk.mark = @mark THEN ttk.wt_kowake * 1000
						WHEN ttk.nm_tani = @nm_taniG THEN ttk.wt_kowake * 1000
						ELSE ttk.wt_kowake
					END AS wt_kowake
					,ttk.su_kowake
					,CASE
						--WHEN ttk.mark = @mark THEN ttk.wt_kowake_hasu * 1000
						WHEN ttk.nm_tani = @nm_taniG THEN ttk.wt_kowake_hasu * 1000
						ELSE ttk.wt_kowake_hasu
					END AS wt_kowake_hasu
					,ttk.su_kowake_hasu
					,ROW_NUMBER() OVER (ORDER BY ttk.no_tonyu) AS RN
				FROM tr_tonyu_keikaku ttk
				WHERE
					ttk.cd_shokuba = @cd_shokuba
					AND ttk.cd_line = @cd_line
					AND ttk.cd_panel = @cd_panel
					AND ttk.no_kotei = @no_kotei
					AND ttk.kbn_seikihasu = @kbn_seikihasu
			)
		-- 画面に返却する値を取得
		SELECT
			cnt
			,cte_row.no_tonyu
			,cte_row.mark
			,cte_row.cd_hinmei
			,cte_row.nm_hinmei
			,cte_row.wt_haigo
			,cte_row.nm_tani
			,cte_row.wt_nisugata
			,cte_row.su_nisugata
			,cte_row.wt_kowake
			,cte_row.su_kowake
			,cte_row.wt_kowake_hasu
			,cte_row.su_kowake_hasu
		FROM
			(
				SELECT
					MAX(RN) OVER() cnt
					,*
				FROM cte
			) cte_row
		WHERE
			RN BETWEEN @start AND @end
	END
END
GO