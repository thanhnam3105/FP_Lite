IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoNippo_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoNippo_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kasahara.a>
-- Create date: <Create Date,,2013.05.27>
-- Update: <2017.11.21 cho.k>
--       : <2022.12.16 brc.takaki> #1997対応：使用予実トランデータの削除処理を資材使用マスタのデータにかかわらず実行されるように修正。
-- Description:	製造日報の更新処理
-- =============================================

CREATE PROCEDURE [dbo].[usp_SeizoNippo_update]
	@no_lot_seihin VARCHAR(14)
	,@dt_seizo DATETIME
	,@cd_hinmei VARCHAR(14)
	,@su_seizo_jisseki DECIMAL(13, 3)
	,@flg_jisseki SMALLINT
    ,@JissekiYojitsuFlag smallint
    ,@ShiyoYojitsuSeqNoSaibanKbn varchar(2)
    ,@ShiyoYojitsuSeqNoPrefixSaibanKbn varchar(1)
    ,@FlagFalse varchar(1)
    ,@persentKanzan DECIMAL(5, 2)
    ,@su_batch_jisseki DECIMAL(12, 6)
    ,@dt_shomi DATETIME
	,@no_lot_hyoji VARCHAR(30)
	,@isUpdateAnbun SMALLINT -- 画面ではisCheckAnbun。Nullか１で渡される。 -- SAP連携対応
	,@midensoDensoKubun SMALLINT -- 区分／コード一覧．伝送区分．未伝送 -- SAP連携対応
AS
BEGIN

	-- UTC日付へフォーマット
	--SET @dt_seizo = DATEADD(SECOND, DATEDIFF(SECOND, GETDATE(), GETUTCDATE()), @dt_seizo)

	DECLARE @flg_jisseki_old SMALLINT
	DECLARE @su_seizo_jisseki_old DECIMAL(13, 3)
	DECLARE @kbn_shikomi_jisseki_update SMALLINT

	-- 更新前の確定有無を取得
	SELECT @flg_jisseki_old = flg_jisseki FROM tr_keikaku_seihin WHERE no_lot_seihin = @no_lot_seihin

	-- 更新前の実績数を取得
	SELECT @su_seizo_jisseki_old = su_seizo_jisseki FROM tr_keikaku_seihin WHERE no_lot_seihin = @no_lot_seihin

	-- 機能選択の仕込実績更新区分【区分：30】を取得
	SELECT @kbn_shikomi_jisseki_update = ISNULL(kbn_kino_naiyo,0) FROM cn_kino_sentaku WHERE kbn_kino = 30

	/*******************************
		製品計画トラン　更新
	*******************************/
	UPDATE tr_keikaku_seihin
	SET su_seizo_jisseki = @su_seizo_jisseki
		,flg_jisseki = @flg_jisseki
		,dt_update = GETUTCDATE()
		,su_batch_jisseki = @su_batch_jisseki
		,dt_shomi = @dt_shomi
		,no_lot_hyoji = @no_lot_hyoji
	WHERE no_lot_seihin = @no_lot_seihin

	/*******************************************
		使用予実トラン　新規登録・更新・削除
	*******************************************/
	-- 使用予実トラン　削除
	-- 確定取消しされたデータのみ行う
	IF (@flg_jisseki_old = 1 AND @flg_jisseki = 0)
	BEGIN
		-- 使用予実トランの削除
		DELETE tr_shiyo_yojitsu
		WHERE flg_yojitsu = 1
			AND no_lot_seihin = @no_lot_seihin
			AND no_lot_shikakari IS NULL

		-- 原価用使用トランの削除
		EXEC dbo.usp_GenkaShiyo_delete @no_lot_seihin, null
	END

	-- 使用予実トラン　更新(DELTE)
	-- 確定　かつ　製造実績数に変更のあったデータのみ行う
	IF (@flg_jisseki_old = 1 AND @flg_jisseki = 1)
	BEGIN
		DELETE tr_shiyo_yojitsu
		WHERE flg_yojitsu = 1
			AND dt_shiyo = @dt_seizo
			AND no_lot_seihin = @no_lot_seihin
			AND no_lot_shikakari IS NULL
	END
	
	-- 資材使用マスタ　検索
	DECLARE @cd_shizai VARCHAR(14)
	DECLARE @su_shiyo_shizai DECIMAL(12,6)
	DECLARE @su_shiyo DECIMAL(12,6)
	DECLARE @no_seq varchar(14)
    DECLARE @budomari DECIMAL(5,2)
	--DECLARE @cnt smallint
	--SET @cnt = 0

	DECLARE ichiran_cd_shizai CURSOR FAST_FORWARD FOR
	SELECT cd_shizai, su_shiyo FROM udf_ShizaiShiyoYukoHan(@cd_hinmei, @FlagFalse, @dt_seizo)

	OPEN ichiran_cd_shizai
		IF (@@error <> 0)
		BEGIN
			DEALLOCATE ichiran_cd_shizai
		END
		FETCH NEXT FROM ichiran_cd_shizai INTO @cd_shizai, @su_shiyo_shizai
		WHILE @@FETCH_STATUS = 0
		BEGIN
            
            -- 品名マスタから歩留を取得
            SET @budomari = NULL -- 一度クリア
            SET @budomari = (SELECT ma.ritsu_budomari FROM ma_hinmei ma
							 WHERE ma.cd_hinmei = @cd_shizai)
            IF @budomari IS NULL
            BEGIN
				SET @budomari = @persentKanzan	-- NULLの場合、初期値を設定
			END
			
			-- 使用数を計算
			SET @su_shiyo = 0.00 -- 一度クリア
			SET @su_shiyo = @su_seizo_jisseki * @su_shiyo_shizai / @budomari * @persentKanzan

			--使用予実トラン　新規登録・更新(INSERT)
			-- 確定データのみ行う
			--IF (@flg_jisseki_old = 0 AND @flg_jisseki = 1 AND @cd_shizai IS NOT NULL AND @cd_shizai <> '')
			IF ((@flg_jisseki_old = 0 OR @flg_jisseki_old = 1) AND @flg_jisseki = 1 AND @cd_shizai IS NOT NULL AND @cd_shizai <> '')
			BEGIN
				-- 使用予実　採番処理
				EXEC dbo.usp_cm_Saiban @ShiyoYojitsuSeqNoSaibanKbn, @ShiyoYojitsuSeqNoPrefixSaibanKbn,
				@no_saiban = @no_seq output

				INSERT INTO tr_shiyo_yojitsu (
					no_seq
					,flg_yojitsu
					,cd_hinmei
					,dt_shiyo
					,no_lot_seihin
					,no_lot_shikakari
					,su_shiyo
				) VALUES (
					@no_seq
					,@JissekiYojitsuFlag
					,@cd_shizai
					,@dt_seizo
					,@no_lot_seihin
					,NULL
					--,(@su_seizo_jisseki * @su_shiyo_shizai) -- 使用数
					,@su_shiyo
				)
			END
	        
			/*******************************
				使用予実トラン　削除
			*******************************/
			-- 確定取消しされたデータのみ行う
			/*
			IF (@flg_jisseki_old = 1 AND @flg_jisseki = 0 AND @cd_shizai IS NOT NULL AND @cd_shizai <> '')
			BEGIN
			*/
				-- 使用予実トランの削除
				/*
				DELETE tr_shiyo_yojitsu
				WHERE flg_yojitsu = 1
					AND cd_hinmei = @cd_shizai
					AND dt_shiyo = @dt_seizo
					AND no_lot_seihin = @no_lot_seihin
					AND no_lot_shikakari IS NULL
				*/				
			/*
				IF(@cnt = 0)
				BEGIN
					DELETE tr_shiyo_yojitsu
					WHERE flg_yojitsu = 1
						AND no_lot_seihin = @no_lot_seihin
						AND no_lot_shikakari IS NULL
				END
				-- 原価用使用トランの削除
				EXEC dbo.usp_GenkaShiyo_delete @no_lot_seihin, null
			END
			*/
	        
			/*******************************
				使用予実トラン　更新
			*******************************/
			/*
			-- 確定　かつ　製造実績数に変更のあったデータのみ行う
			IF (@flg_jisseki_old = 1 AND @flg_jisseki = 1 AND @cd_shizai IS NOT NULL AND @cd_shizai <> '')
			BEGIN
				-- 削除
				IF (@cnt = 0)
				BEGIN
					DELETE tr_shiyo_yojitsu
				WHERE
					flg_yojitsu = 1
					AND dt_shiyo = @dt_seizo
					AND no_lot_seihin = @no_lot_seihin
					AND no_lot_shikakari IS NULL
				END

				-- 使用予実　採番処理
				EXEC dbo.usp_cm_Saiban @ShiyoYojitsuSeqNoSaibanKbn, @ShiyoYojitsuSeqNoPrefixSaibanKbn,
				@no_saiban = @no_seq output

				-- 新規登録
				INSERT INTO tr_shiyo_yojitsu (
					no_seq
					,flg_yojitsu
					,cd_hinmei
					,dt_shiyo
					,no_lot_seihin
					,no_lot_shikakari
					,su_shiyo
				) VALUES (
					@no_seq
					,@JissekiYojitsuFlag
					,@cd_shizai
					,@dt_seizo
					,@no_lot_seihin
					,NULL
					--,(@su_seizo_jisseki * @su_shiyo_shizai) -- 使用数
					,@su_shiyo
				)
			END
			SET @cnt = @cnt + 1
			*/
			FETCH NEXT FROM ichiran_cd_shizai INTO @cd_shizai, @su_shiyo_shizai
		END
		
	CLOSE ichiran_cd_shizai
	BEGIN
		DEALLOCATE ichiran_cd_shizai
	END

	IF @isUpdateAnbun = 1
	BEGIN
		UPDATE tr_sap_shiyo_yojitsu_anbun
		SET kbn_jotai_denso = @midensoDensoKubun
		WHERE
			no_lot_seihin = @no_lot_seihin
	END
	
	-- 仕込実績更新区分が1（更新）且つ、製造数か実績チェックが変更された場合は仕込実績を更新する。
	IF (
			@kbn_shikomi_jisseki_update = 1
			AND (
					(@su_seizo_jisseki <> @su_seizo_jisseki_old)
				 OR (@flg_jisseki <> @flg_jisseki_old)
				)
		)
	BEGIN
		IF @flg_jisseki = 0
		BEGIN
			SET @su_seizo_jisseki = 0
		END
		-- 仕込実績の更新を行う
		EXEC usp_SeizoNippoShikomiJisseki_update
				@dt_seizo
				, @cd_hinmei
				, @no_lot_seihin
				, @su_seizo_jisseki
	END

END





















GO
