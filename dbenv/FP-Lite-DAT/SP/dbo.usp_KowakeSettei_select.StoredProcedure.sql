IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KowakeSettei_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KowakeSettei_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：設定画面(小分) パネル情報を取得する
ファイル名  ：usp_KowakeSettei_select
入力引数    ：@cdPanel, @cdShokuba, @shiyoMishiyoFlg
出力引数    ：
戻り値      ：成功時[0] 失敗時[0以外のエラーコード]
作成日      ：2013.12.03 ADMAX nakamura.m
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KowakeSettei_select] 
	@cdPanel			VARCHAR(3)		-- パネルコード
	,@cdShokuba			VARCHAR(10)		-- 職場コード
	,@shiyoMishiyoFlg	SMALLINT		-- 未使用フラグ．使用
AS
BEGIN
	WITH cte AS
		(
			SELECT
				mp.cd_hakari_1
				,mp.no_hakari_com_1
				,mp.flg_hakari_1
				,mp.cd_hakari_2
				,mp.no_hakari_com_2
				,mp.flg_hakari_2
				,mp.wt_kirikae_hakari
				,mp.no_com_reader
				,mp.su_hakari
				,mp.ts
				,ROW_NUMBER() OVER (ORDER BY mp.cd_panel) AS RN
			FROM ma_panel mp
			INNER JOIN
				(
					SELECT
						*
					FROM ma_hakari
					WHERE
						ma_hakari.flg_mishiyo = @shiyoMishiyoFlg
				) hakari_first
			ON mp.cd_hakari_1 = hakari_first.cd_hakari
			LEFT OUTER JOIN
				(
					SELECT
						*
					FROM ma_hakari
					WHERE
						ma_hakari.flg_mishiyo = @shiyoMishiyoFlg
				) hakari_second
			ON mp.cd_hakari_2 = hakari_second.cd_hakari
			WHERE
				mp.cd_panel = @cdPanel
				AND mp.cd_shokuba = @cdShokuba
		)
	SELECT
		cnt
		,cte_row.cd_hakari_1
		,cte_row.no_hakari_com_1
		,cte_row.flg_hakari_1
		,cte_row.cd_hakari_2
		,cte_row.no_hakari_com_2
		,cte_row.flg_hakari_2
		,cte_row.wt_kirikae_hakari
		,cte_row.no_com_reader
		,cte_row.su_hakari
		,cte_row.ts
	FROM
		(
			SELECT
				MAX(RN) OVER() AS cnt
				,*
			FROM
				cte
		) cte_row
END
GO
