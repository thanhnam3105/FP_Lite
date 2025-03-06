IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KasaneLabelShogo_select_03') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KasaneLabelShogo_select_03]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：重ねラベル照合 検索03
ファイル名	：usp_KasaneLabelShogo_select03
入力引数	：@dt_seizo, @cd_haigo, @no_tonyu
              , @no_kotei ,@cd_line ,@cd_hinmei 
              , @su_kai ,@no_lot_seihin ,@flg_mishiyo
              , @ritsu_kihon
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2013.11.06  ADMAX okuda.k
更新日		：2014.02.20  ADMAX kunii.h
更新日		：2016.08.05  BRC   motojima.m  LB対応
更新日		：2017.04.26  BRC   kanehira.d  Q&Bサポート対応No.56　		　
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KasaneLabelShogo_select_03]
(
	@dt_seizo		DATETIME      --製造日
	,@cd_haigo		VARCHAR(14)   --配合コード
	,@no_tonyu		DECIMAL(4,0)  --投入番号
	,@no_kotei		DECIMAL(4,0)  --工程番号
	,@cd_line		VARCHAR(10)   --ラインコード
	,@cd_hinmei		VARCHAR(14)   --品名コード
	,@su_kai		DECIMAL(4,0)  --回数
	,@no_lot_seihin	VARCHAR(14)   --製品ロット番号
	,@flg_mishiyo	SMALLINT      --未使用フラグ
	,@su_ko			DECIMAL(4,0)  --個数
	,@kbn_seikihasu	SMALLINT      --正規、端数区分
	,@kbn_kowakehasu SMALLINT     --端数フラグ
	,@ritsu_kihon   DECIMAL(5,3)  --基本倍率
)
AS
BEGIN
	SELECT
		tk.dt_kowake
	    ,tk.cd_hinmei
	    ,tk.nm_hinmei
	    ,tk.nm_seihin
	    ,tk.wt_haigo
	    ,SUM(tk.wt_jisseki) AS wt_jisseki
	    ,tani.nm_tani
	    ,tk.su_kai
	    ,tk.su_ko
	    ,tk.no_tonyu
	    ,ISNULL(tanto_hyoryo.nm_tanto, '') AS hyoryoSya
	    ,tk.dt_chikan
	    ,tanto_chikan.nm_tanto chikanSya
	    ,tk.kbn_seikihasu
		,hinKbnMa.kbn_hin
		,hinKbnMa.nm_kbn_hin
	FROM tr_kowake tk
	LEFT OUTER JOIN ma_tanto tanto_hyoryo
	ON tk.cd_tanto_kowake  = tanto_hyoryo.cd_tanto
	AND tanto_hyoryo.flg_mishiyo = @flg_mishiyo
	LEFT OUTER JOIN ma_tanto tanto_chikan
	ON tk.cd_tanto_chikan = tanto_chikan.cd_tanto
	AND tanto_chikan.flg_mishiyo = @flg_mishiyo
	LEFT OUTER JOIN ma_kbn_hin hinKbnMa
	ON tk.kbn_hin = hinKbnMa.kbn_hin
	LEFT OUTER JOIN  ma_hakari hakari
	ON tk.cd_hakari = hakari.cd_hakari
	LEFT OUTER JOIN ma_tani tani
	ON hakari.cd_tani = tani.cd_tani
	WHERE
		@dt_seizo <= tk.dt_seizo
		AND tk.dt_seizo <
			(
				SELECT DATEADD(DD,1,@dt_seizo)
			)
		AND tk.cd_seihin = @cd_haigo
		AND tk.su_kai = @su_kai
		AND tk.no_tonyu = @no_tonyu
		AND tk.cd_line = @cd_line
		AND tk.no_kotei = @no_kotei
		AND tk.cd_hinmei = @cd_hinmei
		AND (tk.no_lot_seihin = @no_lot_seihin 
		OR tk.no_lot_seihin is NULL)
		AND tk.su_ko = @su_ko
		AND tk.kbn_seikihasu = @kbn_seikihasu
		AND tk.kbn_kowakehasu = @kbn_kowakehasu
		AND (tk.ritsu_kihon IS NULL
				OR tk.ritsu_kihon = @ritsu_kihon)
	GROUP BY
	    tk.dt_kowake
	    , tk.cd_hinmei
	    , tk.nm_hinmei
	    , tk.nm_seihin
	    , tk.wt_haigo
	    ,tani.nm_tani
	    , tk.su_kai
	    , tk.su_ko
	    , tk.no_tonyu
	    , tanto_hyoryo.nm_tanto
	    , tk.dt_chikan
	    , tanto_chikan.nm_tanto
	    , tk.kbn_seikihasu
		, hinKbnMa.kbn_hin
		, hinKbnMa.nm_kbn_hin
	ORDER BY 
	    tk.dt_kowake 
END
GO
