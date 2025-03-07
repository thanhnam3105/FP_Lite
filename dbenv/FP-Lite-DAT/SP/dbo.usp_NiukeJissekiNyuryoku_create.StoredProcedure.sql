IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeJissekiNyuryoku_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeJissekiNyuryoku_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：荷受実績入力　変動表で作成した予定の実績を新規登録します。
ファイル名	：usp_NiukeJissekiNyuryoku_create
入力引数	：@dt_niuke, @cd_hinmei, @kbn_hin
			  , @cd_niuke_basho, @NyushukoShiire, @ryohinZaikoKbn
		      , @tm_nonyu_yotei, @su_nonyu_yotei, @su_nonyu_yotei_hasu
		      , @tm_nonyu_jitsu, @su_nonyu_jitsu, @su_nonyu_jitsu_hasu
			  , @dt_seizo, @dt_kigen, @kin_kuraire
			  , @no_lot, @no_denpyo, @biko
			  , @cd_torihiki, @mikakuteiKakuteiFlg, @cd_hinmei_maker
			  , @nm_kuni, @cd_maker, @nm_maker
			  , @cd_maker_kojo, @nm_maker_kojo, @nm_hyoji_nisugata
			  , @nm_tani_nonyu, @dt_nonyu, @user
			  , @minSeq, @KbnSaibanNoNiuke, @KbnSaibanNoNiukePrefix
			  , @KbnSaibanLotNiuke, @KbnSaibanLotNiukePrefix
出力引数	：	
戻り値		：
作成日		：2013.12.05  ADMAX kakuta.y
更新日		：2016.12.13  BRC   motojima.m 中文対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeJissekiNyuryoku_create]
    @dt_niuke					DATETIME		-- 荷受日
    ,@cd_hinmei					VARCHAR(14)		-- 品名コード
    ,@kbn_hin					SMALLINT		-- 品区分
    ,@cd_niuke_basho			VARCHAR(10)		-- 荷受場所コード
    ,@NyushukoShiire			SMALLINT		-- コード一覧.入出庫区分.仕入
    ,@ryohinZaikoKbn			SMALLINT		-- コード一覧.在庫区分.良品
    ,@tm_nonyu_yotei			DATETIME		-- 予定
    ,@su_nonyu_yotei			DECIMAL(9,2)	-- 納入数(予)
    ,@su_nonyu_yotei_hasu		DECIMAL(9,2)	-- 納入端数(予)
    ,@tm_nonyu_jitsu			DATETIME		-- 時刻
    ,@su_nonyu_jitsu			DECIMAL(9,2)	-- 納入数(実)
    ,@su_nonyu_jitsu_hasu		DECIMAL(9,2)	-- 納入端数(実)
    ,@dt_seizo					DATETIME		-- 製造日
    ,@dt_kigen					DATETIME		-- 賞味期限
    ,@kin_kuraire				DECIMAL(12,4)	-- 金額
    ,@no_lot					VARCHAR(14)		-- ロットNo.
    ,@no_denpyo					VARCHAR(30)		-- 伝票No.
    --,@biko					VARCHAR(50)		-- 備考
    ,@biko						NVARCHAR(50)	-- 備考
    ,@cd_torihiki				VARCHAR(13)		-- 取引先コード
	,@mikakuteiKakuteiFlg		SMALLINT		-- コード一覧.確定フラグ.未確定
    ,@cd_hinmei_maker			VARCHAR(14)		-- 品名コード(14桁)
    --,@nm_kuni					VARCHAR(60)		-- 国名
    ,@nm_kuni					NVARCHAR(60)	-- 国名
    ,@cd_maker					VARCHAR(20)		-- メーカーコード(GLN)
    --,@nm_maker				VARCHAR(60)		-- メーカー名
    ,@nm_maker					NVARCHAR(60)	-- メーカー名
    ,@cd_maker_kojo				VARCHAR(20)		-- メーカー工場コード
	--,@nm_maker_kojo			VARCHAR(60)		-- メーカー工場名
	,@nm_maker_kojo				NVARCHAR(60)	-- メーカー工場名
    --,@nm_hyoji_nisugata		VARCHAR(26)		-- 荷姿(実)
    ,@nm_hyoji_nisugata			NVARCHAR(26)	-- 荷姿(実)
    --,@nm_tani_nonyu			VARCHAR(12)		-- 納入単位(実)
    ,@nm_tani_nonyu				NVARCHAR(12)	-- 納入単位(実)
    ,@dt_nonyu					DATETIME		-- 納入日
    ,@user						VARCHAR(10)		-- ログインユーザーコード
    ,@minSeq					DECIMAL(8,0)	-- 荷受トラン最小シーケンス番号
    ,@KbnSaibanNoNiuke			VARCHAR(2)		-- コード一覧.採番.採番区分.荷受番号
    ,@KbnSaibanNoNiukePrefix	VARCHAR(1)		-- コード一覧.採番.採番接頭辞.荷受番号
    ,@KbnSaibanLotNiuke			VARCHAR(2)		-- コード一覧.採番.採番区分.荷受ロット
    ,@KbnSaibanLotNiukePrefix	VARCHAR(1)		-- コード一覧.採番.採番接頭辞.荷受ロット
    
AS
BEGIN
	
	DECLARE @no_niuke VARCHAR(14) = ''
	
	-- 荷受番号を取得します。
	EXEC dbo.usp_cm_Saiban @KbnSaibanNoNiuke, @KbnSaibanNoNiukePrefix, @no_niuke OUTPUT
	
	-- ロット番号に入力がない場合は採番処理を行います。
	IF @no_lot IS NULL 
		OR @no_lot = ''
		BEGIN
			EXEC dbo.usp_cm_Saiban @KbnSaibanLotNiuke, @KbnSaibanLotNiukePrefix, @no_lot OUTPUT
		END
		
	INSERT INTO tr_niuke
		(
			no_niuke
			,dt_niuke
		    ,cd_hinmei
		    ,kbn_hin
		    ,cd_niuke_basho
		    ,kbn_nyushukko
		    ,kbn_zaiko
		    ,tm_nonyu_yotei
		    ,su_nonyu_yotei
		    ,su_nonyu_yotei_hasu
		    ,tm_nonyu_jitsu
		    ,su_nonyu_jitsu
		    ,su_nonyu_jitsu_hasu
		    ,su_zaiko					
		    ,su_zaiko_hasu
		    ,dt_seizo
		    ,dt_kigen
		    ,kin_kuraire
		    ,no_lot
		    ,no_denpyo
		    ,biko
		    ,cd_torihiki
			,flg_kakutei
		    ,cd_hinmei_maker
		    ,nm_kuni
		    ,cd_maker
		    ,nm_maker
		    ,cd_maker_kojo
			,nm_maker_kojo
		    ,nm_hyoji_nisugata
		    ,nm_tani_nonyu
		    ,dt_nonyu
		    ,cd_update
			,dt_update
		    ,no_seq
		)
	VALUES
		(
			@no_niuke
			,@dt_niuke
		    ,@cd_hinmei
		    ,@kbn_hin
		    ,@cd_niuke_basho
		    ,@NyushukoShiire
		    ,@ryohinZaikoKbn
		    ,@tm_nonyu_yotei
		    ,@su_nonyu_yotei
		    ,@su_nonyu_yotei_hasu
		    ,@tm_nonyu_jitsu
		    ,@su_nonyu_jitsu
		    ,@su_nonyu_jitsu_hasu
			,@su_nonyu_jitsu					
		    ,@su_nonyu_jitsu_hasu
		    ,@dt_seizo
		    ,@dt_kigen
		    ,@kin_kuraire
		    ,@no_lot
		    ,@no_denpyo
		    ,@biko
		    ,@cd_torihiki
			,@mikakuteiKakuteiFlg
		    ,@cd_hinmei_maker
		    ,@nm_kuni
		    ,@cd_maker
		    ,@nm_maker
		    ,@cd_maker_kojo
			,@nm_maker_kojo
		    ,@nm_hyoji_nisugata
		    ,@nm_tani_nonyu
		    ,@dt_nonyu
		    ,@user
			,GETUTCDATE()
		    ,@minSeq
		)
END
GO
