IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryozanHyoryoKeikaku_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryozanHyoryoKeikaku_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：原料残秤量（計画変更） 登録処理
ファイル名	：usp_GenryozanHyoryoKeikaku_create
入力引数	：@dt_label_hakko, @cd_panel, @cd_hakari
			  , @cd_hinmei, @nm_hinmei, @wt_zan
			  , @wt_futai, @cd_user, @kaifuMikaifuFlg
			  , @dt_system, @dt_shomi_kaifugo
			  , @shiyoHakiFlg, @cd_label, @no_lot
			  , @dt_shomi_kaifumae, @dt_seizo, @no_lot_kowake
			  , @no_lot_oya, @zanlotKbnSaiban, @zanlotPrefixSaiban
出力引数	：
戻り値		：
作成日		：2014.02.12  ADMAX kakuta.y
更新日		：2015.09.18  ADMAX taira.s
更新日		：2016.12.13  BRC   motojima.m  中文対応
更新日		：2018.03.15  BRC   yokota.t    解凍ラベル対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GenryozanHyoryoKeikaku_create]
	@dt_label_hakko			DATETIME		-- ラベル発行日時
	,@cd_panel				VARCHAR(3)		-- セッション情報．パネルコード
	,@cd_hakari				VARCHAR(10)		-- 秤マスタ．秤コード
	,@cd_hinmei				VARCHAR(14)		-- 画面．コード
	--,@nm_hinmei			VARCHAR(50)		-- 画面．原料名
	,@nm_hinmei				NVARCHAR(50)	-- 画面．原料名
	,@wt_zan				DECIMAL(12,6)	-- 画面．残重量
	,@wt_futai				DECIMAL(12,6)	-- 画面．風袋重量
	,@cd_user				VARCHAR(10)		-- セッション情報．ログインユーザーコード
	,@kaifuMikaifuFlg		SMALLINT		-- 区分/コード一覧．未開封フラグ．開封
	,@dt_system				DATETIME		-- システム日付
	,@dt_shomi_kaifugo		DATETIME		-- 画面．開封後
	,@shiyoHakiFlg			SMALLINT		-- 区分/コード一覧．破棄フラグ．使用
	,@cd_label				TEXT			-- ラベルコード
	,@no_lot				VARCHAR(14)		-- 画面．ロット
	,@dt_shomi_kaifumae		DATETIME		-- 画面．開封前
	,@dt_seizo				DATETIME		-- ラベル情報．製造日
	,@no_lot_kowake			VARCHAR(14)		-- 小分実績トラン．小分ロット番号
	,@no_lot_oya			VARCHAR(14)		-- 小分実績トラン．親ロット番号
	--,@zanlotKbnSaiban		VARCHAR(1)		-- 区分/コード一覧．採番区分．残ロット
	--,@zanlotPrefixSaiban	VARCHAR(1)		-- 区分/コード一覧．採番接頭辞区分．残ロット
	,@kbn_label				SMALLINT		-- ラベル区分
	,@no_lot_zan			VARCHAR(14)		-- クライアントで採番された残ロット番号
	,@dt_shomi_kaitogo		DATETIME		-- 画面．解凍後
AS
BEGIN

	DECLARE @no_saiban VARCHAR(14)
	SET @no_saiban = @no_lot_zan;
	--EXEC dbo.usp_cm_Saiban
	--	@zanlotKbnSaiban
	--	,@zanlotPrefixSaiban
	--	,@no_saiban OUTPUT

	-- 残実績トラン追加処理
	INSERT INTO tr_zan_jiseki
		(
			no_lot_zan
			,dt_hyoryo_zan
			,cd_panel
			,cd_hakari
			,cd_hinmei
			,nm_hinmei
			,wt_jisseki
			,wt_jisseki_futai
			,cd_tanto
			,dt_read
			,flg_mikaifu
			,dt_kaifu
			,dt_kigen
			,flg_ido
			,flg_haki
			,cd_maker
			,cd_label
			,kbn_label
			,dt_shomi_kaito
		)
	VALUES
		(
			@no_saiban
			,@dt_label_hakko
			,@cd_panel
			,@cd_hakari
			,@cd_hinmei
			,@nm_hinmei
			,@wt_zan
			,@wt_futai
			,@cd_user
			,NULL
			,@kaifuMikaifuFlg
			,@dt_system
			,@dt_shomi_kaifugo
			,NULL
			,@shiyoHakiFlg
			,NULL
			,@cd_label
			,@kbn_label
			,@dt_shomi_kaitogo
		)

	-- 混合ロット実績トラン追加処理
	INSERT INTO tr_lot
		(
			no_lot_jisseki
			,no_lot
			,wt_jisseki
			,dt_shomi
			,dt_shomi_kaifu
			,dt_seizo_genryo
			,dt_shomi_kaito
		)
	VALUES
		(
			@no_saiban
			,@no_lot
			,@wt_zan
			,@dt_shomi_kaifumae
			,@dt_shomi_kaifugo
			,@dt_seizo
			,@dt_shomi_kaitogo
		)

	-- 混合荷姿トラン追加処理
	INSERT INTO tr_kongo_nisugata
		(
			dt_kowake
			,no_lot_jisseki
			,no_lot
			,old_no_lot_jisseki
			,old_no_lot
			,old_wt_jisseki
			,old_dt_shomi
			,old_dt_shomi_kaifu
			,old_dt_seizo_genryo
			,cd_maker
			,old_dt_shomi_kaito
		)
	SELECT
		tk.dt_kowake
		,@no_saiban
		,@no_lot
		,tl.no_lot_jisseki
		,tl.no_lot
		,tl.wt_jisseki
		,tl.dt_shomi
		,tl.dt_shomi_kaifu
		,tl.dt_seizo_genryo
		,''
		,tl.dt_shomi_kaito
	FROM 
		(
			SELECT 
				no_lot_kowake
				,dt_kowake
			FROM tr_kowake
			WHERE ((@no_lot_oya IS NULL
				OR @no_lot_oya = '')			-- ロット切替していない場合
  				AND no_lot_kowake = @no_lot_kowake
  				)
				OR((@no_lot_oya IS NOT NULL
				AND @no_lot_oya <> '')		-- ロット切替している場合
				AND no_lot_oya = @no_lot_oya				
				)
		) tk
	INNER JOIN 
		(
			SELECT 
				no_lot_jisseki
				,no_lot
				,wt_jisseki
				,dt_shomi
				,dt_shomi_kaifu
				,dt_seizo_genryo
				,dt_shomi_kaito
			FROM tr_lot
			WHERE ((@no_lot_oya IS NULL
				OR @no_lot_oya = '')			-- ロット切替していない場合
  				AND no_lot_jisseki = @no_lot_kowake
  				)
				OR((@no_lot_oya IS NOT NULL
				AND @no_lot_oya <> '')		-- ロット切替している場合
				AND no_lot_jisseki IN
				(
					SELECT
						tk2.no_lot_kowake
					FROM tr_kowake tk2
					WHERE
						tk2.no_lot_oya = @no_lot_oya
				))
		) tl
	ON tk.no_lot_kowake = tl.no_lot_jisseki

END
GO
