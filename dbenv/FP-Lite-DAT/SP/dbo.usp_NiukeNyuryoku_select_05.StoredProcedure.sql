IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_select_05') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_select_05]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：荷受入力 実績検索　荷受トラン(実績なし)の場合
ファイル名	：usp_NiukeNyuryoku_select_05
入力引数	：@skip, @top, @no_nonyu
出力引数	：
戻り値		：
作成日		：2016.09.01  BRC   motojima.m 荷受入力行追加対応
更新日		：2016.11.15  BRC   cho.k 納入確定フラグの初期値を0で取得
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_select_05]
	@skip					DECIMAL(10)		-- スキップ
	,@top					DECIMAL(10)		-- 検索データ上限
	,@no_nonyu				VARCHAR(13)		-- 納入番号
AS
BEGIN

	DECLARE @start	DECIMAL(10)
    DECLARE @end	DECIMAL(10)
	-- フラグ値
	DECLARE @zeroToFlg	SMALLINT
	DECLARE @oneToFlg	SMALLINT

    SET		@start	= @skip + 1
    SET		@end	= @skip + @top
	SET		@zeroToFlg	= 0
	SET		@oneToFlg	= 1


	DECLARE @initStr	VARCHAR
	SET @initStr = '';

	DECLARE @noSeqMin DECIMAL(8,0)
	SET @noSeqMin = (
						SELECT
							MIN(no_seq)
						FROM tr_niuke
					);

	WITH cte AS
		(

			SELECT	
				t_niu.tm_nonyu_jitsu tm_nonyu_jitsu					-- 時刻
				,t_niu.su_nonyu_jitsu								-- C/S数
				,t_niu.su_nonyu_jitsu_hasu							-- 端数
				,t_niu.kin_kuraire									-- 金額
				,ISNULL(t_niu.no_lot, @initStr ) AS no_lot			-- ロットNo.
				,t_niu.dt_seizo										-- 製造日
				,t_niu.dt_kigen										-- 賞味期限
				,t_niu.no_nohinsho									-- 納品書番号
				,t_niu.no_zeikan_shorui								-- 税関書類No.
				,ISNULL(t_niu.no_denpyo, @initStr ) AS no_denpyo	-- 伝票No.
				,ISNULL(t_niu.biko, @initStr ) AS biko				-- 備考
				,t_niu.no_niuke										-- 荷受番号(非表示項目)
				,CASE t_niu.tm_nonyu_jitsu
					WHEN NULL THEN 0
					ELSE 1
				END flg_tm_jitsu									-- 実績時刻フラグ(非表示項目)
				,t_niu.dt_nonyu										-- 納入日
				,t_niu.kbn_nyuko AS kbn_nyuko						-- 入庫区分(非表示項目)
				,t_niu.no_nonyu AS no_nonyu							-- 納入番号(非表示項目)
				,t_niu.no_nonyu AS no_nonyu_yotei					-- 納入予定番号(非表示項目)
				--,t_niu.flg_kakutei AS flg_kakutei_nonyu				-- 確定フラグ(非表示項目)
				,@zeroToFlg	AS flg_kakutei_nonyu				-- 確定フラグ(非表示項目)
				,ROW_NUMBER() OVER (ORDER BY t_niu.tm_nonyu_jitsu, t_niu.no_niuke) AS RN
			FROM tr_niuke t_niu
			WHERE 
				t_niu.no_nonyu = @no_nonyu
				AND t_niu.no_seq = @noSeqMin
		)
		
		-- 画面に返却する値を取得
		SELECT
			cnt
			,cte_row.tm_nonyu_jitsu
			,cte_row.su_nonyu_jitsu
			,cte_row.su_nonyu_jitsu_hasu
			,cte_row.kin_kuraire
			,cte_row.no_lot
			,cte_row.dt_seizo
			,cte_row.dt_kigen
			,cte_row.no_nohinsho
			,cte_row.no_zeikan_shorui
			,cte_row.no_denpyo
			,cte_row.biko
			--非表示項目
			,cte_row.no_niuke
			,cte_row.flg_tm_jitsu
			,cte_row.dt_nonyu
			,cte_row.kbn_nyuko
			,cte_row.no_nonyu
			,cte_row.no_nonyu_yotei
			,cte_row.flg_kakutei_nonyu
		FROM
			(
				SELECT 
					MAX(RN) OVER() AS cnt
					,*
				FROM cte 
			) cte_row
		WHERE RN BETWEEN @start AND @end
		ORDER BY RN
END
GO
