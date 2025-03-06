IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：荷受入力　実績を納入予実トランに登録・更新します。
ファイル名	：usp_NiukeNyuryoku_create
入力引数	：@cd_hinmei, @cd_torihiki, @dt_niuke
			  , @cd_tani_nonyu, @kgTaniCode, @lTaniCode
			  , @su_iri, @nonyu_tanka, @nonyuSaibanNo, @nonyuSaibanPrefix
			  , @jissekiYojitsuFlg, @cd_torihiki2, @kbn_zei, @flg_create
出力引数	：
戻り値		：
作成日		：2013.11.12  ADMAX kakuta.y
更新日		：2015.10.01  ADMAX kakuta.y 納入予定番号対応
更新日		：2019.01.13  BRC motojima.m 予定一覧・変動表の納入実績が2倍になる不具合修正
更新日		：2019.02.18  BRC motojima.m 予定一覧・変動表の納入実績が2倍になる不具合修正(返品も除外)
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_create] 
	@cd_hinmei				VARCHAR(14)		-- 明細(予定)品名コード
	,@cd_torihiki			VARCHAR(13)		-- 明細(予定)取引先コード
	--,@dt_niuke				DATETIME		-- 検索条件/荷受日
	,@dt_niuke				DATETIME		-- 明細(実績)納入日
	,@cd_tani_nonyu			VARCHAR(10)		-- 明細(予定)納入単位コード
	,@kgTaniCode			VARCHAR(10)		-- コード一覧/納入単位コードKｇ
	,@lTaniCode				VARCHAR(10)		-- コード一覧/納入単位コードL
	,@su_iri				DECIMAL(8,0)	-- 明細(予定)入数
	,@nonyu_tanka			DECIMAL(12,4)	-- 納入単価
	,@nonyuSaibanNo			VARCHAR(2)		-- 納入番号採番用コード
	,@nonyuSaibanPrefix		VARCHAR			-- 納入番号採番用接頭辞
	,@jissekiYojitsuFlg		SMALLINT		-- コード一覧/予実フラグ.実績
	,@cd_torihiki2			VARCHAR(13)		-- 明細(予定)取引先コード2
	,@kbn_zei				SMALLINT		-- 明細(予定)税区分
	,@flg_create			BIT				-- 更新フラグ(create = true, update = false)
	,@kbn_nyuko				SMALLINT		-- 明細/入庫区分
	,@no_nonyu				VARCHAR(13)		-- 明細(実績)/納入番号
	,@no_nonyu_yotei		VARCHAR(13)		-- 明細(予定)/納入予定番号

AS
BEGIN

	-- 変数宣言
	DECLARE @sum_nonyu				DECIMAL(18,2)
			, @sum_hasu				DECIMAL(18,2)
			, @su_nonyu				DECIMAL(10,2)
			, @su_hasu				DECIMAL(10,2)
			, @max_su				DECIMAL(9,2)
			, @flg_kakutei			SMALLINT
			, @flg_kakutei_nonyu	SMALLINT
			, @sum_kuraire			DECIMAL(18,4)
			--, @no_nonyu				VARCHAR(13)
			, @zeroNum				SMALLINT
			, @oneNum				SMALLINT
			, @thausandNum			SMALLINT
			, @true					BIT
			--, @nonyu				VARCHAR(13)
			, @no_nonyu_existcheck	VARCHAR(13)
			, @tan_nonyu_calc		DECIMAL(12,4)


	-- 値格納
	SET @max_su			= 9999999
	SET @zeroNum		= 0
	SET @oneNum			= 1
	SET @thausandNum	= 1000
	SET	@true			= 1


	-- 実納入数合計、実納入端数合計の取得
	SELECT
		@sum_nonyu	= ISNULL(SUM(t_n.su_nonyu_jitsu), @zeroNum)
		, @sum_hasu = ISNULL(SUM(t_n.su_nonyu_jitsu_hasu), @zeroNum)
		--, @nonyu = t_n.no_nonyu
	FROM tr_niuke t_n
	WHERE
		t_n.cd_hinmei = @cd_hinmei
		AND t_n.cd_torihiki = @cd_torihiki
		--AND @dt_niuke <= t_n.dt_niuke
		AND t_n.no_nonyu = @no_nonyu
		and (@kbn_nyuko is null or t_n.kbn_nyuko = @kbn_nyuko)
		--AND t_n.kbn_nyushukko NOT IN (11,12)
		AND t_n.kbn_nyushukko NOT IN (8,11,12)
		--AND t_n.kbn_nyuko = @kbn_nyuko
		--AND t_n.dt_niuke < (SELECT DATEADD(DD,1,@dt_niuke))
	GROUP BY t_n.no_nonyu


	-- 取得した合計が項目の制限範囲を超える場合は上限値をセットします。
	IF @sum_nonyu > @max_su
	BEGIN
		SET @sum_nonyu = @max_su
	END
	IF @sum_hasu > @max_su
	BEGIN
		SET @sum_hasu = @max_su
	END


	-- 納入数、納入端数算出処理(納入単位が「Kg」か「L」の場合は「g」「ml」に合わせる)
	IF @cd_tani_nonyu = @kgTaniCode OR @cd_tani_nonyu = @lTaniCode
	BEGIN
		SET @su_iri = @su_iri * @thausandNum
	END

	SET @su_nonyu = FLOOR((@sum_nonyu * @su_iri + @sum_hasu) / @su_iri)
	SET @su_hasu = FLOOR(@sum_hasu % @su_iri)

	-- 算出した数が項目の制限範囲を超える場合は上限値をセットします。
	IF @su_nonyu > @max_su
	BEGIN
		SET @su_nonyu = @max_su
	END
	IF @su_hasu > @max_su
	BEGIN
		SET @su_hasu = @max_su
	END


	-- 確定フラグの設定
	SELECT 
		@flg_kakutei = t_n.flg_kakutei
		,@sum_kuraire = SUM(t_n.kin_kuraire)
	FROM tr_niuke t_n
	WHERE
		t_n.cd_hinmei = @cd_hinmei
		AND t_n.cd_torihiki = @cd_torihiki
		AND t_n.no_nonyu = @no_nonyu
		--AND t_n.kbn_nyuko = @kbn_nyuko
		AND (@kbn_nyuko is null or t_n.kbn_nyuko = @kbn_nyuko)
		--AND @dt_niuke <= t_n.dt_niuke 
		--AND t_n.dt_niuke < (SELECT DATEADD(DD,1,@dt_niuke))
	GROUP BY
		t_n.cd_hinmei
		,cd_torihiki
		--,t_n.dt_niuke
		,t_n.flg_kakutei

		
	-- 納入予実トランの確定フラグを取得
	SELECT 
		@flg_kakutei_nonyu = flg_kakutei
	FROM tr_nonyu
	WHERE 
		cd_hinmei = @cd_hinmei
		AND cd_torihiki = @cd_torihiki
		--AND dt_nonyu	= @dt_niuke
		AND no_nonyu = @no_nonyu
		--AND kbn_nyuko = @kbn_nyuko
		AND (@kbn_nyuko is null or kbn_nyuko = @kbn_nyuko)
		AND flg_yojitsu	= @jissekiYojitsuFlg


	-- 納入予実トランの納入番号を取得(一旦保留ここから)
	--SELECT 
	--	@no_nonyu = no_nonyu
	--FROM tr_nonyu
	--WHERE 
	--	cd_hinmei = @cd_hinmei
	--	AND cd_torihiki = @cd_torihiki
	--	AND dt_nonyu	= @dt_niuke
	--	AND flg_yojitsu	= 0
	-- 納入予実トランの納入番号を取得(一旦保留ここまで)


	-- 納入予実トランの確定フラグが立っている場合は確定をセットします。
	-- 上記以外の処理。
	-- 明細(実績)の金額合計が1以上だった場合で、荷受トランの確定フラグが立っていた場合、納入予実トランの確定フラグを立てます。
	IF @flg_kakutei_nonyu = 1
		OR (@sum_kuraire > 0 AND @flg_kakutei = 1)
	BEGIN
		SET @flg_kakutei = 1
	END
	ELSE
	BEGIN
		SET @flg_kakutei = 0
	END


	-- 金額の算出
	IF @sum_kuraire = 0 OR @sum_kuraire IS NULL
	BEGIN
		SET @sum_kuraire = FLOOR(@su_nonyu * @nonyu_tanka + @su_hasu * ( @nonyu_tanka / @su_iri))
	END

	-- 金額のオーバーフロー対応
	IF @sum_kuraire > 99999999.9999
	BEGIN
		SET @sum_kuraire = 99999999.9999
	END



	-- 追加処理
	IF @flg_create = @true

	BEGIN
		----一旦保留ここから
		--if @nonyu is null
		--begin
		---- 納入番号採番処理
		--	EXEC dbo.usp_cm_Saiban @nonyuSaibanNo, @nonyuSaibanPrefix, @no_nonyu OUTPUT
		--	set @nonyu = @no_nonyu
		--end
		----一旦保留ここまで

		-- 納入予実トラン追加処理
		INSERT INTO tr_nonyu
			(
				flg_yojitsu
				,no_nonyu
				,dt_nonyu
				,cd_hinmei
				,su_nonyu
				,su_nonyu_hasu
				,cd_torihiki
				,cd_torihiki2
				,tan_nonyu
				,kin_kingaku
				,kbn_zei
				,flg_kakutei
				,kbn_nyuko
				,no_nonyu_yotei
			)
		VALUES
			(
				@jissekiYojitsuFlg
				--,@nonyu
				,@no_nonyu
				,@dt_niuke
				,@cd_hinmei
				,@su_nonyu
				,@su_hasu
				,@cd_torihiki
				,@cd_torihiki2
				,@nonyu_tanka
				,@sum_kuraire
				,@kbn_zei
				,@flg_kakutei
				,@kbn_nyuko
				,@no_nonyu_yotei
			)
	END

	-- 更新処理(原資材変動表で必要なため、予定は更新しません。)
	ELSE

	BEGIN
		
		UPDATE tr_nonyu
		SET	
			su_nonyu = @su_nonyu
			,su_nonyu_hasu = @su_hasu
			,cd_torihiki2 = @cd_torihiki2
			,tan_nonyu = @nonyu_tanka
			,kin_kingaku = @sum_kuraire
			,flg_kakutei = @flg_kakutei
			,dt_nonyu = @dt_niuke
		WHERE
			cd_hinmei = @cd_hinmei
			--AND @dt_niuke <= dt_nonyu
			--AND dt_nonyu < (SELECT DATEADD(DD,1,@dt_niuke))
			AND cd_torihiki = @cd_torihiki
			AND no_nonyu = @no_nonyu
			--AND kbn_nyuko = @kbn_nyuko
			AND (@kbn_nyuko is null or kbn_nyuko = @kbn_nyuko)
			AND flg_yojitsu = @jissekiYojitsuFlg
	END
END
GO
