IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'udf_SokoIdoKanri_ZaikoHyoji') AND xtype IN (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_SokoIdoKanri_ZaikoHyoji]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
-- Author:		<Author, thien.nh>
-- Create date: <Create Date, 2018.08.10 >
-- Last Update: 2018.08.13 thien.nh
-- Description:	get su zaiko
*****************************************************/
CREATE FUNCTION [dbo].[udf_SokoIdoKanri_ZaikoHyoji]
	(
		@dt_shukko				DATETIME
		,@no_niuke				VARCHAR(14)
		,@cd_niuke_basho		VARCHAR(10)
		,@kbn_zaiko				SMALLINT
		
		,@shiireNyushukkoKbn	SMALLINT		-- 【入出庫区分】　仕入	 = 1
		,@shukkoNyushukkoKbn	SMALLINT		-- 【入出庫区分】　出庫	 = 3
		,@kakozanNyushukkoKbn	SMALLINT		-- 【入出庫区分】　加工残 = 4
		,@horyuNyushukkoKbn		SMALLINT		-- 【入出庫区分】　区分変更 保留 = 5
		,@ryohinNyushukkoKbn	SMALLINT		-- 【入出庫区分】　区分変更 良品	= 6
		,@henpinKbn				SMALLINT		-- 【入出庫区分】　返品		= 8
		,@addKbn				SMALLINT		-- 【入出庫区分】　追加		= 9
		,@idodeKbn				SMALLINT		-- 【入出庫区分】　移動出 = 11
		,@idoiriKbn				SMALLINT		-- 【入出庫区分】　移動入 = 12
		,@ryohinZaikoKbn		SMALLINT		-- 在庫区分.良品			 = 1
		,@horyuZaikoKbn			SMALLINT		-- 在庫区分.保留			 = 2

	)
RETURNS @tbl_zaiko TABLE
	(
		su_zaiko				DECIMAL(9,2)
		,su_zaiko_hasu			DECIMAL(9,2)
	)
AS
BEGIN
    DECLARE 
		@su_result				DECIMAL(9,2)
		,@su_hasu_result		DECIMAL(9,2)
		
		,@su_shukko				DECIMAL(9,2)
		,@su_shukko_hasu		DECIMAL(9,2)
		,@su_shukko_henpin		DECIMAL(9,2)
		,@su_shukko_hasu_henpin	DECIMAL(9,2)

		,@su_in_6				DECIMAL(9,2)
		,@su_in_6_hasu			DECIMAL(9,2)
		,@su_in_5				DECIMAL(9,2)
		,@su_in_5_hasu			DECIMAL(9,2)
		,@no_seq_max_kakozan	DECIMAL(8, 0) = 0;
		
	-- table tmp with no_niuke
	DECLARE @tmp_niuke TABLE 
	(
		no_niuke				varchar(14)		NOT NULL,
		dt_niuke				datetime		NOT NULL,
		cd_hinmei				varchar(14)		NOT NULL,
		kbn_hin					smallint		NULL,
		cd_niuke_basho			varchar(10)		NOT NULL,
		kbn_nyushukko			smallint		NULL,
		kbn_zaiko				smallint		NOT NULL,
		tm_nonyu_yotei			datetime		NULL,
		su_nonyu_yotei			decimal(9, 2)	NULL,
		su_nonyu_yotei_hasu		decimal(9, 2)	NULL,
		tm_nonyu_jitsu			datetime		NULL,
		su_nonyu_jitsu			decimal(9, 2)	NULL,
		su_nonyu_jitsu_hasu		decimal(9, 2)	NULL,
		su_zaiko				decimal(9, 2)	NULL,
		su_zaiko_hasu			decimal(9, 2)	NULL,
		su_shukko				decimal(9, 2)	NULL,
		su_shukko_hasu			decimal(9, 2)	NULL,
		su_kakozan				decimal(9, 2)	NULL,
		su_kakozan_hasu			decimal(9, 2)	NULL,
		dt_seizo				datetime		NULL,
		dt_kigen				datetime		NULL,
		kin_kuraire				decimal(12, 4)	NULL,
		no_lot					varchar(14)		NULL,
		no_denpyo				varchar(30)		NULL,
		biko					nvarchar(50)	NULL,
		cd_torihiki				varchar(13)		NOT NULL,
		flg_kakutei				smallint		NULL,
		cd_hinmei_maker			varchar(14)		NULL,
		nm_kuni					nvarchar(60)	NULL,
		cd_maker				varchar(20)		NULL,
		nm_maker				nvarchar(60)	NULL,
		cd_maker_kojo			varchar(20)		NULL,
		nm_maker_kojo			nvarchar(60)	NULL,
		nm_hyoji_nisugata		nvarchar(26)	NULL,
		nm_tani_nonyu			nvarchar(12)	NULL,
		dt_nonyu				datetime		NULL,
		dt_label_hakko			datetime		NULL,
		cd_update				varchar(10)		NULL,
		dt_update				datetime		NULL,
		no_seq					decimal(8, 0)	NOT NULL,
		kbn_nyuko				smallint		NULL,
		no_nonyu				varchar(13)		NULL,
		flg_print				smallint		NULL,
		no_nohinsho				nvarchar(16)	NULL,
		no_zeikan_shorui		nvarchar(16)	NULL,
		flg_shonin				smallint		NULL,
		cd_niuke_basho_before	varchar(10)		NULL,
		kbn_zaiko_before		smallint		NULL
	);
	
	-- insert to table tmp
	INSERT INTO @tmp_niuke
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
		,su_shukko
		,su_shukko_hasu
		,su_kakozan
		,su_kakozan_hasu
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
		,dt_label_hakko
		,cd_update
		,dt_update
		,no_seq
		,kbn_nyuko
		,no_nonyu
		,flg_print
		,no_nohinsho
		,no_zeikan_shorui
		,flg_shonin
		,cd_niuke_basho_before
		,kbn_zaiko_before
	)
	SELECT
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
		,su_shukko
		,su_shukko_hasu
		,su_kakozan
		,su_kakozan_hasu
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
		,dt_label_hakko
		,cd_update
		,dt_update
		,no_seq
		,kbn_nyuko
		,no_nonyu
		,flg_print
		,no_nohinsho
		,no_zeikan_shorui
		,flg_shonin
		,cd_niuke_basho_before
		,kbn_zaiko_before
	FROM tr_niuke
	WHERE no_niuke = @no_niuke
	
	-- check kbn_nyushukko = 4
	IF((SELECT COUNT(no_niuke) FROM tr_niuke WHERE no_niuke = @no_niuke AND dt_niuke = @dt_shukko AND cd_niuke_basho = @cd_niuke_basho 
													AND kbn_zaiko = @kbn_zaiko AND kbn_nyushukko = @kakozanNyushukkoKbn) > 0) -- 4
	BEGIN
		SELECT
			@no_seq_max_kakozan = ISNULL(NIUKE.no_seq,0)
			, @su_result = su_zaiko
			,@su_hasu_result  = su_zaiko_hasu
		FROM
		(
			SELECT
				no_niuke
				,MAX(no_seq) AS no_seq
			FROM @tmp_niuke 
			WHERE 
				dt_niuke			= @dt_shukko 
				AND cd_niuke_basho	= @cd_niuke_basho 
				AND kbn_zaiko		= @kbn_zaiko 
				AND kbn_nyushukko	= @kakozanNyushukkoKbn
			GROUP BY
				no_niuke
		) NIUKE
		INNER JOIN @tmp_niuke TMP
		ON NIUKE.no_niuke = TMP.no_niuke
		AND NIUKE.no_seq = TMP.no_seq
		
	END

	ELSE
	BEGIN
		SET @no_seq_max_kakozan = 0;
		-- check kbn_nyushukko = 1, 9
		IF((SELECT COUNT(no_niuke) FROM @tmp_niuke WHERE dt_niuke = @dt_shukko  AND cd_niuke_basho = @cd_niuke_basho 
													AND kbn_zaiko = @kbn_zaiko AND kbn_nyushukko IN (@shiireNyushukkoKbn, @addKbn)) > 0) -- 1, 9
		BEGIN
			SELECT 
				@su_result = su_zaiko
				,@su_hasu_result  = su_zaiko_hasu 
			FROM @tmp_niuke 
			WHERE 
				kbn_nyushukko IN (@shiireNyushukkoKbn, @addKbn)
				AND
				(
					(dt_niuke < @dt_shukko AND no_seq <> 1)
					OR
					(dt_nonyu <= @dt_shukko AND no_seq = 1)
				)
		END
		ELSE
		BEGIN
				SELECT
					@su_result = su_zaiko
					,@su_hasu_result  = su_zaiko_hasu 
				FROM 
				(
					SELECT
						no_niuke
						,cd_niuke_basho
						,kbn_zaiko
						,MAX(no_seq) AS no_seq
					FROM
					(
						SELECT
							no_niuke
							,cd_niuke_basho
							,kbn_zaiko
							,no_seq
							,kbn_nyushukko
							,su_zaiko
							,su_zaiko_hasu
						FROM @tmp_niuke NIUKE
						WHERE NIUKE.no_niuke			= @no_niuke
							AND NIUKE.cd_niuke_basho	= @cd_niuke_basho
							AND NIUKE.kbn_zaiko			= @kbn_zaiko

							AND
							(
								(NIUKE.dt_niuke < @dt_shukko AND NIUKE.no_seq <> 1)
								OR
								(NIUKE.dt_nonyu <= @dt_shukko AND NIUKE.no_seq = 1)
							)
					) A
					GROUP BY
							no_niuke
							,cd_niuke_basho
							,kbn_zaiko
				) A
				INNER JOIN @tmp_niuke  NIUKE
				ON A.no_niuke			= NIUKE.no_niuke
				AND A.cd_niuke_basho	= NIUKE.cd_niuke_basho
				AND A.kbn_zaiko			= NIUKE.kbn_zaiko
				AND A.no_seq			= NIUKE.no_seq
		END
	END

	-- get su_shukko with su_shukko = 3
	SELECT
		@su_shukko			= ISNULL(su_shukko, 0)
		,@su_shukko_hasu	= ISNULL(su_shukko_hasu , 0)
	FROM @tmp_niuke 
	WHERE 
		no_niuke			= @no_niuke
		AND cd_niuke_basho	= @cd_niuke_basho
		AND kbn_zaiko		= @kbn_zaiko
		AND dt_niuke		= @dt_shukko 
		AND kbn_nyushukko	= @shukkoNyushukkoKbn
		AND ((no_seq		> @no_seq_max_kakozan AND @no_seq_max_kakozan <> 0) OR (@no_seq_max_kakozan = 0))

	-- get su_shukko with su_shukko = 8
	SELECT
		@su_shukko_henpin		 = ISNULL(su_shukko, 0)
		,@su_shukko_hasu_henpin  = ISNULL(su_shukko_hasu , 0)
	FROM @tmp_niuke 
	WHERE 
		no_niuke			= @no_niuke
		AND cd_niuke_basho	= @cd_niuke_basho
		AND kbn_zaiko		= @kbn_zaiko
		AND dt_niuke		= @dt_shukko 
		AND kbn_nyushukko	= @henpinKbn
		AND ((no_seq		> @no_seq_max_kakozan AND @no_seq_max_kakozan <> 0) OR (@no_seq_max_kakozan = 0))

	-- get su_shukko with su_shukko IN (6)
	SELECT
		@su_in_6		= CASE WHEN kbn_zaiko = @ryohinZaikoKbn THEN ISNULL(su_nonyu_jitsu, 0)
								WHEN kbn_zaiko = @horyuZaikoKbn THEN ISNULL(su_shukko, 0)
							END
		,@su_in_6_hasu  = CASE WHEN kbn_zaiko = @ryohinZaikoKbn THEN ISNULL(su_nonyu_jitsu_hasu, 0)
								WHEN kbn_zaiko = @horyuZaikoKbn THEN ISNULL(su_shukko_hasu, 0)
							END
	FROM @tmp_niuke 
	WHERE 
		no_niuke			= @no_niuke 
		AND cd_niuke_basho	= @cd_niuke_basho
		AND kbn_zaiko		= @kbn_zaiko
		AND dt_niuke		= @dt_shukko 
		AND kbn_nyushukko	= @ryohinNyushukkoKbn
		AND ((no_seq		> @no_seq_max_kakozan AND @no_seq_max_kakozan <> 0) OR (@no_seq_max_kakozan = 0))

	
	-- get su_shukko with su_shukko IN (5)
	SELECT
		@su_in_5		=  CASE WHEN kbn_zaiko = @ryohinZaikoKbn THEN ISNULL(su_shukko, 0)
								WHEN kbn_zaiko = @horyuZaikoKbn  THEN ISNULL(su_nonyu_jitsu, 0)
							END
		,@su_in_5_hasu  = CASE WHEN kbn_zaiko  = @ryohinZaikoKbn THEN ISNULL(su_shukko_hasu, 0)
								WHEN kbn_zaiko = @horyuZaikoKbn  THEN ISNULL(su_nonyu_jitsu_hasu, 0)
							END
	FROM @tmp_niuke 
	WHERE 
		no_niuke			= @no_niuke
		AND cd_niuke_basho	= @cd_niuke_basho
		AND kbn_zaiko		= @kbn_zaiko
		AND dt_niuke		= @dt_shukko
		AND kbn_nyushukko	= @horyuNyushukkoKbn
		AND ((no_seq		> @no_seq_max_kakozan AND @no_seq_max_kakozan <> 0) OR (@no_seq_max_kakozan = 0))

	IF(@kbn_zaiko = @ryohinZaikoKbn) -- = 1
	BEGIN
		SET @su_result		= ISNULL(@su_result, 0)		 - ISNULL(@su_shukko_henpin, 0)		 - ISNULL(@su_shukko, 0)	 + ISNULL(@su_in_6, 0)
		SET @su_hasu_result = ISNULL(@su_hasu_result, 0) - ISNULL(@su_shukko_hasu_henpin, 0) + ISNULL(@su_in_6_hasu, 0)
	END
	ELSE IF(@kbn_zaiko = @horyuZaikoKbn) -- = 2
	BEGIN
		SET @su_result		= ISNULL(@su_result, 0)			- ISNULL(@su_in_6, 0)		+ ISNULL(@su_in_5, 0)
		SET @su_hasu_result = ISNULL(@su_hasu_result, 0)	- ISNULL(@su_in_6_hasu, 0)  + ISNULL(@su_in_5_hasu, 0)
	END
	
	-- insert to table return
	INSERT INTO @tbl_zaiko
	SELECT @su_result, @su_hasu_result
	
	RETURN
END

GO
