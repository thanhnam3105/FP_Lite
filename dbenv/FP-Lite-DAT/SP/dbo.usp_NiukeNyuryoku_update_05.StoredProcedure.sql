IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_update_05') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_update_05]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：荷受入力　明細(予定)の更新を荷受トランに書き込みます。（追加予定用）
ファイル名	：usp_NiukeNyuryoku_update_05
入力引数	：@flg_kakutei, @kbn_nyushukko, @tm_nonyu_yotei
			  , @su_nonyu_yotei, @su_nonyu_yotei_hasu
			  , @no_niuke, @shiireNyushukoKbn, @sotoinyuNyushukoKbn, @addKbn
			  , @user, @no_nonyu_yotei, @yojitusFlagYotei, @yojitsuFlagJisseki
出力引数	：--
戻り値		：--
作成日		：2016.11.30  BRC cho.k
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_update_05]
	@flg_kakutei			SMALLINT		-- 確定フラグ
	, @kbn_nyushukko		SMALLINT		-- 入出庫区分(仕入 or 外移入)
	, @tm_nonyu_yotei		DATETIME		-- 予定時刻
	, @su_nonyu_yotei		DECIMAL(9,2)	-- 納入予定数
	, @su_nonyu_yotei_hasu	DECIMAL(9,2)	-- 納入予定数(端数)
	, @no_niuke				VARCHAR(14)		-- 荷受番号(予定)
	, @shiireNyushukoKbn	SMALLINT		-- コード一覧/入出庫区分.仕入
	, @sotoinyuNyushukoKbn	SMALLINT		-- コード一覧/入出庫区分.外移入
	, @addKbn		        SMALLINT		-- コード一覧/入出庫区分.追加
	, @user					VARCHAR(10)		-- ログインユーザコード
	, @no_nonyu_yotei		VARCHAR(13)		-- 納入予定番号
	, @yojitsuFlagYotei		SMALLINT		-- 区分／コード一覧．予実フラグ．予定
	, @yojitsuFlagJisseki	SMALLINT		-- 区分／コード一覧．予実フラグ．実績
AS

BEGIN

	-- 荷受トラン更新処理
	UPDATE tr_niuke
	SET
		flg_kakutei = @flg_kakutei
		, kbn_nyushukko = @kbn_nyushukko
		, tm_nonyu_yotei = @tm_nonyu_yotei
		, su_nonyu_yotei = @su_nonyu_yotei
		, su_nonyu_yotei_hasu = @su_nonyu_yotei_hasu
		, cd_update = @user
		, dt_update = GETUTCDATE()
	WHERE
		( 
			no_niuke IN
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
					)
			OR no_niuke = @no_niuke
			OR no_nonyu = @no_nonyu_yotei
		)
		AND kbn_nyushukko IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn, @addKbn)
END
GO
