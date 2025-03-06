IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoCheckKasaneKowake_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoCheckKasaneKowake_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：配合チェック  重ね小分ラベルの小分実績・賞味期限チェック
ファイル名  ：usp_HaigoCheckKasaneKowake_select
作成日      ：2015.10.23 MJ ueno.k
更新日      ：2016.01.18 ADMAX kakuta.y 抽出句にkbn_kowakehasu追加
更新日      ：2018.02.23 BRC kanehira.d 検索条件から品名コードを削除　代替品投入対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_HaigoCheckKasaneKowake_select]

	 @no_lot_seihin 		VARCHAR(14)		-- 検索条件：製品ロット番号
	,@no_kotei 				DECIMAL(4)		-- 検索条件：工程番号
	,@no_tonyu				DECIMAL(4)		-- 検索条件：投入番号
	,@dt_seizo				DATETIME		-- 検索条件：製造日
	,@su_ko		            DECIMAL(4)		-- 検索条件：個数
	,@su_kai				DECIMAL(4)		-- 検索条件：回数
	--,@cd_hinmei				VARCHAR(14)		-- 検索条件：品名コード
	,@kbn_hin				SMALLINT		-- 検索条件：品区分
	,@cd_line				VARCHAR(10)		-- 検索条件：ラインコード
	,@kbn_seikihasu			SMALLINT		-- 検索条件：正規、端数区分	
	,@wt_haigo				DECIMAL(12,6)	-- 検索条件：配合重量
	,@no_tonyu_start		DECIMAL(4)		-- 検索条件：重ね開始投入番号
	,@no_tonyu_end			DECIMAL(4)		-- 検索条件：重ね終了投入番号
	,@kbn_kowakehasu		SMALLINT		-- 検索条件：正規、端数小分区分
AS
BEGIN

SELECT
      kowake.dt_kowake
      ,kowake.cd_panel
      ,kowake.cd_hakari
      ,kowake.cd_seihin
      ,kowake.nm_seihin
      ,kowake.cd_hinmei
      ,kowake.nm_hinmei
      ,kowake.no_kotei
      ,kowake.su_ko
      ,kowake.su_kai
      ,kowake.no_tonyu
      ,kowake_wt.wt_total AS wt_haigo	--重ねラベルQRコードは合計重量になるので、重ね内の合計重量を出力
      ,kowake.wt_jisseki
      ,kowake.cd_line
      ,kowake.ritsu_kihon
      ,kowake.cd_maker
      ,kowake.cd_tanto_kowake
      ,kowake.dt_chikan
      ,kowake.cd_tanto_chikan
      ,kowake.dt_shomi
      ,kowake.dt_shomi_kaifu
      ,kowake.dt_seizo
      ,kowake.flg_kanryo_tonyu
      ,kowake.dt_tonyu
      ,kowake.no_lot_oya
      ,kowake.no_lot_seihin
      ,kowake.kbn_seikihasu
	  ,kowake.kbn_kowakehasu
      ,kowake.kbn_hin
FROM tr_kowake kowake

INNER JOIN 
(
	SELECT
		SUM(kk.wt_haigo) AS wt_total
		,kk.no_kotei
		,kk.dt_seizo
		,kk.su_ko
		,kk.su_kai
		,kk.kbn_hin
		,kk.cd_line
		,kk.kbn_seikihasu
		,kk.no_lot_seihin
	FROM
		(
			SELECT DISTINCT
				--SUM(k.wt_haigo) AS wt_total
				k.wt_haigo
				,k.no_kotei
				,k.dt_seizo
				,k.su_ko
				,k.su_kai
				,k.kbn_hin
				,k.cd_line
				,k.kbn_seikihasu
				,k.kbn_kowakehasu
				,k.no_lot_seihin
				,k.no_lot_oya
				,k.cd_hinmei
				,k.no_tonyu
			FROM tr_kowake k
			WHERE
				k.no_lot_seihin = @no_lot_seihin
				AND k.no_kotei = @no_kotei
				AND k.dt_seizo = @dt_seizo
				AND k.su_ko = @su_ko
				AND k.su_kai = @su_kai
				AND k.cd_line = @cd_line
				AND k.kbn_seikihasu = @kbn_seikihasu
				AND k.kbn_kowakehasu = @kbn_kowakehasu
				AND k.no_tonyu BETWEEN @no_tonyu_start AND @no_tonyu_end
		) kk
	GROUP BY
		kk.no_kotei
		,kk.dt_seizo
		,kk.su_ko
		,kk.su_kai
		,kk.kbn_hin
		,kk.cd_line
		,kk.kbn_seikihasu
		,kk.no_lot_seihin
) kowake_wt
ON kowake_wt.no_kotei = kowake.no_kotei
AND	kowake_wt.no_lot_seihin = kowake.no_lot_seihin
AND kowake_wt.dt_seizo = kowake.dt_seizo
AND kowake_wt.su_ko = kowake.su_ko
AND kowake_wt.su_kai = kowake.su_kai
AND kowake_wt.kbn_hin = kowake.kbn_hin
AND kowake_wt.cd_line = kowake.cd_line
AND kowake_wt.kbn_seikihasu = kowake.kbn_seikihasu
WHERE
	kowake.no_lot_seihin = @no_lot_seihin
	AND kowake.no_kotei = @no_kotei
	AND kowake.no_tonyu = @no_tonyu
	AND kowake.dt_seizo = @dt_seizo
	AND kowake.su_ko = @su_ko
	AND kowake.su_kai = @su_kai
	AND kowake.kbn_hin = @kbn_hin
	AND kowake.cd_line = @cd_line
	AND kowake.kbn_seikihasu = @kbn_seikihasu
	AND kowake.kbn_kowakehasu = @kbn_kowakehasu
	--AND kowake.cd_hinmei = @cd_hinmei
	AND kowake_wt.wt_total = @wt_haigo
ORDER BY
	kowake.dt_shomi_kaifu
	,kowake.dt_shomi ASC
END
GO
