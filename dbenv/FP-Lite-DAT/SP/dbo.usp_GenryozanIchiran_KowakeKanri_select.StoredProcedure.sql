IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryozanIchiran_KowakeKanri_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryozanIchiran_KowakeKanri_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：原料残一覧画面 検索
ファイル名	：usp_GenryozanIchiran_KowakeKanri_select
入力引数	：@cd_shokuba, @dt_hyoryo_zan, @chk_zenzan, @chk_shukei
			  , @chk_ari, @chk_nashi, @haki_flg, @taishogaiHakiFlg
			  , @taishoHakiFlg, @shiyoMishiyoFlg, @kigengireKigenFlg
			  , @chokuzenKigenFlg, @chikaiKigenFlg, @yoyuKigenFlg
			  , @kigen_chikai, @kigen_chokuzen, @skip, @top, @isExcel
			  , @dt_utc
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2013.10.02 ADMAX onodera.s
更新日      ：2015.10.05 ADMAX taira.s		賞味期限当日を期限直前とするように修正
更新日      ：2016.08.24 BRC	ieki.h		LB対応
更新日      ：2017.02.15 BRC	kanehira.d	サポートNo.30
更新日      ：2017.06.12 BRC	matsumura.y	職場が選択されていない場合に全職場検索されるよう＆返却値に職場名を含めるように修正
更新日      ：2018.02.26 BRC	yokota.t	解凍ラベル対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GenryozanIchiran_KowakeKanri_select] 
	@cd_shokuba			VARCHAR(10)    --職場コード
	,@dt_hyoryo_zan		DATETIME      --残秤量日
	,@chk_zenzan		SMALLINT      --全原料残チェック
	,@chk_shukei		SMALLINT      --集計チェック
	,@chk_ari			SMALLINT      --チェック有
	,@chk_nashi			SMALLINT      --チェック無
	,@haki_flg			SMALLINT      --破棄フラグ（ラジオボタン）
	,@taishogaiHakiFlg	SMALLINT      --破棄フラグ（破棄対象外）
	,@taishoHakiFlg		SMALLINT      --破棄フラグ（破棄対象）
	,@shiyoMishiyoFlg	SMALLINT      --未使用フラグ（使用）
	,@kigengireKigenFlg	SMALLINT      --期限フラグ（期限切れ）
	,@chokuzenKigenFlg	SMALLINT      --期限フラグ（期限切れ直前）
	,@chikaiKigenFlg	SMALLINT      --期限フラグ（期限切れ近い）
	,@yoyuKigenFlg		SMALLINT      --期限フラグ（期限切れ余裕あり）
	,@kigen_chikai		DECIMAL       --期限切れ近い日数（工場マスタより取得）
	,@kigen_chokuzen	DECIMAL       --期限切れ直前日数（工場マスタより取得）
	,@skip				DECIMAL(10)   --読込開始位置
	,@top				DECIMAL(10)   --画面表示件数
	,@isExcel			BIT           --Excel出力用
	,@dt_utc			DATETIME	  -- システム「年月日」のUTC日時 EX)日本：yyyy/MM/dd 15:00:00.000
	,@kbnKaito			SMALLINT      --解凍ラベル区分
	,@kbnKaitoZan       SMALLINT      --解凍残ラベル区分
AS
    DECLARE @start	DECIMAL(10)
    DECLARE @end	DECIMAL(10)
	DECLARE @true	BIT
	DECLARE @false	BIT
	DECLARE @day	SMALLINT
    SET		@start	= @skip + 1
    SET		@end	= @skip + @top
    SET		@true	= 1
    SET		@false	= 0
    SET		@day	= 1

	-- 「集計」チェックボックスにチェックがある場合、列を埋めるための変数と値
	DECLARE @datetime	DATETIME
	DECLARE	@wt_zero	DECIMAL
	DECLARE	@zeroFlg	SMALLINT
	SET		@datetime	= ''
	SET		@wt_zero	= 0.00
	SET		@zeroFlg	= 0

BEGIN
	-- 集計なし
	IF	@chk_shukei = @chk_nashi
	BEGIN
		WITH cte AS
			(
				SELECT	-- 表示項目
					 ISNULL(TZ.cd_hinmei,'') AS cd_hinmei
					,ISNULL(TZ.nm_hinmei,'') AS nm_hinmei_ja
					,ISNULL(TZ.nm_hinmei,'') AS nm_hinmei_en
					,ISNULL(TZ.nm_hinmei,'') AS nm_hinmei_zh
					,ISNULL(TZ.nm_hinmei,'') AS nm_hinmei_vi
					--,ISNULL(TZ.no_lot,0) AS no_lot
					,CASE 
						WHEN TZ.no_lot = TZ.tkn_no_lot THEN ISNULL(TZ.tkn_old_no_lot,0)
						ELSE ISNULL(TZ.no_lot,0)
					 END AS no_lot
					,ISNULL(TZ.wt_jisseki,0) AS wt_jisseki
					,ISNULL(TZ.wt_jisseki_futai,0) AS wt_jisseki_futai
					,ISNULL(TZ.nm_tani,'') AS nm_tani
					,ISNULL(TZ.cd_panel,'') AS cd_panel
					,ISNULL(TZ.nm_tanto,'') AS nm_tanto
					,ISNULL(TZ.dt_hyoryo_zan,'') AS dt_hyoryo_zan		-- 残秤量日
					,ISNULL(TZ.dt_hyoryo_zan,'') AS tm_hyoryo_zan		-- 処理時刻
					,ISNULL(TZ.dt_shiyo,'') AS dt_shiyo					-- 開封後賞味期限
					,ISNULL(TZ.dt_kigen,'') AS dt_kigen					-- 賞味期限
					,ISNULL(TZ.dt_shomi_kaito,'') AS dt_shomi_kaito		-- 解凍後賞味期限
					,ISNULL(TZ.nm_torihiki,'') AS nm_torihiki
					,ISNULL(TZ.flg_mikaifu,0) AS flg_mikaifu
					,ISNULL(TZ.flg_haki,0) AS flg_haki
					,ISNULL(TZ.nm_shokuba, '') AS nm_shokuba
					-- 非表示項目
					,TZ.no_lot_zan
					,CASE
						-- 使用期限切れ
						WHEN TZ.dt_shiyo < @dt_utc THEN @kigengireKigenFlg						
						-- 使用期限直前
						WHEN TZ.dt_shiyo >=  @dt_utc
						AND TZ.dt_shiyo < DATEADD(DAY,@kigen_chokuzen + 1, @dt_utc) THEN @chokuzenKigenFlg						
						-- 使用期限近い
						WHEN TZ.dt_shiyo >=  DATEADD(DAY,@kigen_chokuzen + 1, @dt_utc)
						AND TZ.dt_shiyo < DATEADD(DAY,@kigen_chikai + 1, @dt_utc) THEN @chikaiKigenFlg
						-- 使用期限まで余裕あり
						ELSE @yoyuKigenFlg
					END AS kigen
					,TZ.kbn_label
					 -- 並び替え条件
					,ROW_NUMBER() OVER (ORDER BY TZ.cd_hinmei,TZ.cd_shokuba,TZ.dt_shiyo) AS RN
				FROM
					(
						SELECT
							tzj.cd_hinmei
							,tzj.nm_hinmei
							,tl.no_lot
							,tzj.wt_jisseki
							,tzj.wt_jisseki_futai
							,tani.nm_tani
							,tzj.cd_panel
							,mta.nm_tanto
							,tzj.dt_hyoryo_zan
							--,tzj.dt_kigen
							,tl.dt_shomi AS dt_kigen
							,mt.nm_torihiki
							,tzj.flg_mikaifu
							,tzj.flg_haki
							,tzj.no_lot_zan
							,mp.cd_shokuba
							,msh.nm_shokuba
							,CASE
								-- 解凍ラベルまたは解凍残ラベルの場合
								WHEN tzj.kbn_label = @kbnKaito OR tzj.kbn_label = @kbnKaitoZan THEN tl.dt_shomi_kaito
								--WHEN tzj.dt_kigen < tl.dt_shomi_kaifu THEN tzj.dt_kigen
								--WHEN tzj.dt_kigen >= tl.dt_shomi_kaifu THEN tl.dt_shomi_kaifu
								WHEN tl.dt_shomi < tl.dt_shomi_kaifu THEN tl.dt_shomi
								WHEN tl.dt_shomi >= tl.dt_shomi_kaifu THEN tl.dt_shomi_kaifu
							END AS dt_shiyo
							,tl.dt_shomi_kaito
							,tkn.no_lot AS tkn_no_lot
							,tkn.old_no_lot AS tkn_old_no_lot
							,tzj.kbn_label AS kbn_label
						FROM tr_zan_jiseki tzj
						LEFT OUTER JOIN ma_torihiki mt
						ON tzj.cd_maker = mt.cd_torihiki
						AND mt.flg_mishiyo = @shiyoMishiyoFlg
						LEFT OUTER JOIN ma_tanto mta
						ON tzj.cd_tanto = mta.cd_tanto
						AND mta.flg_mishiyo = @shiyoMishiyoFlg
						LEFT OUTER JOIN tr_lot tl
						ON tzj.no_lot_zan = tl.no_lot_jisseki
						LEFT OUTER JOIN tr_kongo_nisugata tkn
						ON tzj.no_lot_zan = tkn.no_lot_jisseki
						AND tl.no_lot = tkn.no_lot
						LEFT JOIN ma_panel mp
						ON tzj.cd_panel = mp.cd_panel
						AND mp.flg_mishiyo = @shiyoMishiyoFlg
						LEFT OUTER JOIN  ma_hakari hakari
						ON tzj.cd_hakari = hakari.cd_hakari
						LEFT OUTER JOIN ma_tani tani
						ON hakari.cd_tani = tani.cd_tani
						LEFT JOIN ma_shokuba msh
						ON mp.cd_shokuba = msh.cd_shokuba
					) TZ
				WHERE
					--TZ.cd_shokuba = @cd_shokuba
					(@cd_shokuba IS NULL OR TZ.cd_shokuba = @cd_shokuba)
					AND ((@chk_zenzan = @chk_ari) -- 全原料残チェック
					OR (@dt_hyoryo_zan <= TZ.dt_hyoryo_zan
					AND TZ.dt_hyoryo_zan < (SELECT DATEADD(DD,@day,@dt_hyoryo_zan))))
					AND ((@haki_flg = @chk_ari)	-- 破棄フラグチェック
					OR (TZ.flg_haki = @taishogaiHakiFlg))
			)
		SELECT
			cnt
			-- 表示項目
			,cte_row.cd_hinmei
			,cte_row.nm_hinmei_ja
			,cte_row.nm_hinmei_en
			,cte_row.nm_hinmei_zh
			,cte_row.nm_hinmei_vi
			,cte_row.no_lot
			,cte_row.wt_jisseki
			,cte_row.wt_jisseki_futai
			,cte_row.nm_tani
			,cte_row.cd_panel
			,cte_row.nm_tanto
			,cte_row.dt_hyoryo_zan
			,cte_row.tm_hyoryo_zan
			,cte_row.dt_shiyo
			,cte_row.dt_kigen
			,cte_row.dt_shomi_kaito
			,cte_row.nm_torihiki
			,cte_row.flg_mikaifu
			,cte_row.flg_haki
			,cte_row.nm_shokuba
			-- 非表示項目
			,cte_row.no_lot_zan
			,cte_row.kigen
			,cte_row.kbn_label
		FROM
			(
				SELECT
					MAX(RN) OVER() AS cnt
					,*
				FROM cte
			) cte_row
		WHERE
			(
				(
					@isExcel = @false
					AND RN BETWEEN @start AND @end
				)
				OR @isExcel = @true
			)
	END -- 集計あり
	ELSE IF @chk_shukei = @chk_ari
	BEGIN
		WITH cte AS
			(
				SELECT	-- 表示項目
					 ISNULL(TZ_shukei.cd_hinmei,'') AS cd_hinmei
					,ISNULL(TZ_shukei.nm_hinmei_ja,'') AS nm_hinmei_ja
					,ISNULL(TZ_shukei.nm_hinmei_en,'') AS nm_hinmei_en
					,ISNULL(TZ_shukei.nm_hinmei_zh,'') AS nm_hinmei_zh
					,ISNULL(TZ_shukei.nm_hinmei_vi,'') AS nm_hinmei_vi
					,SUM(TZ_shukei.wt_jisseki) AS wt_jisseki
					,ISNULL(TZ_shukei.nm_tani,'') AS nm_tani
					,ISNULL(TZ_shukei.flg_haki,0) AS flg_haki
					,ISNULL(TZ_shukei.nm_shokuba, '') AS nm_shokuba
					-- 非表示項目
					,ISNULL(TZ_shukei.kigen,'') AS kigen
					-- 「''」は複合型と合わせるための空箇所
					,'' AS no_lot
					,@wt_zero AS wt_jisseki_futai
					,'' AS cd_panel
					,'' AS nm_tanto
					,@datetime AS dt_hyoryo_zan
					,@datetime AS tm_hyoryo_zan
					,@datetime AS dt_shiyo
					,@datetime AS dt_kigen
					,@datetime AS dt_shomi_kaito
					,'' AS nm_torihiki
					,@zeroFlg AS flg_mikaifu
					,'' AS no_lot_zan
					,@zeroFlg AS kbn_label
					-- 並び替え条件
					,ROW_NUMBER() OVER (ORDER BY TZ_shukei.cd_hinmei, TZ_shukei.cd_shokuba) AS RN
				FROM
					(
						SELECT
							TZ.cd_hinmei
							,CASE
								-- 仕掛残の場合
								WHEN TZ.kbn_label = 5 THEN 
									-- 配合マスタに登録がない場合は残実績トランの配合名を取得
									(CASE 
										WHEN TZ.haigoCode IS NOT NULL THEN TZ.nm_haigo_ja ELSE TZ.nm_hinmei
									END)
								-- 原料残の場合
								ELSE
									-- 品名マスタに登録がない場合は残実績トランの品名を取得 
									(CASE 
										WHEN TZ.hinCode IS NOT NULL THEN TZ.nm_hinmei_ja ELSE TZ.nm_hinmei
									END) 
							END AS nm_hinmei_ja
							,CASE
								 -- 仕掛残の場合
								WHEN TZ.kbn_label = 5 THEN 
									(CASE 
										WHEN TZ.haigoCode IS NOT NULL THEN TZ.nm_haigo_en ELSE TZ.nm_hinmei
									END)
								-- 原料残の場合
								ELSE 
									(CASE 
										WHEN TZ.hinCode IS NOT NULL THEN TZ.nm_hinmei_en ELSE TZ.nm_hinmei
									END) 
							END AS nm_hinmei_en
							,CASE
								-- 仕掛残の場合
								WHEN TZ.kbn_label = 5 THEN 
									(CASE 
										WHEN TZ.haigoCode IS NOT NULL THEN TZ.nm_haigo_zh ELSE TZ.nm_hinmei
									END) 
								-- 原料残の場合
								ELSE
									(CASE 
										WHEN TZ.hinCode IS NOT NULL THEN TZ.nm_hinmei_zh ELSE TZ.nm_hinmei
									END)  
							END AS nm_hinmei_zh
							,CASE
								 -- 仕掛残の場合
								WHEN TZ.kbn_label = 5 THEN 
									(CASE 
										WHEN TZ.haigoCode IS NOT NULL THEN TZ.nm_haigo_vi ELSE TZ.nm_hinmei
									END)
								-- 原料残の場合
								ELSE 
									(CASE 
										WHEN TZ.hinCode IS NOT NULL THEN TZ.nm_hinmei_vi ELSE TZ.nm_hinmei
									END) 
							END AS nm_hinmei_vi
							,TZ.wt_jisseki
							,TZ.nm_tani
							,TZ.cd_shokuba
							,TZ.nm_shokuba
							,TZ.flg_haki
							,CASE
								-- 使用期限切れ
								WHEN TZ.dt_shiyo < @dt_utc THEN @kigengireKigenFlg
								-- 使用期限直前
								WHEN TZ.dt_shiyo >=  @dt_utc
								AND TZ.dt_shiyo < DATEADD(DAY,@kigen_chokuzen + 1, @dt_utc) THEN @chokuzenKigenFlg
								-- 使用期限近い
								WHEN TZ.dt_shiyo >=  DATEADD(DAY,@kigen_chokuzen + 1, @dt_utc)
								AND TZ.dt_shiyo < DATEADD(DAY,@kigen_chikai + 1, @dt_utc) THEN @chikaiKigenFlg
								-- 使用期限まで余裕あり
								ELSE @yoyuKigenFlg
							END AS kigen
						FROM
							(
								SELECT
									tzj.cd_hinmei
									,mh.cd_hinmei as hinCode
									,mhm.cd_haigo as haigoCode
									,mh.nm_hinmei_ja
									,mh.nm_hinmei_en
									,mh.nm_hinmei_zh
									,mh.nm_hinmei_vi
									,mhm.nm_haigo_ja
									,mhm.nm_haigo_en
									,mhm.nm_haigo_zh
									,mhm.nm_haigo_vi
									,tzj.nm_hinmei
									,tzj.wt_jisseki
									,tani.nm_tani
									,tzj.flg_haki
									,mp.cd_shokuba
									,msh.nm_shokuba 
									,tzj.dt_hyoryo_zan
									,tzj.kbn_label
									,CASE
										-- 解凍残ラベルの場合
										WHEN tzj.kbn_label = @kbnKaitoZan THEN tl.dt_shomi_kaito
										--WHEN tzj.dt_kigen < tl.dt_shomi_kaifu THEN tzj.dt_kigen
										--WHEN tzj.dt_kigen >= tl.dt_shomi_kaifu THEN tl.dt_shomi_kaifu
										WHEN tl.dt_shomi < tl.dt_shomi_kaifu THEN tl.dt_shomi
										WHEN tl.dt_shomi >= tl.dt_shomi_kaifu THEN tl.dt_shomi_kaifu
									 END AS dt_shiyo
								FROM tr_zan_jiseki tzj
								LEFT OUTER JOIN tr_lot tl
								ON tzj.no_lot_zan = tl.no_lot_jisseki
								LEFT OUTER JOIN ma_panel mp
								ON tzj.cd_panel = mp.cd_panel
								AND mp.flg_mishiyo = @shiyoMishiyoFlg
								LEFT OUTER JOIN ma_hinmei mh
								ON tzj.cd_hinmei = mh.cd_hinmei
								LEFT OUTER JOIN ma_haigo_mei mhm
								ON tzj.cd_hinmei = mhm.cd_haigo
								AND mhm.no_han = 1
								LEFT OUTER JOIN  ma_hakari hakari
								ON tzj.cd_hakari = hakari.cd_hakari
								LEFT OUTER JOIN ma_tani tani
								ON hakari.cd_tani = tani.cd_tani
								LEFT JOIN ma_shokuba msh
								ON mp.cd_shokuba = msh.cd_shokuba
							) TZ
						WHERE
							--TZ.cd_shokuba = @cd_shokuba
							(@cd_shokuba IS NULL OR TZ.cd_shokuba = @cd_shokuba)
							AND (	-- 全原料残チェック
									(@chk_zenzan = @chk_ari)
									OR (
										@dt_hyoryo_zan <= TZ.dt_hyoryo_zan
										AND TZ.dt_hyoryo_zan <
											(
												SELECT DATEADD(DD,@day,@dt_hyoryo_zan)
											)
										)
							)
							AND (	-- 破棄フラグチェック
									(@haki_flg = @chk_ari)
									OR (TZ.flg_haki = @taishogaiHakiFlg)
								)
							AND kbn_label != @kbnKaito	-- 解凍ラベル区分は除外 
					) TZ_shukei
				GROUP BY
					TZ_shukei.cd_hinmei
					,TZ_shukei.nm_hinmei_ja
					,TZ_shukei.nm_hinmei_en
					,TZ_shukei.nm_hinmei_zh
					,TZ_shukei.nm_hinmei_vi
					,TZ_shukei.kigen
					,TZ_shukei.nm_tani
					,TZ_shukei.flg_haki
					,TZ_shukei.cd_shokuba
					,TZ_shukei.nm_shokuba
			)
		SELECT
			cnt
			-- 表示項目
			,cte_row.cd_hinmei
			,cte_row.nm_hinmei_ja
			,cte_row.nm_hinmei_en
			,cte_row.nm_hinmei_zh
			,cte_row.nm_hinmei_vi
			,cte_row.flg_haki
			,cte_row.nm_shokuba
			-- 非表示項目
			,cte_row.kigen
			-- 「''」「0」は複合型と合わせるための空箇所
			,cte_row.no_lot
			,cte_row.wt_jisseki
			,cte_row.wt_jisseki_futai
			,cte_row.nm_tani
			,cte_row.cd_panel
			,cte_row.nm_tanto
			,cte_row.dt_hyoryo_zan
			,cte_row.tm_hyoryo_zan
			,cte_row.dt_shiyo
			,cte_row.dt_kigen
			,cte_row.dt_shomi_kaito
			,cte_row.nm_torihiki
			,cte_row.flg_mikaifu
			,cte_row.no_lot_zan
			,cte_row.kbn_label
		FROM
			(
				SELECT
					MAX(RN) OVER() AS cnt
					,*
				FROM cte
			) cte_row
		WHERE
			(
				(
					@isExcel = @false
					AND RN BETWEEN @start AND @end
				)
				OR @isExcel = @true
			)
	END
END


GO