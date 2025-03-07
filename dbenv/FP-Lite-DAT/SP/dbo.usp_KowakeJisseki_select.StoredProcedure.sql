IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KowakeJisseki_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KowakeJisseki_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：小分実績 検索
ファイル名	：usp_KowakeJisseki_select
入力引数	：@cd_panel, @dt, @no_type, @letters_kowake
			  , @letters_haki, @skip, @top
出力引数	：
戻り値		：失敗時[0以外のエラーコード]
作成日		：2013.10.17  ADMAX okuda.k
更新日		：2014.01.30  ADMAX kakuta.y -- 40件検索に対応,集計対応
更新日		：2016.07.22  BRC   motojima.m -- LB対応
更新日		：2017.02.13  BRC   matsumura.y -- QBサポートNo.33対応
更新日		：2017.03.22  BRC   sato.s -- 単体テスト不具合No.84対応
更新日		：2018.02.26  BRC   yokota.t -- 解凍ラベル対応
更新日		：2018.11.02  TOS   nakamura.r -- sort順追加
*****************************************************/
CREATE  PROCEDURE [dbo].[usp_KowakeJisseki_select]
(
	@cd_panel 			VARCHAR(3)	-- 場所番号
	,@dt 				DATETIME	-- 検索日付
	,@no_type			NUMERIC(1)	-- (1:小分記録、2:張替記録)
	,@letters_kowake	smallint	-- 投入完了フラグ．未完了
	,@letters_haki		smallint	-- 投入完了フラグ．完了
	,@skip				DECIMAL(10)	-- 検索条件始点
	,@top				DECIMAL(10)	-- 検索条件上限
)
AS

BEGIN

	DECLARE @start	DECIMAL(11)
    DECLARE @end	DECIMAL(11)
    SET	@start		= @skip + 1
    SET	@end		= @skip + @top

    DECLARE @su_keta_shosuten SMALLINT -- 配合重量の小数点以下の桁数
    SET @su_keta_shosuten = (SELECT TOP 1 su_keta_shosuten FROM ma_kojo)

--小分け記録検索
	IF @no_type = 1
	BEGIN

		WITH cte AS
			(
				SELECT
					*
					,ROW_NUMBER() OVER (ORDER BY uni.cd_hinmei,uni.jikoku) AS RN
				FROM
					(
						SELECT DISTINCT
							tk.dt_kowake AS jikoku
							,tl.no_lot
							,tk.dt_kowake
							,tk.cd_seihin
							,tk.nm_seihin
							,tk.nm_seihin AS seihinmei
							,tk.cd_hinmei
							,tk.nm_hinmei
							,tk.no_kotei
							,tk.su_ko
							,tk.su_kai
							,tk.no_tonyu
							--,tk.wt_haigo
							,CASE --配合重量(小数第@su_keta_shosuten位まで表示。切捨て
							WHEN tani.cd_tani = '3' 
							THEN ROUND(tk.wt_haigo * 1000, @su_keta_shosuten, 1) --g変換 
							ELSE ROUND(tk.wt_haigo, @su_keta_shosuten, 1) 
							END AS wt_haigo
							--,tk.wt_jisseki
							,CASE --実績値(小数第3位まで表示。切捨て
							WHEN tani.cd_tani = '3' 
							THEN ROUND(tk.wt_jisseki * 1000, 3, 1) --g変換
							ELSE ROUND(tk.wt_jisseki, 3, 1) 
							END AS wt_jisseki
							,tani.nm_tani
							,tk.cd_line
							,tk.ritsu_kihon
							,tk.cd_tanto_kowake
							,tanto_kowake.nm_tanto AS nm_tanto_kowake
							,tanto_tikan.nm_tanto AS nm_tanto_tikan
							,tk.dt_chikan
							,tk.dt_shomi
							,tk.dt_shomi_kaifu
							,tk.dt_shomi_kaito
							,tk.dt_seizo
							,CASE ISNULL(tk.flg_kanryo_tonyu, 0)
								WHEN 0 THEN @letters_kowake
								ELSE @letters_haki
							END AS flg_kanryo_tonyu
							,tk.no_lot_kowake
							,tk.no_lot_oya 
						FROM tr_kowake tk
						INNER JOIN
							(
								SELECT
									tr_lot.no_lot_jisseki
									,MIN(no_lot) AS no_lot
								FROM tr_lot
								GROUP BY
									no_lot_jisseki
								HAVING
									COUNT(no_lot_jisseki) < 2
							) tl
						ON tk.no_lot_kowake = tl.no_lot_jisseki
						LEFT OUTER JOIN ma_tanto tanto_kowake
						ON tk.cd_tanto_kowake = tanto_kowake.cd_tanto
						LEFT OUTER JOIN ma_tanto tanto_tikan
						ON tk.cd_tanto_chikan = tanto_tikan.cd_tanto
						LEFT OUTER JOIN  ma_hakari hakari
						ON tk.cd_hakari = hakari.cd_hakari
						LEFT OUTER JOIN ma_tani tani
						ON hakari.cd_tani = tani.cd_tani
						WHERE
							@dt <= tk.dt_kowake
							AND tk.dt_kowake <
								(
									SELECT DATEADD(DD,1,@dt)
								)
							AND tk.cd_panel = @cd_panel
							AND tk.no_lot_oya IS NULL

						UNION

						SELECT DISTINCT
							tl.dt_kowake AS jikoku
							,CASE
								WHEN tk.no_lot_oya IS NULL THEN ''
								ELSE tl.no_lot
							END AS no_lot
							,tk.dt_kowake
							,tk.cd_seihin
							,tk.nm_seihin
							,tk.nm_seihin AS seihinmei
							,tk.cd_hinmei
							,tk.nm_hinmei
							,tk.no_kotei
							,tk.su_ko
							,tk.su_kai
							,tk.no_tonyu
							--,tk.wt_haigo
							,CASE --配合重量(小数第@su_keta_shosuten位まで表示。切捨て
							WHEN tani.cd_tani = '3' 
							THEN ROUND(tk.wt_haigo * 1000, @su_keta_shosuten, 1) --g変換
							ELSE ROUND(tk.wt_haigo, @su_keta_shosuten, 1) 
							END AS wt_haigo
							--,tl.wt_jisseki
							,CASE --実績値(小数第3位まで表示。切捨て
							WHEN tani.cd_tani = '3' 
							THEN ROUND(tl.wt_jisseki * 1000, 3, 1) --g変換
							ELSE ROUND(tl.wt_jisseki, 3, 1) 
							END AS wt_jisseki
							,tani.nm_tani
							,tk.cd_line
							,tk.ritsu_kihon
							,tk.cd_tanto_kowake
							,tanto_kowake.nm_tanto AS nm_tanto_kowake
							,tanto_tikan.nm_tanto AS nm_tanto_tikan
							,tk.dt_chikan
							,tl.dt_shomi
							,tl.dt_shomi_kaifu
							,tl.dt_shomi_kaito
							,tl.dt_seizo
							,CASE ISNULL(tk.flg_kanryo_tonyu, 0)
								WHEN 0 THEN @letters_kowake
								ELSE @letters_haki
							END flg_kanryo_tonyu
							,tl.no_lot_kowake
							,tk.no_lot_oya 
						FROM tr_kowake tk
						INNER JOIN
							(
								SELECT
									tr_kowake.no_lot_oya
									,SUM(tr_kowake.wt_jisseki) AS wt_jisseki
									,MIN(tr_kowake.dt_kowake) AS dt_kowake
									,MIN(tr_kowake.dt_shomi) AS dt_shomi
									,MIN(tr_kowake.dt_shomi_kaifu) AS dt_shomi_kaifu
									,MIN(tr_kowake.dt_shomi_kaito) AS dt_shomi_kaito
									,MIN(tr_kowake.dt_seizo) AS dt_seizo
									,MIN(tr_kowake.no_lot_kowake) AS no_lot_kowake
									,									
									STUFF(		
										(
											SELECT
												--lot_kirikae.no_lot + ','
												',' + lot_kirikae.no_lot
										  	FROM
										  		(
										  			SELECT
										  				tr_lot.no_lot
										  				,tr_lot.no_lot_jisseki
										  				,tr_kowake.no_lot_oya
													FROM tr_lot
													INNER JOIN tr_kowake
													ON tr_kowake.no_lot_kowake = tr_lot.no_lot_jisseki
													WHERE
														@dt <= tr_kowake.dt_kowake
														AND tr_kowake.dt_kowake <
															(
																SELECT DATEADD(DD,1,@dt)
															)
														AND tr_kowake.cd_panel = @cd_panel
														AND tr_kowake.no_lot_oya IS NOT NULL
												) lot_kirikae
											WHERE
												lot_kirikae.no_lot_oya = tr_kowake.no_lot_oya
												AND no_lot IS NOT NULL
											ORDER BY
												lot_kirikae.no_lot_oya
											FOR XML PATH('')
										),1,1,''
										) no_lot
								FROM tr_kowake
								WHERE
									no_lot_oya IS NOT NULL
								GROUP BY
									no_lot_oya
							) tl
						ON tk.no_lot_oya = tl.no_lot_oya
						AND tk.no_lot_kowake = tl.no_lot_oya
						LEFT OUTER JOIN ma_tanto tanto_kowake
						ON tk.cd_tanto_kowake = tanto_kowake.cd_tanto
						LEFT OUTER JOIN ma_tanto tanto_tikan
						ON tk.cd_tanto_chikan = tanto_tikan.cd_tanto
						LEFT OUTER JOIN  ma_hakari hakari
						ON tk.cd_hakari = hakari.cd_hakari
						LEFT OUTER JOIN ma_tani tani
						ON hakari.cd_tani = tani.cd_tani
						WHERE
							@dt <= tk.dt_kowake
							AND tk.dt_kowake <
								(
									SELECT DATEADD(DD,1,@dt)
								)
							AND tk.cd_panel = @cd_panel
					) uni
			)
		-- 画面に返却する値を取得
		SELECT
			cnt	-- 行総数
			,cte_row.jikoku
			,cte_row.no_lot
			,cte_row.dt_kowake
			,cte_row.cd_seihin
			,cte_row.nm_seihin
			,cte_row.seihinmei
			,cte_row.cd_hinmei
			,cte_row.nm_hinmei
			,cte_row.no_kotei
			,cte_row.su_ko
			,cte_row.su_kai
			,cte_row.no_tonyu
			,cte_row.wt_haigo
			,cte_row.wt_jisseki
			,cte_row.nm_tani
			,cte_row.cd_line
			,cte_row.ritsu_kihon
			,cte_row.cd_tanto_kowake
			,cte_row.nm_tanto_kowake
			,cte_row.nm_tanto_tikan
			,cte_row.dt_chikan
			,cte_row.dt_shomi
			,cte_row.dt_shomi_kaifu
			,cte_row.dt_shomi_kaito
			,cte_row.dt_seizo
			,cte_row.flg_kanryo_tonyu
			,cte_row.no_lot_kowake
			,cte_row.no_lot_oya
		FROM
			(
				SELECT 
					MAX(RN) OVER() AS cnt
					,*
				FROM cte
			) cte_row
		WHERE
			RN BETWEEN @start AND @end
		ORDER BY cte_row.RN

	END

	--張替え記録検索
	ELSE IF @no_type = 2
	BEGIN
		WITH cte AS
			(
				SELECT
					*
					,ROW_NUMBER() OVER (ORDER BY uni.no_lot_oya) AS RN
				FROM
					(
						SELECT
							tk.dt_kowake AS jikoku
							,tl.no_lot
							,tk.dt_kowake
							,tk.cd_seihin
							,tk.nm_seihin
							,tk.nm_seihin AS seihinmei
							,tk.cd_hinmei
							,tk.nm_hinmei
							,tk.no_kotei
							,tk.su_ko
							,tk.su_kai
							,tk.no_tonyu
							--,tk.wt_haigo
							,CASE --配合重量(小数第@su_keta_shosuten位まで表示。切捨て
							WHEN tani.cd_tani = '3' 
							THEN ROUND(tk.wt_haigo * 1000, @su_keta_shosuten, 1) --g変換 
							ELSE ROUND(tk.wt_haigo, @su_keta_shosuten, 1) 
							END AS wt_haigo
							--,tk.wt_jisseki
							,CASE --実績値(小数第3位まで表示。切捨て
							WHEN tani.cd_tani = '3' 
							THEN ROUND(tk.wt_jisseki * 1000, 3, 1) --g変換
							ELSE ROUND(tk.wt_jisseki, 3, 1) 
							END AS wt_jisseki
							,tani.nm_tani
							,tk.cd_line
							,tk.ritsu_kihon
							,tk.cd_tanto_kowake
							,tanto_kowake.nm_tanto AS nm_tanto_kowake
							,tanto_tikan.nm_tanto AS nm_tanto_tikan
							,tk.dt_chikan
							,tk.dt_shomi
							,tk.dt_shomi_kaifu
							,tk.dt_shomi_kaito
							,tk.dt_seizo
							,CASE ISNULL(tk.flg_kanryo_tonyu, 0)
								WHEN 0 THEN @letters_kowake
								ELSE @letters_haki
							END flg_kanryo_tonyu
							,tk.no_lot_kowake
							,tk.no_lot_oya 
						FROM tr_kowake tk
						INNER JOIN 
							(
								SELECT
									tr_lot.no_lot_jisseki
									,MIN(no_lot) AS no_lot
								FROM tr_lot
								GROUP BY
								 	no_lot_jisseki
								HAVING COUNT(no_lot_jisseki) < 2
							) tl
						ON tk.no_lot_kowake = tl.no_lot_jisseki
						LEFT OUTER JOIN ma_tanto tanto_kowake
						ON tk.cd_tanto_kowake = tanto_kowake.cd_tanto
						LEFT OUTER JOIN ma_tanto tanto_tikan
						ON tk.cd_tanto_chikan = tanto_tikan.cd_tanto
						LEFT OUTER JOIN  ma_hakari hakari
						ON tk.cd_hakari = hakari.cd_hakari
						LEFT OUTER JOIN ma_tani tani
						ON hakari.cd_tani = tani.cd_tani
						WHERE
							@dt <= tk.dt_chikan
							AND tk.dt_chikan <
								(
									SELECT DATEADD(DD,1,@dt)
								)
							AND tk.cd_panel = @cd_panel
							AND tk.no_lot_oya IS NULL

						UNION

						SELECT DISTINCT
							tl.dt_kowake AS jikoku
							,tl.no_lot
							,tk.dt_kowake
							,tk.cd_seihin
							,tk.nm_seihin
							,tk.nm_seihin AS seihinmei
							,tk.cd_hinmei
							,tk.nm_hinmei
							,tk.no_kotei
							,tk.su_ko
							,tk.su_kai
							,tk.no_tonyu
							--,tk.wt_haigo
							,CASE --配合重量(小数第@su_keta_shosuten位まで表示。切捨て
							WHEN tani.cd_tani = '3' 
							THEN ROUND(tk.wt_haigo * 1000, @su_keta_shosuten, 1) --g変換 
							ELSE ROUND(tk.wt_haigo, @su_keta_shosuten, 1) 
							END AS wt_haigo
							--,tl.wt_jisseki
							,CASE --実績値(小数第3位まで表示。切捨て
							WHEN tani.cd_tani = '3' 
							THEN ROUND(tl.wt_jisseki * 1000, 3, 1) --g変換
							ELSE ROUND(tl.wt_jisseki, 3, 1) 
							END AS wt_jisseki
							,tani.nm_tani
							,tk.cd_line
							,tk.ritsu_kihon
							,tk.cd_tanto_kowake
							,tanto_kowake.nm_tanto AS nm_tanto_kowake
							,tanto_tikan.nm_tanto AS nm_tanto_tikan
							,tk.dt_chikan
							,tl.dt_shomi
							,tl.dt_shomi_kaifu
							,tl.dt_shomi_kaito
							,tl.dt_seizo
							,CASE ISNULL(tk.flg_kanryo_tonyu, 0)
								WHEN 0 THEN @letters_kowake
								ELSE @letters_haki
							END flg_kanryo_tonyu
							,tl.no_lot_kowake
							,tk.no_lot_oya 
						FROM tr_kowake tk
						INNER JOIN 
							(
								SELECT
									tr_kowake.no_lot_oya
									,SUM(tr_kowake.wt_jisseki) AS wt_jisseki
									,MIN(tr_kowake.dt_kowake) AS dt_kowake
									,MIN(tr_kowake.dt_shomi) AS dt_shomi
									,MIN(tr_kowake.dt_shomi_kaifu) AS dt_shomi_kaifu
									,MIN(tr_kowake.dt_shomi_kaito) AS dt_shomi_kaito
									,MIN(tr_kowake.dt_seizo) AS dt_seizo
									,MIN(tr_kowake.no_lot_kowake) AS no_lot_kowake
									,
										(
											SELECT
												lot_kirikae.no_lot + ',' 
											FROM
												(
													SELECT
														tr_lot.no_lot
														,tr_lot.no_lot_jisseki
														,tr_kowake.no_lot_oya
													FROM tr_lot
													INNER JOIN tr_kowake
													ON tr_kowake.no_lot_kowake = tr_lot.no_lot_jisseki
													WHERE
														@dt <= tr_kowake.dt_chikan
														AND tr_kowake.dt_chikan <
															(
																SELECT DATEADD(DD,1,@dt)
															)
														AND tr_kowake.cd_panel = @cd_panel
														AND tr_kowake.no_lot_oya IS NOT NULL
												) lot_kirikae
											WHERE
												lot_kirikae.no_lot_oya = tr_kowake.no_lot_oya
												AND no_lot IS NOT NULL
											ORDER BY
										  		lot_kirikae.no_lot_oya
									   		FOR XML PATH('')
										) no_lot
								FROM tr_kowake
								WHERE
									no_lot_oya IS NOT NULL
								GROUP BY
									no_lot_oya
							) tl
						ON tk.no_lot_oya = tl.no_lot_oya
						AND tk.no_lot_kowake = tl.no_lot_oya
						LEFT OUTER JOIN ma_tanto tanto_kowake
						ON tk.cd_tanto_kowake = tanto_kowake.cd_tanto
						LEFT OUTER JOIN ma_tanto tanto_tikan
						ON tk.cd_tanto_chikan = tanto_tikan.cd_tanto
						LEFT OUTER JOIN  ma_hakari hakari
						ON tk.cd_hakari = hakari.cd_hakari
						LEFT OUTER JOIN ma_tani tani
						ON hakari.cd_tani = tani.cd_tani
						WHERE
							@dt <= tk.dt_chikan
							AND tk.dt_chikan <
								(
									SELECT DATEADD(DD,1,@dt)
								)
							AND tk.cd_panel = @cd_panel

					) uni
			)
		-- 画面に返却する値を取得
		SELECT
			cnt	-- 行総数
			,cte_row.jikoku
			,cte_row.no_lot
			,cte_row.dt_kowake
			,cte_row.cd_seihin
			,cte_row.nm_seihin
			,cte_row.seihinmei
			,cte_row.cd_hinmei
			,cte_row.nm_hinmei
			,cte_row.no_kotei
			,cte_row.su_ko
			,cte_row.su_kai
			,cte_row.no_tonyu
			,cte_row.wt_haigo
			,cte_row.wt_jisseki
			,cte_row.nm_tani
			,cte_row.cd_line
			,cte_row.ritsu_kihon
			,cte_row.cd_tanto_kowake
			,cte_row.nm_tanto_kowake
			,cte_row.nm_tanto_tikan
			,cte_row.dt_chikan
			,cte_row.dt_shomi
			,cte_row.dt_shomi_kaifu
			,cte_row.dt_shomi_kaito
			,cte_row.dt_seizo
			,cte_row.flg_kanryo_tonyu
			,cte_row.no_lot_kowake
			,cte_row.no_lot_oya
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
