IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NonyuIraishoList_torihiki_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NonyuIraishoList_torihiki_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		tsujita.s
-- Create date: 2014.01.08
-- Description:	納入依頼書リスト
--    検索条件/取引先情報の取得処理
-- ===============================================
CREATE PROCEDURE [dbo].[usp_NonyuIraishoList_torihiki_select]
	@codes			varchar(1000)	-- 選択された取引先コードまたは品名コード
	,@hizuke_from	datetime		-- 日付：始点
	,@hizuke_to		datetime		-- 日付：終点
	,@today			datetime		-- UTC時間で変換済みシステム日付
	,@yotei_nashi	smallint		-- 1：「予定なしも出力」にチェックあり
	,@flg_hin		smallint		-- 品名選択フラグ(1：品名選択　0：品名選択以外)
	,@flg_shiyo		smallint		-- 定数：未使用フラグ：使用
	,@flg_yotei		smallint		-- 定数：予実フラグ：予定
	,@flg_jisseki	smallint		-- 定数：予実フラグ：実績
AS
BEGIN

	SET NOCOUNT ON

	-- ==================================================================
	--  品 名 選 択 の 場 合
	-- ==================================================================
	IF @flg_hin = 1
	BEGIN
		-- ==================================
		--  「予定なしも出力」にチェックあり
		-- ==================================
		IF @yotei_nashi = 1
		BEGIN
			-- 納入トランになかったものは原資材購入先マスタから取得する
			SELECT
				COALESCE(tori_tr.cd_torihiki, tori_wk.cd_torihiki) AS cd_torihiki
				,COALESCE(tori_tr.nm_torihiki, tori_wk.nm_torihiki) AS nm_torihiki
			FROM (
				-- 納入トラン
				SELECT cd_hinmei AS cd_hinmei
					,cd_torihiki AS cd_torihiki
				FROM tr_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND (
					(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
					OR
					(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
				)
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@codes))
				AND (su_nonyu > 0 OR su_nonyu_hasu > 0)
			) TR

			-- 納入ワークトラン
			LEFT JOIN (
				SELECT cd_hinmei AS cd_hinmei
					,cd_torihiki AS cd_torihiki
				FROM wk_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@codes))
				AND su_nonyu > 0
			) WORK
			ON WORK.cd_hinmei = TR.cd_hinmei

			-- 取引先マスタ_トラン
			LEFT JOIN ma_torihiki tori_tr
			ON tori_tr.cd_torihiki = TR.cd_torihiki
			AND tori_tr.flg_mishiyo = @flg_shiyo

			-- 取引先マスタ_ワーク
			LEFT JOIN ma_torihiki tori_wk
			ON tori_wk.cd_torihiki = WORK.cd_torihiki
			AND tori_wk.flg_mishiyo = @flg_shiyo

		UNION

			SELECT
				tori.cd_torihiki AS cd_torihiki
				,tori.nm_torihiki AS nm_torihiki
			FROM (
				SELECT cd_hinmei
				,MIN(no_juni_yusen) AS no_juni_yusen
				FROM ma_konyu
				WHERE cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@codes))
				AND flg_mishiyo = @flg_shiyo
				GROUP BY cd_hinmei
			) YUSEN

			-- 原資材購入先マスタ
			LEFT JOIN ma_konyu konyu
			ON konyu.cd_hinmei = YUSEN.cd_hinmei
			AND konyu.no_juni_yusen = YUSEN.no_juni_yusen
			AND konyu.flg_mishiyo = @flg_shiyo

			-- 取引先マスタ
			LEFT JOIN ma_torihiki tori
			ON tori.cd_torihiki = konyu.cd_torihiki
			AND tori.flg_mishiyo = @flg_shiyo

			-- 納入トラン
			LEFT JOIN (
				SELECT tr.cd_hinmei AS cd_hinmei
					,tr.su_nonyu AS su_nonyu
				FROM tr_nonyu tr
				INNER JOIN ma_torihiki tori
				ON tori.cd_torihiki = tr.cd_torihiki
				AND tori.flg_mishiyo = @flg_shiyo
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND (
					(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
					OR
					(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
				)
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@codes))
				AND (su_nonyu > 0 OR su_nonyu_hasu > 0)
			) TR
			ON TR.cd_hinmei = konyu.cd_hinmei

			-- 納入ワークトラン
			LEFT JOIN (
				SELECT wk.cd_hinmei AS cd_hinmei
					,wk.su_nonyu AS su_nonyu
				FROM wk_nonyu wk
				INNER JOIN ma_torihiki tori
				ON tori.cd_torihiki = wk.cd_torihiki
				AND tori.flg_mishiyo = @flg_shiyo
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@codes))
				AND su_nonyu > 0
			) WORK
			ON WORK.cd_hinmei = konyu.cd_hinmei

			WHERE tori.cd_torihiki IS NOT NULL
			AND TR.su_nonyu IS NULL
			AND WORK.su_nonyu IS NULL
		END


		-- ==================================
		--  「予定なしも出力」にチェックなし
		-- ==================================
		ELSE BEGIN
		-- 納入予実トランと納入ワークから取得する
			SELECT
				tori.cd_torihiki AS cd_torihiki
				,tori.nm_torihiki AS nm_torihiki
			FROM (
				-- 納入トラン
				SELECT cd_hinmei AS cd_hinmei
					,cd_torihiki AS cd_torihiki
				FROM tr_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND (
					(dt_nonyu < @today AND flg_yojitsu = @flg_jisseki)
					OR
					(dt_nonyu >= @today AND flg_yojitsu = @flg_yotei)
				)
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@codes))
				AND (su_nonyu > 0 OR su_nonyu_hasu > 0)
			) TR

			-- 取引先マスタ_トラン
			LEFT JOIN ma_torihiki tori
			ON tori.cd_torihiki = TR.cd_torihiki
			AND tori.flg_mishiyo = @flg_shiyo
			
			WHERE tori.cd_torihiki IS NOT NULL

		UNION

			SELECT
				tori.cd_torihiki AS cd_torihiki
				,tori.nm_torihiki AS nm_torihiki
			FROM (
				-- 納入ワークトラン
				SELECT cd_hinmei AS cd_hinmei
					,cd_torihiki AS cd_torihiki
				FROM wk_nonyu
				WHERE dt_nonyu >= @hizuke_from
				AND dt_nonyu < @hizuke_to
				AND cd_hinmei
					IN (SELECT id FROM udf_SplitCommaValue(@codes))
				AND su_nonyu > 0
			) WORK

			-- 取引先マスタ_ワーク
			LEFT JOIN ma_torihiki tori
			ON tori.cd_torihiki = WORK.cd_torihiki
			AND tori.flg_mishiyo = @flg_shiyo
			
			WHERE tori.cd_torihiki IS NOT NULL
		END
	END

	-- ==================================================================
	--  品 名 選 択 以 外 の 場 合
	-- ==================================================================
	-- 取引先マスタから取得
	ELSE BEGIN
		SELECT
			cd_torihiki
			,nm_torihiki
		FROM
			ma_torihiki
		WHERE
			cd_torihiki IN (SELECT id FROM udf_SplitCommaValue(@codes))
		AND
			flg_mishiyo = @flg_shiyo
	END


END
GO
