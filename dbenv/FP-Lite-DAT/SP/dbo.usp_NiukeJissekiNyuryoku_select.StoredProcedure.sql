IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeJissekiNyuryoku_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeJissekiNyuryoku_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：荷受実績入力　
ファイル名	：usp_NiukeJissekiNyuryoku_select
入力引数	：@no_niuke, @cd_hinmei, @cd_torihiki
              , @dt_nonyu, @shiyoMishiyoFlg, @yoteiYojitsuFlg
出力引数	：	
戻り値		：
作成日		：2013.10.04  ADMAX kakuta.y
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeJissekiNyuryoku_select] 
	@no_niuke			VARCHAR(14)	-- 荷受入力からの引数
	,@cd_hinmei			VARCHAR(14)	-- 品名コード(原資材変動表予定検索用)
	,@cd_torihiki		VARCHAR(13)	-- 取引先コード(原資材変動表予定検索用)
	,@dt_nonyu			DATETIME	-- 納入日(荷受入力での検索条件.荷受日。原資材変動表予定検索用)
	,@shiyoMishiyoFlg	SMALLINT	-- コード一覧.未使用フラグ.使用
	,@yoteiYojitsuFlg	SMALLINT	-- コード一覧.予実フラグ.予定

AS
BEGIN

	IF @no_niuke IS NOT NULL
	BEGIN

		-- 荷受入力で作成したデータの場合
		SELECT	
			m_niu.nm_niuke													-- 荷受場所
			,t_niu.dt_niuke													-- 荷受日
			,m_tani.nm_tani													-- 納入単位(予)
			,t_niu.cd_hinmei												-- 品名コード
			,m_hin.nm_hinmei_ja												-- 品名(日本語)
			,m_hin.nm_hinmei_en												-- 品名(英語)
			,m_hin.nm_hinmei_zh												-- 品名(中国語)
			,m_hin.nm_hinmei_vi
			,ISNULL(m_hin.nm_nisugata_hyoji,'') AS nm_nisugata_hyoji		-- 荷姿(予)
			,t_niu.cd_torihiki												-- 取引先コード
			,m_torihiki.nm_torihiki											-- 取引先名
			,m_hokan.nm_hokan_kbn											-- 品位状態
			,t_niu.tm_nonyu_yotei											-- 予定
			,ISNULL(m_bunrui.nm_bunrui,'') AS nm_bunrui						-- 品分類
			,m_hin.dd_shomi													-- 賞味期限
			,t_niu.su_nonyu_yotei											-- 納入数(予)
			,t_niu.su_nonyu_yotei_hasu										-- 納入端数(予)
			,t_niu.tm_nonyu_jitsu											-- 時刻
			,t_niu.su_nonyu_jitsu											-- 納入数(実)
			,t_niu.su_nonyu_jitsu_hasu										-- 納入端数(実)
			,t_niu.kin_kuraire												-- 金額
			,t_niu.dt_seizo													-- 製造日
			,t_niu.dt_kigen													-- 賞味期限
			,ISNULL(t_niu.no_lot, '') AS no_lot								-- ロットNo.
			,ISNULL(t_niu.no_denpyo, '') AS no_denpyo						-- 伝票No.
			,ISNULL(t_niu.biko,'') AS biko									-- 備考
			,ISNULL(t_niu.cd_hinmei_maker,'') AS cd_hinmei_maker			-- 品名コード(14桁)
			,ISNULL(t_niu.nm_kuni,'') AS nm_kuni							-- 国名
			,ISNULL(t_niu.cd_maker,'') AS cd_maker							-- メーカーコード(GLN)
			,ISNULL(t_niu.nm_maker,'') AS nm_maker							-- メーカー名
			,ISNULL(t_niu.cd_maker_kojo,'') AS cd_maker_kojo				-- メーカー工場コード
			,ISNULL(t_niu.nm_maker_kojo,'') AS nm_maker_kojo				-- メーカー工場名
			,ISNULL(t_niu.nm_hyoji_nisugata, '') AS	nm_hyoji_nisugata_niuke	-- 荷姿(実)
			,ISNULL(t_niu.nm_tani_nonyu, '') AS nm_tani_nonyu				-- 納入単位(実)
			,t_niu.dt_nonyu													-- 納入日
			,t_niu.dt_label_hakko											-- ラベル発行日時
			-- 非表示項目
			,m_hin.su_iri													-- 入数
			,m_hin.kbn_zei													-- 税区分
			,t_niu.flg_kakutei												-- 確定フラグ
			,ISNULL(m_konyu.cd_torihiki2, '') AS cd_torihiki2				-- 取引先コード2
			,ISNULL(m_konyu.cd_tani_nonyu, '') AS cd_tani_nonyu				-- 納入単位コード
			,m_hin.kbn_hin													-- 品区分
			,t_niu.no_nonyu													-- 納入番号
		FROM tr_niuke t_niu
		LEFT OUTER JOIN ma_hinmei m_hin
		ON m_hin.cd_hinmei = t_niu.cd_hinmei
		AND m_hin.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_bunrui m_bunrui
		ON m_hin.cd_bunrui = m_bunrui.cd_bunrui
		AND m_hin.kbn_hin = m_bunrui.kbn_hin
		LEFT OUTER JOIN ma_niuke m_niu
		ON t_niu.cd_niuke_basho = m_niu.cd_niuke_basho
		AND m_niu.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_kbn_hokan m_hokan
		ON m_hin.kbn_hokan = m_hokan.cd_hokan_kbn
		AND m_hokan.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_torihiki m_torihiki
		ON t_niu.cd_torihiki = m_torihiki.cd_torihiki
		AND m_torihiki.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_konyu m_konyu
		ON m_konyu.cd_hinmei = t_niu.cd_hinmei
		AND m_konyu.cd_torihiki = t_niu.cd_torihiki
		AND m_konyu.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tani
		ON m_tani.cd_tani = m_konyu.cd_tani_nonyu
		WHERE
			t_niu.no_seq =
			(
				SELECT
					MIN(no_seq) 
				FROM tr_niuke
			)
			AND t_niu.no_niuke = @no_niuke
	END
	
	ELSE
	BEGIN
	
		DECLARE @initStr	VARCHAR
		DECLARE @initNum	SMALLINT
		DECLARE @initDeci	DECIMAL(2,1)
		DECLARE @initTime	DATETIME
	
		SET @initStr	= ''
		SET @initNum	= 0
		SET @initDeci	= 0.0
		SET @initTime	= '00:00:00.000'
	
		-- 原資材変動表で作成した予定で、荷受実績データが存在しない場合
		SELECT	
			m_niu.nm_niuke												-- 荷受場所名
			,t_nonyu.dt_nonyu dt_niuke									-- 荷受日,納入日
			,m_tani.nm_tani												-- 単位名
			,t_nonyu.cd_hinmei											-- 品名コード
			,m_hin.nm_hinmei_ja											-- 品名(日本語)
			,m_hin.nm_hinmei_en											-- 品名(英語)
			,m_hin.nm_hinmei_zh											-- 品名(中国語)
			,m_hin.nm_hinmei_vi
			,m_hin.nm_nisugata_hyoji									-- 荷姿表示用
			,t_nonyu.cd_torihiki										-- 取引先コード
			,m_torihiki.nm_torihiki										-- 取引先名
			,m_hokan.nm_hokan_kbn										-- 品位状態
			,@initTime tm_nonyu_yotei									-- 納入予定時刻
			,@initStr nm_bunrui											-- 分類名
			,m_hin.dd_shomi												-- 賞味期限
			,t_nonyu.su_nonyu su_nonyu_yotei							-- 納入数
			,@initDeci su_nonyu_yotei_hasu								-- 納入予定端数
			,@initTime tm_nonyu_jitsu									-- 実納入時刻
			,@initDeci su_nonyu_jitsu									-- 実納入数
			,@initDeci su_nonyu_jitsu_hasu								-- 実納入端数
			,@initDeci kin_kuraire										-- 金額
			,@initTime dt_seizo											-- 製造日
			,@initTime dt_kigen											-- 賞味期限
			,@initStr no_lot											-- ロットNo.
			,@initStr no_denpyo											-- 伝票No.
			,@initStr biko												-- 備考
			,t_nonyu.cd_hinmei cd_hinmei_maker							-- 品名コード(14)
			,@initStr nm_kuni											-- 国名
			,@initStr cd_maker											-- メーカーコード(GLN)
			,@initStr nm_maker											-- メーカー名
			,@initStr cd_maker_kojo										-- メーカー工場コード
			,@initStr nm_maker_kojo										-- メーカー名
			,@initStr nm_hyoji_nisugata_niuke							-- 荷姿(実)
			,@initStr nm_tani_nonyu										-- 納入単位(実)
			,@initTime dt_nonyu											-- 納入日
			,@initTime dt_label_hakko									-- ラベル発効日
			-- 非表示
			,m_hin.su_iri												-- 入数(非表示)
			,m_hin.kbn_zei												-- 税区分
			,t_nonyu.flg_kakutei										-- 確定フラグ
			,ISNULL(m_konyu.cd_torihiki2, @initStr) AS cd_torihiki2		-- 取引先コード2
			,ISNULL(m_konyu.cd_tani_nonyu, @initStr) AS cd_tani_nonyu	-- 納入単位コード
			,m_hin.kbn_hin												-- 品区分
			,t_nonyu.no_nonyu											-- 納入番号
		FROM tr_nonyu t_nonyu
		LEFT OUTER JOIN ma_hinmei m_hin
		ON t_nonyu.cd_hinmei = m_hin.cd_hinmei
		AND m_hin.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_bunrui m_bunrui
		ON m_hin.cd_bunrui = m_bunrui.cd_bunrui
		AND m_hin.kbn_hin = m_bunrui.kbn_hin
		LEFT OUTER JOIN ma_niuke m_niu
		ON m_hin.cd_niuke_basho = m_niu.cd_niuke_basho
		AND m_niu.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_kbn_hokan m_hokan
		ON m_hin.kbn_hokan = m_hokan.cd_hokan_kbn
		AND m_hokan.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_torihiki m_torihiki
		ON t_nonyu.cd_torihiki = m_torihiki.cd_torihiki
		AND m_torihiki.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_konyu m_konyu
		ON m_konyu.cd_hinmei = t_nonyu.cd_hinmei
		AND m_konyu.cd_torihiki = t_nonyu.cd_torihiki
		AND m_konyu.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tani
		ON m_tani.cd_tani = m_konyu.cd_tani_nonyu
		WHERE
			t_nonyu.flg_yojitsu	= @yoteiYojitsuFlg
			AND t_nonyu.cd_hinmei = @cd_hinmei
			AND t_nonyu.cd_torihiki = @cd_torihiki
			AND @dt_nonyu <= t_nonyu.dt_nonyu 
			AND t_nonyu.dt_nonyu < (SELECT DATEADD(DD,1,@dt_nonyu))	
	END
END
GO
