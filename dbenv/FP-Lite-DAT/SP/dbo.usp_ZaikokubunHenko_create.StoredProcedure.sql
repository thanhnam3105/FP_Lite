IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ZaikokubunHenko_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ZaikokubunHenko_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：在庫区分変更 追加
ファイル名  ：usp_ZaikokubunHenko_create
入力引数    ：@no_niuke, @dt_niuke, @dt_nitizi
			  , @kbn_nyushukko, @kbn_zaiko, @tm_nonyu_jitsu
			  , @su_zaiko, @su_zaiko_hasu, @su_shukko
			  , @su_shukko_hasu, @biko, @cd_update
			  , @no_seq, @su_iri, @kbn_zaiko_ryohin, @kbn_zaiko_horyu
			  , @cd_genka_center, @cd_soko, @no_nohinsho
出力引数    ：
戻り値      ：
作成日      ：2013.10.03  ADMAX endo.y
更新日      ：2015.10.02  MJ ueno.k
更新日      ：2016.12.19  BRC motojima.m 中文対応
　　　      ：2023.09.04  BRC hashimoto  #2158 変更履歴画面（tr_henko_rireki）に返品データをインサート
*****************************************************/
CREATE PROCEDURE [dbo].[usp_ZaikokubunHenko_create] 
	@no_niuke            VARCHAR(14)   --(ロットNo.別在庫詳細から渡された値)
	, @dt_niuke          DATETIME	   --(ロットNo.別在庫詳細から渡された値)
	, @dt_nitizi         DATETIME	   --画面.変更日付
	, @kbn_nyushukko     SMALLINT
	, @kbn_zaiko         SMALLINT	   --ロットNo.別在庫詳細から渡された在庫区分
	, @tm_nonyu_jitsu    DATETIME	   --画面.変更時刻
	, @su_zaiko          DECIMAL(9, 2)
	, @su_zaiko_hasu     DECIMAL(9, 2)
	, @su_shukko         DECIMAL(9, 2)
	, @su_shukko_hasu    DECIMAL(9, 2)
	--, @biko            VARCHAR(50)   --画面.備考
	, @biko              NVARCHAR(50)  --画面.備考
	, @cd_update         VARCHAR(10)   --セッション情報ログインユーザーコード
	, @no_seq            DECIMAL(8)	   --ロットNo.別在庫詳細画面から渡されたシーケンス番号
	, @su_iri            DECIMAL(5)
	, @kbn_zaiko_ryohin  SMALLINT      --在庫区分"良品"
	, @kbn_zaiko_horyu   SMALLINT	   --在庫区分"保留"
	, @kbnChosei		 SMALLINT	   --調整数反映区分
	, @no_seq_chosei	 VARCHAR(14)   --調整トラン用シーケンス番号
	, @cd_hinmei		 VARCHAR(14)   --画面.品名コード
	, @cd_riyu			 VARCHAR(10)   --理由コード
	, @su_chosei		 DECIMAL(12,6) --調整数
	, @cd_nonyu			 VARCHAR(10)   --納入単位コード
	, @cd_genka_center	 VARCHAR(10)   --原価センターコード
	, @cd_soko			 VARCHAR(10)   --倉庫コード
	--, @no_nohinsho	 VARCHAR(16)   --納品書番号
	, @no_nohinsho		 NVARCHAR(16)  --納品書番号
AS
DECLARE
	@max_no_seq         DECIMAL(8)
	, @max_no_seq_insert DECIMAL(8)
	, @max_kbn_no_seq   DECIMAL(8)
	, @cnt_select       INT
	, @kbn_zaiko_henko  SMALLINT
	, @cs               DECIMAL(9,2)
	, @hasu             DECIMAL(9,2)
	, @csZaiko          DECIMAL(9,2)
	, @hasuZaiko        DECIMAL(9,2)
	, @day				SMALLINT
	, @min_no_seq       DECIMAL(8)
	, @cd_tirihiki      VARCHAR(13)
BEGIN

		SELECT @min_no_seq = MIN(minS.no_seq) FROM tr_niuke minS;

			SET @day = 1
			IF @kbn_zaiko = @kbn_zaiko_ryohin BEGIN
				SET @kbn_zaiko_henko = @kbn_zaiko_horyu
			END
			ELSE BEGIN
				SET @kbn_zaiko_henko = @kbn_zaiko_ryohin
			END 
			/*
			SET @max_no_seq  = (SELECT MAX(no_seq)
								FROM tr_niuke
								WHERE no_niuke = @no_niuke)
			*/
			SET @max_no_seq  = (SELECT MAX(no_seq)
								FROM tr_niuke
								WHERE no_niuke = @no_niuke
								AND 
								(
									(
										(
											convert(datetime,convert(varchar(10),dt_niuke,120) + ' ' +convert(varchar(8),tm_nonyu_jitsu,108)) 
											<= convert(datetime,convert(varchar(10),@dt_nitizi,120) + ' ' +convert(varchar(8),@tm_nonyu_jitsu,108))
										)
										AND 
										(
											no_seq <> @min_no_seq
										)
										AND
										(
											kbn_zaiko = @kbn_zaiko
										)
									)
									 OR 
									(
										(
											 convert(datetime,convert(varchar(10),dt_nonyu,120) + ' ' +convert(varchar(8),tm_nonyu_jitsu,108)) 
											<= convert(datetime,convert(varchar(10),@dt_nitizi,120) + ' ' +convert(varchar(8),@tm_nonyu_jitsu,108))
										)
										AND 
										(
											no_seq = @min_no_seq
										)
										AND
										(
											kbn_zaiko = @kbn_zaiko
										)
									)
								)
--								AND convert(datetime,convert(varchar(10),dt_niuke,120) + ' ' +convert(varchar(8),tm_nonyu_jitsu,108)) 
--									<= convert(datetime,convert(varchar(10),@dt_nitizi,120) + ' ' +convert(varchar(8),@tm_nonyu_jitsu,108))
							);
			SET @max_no_seq_insert = (SELECT MAX(no_seq)
								FROM tr_niuke
								WHERE no_niuke = @no_niuke
								AND 
								(
									(
										(
											convert(datetime,convert(varchar(10),dt_niuke,120) + ' ' +convert(varchar(8),tm_nonyu_jitsu,108)) 
											<= convert(datetime,convert(varchar(10),@dt_nitizi,120) + ' ' +convert(varchar(8),@tm_nonyu_jitsu,108))
										)
										AND 
										(
											no_seq <> @min_no_seq
										)
									)
									 OR 
									(
										(
											 convert(datetime,convert(varchar(10),dt_nonyu,120) + ' ' +convert(varchar(8),tm_nonyu_jitsu,108)) 
											<= convert(datetime,convert(varchar(10),@dt_nitizi,120) + ' ' +convert(varchar(8),@tm_nonyu_jitsu,108))
										)
										AND 
										(
											no_seq = @min_no_seq
										)
									)
								)
							);		

			-- 後続データのシーケンス番号をずらします。
			UPDATE tr_niuke
				SET no_seq = no_seq + 1
			WHERE no_niuke = @no_niuke
				AND no_seq >= @max_no_seq_insert + 1


			INSERT INTO tr_niuke 
			(
			    [no_niuke]
			    , [dt_niuke]
			    , [cd_hinmei]
			    , [kbn_hin]
			    , [cd_niuke_basho]
			    , [kbn_nyushukko]
			    , [kbn_zaiko]
			    , [tm_nonyu_yotei]
			    , [su_nonyu_yotei]
			    , [su_nonyu_yotei_hasu]
			    , [tm_nonyu_jitsu]
			    , [su_nonyu_jitsu]
			    , [su_nonyu_jitsu_hasu]
			    , [su_zaiko]
			    , [su_zaiko_hasu]
			    , [su_shukko]
			    , [su_shukko_hasu]
			    , [su_kakozan]
			    , [su_kakozan_hasu]
			    , [dt_seizo]
			    , [dt_kigen]
			    , [kin_kuraire]
			    , [no_lot]
			    , [no_denpyo]
			    , [biko]
			    , [cd_torihiki]
			    , [flg_kakutei]
			    , [cd_hinmei_maker]
			    , [nm_kuni]
			    , [cd_maker]
			    , [nm_maker]
			    , [cd_maker_kojo]
			    , [nm_maker_kojo]
			    , [nm_hyoji_nisugata]
			    , [nm_tani_nonyu]
			    , [dt_nonyu]
			    , [dt_label_hakko]
			    , [cd_update]
			    , [dt_update]
			    , [no_seq]
		    )
			SELECT
			    @no_niuke
			    , @dt_nitizi
			    , cd_hinmei
			    , kbn_hin
			    , cd_niuke_basho
			    , @kbn_nyushukko
			    , kbn_zaiko
			    , tm_nonyu_yotei
			    , su_nonyu_yotei
			    , su_nonyu_yotei_hasu
			    , @tm_nonyu_jitsu 
			    , 0
			    , 0
			    , @su_zaiko
			    , @su_zaiko_hasu
			    , @su_shukko
			    , @su_shukko_hasu
			    , 0
			    , 0
			    , dt_seizo
			    , dt_kigen
			    , kin_kuraire
			    , no_lot
			    , no_denpyo
			    , @biko
			    , cd_torihiki
			    , flg_kakutei
			    , cd_hinmei_maker
			    , nm_kuni
			    , cd_maker
			    , nm_maker
			    , cd_maker_kojo
			    , nm_maker_kojo
			    , nm_hyoji_nisugata
			    , nm_tani_nonyu
			    , dt_nonyu
			    , dt_label_hakko
			    , @cd_update 
			    , GETUTCDATE()
			    , @max_no_seq_insert + 1
			FROM tr_niuke
			WHERE
				no_niuke                           = @no_niuke
				--AND no_seq                         = @no_seq
				AND no_seq                         = @max_no_seq
				--AND (@dt_niuke <= dt_niuke AND dt_niuke < (SELECT DATEADD(DD,@day,@dt_niuke)))
				AND kbn_zaiko                      = @kbn_zaiko 
				--AND dt_niuke < (SELECT DATEADD(DD,@day,@dt_nitizi))
			
	IF @@ROWCOUNT >= 1 BEGIN
		/*		
		--7-3 選択してない在庫区分の最新シーケンス番号を取得します。
		SET @max_kbn_no_seq = (SELECT MAX(no_seq)
								FROM tr_niuke
								WHERE no_niuke    = @no_niuke
									AND kbn_zaiko <> @kbn_zaiko)

		--7-4 履歴が存在するか確認します。
		SET @cnt_select = (SELECT count(*) 
							FROM tr_niuke 
							WHERE no_niuke    = @no_niuke
								AND kbn_zaiko <> @kbn_zaiko)
		*/
		--7-3 選択してない在庫区分の最新シーケンス番号を取得します。
		SET @max_kbn_no_seq = (SELECT MAX(no_seq)
								FROM tr_niuke
								WHERE no_niuke    = @no_niuke
									AND kbn_zaiko <> @kbn_zaiko
									AND convert(datetime,convert(varchar(10),dt_niuke,120) + ' ' +convert(varchar(8),tm_nonyu_jitsu,108)) 
										<= convert(datetime,convert(varchar(10),@dt_nitizi,120) + ' ' +convert(varchar(8),@tm_nonyu_jitsu,108))
									)

		--7-4 履歴が存在するか確認します。
		SET @cnt_select = (SELECT count(*) 
							FROM tr_niuke 
							WHERE no_niuke    = @no_niuke
								AND kbn_zaiko <> @kbn_zaiko
								AND convert(datetime,convert(varchar(10),dt_niuke,120) + ' ' +convert(varchar(8),tm_nonyu_jitsu,108)) 
									<= convert(datetime,convert(varchar(10),@dt_nitizi,120) + ' ' +convert(varchar(8),@tm_nonyu_jitsu,108))
								)


		--履歴が存在しない場合
		IF @cnt_select = 0 BEGIN

			INSERT INTO tr_niuke
			(
			    [no_niuke]
			    , [dt_niuke]
			    , [cd_hinmei]
			    , [kbn_hin]
			    , [cd_niuke_basho]
			    , [kbn_nyushukko]
			    , [kbn_zaiko]
			    , [tm_nonyu_yotei]
			    , [su_nonyu_yotei]
			    , [su_nonyu_yotei_hasu]
			    , [tm_nonyu_jitsu]
			    , [su_nonyu_jitsu]
			    , [su_nonyu_jitsu_hasu]
			    , [su_zaiko]
			    , [su_zaiko_hasu]
			    , [su_shukko]
			    , [su_shukko_hasu]
			    , [su_kakozan]
			    , [su_kakozan_hasu]
			    , [dt_seizo]
			    , [dt_kigen]
			    , [kin_kuraire]
			    , [no_lot]
			    , [no_denpyo]
			    , [biko]
			    , [cd_torihiki]
			    , [flg_kakutei]
			    , [cd_hinmei_maker]
			    , [nm_kuni]
			    , [cd_maker]
			    , [nm_maker]
			    , [cd_maker_kojo]
			    , [nm_maker_kojo]
			    , [nm_hyoji_nisugata]
			    , [nm_tani_nonyu]
			    , [dt_nonyu]
			    , [dt_label_hakko]
			    , [cd_update]
			    , [dt_update]
			    , [no_seq]
			)
			 SELECT
    			 @no_niuke
				 , @dt_nitizi
				 , cd_hinmei
		         , kbn_hin
	    	     , cd_niuke_basho
			     , @kbn_nyushukko
			     , @kbn_zaiko_henko
			     , tm_nonyu_yotei
			     , su_nonyu_yotei
			     , su_nonyu_yotei_hasu
			     , @tm_nonyu_jitsu 
			     , @su_shukko
			     , @su_shukko_hasu
			     , @su_shukko
			     , @su_shukko_hasu
			     , 0
			     , 0
			     , 0
			     , 0
			     , dt_seizo
			     , dt_kigen
			     , kin_kuraire
			     , no_lot
			     , no_denpyo
			     , @biko  
			     , cd_torihiki
			     , flg_kakutei
			     , cd_hinmei_maker
			     , nm_kuni
			     , cd_maker
			     , nm_maker
			     , cd_maker_kojo
			     , nm_maker_kojo
			     , nm_hyoji_nisugata
			     , nm_tani_nonyu
			     , dt_nonyu
			     , dt_label_hakko
			     , @cd_update 
			     , GETUTCDATE()
			     , @max_no_seq_insert + 1
			FROM tr_niuke
			WHERE
				no_niuke      = @no_niuke
				--AND no_seq    = @no_seq
				AND no_seq    = @max_no_seq
				AND kbn_zaiko = @kbn_zaiko
		END
		ELSE BEGIN
		--履歴が1件以上存在する場合
			SELECT
				@cs    = su_zaiko
				,@hasu = su_zaiko_hasu
			FROM tr_niuke
			WHERE no_niuke    = @no_niuke
				AND no_seq    = @max_kbn_no_seq
				AND kbn_zaiko <> @kbn_zaiko	
			IF @cd_nonyu = '4' or @cd_nonyu = '11'
			BEGIN
				SET @csZaiko   = ROUND((((@cs + @su_shukko) * @su_iri +((@hasu + @su_shukko_hasu) / 1000)) / @su_iri),0,1)
				SET @hasuZaiko = (((@cs + @su_shukko) * @su_iri +((@hasu + @su_shukko_hasu) / 1000))% @su_iri) * 1000
			END
			ELSE
			BEGIN
				SET @csZaiko   = ROUND((((@cs + @su_shukko) * @su_iri +(@hasu + @su_shukko_hasu)) / @su_iri),0,1)
				SET @hasuZaiko = ((@cs + @su_shukko) * @su_iri +(@hasu + @su_shukko_hasu))% @su_iri
			END
			INSERT INTO tr_niuke
		   (
			    [no_niuke]
			    , [dt_niuke]
			    , [cd_hinmei]
			    , [kbn_hin]
			    , [cd_niuke_basho]
			    , [kbn_nyushukko]
			    , [kbn_zaiko]
			    , [tm_nonyu_yotei]
			    , [su_nonyu_yotei]
			    , [su_nonyu_yotei_hasu]
			    , [tm_nonyu_jitsu]
			    , [su_nonyu_jitsu]
			    , [su_nonyu_jitsu_hasu]
			    , [su_zaiko]
			    , [su_zaiko_hasu]
			    , [su_shukko]
			    , [su_shukko_hasu]
			    , [su_kakozan]
			    , [su_kakozan_hasu]
			    , [dt_seizo]
			    , [dt_kigen]
			    , [kin_kuraire]
			    , [no_lot]
			    , [no_denpyo]
			    , [biko]
			    , [cd_torihiki]
			    , [flg_kakutei]
			    , [cd_hinmei_maker]
			    , [nm_kuni]
			    , [cd_maker]
			    , [nm_maker]
			    , [cd_maker_kojo]
			    , [nm_maker_kojo]
			    , [nm_hyoji_nisugata]
			    , [nm_tani_nonyu]
			    , [dt_nonyu]
			    , [dt_label_hakko]
			    , [cd_update]
			    , [dt_update]
			    , [no_seq]
		   )
			 SELECT
			    @no_niuke
			    , @dt_nitizi
			    , cd_hinmei
			    , kbn_hin
			    , cd_niuke_basho
			    , @kbn_nyushukko
			    , kbn_zaiko
			    , tm_nonyu_yotei
			    , su_nonyu_yotei
			    , su_nonyu_yotei_hasu
			    , @tm_nonyu_jitsu 
			    , @su_shukko
			    , @su_shukko_hasu
			    , @csZaiko
			    , @hasuZaiko
			    , 0
			    , 0
			    , 0
			    , 0
			    , dt_seizo
			    , dt_kigen
			    , kin_kuraire
			    , no_lot
			    , no_denpyo
			    , @biko  
			    , cd_torihiki
			    , flg_kakutei
			    , cd_hinmei_maker
			    , nm_kuni
			    , cd_maker
			    , nm_maker
			    , cd_maker_kojo
			    , nm_maker_kojo
			    , nm_hyoji_nisugata
			    , nm_tani_nonyu
			    , dt_nonyu
			    , dt_label_hakko
			    , @cd_update 
			    , GETUTCDATE()
			    , @max_no_seq_insert + 1
			FROM tr_niuke
			WHERE no_niuke    = @no_niuke
				AND no_seq    = @max_kbn_no_seq
				AND kbn_zaiko <> @kbn_zaiko
		END
		IF @kbnChosei = 1 BEGIN
		--調整トラン追加処理	
		SET @cd_tirihiki = (
			SELECT cd_torihiki 
			FROM tr_niuke 
			WHERE no_niuke    = @no_niuke
				AND no_seq    = @min_no_seq
				AND kbn_zaiko = @kbn_zaiko
		)
		
			INSERT INTO tr_chosei
			(
				[no_seq]
				, [cd_hinmei]
				, [dt_hizuke]
				, [cd_riyu]
				, [su_chosei]
				, [biko]
				, [cd_seihin]
				, [dt_update]
				, [cd_update]
				, [cd_genka_center] 
				, [cd_soko] 
				, [no_nohinsho] 
				, [no_niuke] 
				, [kbn_zaiko] 
				, [cd_torihiki] 
			)
			VALUES
			(
				@no_seq_chosei
				, @cd_hinmei
				, @dt_nitizi
				, @cd_riyu
				, @su_chosei
				, @biko
				, ''
				, GETUTCDATE()
				, @cd_update
				, @cd_genka_center
				, @cd_soko
				, @no_nohinsho
				, @no_niuke 
				, @kbn_zaiko
				, @cd_tirihiki
			)

			--変更履歴トランに調整トランへの登録履歴を挿入 #2158
	    	INSERT INTO tr_henko_rireki
		    (
			     kbn_data
				,kbn_shori
				,dt_hizuke
				,cd_hinmei
				,su_henko
				,su_henko_hasu
				,no_lot
				,biko
				,dt_update
				,cd_update
			)
			VALUES
			(
				 1
				,0
				,@dt_nitizi
				,@cd_hinmei
				,@su_chosei
				,0
				,@no_seq_chosei
				,''
				,GETUTCDATE()
				,@cd_update
			)						

		END
		
		--履歴の在庫再計算
		EXEC usp_IdoShukkoShosai_update02  
		@no_niuke        = @no_niuke
		, @kbn_zaiko     = @kbn_zaiko
		, @kbn_nyushukko = 4
		,@cdNonyuTani = @cd_nonyu
		
		--履歴の在庫再計算
		EXEC usp_IdoShukkoShosai_update02  
		@no_niuke        = @no_niuke
		, @kbn_zaiko     = @kbn_zaiko_henko
		, @kbn_nyushukko = 4
		,@cdNonyuTani = @cd_nonyu
		
	END
END
GO
