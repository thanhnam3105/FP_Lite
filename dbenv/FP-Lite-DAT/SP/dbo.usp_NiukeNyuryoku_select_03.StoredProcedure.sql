IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_select_03') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_select_03]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：荷受入力 品名コードから関連項目の値を取得します。
ファイル名  ：usp_NiukeNyuryoku_select_03
入力引数    ：@cd_hinmei, @cd_torihiki, @shiyoMishiyoFlg
出力引数    ：
戻り値      ：
作成日      ：2013.11.06  ADMAX kakuta.y
更新日      ：2022.02.07  BRC   sato.t #1648対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_select_03] 
	@cd_hinmei				VARCHAR(14)
	,@cd_torihiki			VARCHAR(13)
	,@shiyoMishiyoFlg		SMALLINT
AS
BEGIN
	DECLARE @blankStr	VARCHAR
	DECLARE @initInt	SMALLINT
	DECLARE @initDeci	DECIMAL(1,0)
	
	SET		@blankStr	= ''
	SET		@initInt	= 0
	SET		@initDeci	= 0;

	IF @cd_torihiki = '' 
		OR @cd_torihiki IS NULL
	
	BEGIN
	
		SELECT	
			m_ko.cd_torihiki													-- 取引先コード
			,m_tori.nm_torihiki													-- 取引先名
			,ISNULL(m_ko.cd_torihiki2, @blankStr) AS cd_torihiki2				-- 取引先コード2
			,m_tori2.nm_torihiki AS nm_torihiki2								-- 取引先名2
			,ISNULL(m_hin.kbn_hin, @initInt) AS kbn_hin							-- 品区分
			,m_ko.cd_hinmei														-- 品名コード
			,ISNULL(m_hin.nm_hinmei_ja, @blankStr) AS nm_hinmei_ja				-- 品名(日本語)
			,ISNULL(m_hin.nm_hinmei_en, @blankStr) AS nm_hinmei_en				-- 品名(英語)
			,ISNULL(m_hin.nm_hinmei_zh, @blankStr) AS nm_hinmei_zh				-- 品名(中国語)
			,ISNULL(m_hin.nm_hinmei_vi, @blankStr) AS nm_hinmei_vi
			,ISNULL(m_hin.nm_nisugata_hyoji, @blankStr) AS nm_nisugata_hyoji	-- 荷姿
			,m_ko.cd_tani_nonyu													-- 納入単位コード
			,m_tan.nm_tani														-- 納入単位
			,m_ko.tan_nonyu														-- 納入単価
			,ISNULL(m_hin.kbn_hokan, @blankStr)	AS kbn_hokan					-- 保管区分
			,m_hokan.nm_hokan_kbn												-- 品位状態
			,m_ko.su_iri														-- 入数
			,m_ko.wt_nonyu														-- 一個の量
			,ISNULL(m_hin.dd_shomi, @initDeci) AS dd_shomi						-- 賞味期間
			,ISNULL(m_hin.cd_bunrui, @blankStr) AS cd_bunrui					-- 分類コード
			,m_bun.nm_bunrui													-- 分類名
			,ISNULL(m_hin.biko, @blankStr) AS biko								-- 備考
			,m_hin.kbn_zei														-- 税区分
			,m_hin.cd_niuke_basho												-- 荷受場所コード
			,m_ko.cd_tani_nonyu_hasu													-- 納入単位(端数)コード
			,m_tan_hasu.nm_tani AS nm_tani_hasu														-- 納入単位(端数)
		FROM ma_konyu m_ko
		INNER JOIN
			(
				SELECT
					cd_hinmei
					,MIN(no_juni_yusen) no_juni_yusen
				FROM ma_konyu
				WHERE
					cd_hinmei = @cd_hinmei
					AND flg_mishiyo = @shiyoMishiyoFlg
				GROUP BY
					cd_hinmei
			) min_ko
		ON m_ko.cd_hinmei = min_ko.cd_hinmei
		AND m_ko.no_juni_yusen = min_ko.no_juni_yusen
		INNER JOIN ma_hinmei m_hin
		ON m_ko.cd_hinmei			= m_hin.cd_hinmei
		LEFT OUTER JOIN ma_bunrui m_bun
		ON m_hin.cd_bunrui = m_bun.cd_bunrui
		AND m_hin.kbn_hin = m_bun.kbn_hin
		AND m_bun.flg_mishiyo = @shiyoMishiyoFlg	-- 現行なし
		LEFT OUTER JOIN ma_kbn_hokan m_hokan
		ON m_hin.kbn_hokan = m_hokan.cd_hokan_kbn
		AND m_hokan.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tan
		ON m_ko.cd_tani_nonyu = m_tan.cd_tani
		AND m_tan.flg_mishiyo = @shiyoMishiyoFlg	-- 現行なし
		LEFT OUTER JOIN ma_torihiki m_tori
		ON m_ko.cd_torihiki = m_tori.cd_torihiki
		AND m_tori.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_torihiki m_tori2
		ON m_ko.cd_torihiki2 = m_tori2.cd_torihiki
		AND m_tori2.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tan_hasu
		ON m_ko.cd_tani_nonyu_hasu = m_tan_hasu.cd_tani
		AND m_tan_hasu.flg_mishiyo = @shiyoMishiyoFlg
		WHERE
			m_ko.flg_mishiyo = @shiyoMishiyoFlg
			AND m_hin.flg_mishiyo = @shiyoMishiyoFlg
					
		UNION
		SELECT
			@blankStr AS cd_torihiki											-- 取引先コード
			,@blankStr AS nm_torihiki											-- 取引先名
			,@blankStr AS cd_torihiki2											-- 取引先コード2
			,@blankStr AS nm_torihiki2											-- 取引先名2
			,ISNULL(m_hin.kbn_hin, @initInt) AS kbn_hin							-- 品区分
			,m_hin.cd_hinmei													-- 品名コード
			,ISNULL(m_hin.nm_hinmei_ja, @blankStr) AS nm_hinmei_ja				-- 品名(日本語)
			,ISNULL(m_hin.nm_hinmei_en, @blankStr) AS nm_hinmei_en				-- 品名(英語)
			,ISNULL(m_hin.nm_hinmei_zh, @blankStr) AS nm_hinmei_zh				-- 品名(中国語)
			,ISNULL(m_hin.nm_hinmei_vi, @blankStr) AS nm_hinmei_vi
			,ISNULL(m_hin.nm_nisugata_hyoji, @blankStr) AS nm_nisugata_hyoji	-- 荷姿
			,ISNULL(m_hin.cd_tani_nonyu, @blankStr) AS cd_tani_nonyu			-- 納入単位コード
			,m_tan.nm_tani														-- 納入単位
			,ISNULL(m_hin.tan_nonyu, @initDeci) AS tan_nonyu					-- 納入単価
			,ISNULL(m_hin.kbn_hokan, @blankStr) AS kbn_hokan					-- 保管区分
			,m_hokan.nm_hokan_kbn												-- 品位状態
			,ISNULL(m_hin.su_iri, @initDeci) AS su_iri							-- 入数
			,ISNULL(m_hin.wt_ko, @initDeci) AS wt_nonyu							-- 一個の量
			,ISNULL(m_hin.dd_shomi, @initDeci) AS dd_shomi						-- 賞味期間
			,ISNULL(m_hin.cd_bunrui, @blankStr) AS cd_bunrui					-- 分類コード
			,m_bun.nm_bunrui													-- 分類名
			,ISNULL(m_hin.biko, @blankStr) AS biko								-- 備考
			,m_hin.kbn_zei														-- 税区分
			,m_hin.cd_niuke_basho												-- 荷受場所コード
			,ISNULL(m_hin.cd_tani_nonyu_hasu, @blankStr) AS cd_tani_nonyu_hasu			-- 納入単位(端数)コード
			,m_tan_hasu.nm_tani AS nm_tani_hasu														-- 納入単位(端数)
		FROM ma_hinmei m_hin
		LEFT OUTER JOIN ma_bunrui m_bun
		ON m_hin.cd_bunrui = m_bun.cd_bunrui
		AND m_hin.kbn_hin = m_bun.kbn_hin
		AND m_bun.flg_mishiyo = @shiyoMishiyoFlg	-- 現行なし
		LEFT OUTER JOIN ma_tani m_tan
		ON m_hin.cd_tani_nonyu = m_tan.cd_tani
		AND m_tan.flg_mishiyo = @shiyoMishiyoFlg	-- 現行なし
		LEFT OUTER JOIN ma_kbn_hokan m_hokan
		ON m_hin.kbn_hokan = m_hokan.cd_hokan_kbn
		AND m_hokan.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tan_hasu
		ON m_hin.cd_tani_nonyu_hasu = m_tan_hasu.cd_tani
		AND m_tan_hasu.flg_mishiyo = @shiyoMishiyoFlg
		WHERE
			NOT EXISTS 
			(
				SELECT
					*
				FROM ma_konyu m_ko
				INNER JOIN
					(
						SELECT
							cd_hinmei
							,MIN(no_juni_yusen) AS no_juni_yusen
						FROM ma_konyu
						WHERE
							cd_hinmei = @cd_hinmei
							AND flg_mishiyo = @shiyoMishiyoFlg
						GROUP BY
							cd_hinmei
					) min_ko
				ON m_ko.cd_hinmei = min_ko.cd_hinmei
				AND m_ko.no_juni_yusen	= min_ko.no_juni_yusen
				INNER JOIN ma_hinmei m_hin
				ON m_ko.cd_hinmei = m_hin.cd_hinmei
				LEFT OUTER JOIN ma_tani m_tan
				ON m_ko.cd_tani_nonyu = m_tan.cd_tani
				AND m_tan.flg_mishiyo = @shiyoMishiyoFlg	-- 現行なし
				LEFT OUTER JOIN ma_torihiki m_tori
				ON m_ko.cd_torihiki = m_tori.cd_torihiki
				AND m_tori.flg_mishiyo = @shiyoMishiyoFlg	-- 現行なし
				LEFT OUTER JOIN ma_torihiki m_tori2
				ON m_ko.cd_torihiki2 = m_tori2.cd_torihiki
				AND m_tori2.flg_mishiyo = @shiyoMishiyoFlg	-- 現行なし
				WHERE
					m_ko.flg_mishiyo = @shiyoMishiyoFlg
					AND m_hin.flg_mishiyo = @shiyoMishiyoFlg
			)
			AND m_hin.flg_mishiyo = @shiyoMishiyoFlg
			AND m_hin.cd_hinmei = @cd_hinmei
			ORDER BY
				cd_hinmei					 						

	END

	ELSE

	BEGIN
	
		SELECT	
			m_ko.cd_torihiki						-- 取引先コード
			,m_tori.nm_torihiki						-- 取引先名
			,m_ko.cd_torihiki2						-- 取引先コード2
			,m_tori2.nm_torihiki AS nm_torihiki2	-- 取引先名2
			,m_hin.kbn_hin				-- 品区分
			,m_ko.cd_hinmei				-- 品名コード
			,m_hin.nm_hinmei_ja			-- 品名(日本語)
			,m_hin.nm_hinmei_en			-- 品名(英語)
			,m_hin.nm_hinmei_zh			-- 品名(中国語)
			,m_hin.nm_hinmei_vi
			,m_hin.nm_nisugata_hyoji	-- 荷姿
			,m_ko.cd_tani_nonyu			-- 納入単位コード
			,m_tan.nm_tani				-- 納入単位
			,m_ko.tan_nonyu				-- 納入単価
			,m_hin.kbn_hokan			-- 保管区分
			,m_hokan.nm_hokan_kbn		-- 品位状態
			,m_ko.su_iri				-- 入数
			,m_ko.wt_nonyu  AS wt_nonyu	-- 一個の量
			,m_hin.dd_shomi				-- 賞味期間
			,m_hin.cd_bunrui			-- 分類コード
			,m_bun.nm_bunrui			-- 分類名
			,m_hin.biko					-- 備考
			,m_hin.kbn_zei				-- 税区分
			,m_hin.cd_niuke_basho		-- 荷受場所コード
			,m_ko.cd_tani_nonyu_hasu	-- 納入単位(端数)コード
			,m_tan_hasu.nm_tani AS nm_tani_hasu	-- 納入単位(端数)
		FROM ma_konyu m_ko
		INNER JOIN ma_hinmei m_hin
		ON m_ko.cd_hinmei = m_hin.cd_hinmei
		LEFT OUTER JOIN ma_bunrui m_bun
		ON m_hin.cd_bunrui = m_bun.cd_bunrui
		AND m_hin.kbn_hin = m_bun.kbn_hin
		AND m_bun.flg_mishiyo = @shiyoMishiyoFlg	-- 現行なし
		LEFT OUTER JOIN ma_kbn_hokan m_hokan
		ON m_hin.kbn_hokan = m_hokan.cd_hokan_kbn
		AND m_hokan.flg_mishiyo	= @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tan
		ON m_ko.cd_tani_nonyu = m_tan.cd_tani
		AND m_tan.flg_mishiyo = @shiyoMishiyoFlg	-- 現行なし
		LEFT OUTER JOIN ma_torihiki m_tori
		ON m_ko.cd_torihiki	= m_tori.cd_torihiki
		AND m_tori.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_torihiki m_tori2
		ON m_ko.cd_torihiki2 = m_tori2.cd_torihiki
		AND m_tori2.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tan_hasu
		ON m_ko.cd_tani_nonyu_hasu = m_tan_hasu.cd_tani
		AND m_tan_hasu.flg_mishiyo = @shiyoMishiyoFlg
		WHERE
			m_ko.flg_mishiyo = @shiyoMishiyoFlg
			AND m_hin.flg_mishiyo = @shiyoMishiyoFlg
			AND m_ko.cd_hinmei = @cd_hinmei
			AND m_ko.cd_torihiki = @cd_torihiki
	UNION
		SELECT
			@blankStr AS cd_torihiki									-- 取引先コード
			,@blankStr AS nm_torihiki									-- 取引先名
			,@blankStr AS cd_torihiki2									-- 取引先コード2
			,@blankStr AS nm_torihiki2									-- 取引先名2
			,m_hin.kbn_hin												-- 品区分
			,m_hin.cd_hinmei											-- 品名コード
			,m_hin.nm_hinmei_ja											-- 品名(日本語)
			,m_hin.nm_hinmei_en											-- 品名(英語)
			,m_hin.nm_hinmei_zh											-- 品名(中国語)
			,m_hin.nm_hinmei_vi
			,m_hin.nm_nisugata_hyoji									-- 荷姿
			,ISNULL(m_hin.cd_tani_nonyu, @blankStr) AS cd_tani_nonyu	-- 納入単位コード
			,m_tan.nm_tani												-- 納入単位
			,m_hin.tan_nonyu											-- 納入単価
			,m_hin.kbn_hokan											-- 保管区分
			,m_hokan.nm_hokan_kbn										-- 品位状態
			,m_hin.su_iri												-- 入数
			,m_hin.wt_ko AS wt_nonyu									-- 一個の量
			,m_hin.dd_shomi												-- 賞味期間
			,m_hin.cd_bunrui											-- 分類コード
			,m_bun.nm_bunrui											-- 分類名
			,m_hin.biko													-- 備考
			,m_hin.kbn_zei												-- 税区分
			,m_hin.cd_niuke_basho										-- 荷受場所コード
			,ISNULL(m_hin.cd_tani_nonyu_hasu, @blankStr) AS cd_tani_nonyu_hasu	-- 納入単位(端数)コード
			,m_tan_hasu.nm_tani AS nm_tani_hasu									-- 納入単位(端数) 
		FROM ma_hinmei m_hin
		LEFT OUTER JOIN ma_bunrui m_bun
		ON m_hin.cd_bunrui = m_bun.cd_bunrui
		AND m_hin.kbn_hin = m_bun.kbn_hin
		AND m_bun.flg_mishiyo = @shiyoMishiyoFlg	-- 現行なし
		LEFT OUTER JOIN ma_tani m_tan
		ON m_hin.cd_tani_nonyu = m_tan.cd_tani
		AND m_tan.flg_mishiyo = @shiyoMishiyoFlg	-- 現行なし
		LEFT OUTER JOIN ma_kbn_hokan m_hokan
		ON m_hin.kbn_hokan = m_hokan.cd_hokan_kbn
		AND m_hokan.flg_mishiyo	= @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tan_hasu
		ON m_hin.cd_tani_nonyu_hasu = m_tan_hasu.cd_tani
		AND m_tan_hasu.flg_mishiyo = @shiyoMishiyoFlg
		WHERE 
			NOT EXISTS 
			(
				SELECT
					*
				FROM ma_konyu m_ko
				WHERE
					m_ko.cd_hinmei = m_hin.cd_hinmei
			)
		AND m_hin.flg_mishiyo = @shiyoMishiyoFlg
		AND m_hin.cd_hinmei = @cd_hinmei
		ORDER BY 
			cd_hinmei	
	END

END
GO
