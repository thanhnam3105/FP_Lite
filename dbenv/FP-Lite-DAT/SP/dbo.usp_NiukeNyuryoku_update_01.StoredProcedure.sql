IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_update_01') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_update_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：荷受入力　明細(予定)の更新を荷受トランに書き込みます。
ファイル名	：usp_NiukeNyuryoku_update_01
入力引数	：@flg_kakutei, @kbn_nyushukko, @tm_nonyu_yotei
			  , @no_niuke, @addKbn, @shiireNyushukoKbn, @sotoinyuNyushukoKbn
			  , @user, @no_nonyu_yotei, @yojitusFlagYotei, @yojitsuFlagJisseki
出力引数	：
戻り値		：
作成日		：2013.11.13  ADMAX kakuta.y
更新日		：2015.09.24  ADMAX kakuta.y 納入予定番号対応
更新日		：2016.11.15  BRC cho.k 荷受行追加対応
更新日		：2016.11.22  BRC kanehira.d 入出庫区分追加
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_update_01]
	@flg_kakutei			SMALLINT	-- 確定フラグ
	,@kbn_nyushukko			SMALLINT	-- 入出庫区分(仕入 or 外移入)
	,@tm_nonyu_yotei		DATETIME	-- 予定時刻
	,@no_niuke				VARCHAR(14)	-- 荷受番号(予定)
	,@shiireNyushukoKbn		SMALLINT	-- コード一覧/入出庫区分.仕入
	,@addKbn		        SMALLINT	-- コード一覧/入出庫区分.追加
	,@sotoinyuNyushukoKbn	SMALLINT	-- コード一覧/入出庫区分.外移入
	,@user					VARCHAR(10)	-- ログインユーザコード
	--,@no_nonyu				VARCHAR(13)	-- 納入番号(予定)
	,@no_nonyu_yotei		VARCHAR(13)	-- 納入予定番号
	,@yojitsuFlagYotei		SMALLINT	-- 区分／コード一覧．予実フラグ．予定
	,@yojitsuFlagJisseki	SMALLINT	-- 区分／コード一覧．予実フラグ．実績
AS

BEGIN

	-- 荷受トラン更新処理
	UPDATE tr_niuke
	SET
		flg_kakutei = @flg_kakutei
		,kbn_nyushukko = @kbn_nyushukko
		,tm_nonyu_yotei	= @tm_nonyu_yotei
		,cd_update = @user
		,dt_update = GETUTCDATE()
	--WHERE
	--	no_niuke IN	
	--	(
	--		SELECT
	--			t_niu.no_niuke
	--		FROM tr_niuke t_niu
	--		INNER JOIN 
	--			(
	--				SELECT
	--					*
	--				FROM tr_niuke
	--				WHERE
	--					no_niuke = @no_niuke
	--			) t_n
	--		ON t_niu.dt_niuke = t_n.dt_niuke
	--		AND t_niu.cd_hinmei = t_n.cd_hinmei
	--		AND t_niu.cd_torihiki = t_n.cd_torihiki
	--		--AND t_niu.kbn_nyuko = t_n.kbn_nyuko
	--		AND ((t_niu.kbn_nyuko is null AND t_n.kbn_nyuko is null) or t_niu.kbn_nyuko = t_n.kbn_nyuko)
	--	)				
	--AND kbn_nyushukko IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn)
	--AND no_nonyu = @no_nonyu
	WHERE
		-- 納入予実トランと結合できるデータを対象
		--(no_nonyu IS NOT NULL
		--AND no_niuke IN
		( no_niuke IN
					(
						SELECT
							t_niu.no_niuke
						FROM tr_niuke t_niu
						INNER JOIN tr_nonyu t_nou
						ON t_niu.no_nonyu = t_nou.no_nonyu
						WHERE
							(t_nou.flg_yojitsu = @yojitsuFlagYotei
							AND t_nou.no_nonyu = @no_nonyu_yotei)
							OR 
							(t_nou.flg_yojitsu = @yojitsuFlagJisseki
							AND t_nou.no_nonyu_yotei = @no_nonyu_yotei)
		--			))
		)
		OR
		-- 納入予実トランと結合できないデータを対象
		--(no_nonyu IS NULL
		--	AND no_niuke = @no_niuke)
		no_niuke = @no_niuke
		OR no_nonyu = @no_nonyu_yotei )
		--AND kbn_nyushukko IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn)
		AND kbn_nyushukko IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)
END
GO
