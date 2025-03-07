IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeJissekiNyuryoku_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeJissekiNyuryoku_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：荷受実績入力 実績の更新を荷受トランに書き込みます。
ファイル名	：usp_NiukeJissekiNyuryoku_update
入力引数	：@tm_nonyu_jitsu, @su_jitsu, @su_hasu
			  , @kingaku, @dt_seizo, @dt_kigen
			  , @no_lot, @no_denpyo, @biko
			  , @cd_hinmei_maker, @nm_kuni, @cd_maker
			  , @nm_maker, @cd_maker_kojo, @nm_maker_kojo
			  , @nm_hyoji_nisugata, @nm_tani_nonyu, @dt_nonyu
			  , @user, @no_niuke, @shiireNyushukoKbn
			  , @sotoinyuNyushukoKbn, @kakozanNyushukoKbn, @ryohinZaikoKbn
			  , @lotSaibanNo, @lotSaibanPrefix, @kgKanzanKbn, @lKanzanKbn
出力引数	：
戻り値		：
作成日		：2013.12.04  ADMAX kakuta.y
更新日		：2016.12.13  BRC   motojima.m 中文対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeJissekiNyuryoku_update]
	@tm_nonyu_jitsu			DATETIME		-- 実績時刻
	,@su_jitsu				DECIMAL(9,2)	-- 実績C/S数
	,@su_hasu				DECIMAL(9,2)	-- 実績端数
	,@kingaku				DECIMAL(12,4)	-- 金額
	,@dt_seizo				DATETIME		-- 製造日
	,@dt_kigen				DATETIME		-- 賞味期限
	,@no_lot				VARCHAR(14)		-- ロット番号
	,@no_denpyo				VARCHAR(30)		-- 伝票No.
	--,@biko				VARCHAR(50)		-- 備考
	,@biko					NVARCHAR(50)	-- 備考
	,@cd_hinmei_maker		VARCHAR(14)		-- 品コード(14桁)
	--,@nm_kuni				VARCHAR(60)		-- 国名
	,@nm_kuni				NVARCHAR(60)	-- 国名
	,@cd_maker				VARCHAR(20)		-- メーカーコード(GLN)
	--,@nm_maker			VARCHAR(60)		-- メーカー名
	,@nm_maker				NVARCHAR(60)	-- メーカー名
	,@cd_maker_kojo			VARCHAR(20)		-- メーカー工場コード
	--,@nm_maker_kojo		VARCHAR(60)		-- メーカー工場名
	,@nm_maker_kojo			NVARCHAR(60)	-- メーカー工場名
	--,@nm_hyoji_nisugata	VARCHAR(26)		-- 荷姿
	,@nm_hyoji_nisugata		NVARCHAR(26)	-- 荷姿
	--,@nm_tani_nonyu		VARCHAR(12)		-- 納入単位
	,@nm_tani_nonyu			NVARCHAR(12)	-- 納入単位
	,@dt_nonyu				DATETIME		-- 納入日		
	,@user					VARCHAR(10)		-- ログインユーザーコード
	,@no_niuke				VARCHAR(14)		-- 荷受番号
	,@shiireNyushukoKbn		SMALLINT		-- コード一覧/入出庫区分.仕入
	,@sotoinyuNyushukoKbn	SMALLINT		-- コード一覧/入出庫区分.外移入 
	,@kakozanNyushukoKbn	SMALLINT		-- コード一覧/入出庫区分.加工残
	,@ryohinZaikoKbn		SMALLINT		-- コード一覧/在庫区分.良品
	,@lotSaibanNo			VARCHAR(2)		-- コード一覧/採番区分.荷受ロット番号
	,@lotSaibanPrefix		VARCHAR			-- コード一覧/採番接頭辞.荷受ロット番号
	,@kgKanzanKbn			VARCHAR(2)		-- コード一覧．換算区分．Kg
	,@lKanzanKbn			VARCHAR(2)		-- コード一覧．換算区分．L	
AS
BEGIN
	
	-- 引数.ロット番号が空の場合の採番処理
	IF @no_lot = '' 
		OR @no_lot IS NULL
	BEGIN
		EXEC dbo.usp_cm_Saiban @lotSaibanNo, @lotSaibanPrefix, @no_lot OUTPUT
	END
	
	-- 入出庫区分が仕入と外移入のものに対して更新をかけます。
	UPDATE tr_niuke
	SET	
		tm_nonyu_jitsu = @tm_nonyu_jitsu
		,su_nonyu_jitsu = @su_jitsu
		,su_nonyu_jitsu_hasu = @su_hasu
		,su_zaiko = @su_jitsu
		,su_zaiko_hasu = @su_hasu
		,dt_seizo = @dt_seizo
		,dt_kigen = @dt_kigen
		,kin_kuraire = @kingaku
		,no_lot = @no_lot
		,no_denpyo = @no_denpyo
		,biko = @biko
		,cd_hinmei_maker = @cd_hinmei_maker
		,nm_kuni = @nm_kuni
		,cd_maker = @cd_maker
		,nm_maker = @nm_maker
		,cd_maker_kojo = @cd_maker_kojo
		,nm_maker_kojo = @nm_maker_kojo
		,nm_hyoji_nisugata = @nm_hyoji_nisugata
		,nm_tani_nonyu = @nm_tani_nonyu
		,dt_nonyu = @dt_nonyu
		,cd_update = @user
		,dt_update = GETUTCDATE()
	WHERE
		no_niuke = @no_niuke
		AND kbn_nyushukko IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn)
		
	-- 入出庫区分が仕入と外移入でないものに対して更新をかけます。
	UPDATE tr_niuke
	SET
		dt_seizo = @dt_seizo
		,dt_kigen = @dt_kigen
		,no_lot = @no_lot
		,no_denpyo = @no_denpyo
		,cd_hinmei_maker = @cd_hinmei_maker
		,nm_kuni = @nm_kuni
		,cd_maker = @cd_maker
		,nm_maker = @nm_maker
		,cd_maker_kojo = @cd_maker_kojo
		,nm_maker_kojo = @nm_maker_kojo
		,nm_hyoji_nisugata = @nm_hyoji_nisugata
		,nm_tani_nonyu = @nm_tani_nonyu
		,dt_nonyu = @dt_nonyu
		,cd_update = @user
		,dt_update = GETUTCDATE()
	WHERE no_niuke = @no_niuke
		AND kbn_nyushukko NOT IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn)
	-- 在庫数調整を行います。
	EXEC dbo.usp_NiukeNyuryoku_update_04 @no_niuke, @ryohinZaikoKbn, @kakozanNyushukoKbn, @kgKanzanKbn, @lKanzanKbn

END
GO
