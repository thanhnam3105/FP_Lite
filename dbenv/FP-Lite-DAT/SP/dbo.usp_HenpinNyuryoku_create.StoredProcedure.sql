IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HenpinNyuryoku_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HenpinNyuryoku_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：返品入力 追加
ファイル名  ：usp_HenpinNyuryoku_create
入力引数    ：@no_niuke, @dt_nitizi, @kbn_nyushukko, @kbn_zaiko, @tm_nonyu_jitsu
			 , @su_zaiko, @su_zaiko_hasu, @su_shukko, @su_shukko_hasu, @biko, @cd_update
			 , @no_seq, @kbn_zaiko_ryohin, @kbn_zaiko_horyu, @cd_seihin, @cd_hinmei
			 , @su_chosei, @cd_nonyu, @flg_kakutei, @cd_soko, @no_nohinsho, @cd_genka_center, @cd_torihiki
			 , @updflag, @cd_riyu_henpin,@kbn_zaiko_horyu,@kbn_zaiko_horyu,@su_chosei_org,@kbn_sokoidokanri
出力引数    ：
戻り値      ：
作成日      ：2015.09.17  MJ ueno.k 
更新日      ：2016.12.19  BRC motojima.m 中文対応
			　2019.02.08　BRC takaki.r ニアショア作業依頼No.497
			：2023.07.12  BRC hashimoto	ニアショア作業依頼 #2158
*****************************************************/
CREATE PROCEDURE [dbo].[usp_HenpinNyuryoku_create] 
	@no_niuke					VARCHAR(14)		--(ロットNo.別在庫詳細から渡された値)
	, @dt_nitizi				DATETIME		--画面.変更日付
	, @kbn_nyushukko			SMALLINT
	, @kbn_zaiko				SMALLINT		--ロットNo.別在庫詳細から渡された在庫区分
	, @tm_nonyu_jitsu			DATETIME		--画面.変更時刻
	, @su_zaiko					DECIMAL(9,2)
	, @su_zaiko_hasu			DECIMAL(9,2)
	, @su_shukko				DECIMAL(9,2)
	, @su_shukko_hasu			DECIMAL(9,2)
	--, @biko					VARCHAR(50)		--画面.備考
	, @biko						NVARCHAR(50)	--画面.備考
	, @cd_update				VARCHAR(10)		--セッション情報ログインユーザーコード
	, @no_seq					DECIMAL(8)		--ロットNo.別在庫詳細画面から渡されたシーケンス番号
	, @cd_seihin				VARCHAR(14)		--画面.製品コード
	, @cd_hinmei				VARCHAR(14)		--画面.品名コード
	, @su_chosei				DECIMAL(12,6)	--調整数
	, @cd_nonyu					VARCHAR(10)		--納入単位コード
    , @flg_kakutei				SMALLINT		--確定フラグ
    , @cd_soko					VARCHAR(10)		--倉庫コード
    --, @no_nohinsho			VARCHAR(16)		--納品書番号
    , @no_nohinsho				NVARCHAR(16)	--納品書番号
    --, @no_zeikan_shorui		VARCHAR(16)		--税関書類No
    , @no_zeikan_shorui			NVARCHAR(16)	--税関書類No
    , @cd_genka_center			VARCHAR(10)		--原価センターコード
    , @cd_torihiki				VARCHAR(13)		--取引先コード
    , @updflag					SMALLINT
	, @cd_riyu_horyumodoshi		VARCHAR(10)		--理由コード(保留→良品)
	, @cd_riyu_henpin			VARCHAR(10)		--理由コード(返品)
	, @kbn_zaiko_ryohin			SMALLINT		--在庫区分(良品)
	, @kbn_zaiko_horyu			SMALLINT		--在庫区分(保留)
	, @kbn_nyushukko_henpin		SMALLINT		--入出庫区分(返品)
	, @kbn_saiban_chosei		VARCHAR(2)		--採番区分
	, @kbn_saiban_choseiprefix	VARCHAR(1)		--採番区分プレフィックス
	, @kbn_kg_Kanzan			SMALLINT		--換算区分(Kg)
	, @kbn_l_Kanzan				SMALLINT		--換算区分(L)
	, @su_irisu					DECIMAL(5, 0)	--入数
	, @wt_ko					DECIMAL(12, 6)	--個重量
	, @cd_niuke_basho			VARCHAR(10)
	, @su_chosei_org			DECIMAL(12,6)	--調整数(画面入力)
	, @kbn_sokoidokanri			SMALLINT		--倉庫移動管理機能切替区分
AS
DECLARE
	@max_no_seq         DECIMAL(8)
	, @max_kbn_no_seq   DECIMAL(8)
	, @cnt_select       INT
	, @cs               DECIMAL(9,2)
	, @hasu             DECIMAL(9,2)
	, @csZaiko          DECIMAL(9,2)
	, @hasuZaiko        DECIMAL(9,2)
	, @day				SMALLINT
    , @before_no_seq    DECIMAL(8)
    , @ryohin_no_seq   DECIMAL(8)
    , @ryohin_kbn_nyusyukko SMALLINT
    , @updflag_ryohin  SMALLINT	
    , @su_chosei_minus DECIMAL(12,6)
  	, @no_seq_chosei_nyuko	 VARCHAR(14)	--調整トラン用シーケンス番号(良品入庫)
  	, @no_seq_chosei_henpin	 VARCHAR(14)	--調整トラン用シーケンス番号(良品返品)
  	, @return_value VARCHAR(14)
	, @dt_check datetime
	, @su_base_shukko         DECIMAL(9,2)
	, @su_base_shukko_hasu    DECIMAL(9,2)
	, @su_base_zaiko         DECIMAL(9,2)
	, @su_base_zaiko_hasu    DECIMAL(9,2)
	, @su_kiriage			 DECIMAL(9)
	, @su_base_chosei		 DECIMAL(12,6)
	, @no_seq_chosei	 VARCHAR(14)	--調整トラン用シーケンス番号


BEGIN
	DECLARE @cd_niuke_basho_main VARCHAR(10)
			, @no_seq_main DECIMAL(8, 0);

	SELECT TOP 1 
		@cd_niuke_basho_main = data.cd_niuke_basho
		, @no_seq_main = data.no_seq
	FROM
		(SELECT TOP 1
			MAX(niuke.no_seq) AS no_seq
			, niuke.cd_niuke_basho
		FROM tr_niuke niuke
		WHERE
			niuke.no_niuke = @no_niuke
			AND niuke.cd_niuke_basho = @cd_niuke_basho
			AND niuke.kbn_nyushukko = @kbn_nyushukko_henpin
			AND CONVERT(DATETIME,CONVERT(VARCHAR(10), niuke.dt_niuke,120))
				= CONVERT(DATETIME,CONVERT(VARCHAR(10),@dt_nitizi,120))
			AND niuke.no_seq IN (SELECT MAX(no_seq)
								 FROM  tr_niuke
								WHERE
									no_niuke = @no_niuke
									AND CONVERT(DATETIME,CONVERT(VARCHAR(10), dt_niuke,120))
									= CONVERT(DATETIME,CONVERT(VARCHAR(10),@dt_nitizi,120)))
		GROUP BY 
			niuke.cd_niuke_basho) data;
			
			SET @day = 1
			
            IF @updflag = 1 BEGIN
            --返品データ更新
				--荷受トランへ返品データの変更
                UPDATE tr_niuke 
                    SET su_zaiko  = @su_zaiko,
                        su_zaiko_hasu = @su_zaiko_hasu,
                        su_shukko = @su_shukko,
                        su_shukko_hasu = @su_shukko_hasu,
                        biko      = @biko,
                        cd_update = @cd_update,
                        tm_nonyu_jitsu = @tm_nonyu_jitsu,
                        dt_update = GETUTCDATE() 
                WHERE 
    				no_niuke      = @no_niuke
	    			AND no_seq    = @no_seq
		    		AND kbn_zaiko = @kbn_zaiko
		    		AND cd_niuke_basho = @cd_niuke_basho

				if @kbn_zaiko != @kbn_zaiko_horyu BEGIN --保留の場合はこの時点ではまだ調整トラン更新しない
					--採番ストアド実行
					EXEC @return_value = [dbo].[usp_cm_Saiban]
						@kbn_saiban = @kbn_saiban_chosei,
						@kbn_prefix = @kbn_saiban_choseiprefix,
						@no_saiban = @no_seq_chosei OUTPUT

					--調整トラン追加処理	
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
						, [cd_soko]
						, [cd_genka_center] 
					    ,[no_nohinsho]
						,[nm_henpin]
	                    ,[no_niuke]
		                ,[kbn_zaiko]
			            ,[cd_torihiki]
					)
					VALUES
					(
						@no_seq_chosei
						, @cd_hinmei
						, @dt_nitizi
						, @cd_riyu_henpin
						, @su_chosei_org
						, @biko
						, @cd_seihin
						, GETUTCDATE()
						, @cd_update
						, @cd_soko
						, @cd_genka_center
				        ,@no_nohinsho
					    ,@biko
						,@no_niuke
				        ,@kbn_zaiko
					    ,@cd_torihiki
					)
						
					--変更履歴トランに調整トランへの登録履歴を挿入
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
						,1
						,@dt_nitizi
						,@cd_hinmei
						,@su_chosei_org
						,0
						,@no_seq_chosei
						,@biko
						,GETUTCDATE()
						,@cd_update
					)
				END		
            END
            ELSE BEGIN
            --返品データ追加
                SET @before_no_seq = @no_seq - 1
				IF (@cd_niuke_basho_main IS NULL)
				BEGIN
    				SET @max_no_seq  = (SELECT MAX(no_seq)
									FROM tr_niuke
									WHERE 
										no_niuke = @no_niuke
										AND convert(datetime,convert(varchar(10),dt_niuke,120))
											<= convert(datetime,convert(varchar(10),@dt_nitizi,120))
										);
				END 
				ELSE BEGIN
					SET @max_no_seq  = (SELECT MAX(no_seq)
								FROM tr_niuke
								WHERE 
									no_niuke = @no_niuke
									AND kbn_nyushukko <> @kbn_nyushukko_henpin
									AND no_seq <= @no_seq_main
									AND convert(datetime,convert(varchar(10),dt_niuke,120))
										<= convert(datetime,convert(varchar(10),@dt_nitizi,120))
									);
				END
					
	    		-- 後続データのシーケンス番号をずらします。
		    	UPDATE tr_niuke
			    	SET no_seq = no_seq + 1
		    	WHERE no_niuke = @no_niuke
				    AND no_seq >= @max_no_seq + 1
		        
                -- 荷受トランへ返品データの書込
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
			    ,[kbn_nyuko]
			    ,[no_nonyu]
			    ,[flg_shonin]
			    ,[no_nohinsho]
			    ,[no_zeikan_shorui]
    		    )
	    		SELECT
			    no_niuke
			    , @dt_nitizi
			    , cd_hinmei
			    , kbn_hin
			    , @cd_niuke_basho
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
			    , @flg_kakutei
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
			    , @max_no_seq + 1
			    , kbn_nyuko
			    , no_nonyu
				, null
				, null
				, null
	    		FROM tr_niuke
		    	WHERE
				no_niuke                           = @no_niuke
				AND no_seq                         = @before_no_seq
				AND kbn_zaiko                      = @kbn_zaiko 
				AND cd_niuke_basho 				   = @cd_niuke_basho
				
            	IF @@ROWCOUNT >= 1 BEGIN
					if @kbn_zaiko != @kbn_zaiko_horyu BEGIN --保留の場合はこの時点ではまだ調整トラン更新しない
					--採番ストアド実行
					EXEC @return_value = [dbo].[usp_cm_Saiban]
						@kbn_saiban = @kbn_saiban_chosei,
						@kbn_prefix = @kbn_saiban_choseiprefix,
						@no_saiban = @no_seq_chosei OUTPUT

					--調整トラン追加処理	
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
							, [cd_soko]
							, [cd_genka_center] 
						    ,[no_nohinsho]
							,[nm_henpin]
		                    ,[no_niuke]
			                ,[kbn_zaiko]
				            ,[cd_torihiki]
						)
						VALUES
						(
							@no_seq_chosei
							, @cd_hinmei
							, @dt_nitizi
							, @cd_riyu_henpin
							, @su_chosei
							, @biko
							, @cd_seihin
							, GETUTCDATE()
							, @cd_update
							, @cd_soko
							, @cd_genka_center
					        ,@no_nohinsho
						    ,@biko
							,@no_niuke
					        ,@kbn_zaiko
						    ,@cd_torihiki
						)
				
				--変更履歴トランに調整トランへの登録履歴を挿入
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
					,1
					,@dt_nitizi
					,@cd_hinmei
					,@su_chosei
					,0
					,@no_seq_chosei
					,@biko
					,GETUTCDATE()
					,@cd_update
				)						
				
			END
		END
    END

		--履歴の在庫再計算
		EXEC usp_IdoShukkoShosai_update03  
		@no_niuke			= @no_niuke
		, @kbn_zaiko		= @kbn_zaiko
		, @kbn_nyushukko	= 4 
		, @cdNonyuTani		= @cd_nonyu
		, @cdNiuke_basho	= @cd_niuke_basho

	IF @kbn_zaiko = @kbn_zaiko_horyu BEGIN --保留の場合の続き処理
		--良品側への入庫シーケンスNo取得
		SET @ryohin_no_seq = (
			select top 1 
				no_seq 
			from tr_niuke 
			where no_niuke = @no_niuke
				and kbn_zaiko = @kbn_zaiko_ryohin
				and dt_niuke <= @dt_nitizi
				and cd_niuke_basho = @cd_niuke_basho
				order by no_seq desc
		)
		DECLARE @ryohin_no_seq_max DECIMAL(8,0);
		IF (@cd_niuke_basho_main IS NULL)
		BEGIN
			SET @ryohin_no_seq_max = (
				select top 1 
					no_seq 
				from tr_niuke 
				where no_niuke = @no_niuke
					and dt_niuke <= @dt_nitizi
					order by no_seq desc
			);
		END
		ELSE BEGIN
			SET @ryohin_no_seq_max = (
				select top 1 
					no_seq 
				from tr_niuke 
				where no_niuke = @no_niuke
					and dt_niuke <= @dt_nitizi
					and kbn_nyushukko <> @kbn_nyushukko_henpin
					and no_seq <= @no_seq_main
				order by no_seq desc
			);
		END

		select top 1 
				@ryohin_kbn_nyusyukko = kbn_nyushukko 
				,@dt_check = dt_niuke
				,@su_base_zaiko = su_zaiko
				,@su_base_zaiko_hasu = su_zaiko_hasu
				,@su_base_shukko = su_shukko
				,@su_base_shukko_hasu = su_shukko_hasu
		from tr_niuke 
		where no_niuke = @no_niuke
			and kbn_zaiko = @kbn_zaiko_ryohin
			and no_seq = @ryohin_no_seq
			and cd_niuke_basho = @cd_niuke_basho
		
		IF @ryohin_kbn_nyusyukko = @kbn_nyushukko_henpin AND @dt_check = @dt_nitizi AND @cd_niuke_basho_main IS NOT NULL BEGIN
			--対象シーケンスNoが返品でかつ、同日の場合
			--良品の返品データ更新
			SET @updflag_ryohin = 1
			
			--返品数合算
			set @su_base_shukko = @su_base_shukko + @su_shukko
			set @su_base_shukko_hasu = @su_base_shukko_hasu + @su_shukko_hasu
			--端数繰上げ処理			
			IF @cd_nonyu = @kbn_kg_Kanzan OR @cd_nonyu = @kbn_L_Kanzan BEGIN 
				IF @su_base_shukko_hasu >= 1000 BEGIN
					SET @su_base_shukko_hasu = ABS(@su_base_shukko_hasu)
					SET @su_kiriage = CEILING(@su_base_shukko_hasu / 1000 / @su_irisu) - 1
					IF @su_kiriage = 0 AND @su_base_shukko_hasu = 1000 BEGIN
						SET @su_kiriage = 1
					END
					SET @su_base_shukko = @su_base_shukko + @su_kiriage
					SET @su_base_shukko_hasu = @su_base_shukko - @su_kiriage * 1000 * @su_irisu
				END
			END
			ELSE BEGIN
				IF @su_base_shukko_hasu >= @su_irisu BEGIN
					SET @su_base_shukko_hasu = ABS(@su_base_shukko_hasu)
					SET @su_kiriage = CEILING(@su_base_shukko_hasu / @su_irisu) - 1
					IF @su_kiriage = 0 AND @su_base_shukko_hasu = @su_irisu BEGIN
						SET @su_kiriage = 1
					END
					SET @su_base_shukko = @su_base_shukko + @su_kiriage
					SET @su_base_shukko_hasu = @su_base_shukko_hasu - @su_kiriage * @su_irisu
				END
			END
			
			--合算した値で調整数を再計算
			IF @cd_nonyu = @kbn_kg_Kanzan OR @cd_nonyu = @kbn_L_Kanzan BEGIN 
				SET @su_base_chosei = ((@su_base_shukko * @su_irisu) * @wt_ko) + (@su_base_shukko_hasu / 1000)
			END
			ELSE BEGIN
                SET @su_base_chosei = ((@su_base_shukko * @su_irisu) * @wt_ko) + (@su_base_shukko_hasu * @wt_ko)
			END
			
			--合算した返品数で荷受トラン更新
			UPDATE tr_niuke 
			SET 
				su_shukko = @su_base_shukko,
				su_shukko_hasu = @su_base_shukko_hasu,
				biko      = @biko,
				cd_update = @cd_update,
				tm_nonyu_jitsu = @tm_nonyu_jitsu,
				dt_update = GETUTCDATE() 
			WHERE 
				no_niuke      = @no_niuke
				AND no_seq    = @ryohin_no_seq
				AND kbn_zaiko = @kbn_zaiko_ryohin
				AND cd_niuke_basho = @cd_niuke_basho
			
			--出庫の直前シーケンスに入庫分を追加
			SET @before_no_seq =@ryohin_no_seq;
			
	    	-- 後続データのシーケンス番号をずらします。
		    --UPDATE tr_niuke
			   --	SET no_seq = no_seq + 1
		    --WHERE no_niuke = @no_niuke
			   -- AND no_seq >= @ryohin_no_seq_max + 2

			--入庫分の荷受トラン更新(上記返品したシーケンス番号の1つ上に追加)
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
			   ,[kbn_nyuko]
			   ,[no_nonyu]
			    ,[flg_shonin]
			    ,[no_nohinsho]
			    ,[no_zeikan_shorui]
    		   )
	    	SELECT
			   no_niuke
			   , @dt_nitizi
			   , cd_hinmei
			   , kbn_hin
			   , @cd_niuke_basho
			   , @kbn_nyushukko
			   , kbn_zaiko
			   , tm_nonyu_yotei
			   , su_nonyu_yotei
			   , su_nonyu_yotei_hasu
			   , @tm_nonyu_jitsu 
			   , @su_shukko
			   , @su_shukko_hasu
			   , @su_zaiko
			   , @su_zaiko_hasu
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
			   , @flg_kakutei
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
			   , @ryohin_no_seq_max
			   ,kbn_nyuko
			   ,no_nonyu
				,null
				,null
				,null
--			   ,flg_shonin 
--				,no_nohinsho
--				,no_zeikan_shorui 
	    	FROM tr_niuke
		    WHERE
				no_niuke                           = @no_niuke
				AND no_seq                         = @before_no_seq
				AND kbn_zaiko                      = @kbn_zaiko_ryohin 
				AND cd_niuke_basho 				   = @cd_niuke_basho

			--倉庫移動管理機能を使用している場合は、
			--調整トランに在庫区分変更のレコードを登録しない
			IF @kbn_sokoidokanri = 0 or @kbn_sokoidokanri IS NULL
			BEGIN
				--入庫分の調整トラン追加処理	
				SET @su_chosei_minus = 0 - @su_chosei --入庫分長整数をマイナスに
				EXEC @return_value = [dbo].[usp_cm_Saiban]
					@kbn_saiban = @kbn_saiban_chosei,
					@kbn_prefix = @kbn_saiban_choseiprefix,
					@no_saiban = @no_seq_chosei_nyuko OUTPUT

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
					, [cd_soko]
					, [cd_genka_center] 
				    ,[no_nohinsho]
					,[nm_henpin]
	                ,[no_niuke]
	                ,[kbn_zaiko]
		            ,[cd_torihiki]
				)
				VALUES
				(
					@no_seq_chosei_nyuko
					, @cd_hinmei
					, @dt_nitizi
					, @cd_riyu_horyumodoshi
					, @su_chosei_minus
					, @biko
					, @cd_seihin
					, GETUTCDATE()
					, @cd_update
					, @cd_soko
					, @cd_genka_center
			        ,@no_nohinsho
				    ,@biko
					,@no_niuke
			        ,@kbn_zaiko
				    ,@cd_torihiki
				)

				--変更履歴トランに調整トランへの登録履歴を挿入
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
					,1
					,@dt_nitizi
					,@cd_hinmei
					,@su_chosei_minus
					,0
					,@no_seq_chosei_nyuko
					,@biko
					,GETUTCDATE()
					,@cd_update
				)						
			END
			
			--採番ストアド実行
			EXEC @return_value = [dbo].[usp_cm_Saiban]
				@kbn_saiban = @kbn_saiban_chosei,
				@kbn_prefix = @kbn_saiban_choseiprefix,
				@no_saiban = @no_seq_chosei OUTPUT

			--調整トラン追加処理	
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
					, [cd_soko]
					, [cd_genka_center] 
				    ,[no_nohinsho]
					,[nm_henpin]
                    ,[no_niuke]
	                ,[kbn_zaiko]
		            ,[cd_torihiki]
				)
				VALUES
				(
					@no_seq_chosei
					, @cd_hinmei
					, @dt_nitizi
					, @cd_riyu_henpin
					, @su_chosei_org
					, @biko
					, @cd_seihin
					, GETUTCDATE()
					, @cd_update
					, @cd_soko
					, @cd_genka_center
			        ,@no_nohinsho
				    ,@biko
					,@no_niuke
			        ,@kbn_zaiko_ryohin
				    ,@cd_torihiki
				)

				--変更履歴トランに調整トランへの登録履歴を挿入
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
					,1
					,@dt_nitizi
					,@cd_hinmei
					,@su_chosei_org
					,0
					,@no_seq_chosei
					,@biko
					,GETUTCDATE()
					,@cd_update
				)						


			--履歴の在庫再計算(良品分)
			EXEC usp_IdoShukkoShosai_update03  
				@no_niuke			= @no_niuke
				, @kbn_zaiko		= @kbn_zaiko_ryohin
				, @kbn_nyushukko	= 4 
				, @cdNonyuTani		= @cd_nonyu
				, @cdNiuke_basho	= @cd_niuke_basho
		END
		ELSE BEGIN
		--良品の返品データの追加
			SET @updflag_ryohin = 0

    		SET @max_no_seq  = (SELECT MAX(no_seq)
							FROM tr_niuke
							WHERE no_niuke = @no_niuke
						   	AND kbn_zaiko = @kbn_zaiko_ryohin
							AND cd_niuke_basho = @cd_niuke_basho
							AND convert(datetime,convert(varchar(10),dt_niuke,120))
								<= convert(datetime,convert(varchar(10),@dt_nitizi,120))
							)	
			
			DECLARE @max_no_seq_new  DECIMAL (8,0);
			IF (@cd_niuke_basho_main IS NULL)
			BEGIN
				SET @max_no_seq_new = (SELECT 
											MAX(no_seq)
										FROM tr_niuke
										WHERE 
											no_niuke = @no_niuke
											AND convert(datetime,convert(varchar(10),dt_niuke,120))
												<= convert(datetime,convert(varchar(10),@dt_nitizi,120))
										);
			END
			ELSE BEGIN
				SET @max_no_seq_new = (SELECT 
											MAX(no_seq)
										FROM tr_niuke
										WHERE 
											no_niuke = @no_niuke
											AND kbn_nyushukko <> @kbn_nyushukko_henpin
											AND no_seq <= @no_seq_main
											AND convert(datetime,convert(varchar(10),dt_niuke,120))
												<= convert(datetime,convert(varchar(10),@dt_nitizi,120))
										);
			END
					
			SET @ryohin_no_seq = @max_no_seq + 1
			
	    	-- 後続データのシーケンス番号をずらします。
	    	-- 入庫分と返品分があるので2つずらす
		    UPDATE tr_niuke
			   	SET no_seq = no_seq + 1
		    WHERE no_niuke = @no_niuke
			    AND no_seq >= @max_no_seq_new + 1
			
			IF(@max_no_seq IS NOT NULL)
			BEGIN 
			--入庫分の荷受トラン更新
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
			   ,[kbn_nyuko]
			   ,[no_nonyu]
			   ,[flg_shonin]
			   ,[no_nohinsho] 
			   ,[no_zeikan_shorui]
    		   )
	    	SELECT
			   no_niuke
			   , @dt_nitizi
			   , cd_hinmei
			   , kbn_hin
			   , @cd_niuke_basho
			   , @kbn_nyushukko
			   , kbn_zaiko
			   , tm_nonyu_yotei
			   , su_nonyu_yotei
			   , su_nonyu_yotei_hasu
			   , @tm_nonyu_jitsu 
			   , @su_shukko
			   , @su_shukko_hasu
			   , @su_zaiko
			   , @su_zaiko_hasu
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
			   , @flg_kakutei
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
			   , @max_no_seq_new
			   , kbn_nyuko
			   , no_nonyu
				, null
				, null
				, null
--			   , flg_shonin 
--			   , @no_nohinsho
--			   , @no_zeikan_shorui
	    	FROM tr_niuke
		    WHERE
				no_niuke                           = @no_niuke
				AND no_seq                         = @max_no_seq
				AND kbn_zaiko                      = @kbn_zaiko_ryohin
				AND cd_niuke_basho 				   = @cd_niuke_basho
			END
			ELSE BEGIN
				--入庫分の荷受トラン更新
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
				   ,[kbn_nyuko]
				   ,[no_nonyu]
				   ,[flg_shonin]
				   ,[no_nohinsho] 
				   ,[no_zeikan_shorui]
    			   )
	    		SELECT TOP 1
				   no_niuke
				   , @dt_nitizi
				   , cd_hinmei
				   , kbn_hin
				   , @cd_niuke_basho
				   , @kbn_nyushukko
				   , kbn_zaiko
				   , tm_nonyu_yotei
				   , su_nonyu_yotei
				   , su_nonyu_yotei_hasu
				   , @tm_nonyu_jitsu 
				   , @su_shukko
				   , @su_shukko_hasu
				   , @su_zaiko
				   , @su_zaiko_hasu
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
				   , @flg_kakutei
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
				   , @max_no_seq_new
				   , kbn_nyuko
				   , no_nonyu
					, null
					, null
					, null
	--			   , flg_shonin 
	--			   , @no_nohinsho
	--			   , @no_zeikan_shorui
	    		FROM tr_niuke
				WHERE
					no_niuke                           = @no_niuke
					AND kbn_zaiko                      = @kbn_zaiko_ryohin
			END

			--倉庫移動管理機能を使用している場合は、
			--調整トランに在庫区分変更のレコードを登録しない
			IF @kbn_sokoidokanri = 0 or @kbn_sokoidokanri IS NULL
			BEGIN
				SET @su_chosei_minus = 0 - @su_chosei --入庫分長整数をマイナスに
	            IF @@ROWCOUNT >= 1 BEGIN
					--入庫分の調整トラン追加処理	
					EXEC @return_value = [dbo].[usp_cm_Saiban]
						@kbn_saiban = @kbn_saiban_chosei,
						@kbn_prefix = @kbn_saiban_choseiprefix,
						@no_saiban = @no_seq_chosei_nyuko OUTPUT

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
						, [cd_soko]
						, [cd_genka_center] 
					    ,[no_nohinsho]
						,[nm_henpin]
	                    ,[no_niuke]
		                ,[kbn_zaiko]
			            ,[cd_torihiki]
					)
					VALUES
					(
						@no_seq_chosei_nyuko
						, @cd_hinmei
						, @dt_nitizi
						, @cd_riyu_horyumodoshi
						, @su_chosei_minus
						, @biko
						, @cd_seihin
						, GETUTCDATE()
						, @cd_update
						, @cd_soko
						, @cd_genka_center
				        ,@no_nohinsho
					    ,@biko
						,@no_niuke
				        ,@kbn_zaiko
					    ,@cd_torihiki
					)

					--変更履歴トランに調整トランへの登録履歴を挿入
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
						,1
						,@dt_nitizi
						,@cd_hinmei
						,@su_chosei_minus
						,0
						,@no_seq_chosei_nyuko
						,@biko
						,GETUTCDATE()
						,@cd_update
					)
				END
			END
				
			SET @before_no_seq = @max_no_seq
			SET @ryohin_no_seq = @ryohin_no_seq + 1	
			
			IF(@max_no_seq IS NOT NULL)
			BEGIN
				
				--返品分の荷受トラン更新
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
					,[kbn_nyuko]
					,[no_nonyu]
					,[flg_shonin]
					,[no_nohinsho]
					,[no_zeikan_shorui] 
    				)
	    		SELECT
					no_niuke
					, @dt_nitizi
					, cd_hinmei
					, kbn_hin
					, @cd_niuke_basho
					, @kbn_nyushukko_henpin
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
					, @flg_kakutei
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
					, @max_no_seq_new + 1
					, kbn_nyuko
					, no_nonyu
					, null
					, null
					, null
	--			    , flg_shonin 
	--			    , @no_nohinsho
	--			    , @no_zeikan_shorui
	    		FROM tr_niuke
				WHERE
					no_niuke                           = @no_niuke
					AND no_seq                         = @before_no_seq
					AND kbn_zaiko                      = @kbn_zaiko_ryohin 
					AND cd_niuke_basho 				   = @cd_niuke_basho
			END		
			ELSE BEGIN
					
				--返品分の荷受トラン更新
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
					,[kbn_nyuko]
					,[no_nonyu]
					,[flg_shonin]
					,[no_nohinsho]
					,[no_zeikan_shorui] 
    				)
	    		SELECT TOP 1
					no_niuke
					, @dt_nitizi
					, cd_hinmei
					, kbn_hin
					, @cd_niuke_basho
					, @kbn_nyushukko_henpin
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
					, @flg_kakutei
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
					, @max_no_seq_new + 1
					, kbn_nyuko
					, no_nonyu
					, null
					, null
					, null
	--			    , flg_shonin 
	--			    , @no_nohinsho
	--			    , @no_zeikan_shorui
	    		FROM tr_niuke
				WHERE
					no_niuke                           = @no_niuke
					AND kbn_zaiko                      = @kbn_zaiko_ryohin 
			END

            IF @@ROWCOUNT >= 1 BEGIN
				--返品分の調整トラン追加処理	
				EXEC @return_value = [dbo].[usp_cm_Saiban]
					@kbn_saiban = @kbn_saiban_chosei,
					@kbn_prefix = @kbn_saiban_choseiprefix,
					@no_saiban = @no_seq_chosei_henpin OUTPUT

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
					, [cd_soko]
					, [cd_genka_center] 
				    ,[no_nohinsho]
					,[nm_henpin]
                    ,[no_niuke]
	                ,[kbn_zaiko]
		            ,[cd_torihiki]
				)
				VALUES
				(
					@no_seq_chosei_henpin
					, @cd_hinmei
					, @dt_nitizi
					, @cd_riyu_henpin
					, @su_chosei
					, @biko
					, @cd_seihin
					, GETUTCDATE()
					, @cd_update
					, @cd_soko
					, @cd_genka_center
			        ,@no_nohinsho
				    ,@biko
					,@no_niuke
			        ,@kbn_zaiko_ryohin
				    ,@cd_torihiki
				)

				--変更履歴トランに調整トランへの登録履歴を挿入
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
					,1
					,@dt_nitizi
					,@cd_hinmei
					,@su_chosei
					,0
					,@no_seq_chosei_henpin
					,@biko
					,GETUTCDATE()
					,@cd_update
				)
			END
		END
		
		--履歴の在庫再計算(良品分)
		EXEC usp_IdoShukkoShosai_update03  
			@no_niuke			= @no_niuke
			, @kbn_zaiko		= @kbn_zaiko_ryohin
			, @kbn_nyushukko	= 4 
			, @cdNonyuTani		= @cd_nonyu
			, @cdNiuke_basho	= @cd_niuke_basho
	END
END

GO

