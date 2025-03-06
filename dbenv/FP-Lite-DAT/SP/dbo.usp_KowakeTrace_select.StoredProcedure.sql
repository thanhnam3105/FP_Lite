IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KowakeTrace_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KowakeTrace_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：小分実績トレース画面　検索
ファイル名	：usp_KowakeTrace_select
入力引数	：@chk_dt_kowake ,@dt_kowake_st ,@dt_kowake_en
			 ,@chk_dt_seizo ,@dt_seizo_st ,@dt_seizo_en
			 ,@chk_dt_genryo ,@dt_genryoSeizo_st ,@dt_genryoSeizo_en
			 ,@chk_cd_shokuba ,@cd_shokuba ,@chk_kbn_hin
			 ,@kbn_hin ,@chk_genryo ,@genryoLot
			 ,@chk_cd_genryo ,@cd_genryo ,@chk_cd_haigo
			 ,@cd_haigo ,@kbn_haki ,@kbn_jikagen
			 ,@skip ,@top ,@isExcel
出力引数	：	
戻り値		：
作成日		：2014.01.16  ADMAX endo.y
更新日		：2015.08.06  ADMAX kakuta.y 品区分の原料・自家原料と仕掛品を考慮
更新日		：2016.08.19  BRC motojima.m LB対応
更新日		：2018.02.26  BRC yokota.t	 解凍ラベル対応
更新日		：2018.05.15  BRC tokumoto.k 開封前賞味期限追加
*****************************************************/
CREATE  PROCEDURE [dbo].[usp_KowakeTrace_select](
	@chk_dt_kowake		SMALLINT	--検索条件/小分日チェック
	,@dt_kowake_st		DATETIME	--検索条件/小分日(開始)
	,@dt_kowake_en		DATETIME	--検索条件/小分日(終了)
	,@chk_dt_seizo		SMALLINT	--検索条件/製造日チェック
	,@dt_seizo_st		DATETIME	--検索条件/製造日(開始)
	,@dt_seizo_en		DATETIME	--検索条件/製造日(終了)
	,@chk_dt_genryo		SMALLINT	--検索条件/原料製造日チェック
	,@dt_genryoSeizo_st	DATETIME	--検索条件/原料製造日(開始)
	,@dt_genryoSeizo_en	DATETIME	--検索条件/原料製造日(終了)
	,@chk_cd_shokuba	SMALLINT	--検索条件/職場チェック
	,@cd_shokuba		VARCHAR(10)	--検索条件/職場
	,@chk_kbn_hin		SMALLINT	--検索条件/品区分チェック
	,@kbn_hin			SMALLINT	--検索条件/品区分
	,@chk_genryo		SMALLINT	--検索条件/原料ロットチェック
	,@genryoLot			VARCHAR(14)	--検索条件/原料ロット
	,@chk_cd_genryo		SMALLINT	--検索条件/原料コードチェック
	,@cd_genryo			VARCHAR(14)	--検索条件/原料コード
	,@chk_cd_haigo		SMALLINT	--検索条件/配合コードチェック
	,@cd_haigo			VARCHAR(14)	--検索条件/配合コード
	,@kbn_haki			SMALLINT	--検索条件/破棄表示
	--,@kbn_jikagen		SMALLINT	--品区分.自家原料
	,@kbn_jikagen		SMALLINT	--処理品
	,@skip				DECIMAL(10)
	,@top				DECIMAL(10)
	,@isExcel			BIT
	,@genryoHinKbn		SMALLINT	--品区分.原料
	,@shikakariHinKbn	SMALLINT	--品区分.仕掛品
	,@jikagenHinKbn		SMALLINT	--品区分.自家原料
	,@pageHinKbn		SMALLINT	--検索条件/原料品区分
	,@genryoPageHinKbn	SMALLINT	--原料品区分.原料・自家原料
	,@haigoPageHinKbn	SMALLINT	--原料品区分.仕掛品
)
AS
BEGIN
    DECLARE  @start				DECIMAL(10)
    DECLARE  @end				DECIMAL(10)
	DECLARE  @true				BIT
	DECLARE  @false				BIT
	DECLARE  @day				SMALLINT
	DECLARE  @haki				SMALLINT
    SET      @start = @skip + 1
    SET      @end   = @skip + @top
    SET      @true  = 1
    SET      @false = 0
    SET		 @day   = 1
	SET @haki =
	CASE 
	WHEN @kbn_haki = 1 THEN
	0
	WHEN @kbn_haki = 2 THEN
	1
	ELSE
	2
	END
    
    BEGIN
		WITH cte AS
		(    
			SELECT
				ISNULL(kowake.cd_seihin,'') AS cd_hin
				,ISNULL(kowake.nm_seihin,'') AS nm_hin
				,ISNULL(kowake.cd_hinmei,'') AS cd_genryo
				,ISNULL(kowake.nm_hinmei,'') AS nm_genryo
				,ISNULL(kowake.no_kotei,0) AS no_kotei
				,ISNULL(kowake.su_kai,0) AS su_kai
				,ISNULL(kowake.no_tonyu,0) AS no_tonyu
				,ISNULL(kowake.su_ko,0) AS su_ko
				,kowake.dt_kowake AS dt_kowake
				--CONVERT(VARCHAR,ISNULL(kowake.dt_kowake,''),111) dt_kowake
				,ISNULL(kowake.cd_line,'') AS cd_line
				,ISNULL(line.nm_line,'') AS nm_line
				,ISNULL(line.cd_shokuba,'') AS cd_shokuba
				,ISNULL(shokuba.nm_shokuba,'') AS nm_shokuba
				,ISNULL(ROUND(kowake.wt_haigo,3),0) AS qty_haigo
				,ISNULL(ROUND(kowake.wt_jisseki,3),0) AS qty_jiseki
				,tani.nm_tani
				,kowake.dt_shomi AS dt_shomi_mikaifu
				,CASE
					WHEN kowake.dt_shomi_kaifu > kowake.dt_shomi 
							AND kowake.dt_shomi_kaito > kowake.dt_shomi
						THEN kowake.dt_shomi
					WHEN kowake.dt_shomi_kaifu > kowake.dt_shomi_kaito
							AND kowake.dt_shomi > kowake.dt_shomi_kaito
						THEN kowake.dt_shomi_kaito					
					ELSE kowake.dt_shomi_kaifu
				END AS dt_kigen	
				,kowake.dt_seizo AS dt_seizo_kowake
				,ISNULL(lot.no_lot,'') AS no_lot
				,lot.dt_seizo_genryo AS dt_seizo_niuke
				,ISNULL(mtk.nm_tanto,'') AS nm_tanto_kowake
				,kowake.dt_chikan AS dt_tikan
				,ISNULL(mtt.nm_tanto,'') AS nm_tanto_tikan
				,ROW_NUMBER() OVER (ORDER BY
										line.cd_shokuba,
										kowake.dt_seizo,
										kowake.cd_line,
										kowake.cd_hinmei,
										kowake.cd_seihin,
										kowake.no_kotei,
										kowake.su_kai,
										kowake.no_tonyu,
										kowake.su_ko,
										kowake.dt_kowake
									) AS RN
			FROM tr_kowake kowake
			LEFT OUTER JOIN ma_line line
			ON kowake.cd_line = line.cd_line
			LEFT OUTER JOIN ma_shokuba shokuba
			ON line.cd_shokuba = shokuba.cd_shokuba
			LEFT OUTER JOIN
					--(select * from tr_lot where ((@chk_dt_genryo = @false)
					--	or ( tr_lot.dt_seizo_genryo >= convert(date,@dt_genryoSeizo_st)
					--			and tr_lot.dt_seizo_genryo < convert(date,DATEADD(DD,@day,@dt_genryoSeizo_en))
					--		)
					--) ) lot
			tr_lot lot
			ON kowake.no_lot_kowake = lot.no_lot_jisseki
			AND kowake.wt_jisseki = lot.wt_jisseki
			LEFT OUTER JOIN ma_haigo_mei mhm
			ON mhm.cd_haigo = kowake.cd_seihin
			AND mhm.no_han = 1
			LEFT OUTER JOIN ma_tanto mtk
			ON kowake.cd_tanto_kowake = mtk.cd_tanto
			LEFT OUTER JOIN ma_tanto mtt
			ON kowake.cd_tanto_chikan = mtt.cd_tanto
			LEFT OUTER JOIN  ma_hakari hakari
			ON kowake.cd_hakari = hakari.cd_hakari
			LEFT OUTER JOIN ma_tani tani
			ON hakari.cd_tani = tani.cd_tani
					
			WHERE
				((@chk_cd_shokuba = @false) or line.cd_shokuba = @cd_shokuba)
				AND ((@chk_dt_kowake = @false) 
						OR ( kowake.dt_kowake >= @dt_kowake_st AND kowake.dt_kowake < DATEADD(DD,@day,@dt_kowake_en))
					)
				AND ((@chk_dt_seizo = @false) 
						OR ( kowake.dt_seizo >= @dt_seizo_st AND kowake.dt_seizo < DATEADD(DD,@day,@dt_seizo_en))
					)
				AND ((@chk_dt_genryo = @false) 
						OR ( lot.dt_seizo_genryo >= @dt_genryoSeizo_st AND lot.dt_seizo_genryo < DATEADD(DD,@day,@dt_genryoSeizo_en))
					)
				AND ((@chk_kbn_hin = @false)
						OR ((@kbn_hin = @kbn_jikagen) AND mhm.flg_shorihin = @kbn_jikagen)
					)
				AND ((@chk_cd_genryo = @false) OR kowake.cd_hinmei = @cd_genryo)
				AND ((@chk_cd_haigo = @false) OR kowake.cd_seihin = @cd_haigo)
				AND ((@chk_genryo = @false) OR lot.no_lot = @genryoLot)
				AND ((@kbn_haki = @false) OR (kowake.flg_kanryo_tonyu = @haki))
				AND (@chk_cd_genryo = @false -- 原料が指定されていない場合は品区分での抽出を行いません。
						OR (@pageHinKbn = @genryoPageHinKbn AND (kowake.kbn_hin = @genryoHinKbn OR kowake.kbn_hin = @jikagenHinKbn))
						OR (@pageHinKbn = @haigoPageHinKbn AND kowake.kbn_hin = @shikakariHinKbn)
					)
		)
		-- 画面に返却する値を取得
		SELECT
			cnt
			,cte_row.dt_seizo_kowake
			,cte_row.nm_line
			,cte_row.cd_hin
			,cte_row.nm_hin
			,cte_row.cd_genryo
			,cte_row.nm_genryo
			,cte_row.no_kotei
			,cte_row.su_kai
			,cte_row.no_tonyu
			,cte_row.su_ko
			,cte_row.qty_haigo
			,cte_row.qty_jiseki
			,cte_row.nm_tani
			,cte_row.dt_kowake
			,cte_row.no_lot
			,cte_row.dt_seizo_niuke
			,cte_row.dt_shomi_mikaifu
			,cte_row.dt_kigen
			,cte_row.nm_tanto_kowake
			,cte_row.dt_tikan
			,cte_row.nm_tanto_tikan
			,cte_row.nm_shokuba
			,cte_row.cd_shokuba
			,cte_row.cd_line
		FROM(
				SELECT
					MAX(RN) OVER() cnt
					,*
				FROM
					cte
			) cte_row
		WHERE
		(
			(
				@isExcel = @false
				AND RN BETWEEN @start AND @end
			)
			OR (
				@isExcel = @true
			)
		)
	END
END


GO
