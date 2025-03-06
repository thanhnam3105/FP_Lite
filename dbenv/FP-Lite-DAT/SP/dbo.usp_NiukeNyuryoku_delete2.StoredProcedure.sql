IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_delete2') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_delete2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：荷受入力　荷受トラン(実績なし)の場合、実績データを更新します。
ファイル名	：usp_NiukeNyuryoku_delete2
入力引数	：@no_niuke_yotei, @no_niuke_jisseki, @no_nonyu, @shiireNyushukoKbn
			  , @addKbn, @sotoinyuNyushukoKbn, @cd_update
出力引数	：
戻り値		：
作成日		：2016.09.07  BRC motojima.m	荷受入力行追加対応
更新日		：2016.11.28  BRC cho.k	更新・削除の判定条件修正
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_delete2]
	@no_niuke_yotei			VARCHAR(14)	 -- 明細(予定)荷受番号
	,@no_niuke_jisseki		VARCHAR(14)	 -- 明細(実績)荷受番号
	,@no_nonyu				VARCHAR(14)	 -- 荷受番号
	,@shiireNyushukoKbn		SMALLINT	 -- コード一覧/入出庫区分.仕入
	,@addKbn				SMALLINT	 -- コード一覧/入出庫区分.追加
	,@sotoinyuNyushukoKbn	SMALLINT	 -- コード一覧/入出庫区分.外移入
	,@cd_update				VARCHAR(10)	 -- ログインユーザーコード

AS
BEGIN
	-- NULL格納用変数宣言と格納
	DECLARE @null VARCHAR = NULL
	
	DECLARE @jissekiCount smallint
	
	-- DBに残っている実績数をカウントする
	select @jissekiCount = COUNT(*)
	FROM tr_niuke
	where no_nonyu in (SELECT no_nonyu
						FROM tr_niuke
						where no_niuke = @no_niuke_jisseki)

--	IF @no_niuke_jisseki = @no_niuke_yotei
	-- 最後の一件の場合は予定だけ残す。
	IF @jissekiCount = 1
		BEGIN
			UPDATE tr_niuke
			SET
				tm_nonyu_jitsu = @null
				,su_nonyu_jitsu = @null
				,su_nonyu_jitsu_hasu = @null
				,su_zaiko = @null
				,su_zaiko_hasu = @null
				,dt_seizo = @null
				,dt_kigen = @null
				,kin_kuraire = @null
				,no_lot = @null
				,no_nohinsho = @null
				,no_zeikan_shorui = @null
				,no_denpyo = @null
				,biko = @null
				,cd_hinmei_maker = @null
				,nm_kuni = @null
				,cd_maker_kojo = @null
				,nm_maker_kojo = @null
				,nm_tani_nonyu = @null
				,dt_nonyu = @null
				,dt_label_hakko = @null
				,cd_update = @cd_update
				,dt_update = GETUTCDATE()
			WHERE
--				no_niuke = @no_niuke_yotei
				no_niuke = @no_niuke_jisseki
				--AND kbn_nyushukko IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn)
				AND kbn_nyushukko IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)
		END	
	ELSE 
		BEGIN
			DELETE FROM tr_niuke WHERE no_niuke = @no_niuke_jisseki
		END
END
GO
