IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：荷受入力　実績の明細を削除した場合の荷受トラン削除処理を行います。
						全ての実績データが削除される場合は納入予実トランの
						データも削除します。
ファイル名	：usp_NiukeNyuryoku_delete
入力引数	：@no_niuke_yotei, @no_niuke_jisseki, @shiireNyushukoKbn
			  , @addKbn, @sotoinyuNyushukoKbn, @recordsCount, @deleteCount
			  , @cd_update, @nonyuNoYotei, @nonyuNoJitsu, @ryohinZaikoKubun
出力引数	：
戻り値		：
作成日		：2013.11.12  ADMAX kakuta.y
更新日		：2015.09.24  ADMAX kakuta.y 納入予定番号対応
更新日		：2016.11.22   BRC  kanehira.d 入出庫区分追加
更新日		：2017.06.26   BRC  cho.k １行目削除時の納入番号更新処理を修正（KPMサポートNo022）
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_delete]
	@no_niuke_yotei			VARCHAR(14)	 -- 明細(予定)荷受番号
	,@no_niuke_jisseki		VARCHAR(14)	 -- 明細(実績)荷受番号
	,@shiireNyushukoKbn		SMALLINT	 -- コード一覧/入出庫区分.仕入
	,@addKbn				SMALLINT	 -- コード一覧/入出庫区分.追加
	,@sotoinyuNyushukoKbn	SMALLINT	 -- コード一覧/入出庫区分.外移入
	,@recordsCount			SMALLINT	 -- 明細(実績)削除前総行数
	,@deleteCount			SMALLINT	 -- 明細(実績)削除総件数
	,@jissekiYojitsuFlg		SMALLINT	 -- 区分／コード一覧．予実フラグ．実績
	,@yoteiYojitsuFlg		SMALLINT	 -- 区分／コード一覧．予実フラグ．予定
	,@cd_update				VARCHAR(10)	 -- ログインユーザーコード
	,@nonyuNoYotei			VARCHAR(13)	 -- 納入予定番号
	,@nonyuNoJitsu			VARCHAR(13)	 -- 納入番号
	,@ryohinZaikoKubun		SMALLINT	 -- 区分／コード一覧．在庫区分．良品
AS
BEGIN

	IF @no_niuke_yotei = @no_niuke_jisseki	-- 明細(予定)の荷受番号と明細(実績)の荷受番号が同じで、明細(実績)の削除前行数と削除件数が同じ時(全ての行を削除する時)
		AND @recordsCount = @deleteCount

	BEGIN

		-- NULL格納用変数宣言と格納
		DECLARE @null VARCHAR = NULL
		-- 納入予実トラン削除のキー用変数宣言
		DECLARE @cd_hinmei		VARCHAR(14)
				,@cd_torihiki	VARCHAR(13)
				,@dt_niuke		DATETIME
				,@kbn_nyuko		SMALLINT
				,@no_nonyu		VARCHAR(13)


		-- 同じ荷受番号の中で入出庫区分.仕入,外移入以外のレコードを削除
		DELETE FROM tr_niuke
		WHERE
			no_niuke = @no_niuke_yotei
			--AND kbn_nyushukko NOT IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn)
			AND kbn_nyushukko NOT IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)


		-- 同じ荷受番号の中で入出庫区分.仕入,外移入のレコードを更新(予定として残す)
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
			no_niuke = @no_niuke_jisseki
			--AND kbn_nyushukko IN (@shiireNyushukoKbn, @sotoinyuNyushukoKbn)
			AND kbn_nyushukko IN (@shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn)


		-- 納入予実トランのデータを削除するためのキーを取得します。
		SELECT 
			@cd_hinmei = cd_hinmei
			,@cd_torihiki = cd_torihiki
			,@dt_niuke = dt_niuke
			,@kbn_nyuko = kbn_nyuko
			,@no_nonyu = no_nonyu
		FROM tr_niuke
		WHERE 
			no_niuke = @no_niuke_jisseki
			AND no_seq =	
			(
				SELECT 
					MIN(no_seq) AS no_seq
				FROM tr_niuke
			)

				
		-- 納入予実トランのデータを削除します。
		DELETE FROM tr_nonyu
		WHERE 
			--cd_hinmei = @cd_hinmei
			--AND cd_torihiki = @cd_torihiki
			--AND CONVERT(VARCHAR(10), dt_nonyu, 111) = CONVERT(VARCHAR(10), @dt_niuke, 111)
			--AND flg_yojitsu = @jissekiYojitsuFlg
			--AND no_nonyu = @no_nonyu
			----AND kbn_nyuko = @kbn_nyuko
			--AND (@kbn_nyuko is null or kbn_nyuko = @kbn_nyuko)
			flg_yojitsu = @jissekiYojitsuFlg
			AND no_nonyu_yotei = @nonyuNoYotei
		
		-- 荷受トランのデータを削除します
		delete from tr_niuke
		where no_niuke = @no_niuke_jisseki

	END
	
ELSE

	BEGIN

		---- 上記以外は実績の荷受番号を元にして削除
		--DELETE FROM tr_niuke
		--WHERE 
		--	no_niuke = @no_niuke_jisseki


		-- 削除対象行の納入番号で納入予定を取得します
		DECLARE @nonyuNo VARCHAR(13)
		SELECT
			@nonyuNo = nonyu.no_nonyu
		FROM tr_nonyu nonyu
		INNER JOIN tr_niuke niuke
		  ON niuke.no_nonyu = nonyu.no_nonyu
		  AND niuke.no_niuke = @no_niuke_jisseki
		WHERE
			nonyu.flg_yojitsu = @yoteiYojitsuFlg
		--	AND nonyu.no_nonyu = @nonyuNoJitsu


		-- 納入予定の存在チェック
		IF @nonyuNo IS NULL
		BEGIN
			-- 取得できない場合


			-- 荷受トランを削除
			DELETE FROM tr_niuke
			WHERE
				no_niuke = @no_niuke_jisseki


			-- 納入予実トランを削除
			DELETE FROM tr_nonyu
			WHERE
				flg_yojitsu = @jissekiYojitsuFlg
				AND no_nonyu = @nonyuNoJitsu
		END
		ELSE
		BEGIN
			-- 取得できる場合
			-- 納入予定番号と同じ納入番号の実績を削除する場合、
			-- 変わりの実績を納入予定番号と同じ納入番号に置き換える。


			-- 置き換え対象のキーを格納するための変数宣言
			DECLARE @no_nonyu_update		VARCHAR(13)		-- UPDATE対象
					,@no_niuke_update		VARCHAR(14)		-- UPDATE対象


			-- UPDATE対象を取得します
			SELECT
				@no_nonyu_update = updatedata.no_nonyu
				,@no_niuke_update = updatedata.no_niuke
			FROM
				(
					SELECT TOP 1
						t_no.no_nonyu
						,t_ni.no_niuke
					FROM tr_nonyu t_no
					INNER JOIN tr_niuke t_ni
					ON t_no.no_nonyu = t_ni.no_nonyu
					WHERE
						t_no.flg_yojitsu = @jissekiYojitsuFlg		-- 実績を取得
						AND t_no.no_nonyu <> t_no.no_nonyu_yotei	-- 納入番号と納入予定番号は異なる
						AND t_no.no_nonyu_yotei = @nonyuNoYotei		-- 対象の納入予定番号内で取得
					ORDER BY t_no.no_nonyu
				) updatedata


			-- 対象データの削除(荷受トラン、納入予実トラン)
			-- 荷受トランの実績を削除
			DELETE FROM tr_niuke
			WHERE
				no_niuke = @no_niuke_jisseki

			-- 納入予実トランの実績を削除
			DELETE FROM tr_nonyu
			WHERE
				flg_yojitsu = @jissekiYojitsuFlg
				--AND	no_nonyu = @nonyuNoJitsu
				AND no_nonyu = @nonyuNo


			-- 代替の納入実績の納入番号を納入予定番号で更新し、納入予定番号と同じ納入番号の実績を作成
			UPDATE tr_nonyu
				SET no_nonyu = @nonyuNoYotei
			WHERE
				flg_yojitsu = @jissekiYojitsuFlg
				AND no_nonyu = @no_nonyu_update


			-- 代替の荷受実績の納入番号を納入予定番号で更新し、納入予定番号と同じ納入番号の実績と紐付ける
			UPDATE tr_niuke
				SET no_nonyu = @nonyuNoYotei
			WHERE
				no_niuke = @no_niuke_update
				AND kbn_zaiko = @ryohinZaikoKubun
				AND no_seq = (
								SELECT
									MIN(no_seq)
								FROM tr_niuke
							 )
		END

	END

END
GO
