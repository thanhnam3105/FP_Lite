IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_update_02') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_update_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：荷受入力　明細(実績)の更新を荷受トランに書き込みます。
ファイル名	：usp_NiukeNyuryoku_update_02
入力引数	：@tm_nonyu_jitsu, @su_jitsu, @su_hasu
			  , @dt_seizo, @dt_kigen, @kingaku, @no_lot
			  , @no_nohinsho, @no_zeikan_shorui, @no_denpyo
			  , @biko, @user, @no_niuke_jisseki, @shiireNyushukoKbn
			  , @addKbn, @sotoinyuNyushukoKbn, @kakozanNyushukoKbn
			  , @ryohinZaikoKbn, @lotSaibanNo, @lotSaibanPrefix
			  , @kgKanzanKbn, @lkanzanKbn, @flg_shonin
出力引数	：
戻り値		：
作成日		：2013.11.13  ADMAX kakuta.y
更新日		：2016.08.19  BRC   kanehira.d
更新日		：2016.11.22  BRC   kanehira.d 入出庫区分追加
更新日		：2016.12.19  BRC   motojima.m 中文対応
更新日		：2019.07.11  BRC   kanehira.d 作業依頼No.663 荷受日を納入日で更新
更新日		：2019.11.25  BRC   kanehira.d 荷受日の更新を修正
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_update_02]
	@tm_nonyu_jitsu			DATETIME		-- 明細(実績)時刻
	,@su_jitsu				DECIMAL(9,2)	-- 明細(実績)C/S数
	,@su_hasu				DECIMAL(9,2)	-- 明細(実績)端数
	,@dt_seizo				DATETIME		-- 明細(実績)製造日
	,@dt_kigen				DATETIME		-- 明細(実績)賞味期限
	,@kingaku				DECIMAL(12,4)	-- 明細(実績)金額
	,@no_lot				VARCHAR(14)		-- 明細(実績)ロット番号
	--,@no_nohinsho			VARCHAR(16)		-- 明細(実績)納品書番号
	,@no_nohinsho			NVARCHAR(16)	-- 明細(実績)納品書番号
	--,@no_zeikan_shorui	VARCHAR(16)		-- 明細(実績)税関書類No.
	,@no_zeikan_shorui		NVARCHAR(16)	-- 明細(実績)税関書類No.
	,@no_denpyo				VARCHAR(30)		-- 明細(実績)伝票No.
	--,@biko				VARCHAR(50)		-- 明細(実績)備考
	,@biko					NVARCHAR(50)	-- 明細(実績)備考
	,@user					VARCHAR(10)		-- ログインユーザーコード
	,@no_niuke_jisseki		VARCHAR(14)		-- 明細(実績)荷受番号(非表示)
	,@shiireNyushukoKbn		SMALLINT		-- コード一覧/入出庫区分.仕入
	,@addKbn		        SMALLINT		-- コード一覧/入出庫区分.追加
	,@sotoinyuNyushukoKbn	SMALLINT		-- コード一覧/入出庫区分.外移入 
	,@kakozanNyushukoKbn	SMALLINT		-- コード一覧/入出庫区分.加工残
	,@ryohinZaikoKbn		SMALLINT		-- コード一覧/在庫区分.良品
	,@lotSaibanNo			VARCHAR(2)		-- コード一覧/採番区分.荷受ロット番号
	,@lotSaibanPrefix		VARCHAR			-- コード一覧/採番接頭辞.荷受ロット番号
	,@kgKanzanKbn			VARCHAR(2)		-- コード一覧/換算区分．Kg
	,@lKanzanKbn			VARCHAR(2)		-- コード一覧/換算区分．L
	,@dt_nonyu				DATETIME		-- 明細(実績)納入日
	,@no_nonyu				VARCHAR(13)
	,@flg_shonin            SMALLINT        -- 承認フラグ
AS
BEGIN

		-- 引数.ロット番号が空の場合の採番処理
	IF @no_lot = '' 
	OR @no_lot IS NULL
	
	BEGIN

		EXEC dbo.usp_cm_Saiban 
			@lotSaibanNo, 
			@lotSaibanPrefix, 
			@no_lot OUTPUT
	END

	-- 入出庫区分が仕入と外移入のものに対して更新をかけます。
	UPDATE tr_niuke
	SET
		dt_niuke = @dt_nonyu
		,dt_nonyu = @dt_nonyu
		,tm_nonyu_jitsu = @tm_nonyu_jitsu
		,su_nonyu_jitsu = @su_jitsu
		,su_nonyu_jitsu_hasu = @su_hasu
		,su_zaiko = @su_jitsu
		,su_zaiko_hasu = @su_hasu
		,dt_seizo = @dt_seizo
		,dt_kigen = @dt_kigen
		,kin_kuraire = @kingaku
		,no_lot = @no_lot
		,no_nohinsho = @no_nohinsho
		,no_zeikan_shorui = @no_zeikan_shorui
		,no_denpyo = @no_denpyo
		,cd_update = @user
		,dt_update = GETUTCDATE()
		,no_nonyu = @no_nonyu
		,flg_shonin = @flg_shonin
	WHERE
		no_niuke = @no_niuke_jisseki
		AND kbn_nyushukko IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)

	-- 入出庫区分が仕入と外移入のもの以外に対して更新をかけます。
	-- 荷受日の更新は行わない
	UPDATE tr_niuke
	SET
		dt_nonyu = @dt_nonyu
		,dt_seizo = @dt_seizo
		,dt_kigen = @dt_kigen
		,no_lot = @no_lot
		,no_nohinsho = @no_nohinsho
		,no_zeikan_shorui = @no_zeikan_shorui
		,no_denpyo = @no_denpyo
		,cd_update = @user
		,dt_update = GETUTCDATE()
	WHERE
		no_niuke = @no_niuke_jisseki
		AND kbn_nyushukko NOT IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)

	UPDATE tr_niuke
	SET biko = @biko
	WHERE	
		no_niuke = @no_niuke_jisseki
		AND no_seq = 1

	-- 在庫数調整を行います。
	EXEC dbo.usp_NiukeNyuryoku_update_04 
		@no_niuke_jisseki, 
		@ryohinZaikoKbn, 
		@kakozanNyushukoKbn, 
		@kgKanzanKbn, 
		@lKanzanKbn

	/* 更新処理見直しのためコメントアウト
	
	-- 引数.ロット番号が空の場合の採番処理
	IF @no_lot = '' 
	OR @no_lot IS NULL
	
	BEGIN

		EXEC dbo.usp_cm_Saiban 
			@lotSaibanNo, 
			@lotSaibanPrefix, 
			@no_lot OUTPUT
	END

	-- 入出庫区分が仕入と外移入のものに対して更新をかけます。
	UPDATE tr_niuke
	SET
		dt_niuke = @dt_nonyu
		,dt_nonyu = @dt_nonyu
		,tm_nonyu_jitsu = @tm_nonyu_jitsu
		,su_nonyu_jitsu = @su_jitsu
		,su_nonyu_jitsu_hasu = @su_hasu
		,su_zaiko = @su_jitsu
		,su_zaiko_hasu = @su_hasu
		,dt_seizo = @dt_seizo
		,dt_kigen = @dt_kigen
		,kin_kuraire = @kingaku
		,no_lot = @no_lot
		,no_nohinsho = @no_nohinsho
		,no_zeikan_shorui = @no_zeikan_shorui
		,no_denpyo = @no_denpyo
		--,biko = @biko
		,cd_update = @user
		,dt_update = GETUTCDATE()
		,no_nonyu = @no_nonyu
		,flg_shonin = @flg_shonin
	WHERE
		no_niuke = @no_niuke_jisseki
		--AND kbn_nyushukko IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn)
		AND kbn_nyushukko IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)

	-- 入出庫区分が仕入と外移入のものに対して更新をかけます。
	UPDATE tr_niuke
	SET
		dt_niuke = @dt_nonyu
		,dt_nonyu = @dt_nonyu
		,tm_nonyu_jitsu = @tm_nonyu_jitsu
		,dt_seizo = @dt_seizo
		,dt_kigen = @dt_kigen
		--,kin_kuraire = @kingaku
		,no_lot = @no_lot
		,no_nohinsho = @no_nohinsho
		,no_zeikan_shorui = @no_zeikan_shorui
		,no_denpyo = @no_denpyo
		--,biko = @biko
		,cd_update = @user
		,dt_update = GETUTCDATE()
		--,no_nonyu = @no_nonyu
		--,flg_shonin = @flg_shonin
	WHERE
		no_niuke = @no_niuke_jisseki
		AND kbn_nyushukko NOT IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)

	UPDATE tr_niuke
	SET biko = @biko
	WHERE	
		no_niuke = @no_niuke_jisseki
		AND no_seq = 1

	-- 入出庫区分が仕入と外移入でないものに対して更新をかけます。
	UPDATE tr_niuke
	SET
		dt_seizo = @dt_seizo
		,dt_kigen = @dt_kigen
		,no_lot	= @no_lot
		,no_denpyo = @no_denpyo
		,cd_update = @user
		,dt_update = GETUTCDATE()
	WHERE
		no_niuke = @no_niuke_jisseki
		--AND kbn_nyushukko NOT IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn)
		--AND kbn_nyushukko NOT IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)

	-- 在庫数調整を行います。
	EXEC dbo.usp_NiukeNyuryoku_update_04 
		@no_niuke_jisseki, 
		@ryohinZaikoKbn, 
		@kakozanNyushukoKbn, 
		@kgKanzanKbn, 
		@lKanzanKbn
	*/
END
GO
