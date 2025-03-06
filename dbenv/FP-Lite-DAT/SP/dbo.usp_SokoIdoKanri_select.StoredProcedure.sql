IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SokoIdoKanri_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SokoIdoKanri_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*****************************************************
機能			：Page SokoIdoKanri: Search and Excel
ファイル名	：usp_SokoIdoKanri_select
作成日		：2018.07.12  thien.nh
更新日		：2018.08.27  thien.nh
			  2019.06.03  echigo.r
*****************************************************/
CREATE PROC [dbo].[usp_SokoIdoKanri_select]
	@dt_shukko			DATETIME
	,@dt_niuke_from		DATETIME
	,@dt_niuke_to		DATETIME
	,@cd_niuke_basho	VARCHAR(10)
	,@kbn_hin			SMALLINT
	,@kbn_bunrui		SMALLINT
	,@cd_hinmei			VARCHAR(14)

	,@idodeKbn			SMALLINT		-- 【入出庫区分】　移動出 = 11
	,@idoiriKbn			SMALLINT		-- 【入出庫区分】　移動入 = 12
	,@shiyoMishiyoFlg	SMALLINT		-- 【未使用フラグ】 使用	 = 0
	,@ryohinZaikoKbn	SMALLINT		-- 在庫区分.良品			 = 1
	,@horyuZaikoKbn		SMALLINT		-- 在庫区分.保留			 = 2
    ,@skip				DECIMAL(10)		-- skip	= 0
    ,@top				DECIMAL(10)		-- top = 500
	,@isExcel			BIT				-- export excel: { 0, 1 }
	,@day_before		SMALLINT		-- 移動日の60日前 = -60
	--20190522 echigo add start
	--, @kigengireKigenFlg	SMALLINT	  -- 期限フラグ.期限切れ
	--, @chokuzenKigenFlg		SMALLINT	  -- 期限フラグ.直前
	--, @chikaiKigenFlg		SMALLINT	  -- 期限フラグ.近い
	--, @yoyuKigenFlg			SMALLINT	  -- 期限フラグ.余裕
	, @dt_kigen_chikai		DECIMAL		  -- 工場マスタ.kigen_chika11
	, @dt_kigen_chokuzen	DECIMAL		  -- 工場マスタ.kigen_chokuzen3
	, @dt_utc				DATETIME	  -- システム「年月日」のUTC日時 EX)日本：yyyy/MM/dd 10:00:00.000
	--20190522 echigo add end
AS
	DECLARE @dt_shukko_from			DATETIME
			,@dt_shukko_idoiriKbn	DATETIME
			,@dt_shukko_max			DATETIME
			,@start					DECIMAL(10)
			,@end					DECIMAL(10)
			,@true					BIT
			,@false					BIT,
			@minSeqNo				DECIMAL(8, 0)
			--20190522 echigo add start
			,@kireKigen				VARCHAR
	        ,@majikaKigen			VARCHAR
			,@chikaiKigen			VARCHAR
	        ,@yoyuKigen				VARCHAR
			--,@dt_utc				DATETIME
			--,@dt_kigen_chikai		VARCHAR
			--,@dt_kigen_chokuzen	VARCHAR
			;
			--20190522 echigo add end

	SET	@start	= @skip + 1
	SET	@end	= @skip + @top
	SET	@true	= 1
	SET	@false	= 0
	SET @dt_shukko_from			= DATEADD(DAY, @day_before, @dt_shukko);
	SET @dt_shukko_idoiriKbn	= DATEADD(DAY, -1, @dt_shukko);
	SET @dt_shukko_max			= DATEADD(DD, 1, @dt_shukko)
	SET @minSeqNo = 1;
	--20190522 echigo add start
	SET		@kireKigen			 = '1'
	SET		@majikaKigen		 = '2'
	SET     @chikaiKigen         = '3'
	SET		@yoyuKigen			 = '4'
	--20190522 echigo add end


	DECLARE @shiireNyushukkoKbn		SMALLINT = 1
			,@shukkoNyushukkoKbn	SMALLINT = 3
			,@kakozanNyushukkoKbn	SMALLINT = 4
			,@horyuNyushukkoKbn		SMALLINT = 5
			,@ryohinNyushukkoKbn	SMALLINT = 6
			,@henpinKbn				SMALLINT = 8
			,@addKbn				SMALLINT = 9;

	--- tmp_niuke
	WITH tmp_niuke AS
	(
		SELECT 
			NIUKE.no_niuke
			,NIUKE.dt_niuke
			,NIUKE.dt_nonyu
			,NIUKE.cd_hinmei
			,NIUKE.no_lot
			,NIUKE.biko
			,NIUKE.dt_kigen
			,NIUKE.cd_torihiki
		FROM tr_niuke NIUKE
		WHERE
				  NIUKE.no_seq		= @minSeqNo
			AND ( NIUKE.dt_nonyu	>= @dt_niuke_from	OR @dt_niuke_from	IS NULL	)
			AND ( NIUKE.dt_nonyu	<= @dt_niuke_to		OR @dt_niuke_to		IS NULL	)
			AND ( NIUKE.kbn_hin		= @kbn_hin			OR @kbn_hin			IS NULL )
			AND ( NIUKE.cd_hinmei	= @cd_hinmei		OR @cd_hinmei		IS NULL )
	)

	--- tmp_zaiko
	, tmp_zaiko AS
	(
		SELECT
			NIUKE.no_niuke
			,NIUKE.dt_niuke
			,NIUKE.cd_niuke_basho
			,NIUKE.kbn_zaiko
			,NIUKE.no_seq
			,NIUKE.kbn_nyushukko
			,NIUKE.su_zaiko
			,NIUKE.su_zaiko_hasu
			,CASE	WHEN NIUKE.dt_niuke			= @dt_shukko AND NIUKE.kbn_nyushukko = @idodeKbn	THEN NIUKE.su_zaiko
					WHEN NIUKE.dt_niuke			< @dt_shukko AND NIUKE.kbn_nyushukko = @idodeKbn	THEN NIUKE.su_zaiko + NIUKE.su_nonyu_jitsu
					WHEN NIUKE.kbn_nyushukko	<> @idodeKbn										THEN NIUKE.su_zaiko
				END AS	zaiko_su_zaiko
			,CASE	WHEN NIUKE.dt_niuke			= @dt_shukko AND NIUKE.kbn_nyushukko = @idodeKbn	THEN NIUKE.su_zaiko_hasu
					WHEN NIUKE.dt_niuke			< @dt_shukko AND NIUKE.kbn_nyushukko = @idodeKbn	THEN NIUKE.su_zaiko_hasu + NIUKE.su_nonyu_jitsu
					WHEN NIUKE.kbn_nyushukko	<> @idodeKbn										THEN NIUKE.su_zaiko_hasu
				END AS	zaiko_su_zaiko_hasu
		FROM tr_niuke NIUKE
		INNER JOIN 
		(
			SELECT
				no_niuke
				,cd_niuke_basho
				,kbn_zaiko
				,MAX(no_seq)	AS no_seq
			FROM tr_niuke  NIUKE
			WHERE
					(
						(
							NIUKE.no_seq <> @minSeqNo
							AND NIUKE.dt_niuke <= @dt_shukko
						)
						OR
						(
							NIUKE.no_seq = @minSeqNo
							AND NIUKE.dt_nonyu <= @dt_shukko
						)
					)
					AND ( NIUKE.cd_niuke_basho	= @cd_niuke_basho	OR @cd_niuke_basho	IS NULL )
					AND ( NIUKE.kbn_hin			= @kbn_hin			OR @kbn_hin			IS NULL )
					AND ( NIUKE.cd_hinmei		= @cd_hinmei		OR @cd_hinmei		IS NULL )
			GROUP BY
				no_niuke
				,cd_niuke_basho
				,kbn_zaiko
		) A
		
		ON		A.no_niuke			= NIUKE.no_niuke
			AND A.cd_niuke_basho	= NIUKE.cd_niuke_basho
			AND A.kbn_zaiko			= NIUKE.kbn_zaiko
			AND A.no_seq			= NIUKE.no_seq
		WHERE
			(
			
					(NIUKE.dt_nonyu <= @dt_niuke_to   OR @dt_niuke_to	IS NULL	)
					AND
					(NIUKE.dt_nonyu >= @dt_niuke_from OR @dt_niuke_from	IS NULL	)
					AND
					NIUKE.dt_nonyu <= @dt_shukko
			)
			AND ( NIUKE.cd_niuke_basho	= @cd_niuke_basho	OR @cd_niuke_basho	IS NULL )
			AND ( NIUKE.kbn_hin			= @kbn_hin			OR @kbn_hin			IS NULL )
			AND ( NIUKE.cd_hinmei		= @cd_hinmei		OR @cd_hinmei		IS NULL )
	)
	-- tmp_ido
	, tmp_ido AS
	(
		SELECT
			IDO.no_niuke
			,IDO.cd_niuke_basho
			,IDO.dt_niuke
			,IDO.no_seq
			,IDO.su_nonyu_jitsu
			,IDO.su_nonyu_jitsu_hasu
			,IDO.su_shukko
			,IDO.su_shukko_hasu
			,IDO.cd_niuke_basho_before
			,IDO.kbn_zaiko_before
			,IDO.biko
			,IDO.kbn_zaiko
			,IDO.kbn_nyushukko
		FROM tr_niuke IDO
		WHERE
				  IDO.dt_niuke			= @dt_shukko
			AND	  IDO.kbn_nyushukko		= @idoiriKbn			-- = 12
			AND ( IDO.kbn_hin			= @kbn_hin			OR @kbn_hin			IS NULL )
			AND ( IDO.cd_hinmei			= @cd_hinmei		OR @cd_hinmei		IS NULL )
	)

	--select data from 3 table tmp_niuke, tmp_zaiko, tmp_ido
	SELECT
		cnt
		,no_niuke
		,cd_hinmei
		,nm_hinmei_en
		,nm_hinmei_ja
		,nm_hinmei_zh
		,nm_hinmei_vi
		,dt_niuke
		,dt_nonyu
		,no_lot
		,cd_tani_nonyu
		,su_iri
		,wt_ko
		,nm_nisugata_hyoji

		,zaiko_kbn_niuke_basho
		,zaiko_nm_kbn_niuke
		,zaiko_cd_niuke_basho
		,zaiko_nm_niuke
		,zaiko_kbn_zaiko
		,zaiko_nm_kbn_zaiko
		,zaiko_no_seq
		,zaiko_su_zaiko
		,zaiko_su_zaiko_hasu
		,zaiko_kbn_nyushukko
		
		,ido_kbn_niuke_basho
		,ido_nm_kbn_niuke
		,ido_cd_niuke_basho
		,ido_nm_niuke
		,ido_kbn_zaiko
		,ido_nm_kbn_zaiko
		,ido_no_seq
		,ido_su_nonyu_jitsu
		,ido_su_nonyu_jitsu_hasu
		,ido_kbn_nyushukko

		,ido_su_nonyu_jitsu					AS ido_su_nonyu_jitsu_old
		,ido_su_nonyu_jitsu_hasu			AS ido_su_nonyu_jitsu_hasu_old
		,ido_kbn_niuke_basho				AS ido_kbn_niuke_basho_old
		,ido_cd_niuke_basho					AS ido_cd_niuke_basho_old
		,ido_kbn_zaiko						AS ido_kbn_zaiko_old
		,ido_no_seq							AS ido_no_seq_old
		
		,dbo.udf_GetBikoniuke(zaiko_no_seq, zaiko_cd_niuke_basho, no_niuke, @dt_shukko, zaiko_kbn_zaiko) AS biko
		,su_zaiko
		,su_zaiko_hasu
		,zaikoAll
		,max_dt_niuke
		,max_no_seq
		,ido_no_seq_max

		,CASE WHEN ido_kbn_niuke_basho IS NOT NULL AND ido_cd_niuke_basho IS NOT NULL AND ido_kbn_zaiko IS NOT NULL 
				THEN 1
			  ELSE 0
		 END AS flg_select
		,0	 AS flg_add
		,CASE WHEN ((ido_kbn_niuke_basho IS NOT NULL AND ido_cd_niuke_basho IS NOT NULL AND ido_kbn_zaiko IS NOT NULL) 
						AND ISNULL(ido_no_seq, 0) >= ISNULL(max_no_seq_del, 0))
				THEN 1
			  ELSE 0
		 END AS flg_delete

		,cd_hinmei				AS display_cd_hinmei
		,dt_nonyu				AS display_dt_nonyu
		,no_lot					AS display_no_lot
		,zaiko_nm_kbn_niuke		AS display_zaiko_nm_kbn_niuke
		,zaiko_nm_niuke			AS display_zaiko_nm_niuke
		,zaiko_nm_kbn_zaiko		AS display_zaiko_nm_kbn_zaiko
		,zaiko_su_zaiko			AS display_zaiko_su_zaiko
		,zaiko_su_zaiko_hasu	AS display_zaiko_su_zaiko_hasu
		,tani_nonyu
		,cd_tani_shiyo
		,tani_shiyo
		,dt_kigen
		,dd_shomi
	--20190522 echigo add start
		, CASE
						-- 使用期限切れ
							WHEN dt_kigen < @dt_utc THEN @kireKigen
						-- 使用期限直前
							WHEN dt_kigen >= @dt_utc
							AND dt_kigen < DATEADD(DAY,@dt_kigen_chokuzen,@dt_utc) THEN @majikaKigen
						-- 使用期限近い
							WHEN dt_kigen >=  DATEADD(DAY,@dt_kigen_chokuzen,@dt_utc)
							AND dt_kigen < DATEADD(DAY,@dt_kigen_chikai,@dt_utc) THEN @chikaiKigen
						-- 使用期限まで余裕あり
							ELSE @yoyuKigen
							END AS flg_keikoku
	--20190522 echigo add end

	FROM
	(
		SELECT
			MAX(RN) OVER() cnt
			,RN
			,no_niuke
			,cd_hinmei
			,nm_hinmei_en
			,nm_hinmei_ja
			,nm_hinmei_zh
			,nm_hinmei_vi
			,dt_niuke
			,dt_nonyu
			,no_lot
			,cd_tani_nonyu
			,su_iri
			,wt_ko
			,nm_nisugata_hyoji

			,zaiko_kbn_niuke_basho
			,zaiko_nm_kbn_niuke
			,zaiko_cd_niuke_basho
			,zaiko_nm_niuke
			,zaiko_kbn_zaiko
			,zaiko_nm_kbn_zaiko		
			,zaiko_no_seq
			,zaiko_su_zaiko
			,zaiko_su_zaiko_hasu
			,zaiko_kbn_nyushukko

			,ido_kbn_niuke_basho
			,ido_nm_kbn_niuke
			,ido_cd_niuke_basho
			,ido_nm_niuke
			,ido_kbn_zaiko
			,ido_nm_kbn_zaiko
			,ido_no_seq
			,ido_su_nonyu_jitsu
			,ido_su_nonyu_jitsu_hasu
			,ido_kbn_nyushukko
			
			,biko
			,su_zaiko
			,su_zaiko_hasu
			,zaikoAll
			,max_dt_niuke
			,max_no_seq
			,ido_no_seq_max
			,max_no_seq_del
			,tani_nonyu
			,cd_tani_shiyo
			,tani_shiyo
			,dt_kigen
			,dd_shomi
			--20190529 echigo add start
			--,(SELECT TOP 1 dt_kigen_chokuzen FROM ma_kojo) AS cd_kojo
			--,(SELECT TOP 1 dt_kigen_chikai FROM ma_kojo) AS cd_kojo
			--20190529 echigo add end
		FROM 
		(
			SELECT TOP 100 PERCENT
				ROW_NUMBER() OVER(
									ORDER BY 
										NIUKE.cd_hinmei
										,NIUKE.dt_niuke
										,NIUKE.no_lot
										,ZAIKO.cd_niuke_basho
										,ZAIKO.kbn_zaiko
										,IDO.cd_niuke_basho
										,IDO.kbn_zaiko
								) AS RN
				,NIUKE.no_niuke
				,NIUKE.cd_hinmei
				,ISNULL(HINMEI.nm_hinmei_en, '') AS nm_hinmei_en
				,ISNULL(HINMEI.nm_hinmei_ja, '') AS nm_hinmei_ja
				,ISNULL(HINMEI.nm_hinmei_zh, '') AS nm_hinmei_zh
				,ISNULL(HINMEI.nm_hinmei_vi, '') AS nm_hinmei_vi
				,NIUKE.dt_niuke
				,NIUKE.dt_nonyu
				,NIUKE.no_lot
				,HINMEI.cd_tani_nonyu
				,HINMEI.su_iri
				,HINMEI.wt_ko
				,HINMEI.nm_nisugata_hyoji

				,ZAIKO_KBN_NIUKE.kbn_niuke_basho	AS zaiko_kbn_niuke_basho
				,ZAIKO_KBN_NIUKE.nm_kbn_niuke		AS zaiko_nm_kbn_niuke
				,ZAIKO.cd_niuke_basho				AS zaiko_cd_niuke_basho
				,ZAIKO_NIUKE.nm_niuke				AS zaiko_nm_niuke
				,ZAIKO.kbn_zaiko					AS zaiko_kbn_zaiko
				,ZAIKO_KBN.nm_kbn_zaiko				AS zaiko_nm_kbn_zaiko		
				,ZAIKO.no_seq						AS zaiko_no_seq
				,ZAIKO.zaiko_su_zaiko
				,ZAIKO.zaiko_su_zaiko_hasu
				,ZAIKO.kbn_nyushukko				AS zaiko_kbn_nyushukko

				,IDO_KBN_NIUKE.kbn_niuke_basho		AS ido_kbn_niuke_basho
				,IDO_KBN_NIUKE.nm_kbn_niuke			AS ido_nm_kbn_niuke
				,IDO.cd_niuke_basho					AS ido_cd_niuke_basho
				,IDO_NIUKE.nm_niuke					AS ido_nm_niuke
				,IDO.kbn_zaiko						AS ido_kbn_zaiko
				,IDO_KBN_ZAIKO.nm_kbn_zaiko			AS ido_nm_kbn_zaiko
				,IDO.no_seq							AS ido_no_seq
				,IDO.su_nonyu_jitsu					AS ido_su_nonyu_jitsu
				,IDO.su_nonyu_jitsu_hasu			AS ido_su_nonyu_jitsu_hasu
				,IDO.kbn_nyushukko					AS ido_kbn_nyushukko
				
				,NIUKE.biko
				,ZAIKO.su_zaiko
				,ZAIKO.su_zaiko_hasu
				,CASE WHEN ma_konyu.cd_tani_nonyu = '4' OR ma_konyu.cd_tani_nonyu = '11'
						THEN (ZAIKO.su_zaiko) * ma_konyu.su_iri + ((su_zaiko_hasu )* 1.0 / 1000)
					  ELSE (ZAIKO.su_zaiko) * ma_konyu.su_iri + su_zaiko_hasu
				 END AS zaikoAll
				,tn_max.dt_niuke					AS	max_dt_niuke			-- 荷受日(最新)
				,tn_max.no_seq						AS	max_no_seq				-- シーケンス番号(最新)
				,IDO_MAX.ido_no_seq_max
				,NIUKE_DEL.no_seq					AS  max_no_seq_del
				, nonyu.nm_tani AS tani_nonyu

				, HINMEI.cd_tani_shiyo
				, shiyo.nm_tani AS tani_shiyo
				, NIUKE.dt_kigen
				, HINMEI.dd_shomi
				
			FROM tmp_niuke NIUKE
			--- hinmei
			INNER JOIN ma_hinmei HINMEI
				ON HINMEI.cd_hinmei		= NIUKE.cd_hinmei
				--AND HINMEI.flg_mishiyo  = @shiyoMishiyoFlg
			--- konyu
			INNER JOIN	ma_konyu
				ON NIUKE.cd_torihiki = ma_konyu.cd_torihiki
				AND NIUKE.cd_hinmei = ma_konyu.cd_hinmei
				--AND ma_konyu.flg_mishiyo	= @shiyoMishiyoFlg
			
			LEFT JOIN ma_tani nonyu
			ON HINMEI.cd_tani_nonyu = nonyu.cd_tani
			AND nonyu.flg_mishiyo = @shiyoMishiyoFlg

			LEFT JOIN ma_tani shiyo
			ON HINMEI.cd_tani_shiyo = shiyo.cd_tani
			AND shiyo.flg_mishiyo = @shiyoMishiyoFlg
		
			--- zaiko
			INNER JOIN tmp_zaiko ZAIKO
				ON ZAIKO.no_niuke	= NIUKE.no_niuke
			INNER JOIN ma_niuke ZAIKO_NIUKE
				ON ZAIKO_NIUKE.cd_niuke_basho		=	ZAIKO.cd_niuke_basho
				AND ZAIKO_NIUKE.flg_mishiyo			=	@shiyoMishiyoFlg
			INNER JOIN ma_kbn_niuke ZAIKO_KBN_NIUKE
				ON ZAIKO_KBN_NIUKE.kbn_niuke_basho	= ZAIKO_NIUKE.kbn_niuke_basho
				AND ZAIKO_KBN_NIUKE.flg_mishiyo		= @shiyoMishiyoFlg
			INNER JOIN ma_kbn_zaiko ZAIKO_KBN
				ON ZAIKO_KBN.kbn_zaiko = ZAIKO.kbn_zaiko

			-- niuke max
			LEFT JOIN
			(	
				SELECT
					t_max.no_niuke
					, MAX(t_max.no_seq)		AS no_seq
					, MAX(t_max.dt_niuke)	AS dt_niuke
					, MAX(t_max.dt_nonyu)	AS dt_nonyu
				FROM tr_niuke t_max
				WHERE
					(
						(
							t_max.no_seq <> @minSeqNo
							AND t_max.dt_niuke <= @dt_shukko
						)
						OR
						(					
							t_max.no_seq = @minSeqNo
							AND t_max.dt_nonyu <= @dt_shukko
						)
					)
				GROUP BY
					 t_max.no_niuke
				) tn_max
			ON	ZAIKO.no_niuke	= tn_max.no_niuke

			-- ido
			LEFT OUTER JOIN tmp_ido IDO
				ON IDO.no_niuke					= ZAIKO.no_niuke
				AND IDO.cd_niuke_basho_before		= ZAIKO.cd_niuke_basho
				AND IDO.kbn_zaiko_before			= ZAIKO.kbn_zaiko
			LEFT JOIN ma_niuke IDO_NIUKE
				ON IDO_NIUKE.cd_niuke_basho			= IDO.cd_niuke_basho
				AND IDO_NIUKE.flg_mishiyo			= @shiyoMishiyoFlg
			LEFT JOIN ma_kbn_niuke IDO_KBN_NIUKE
				ON IDO_KBN_NIUKE.kbn_niuke_basho	= IDO_NIUKE.kbn_niuke_basho
				AND IDO_KBN_NIUKE.flg_mishiyo		= @shiyoMishiyoFlg
			LEFT JOIN ma_kbn_zaiko IDO_KBN_ZAIKO
				ON IDO_KBN_ZAIKO.kbn_zaiko			= IDO.kbn_zaiko
						
			-- niuke delete
			LEFT JOIN
			(
				SELECT
					t_max.no_niuke
					,t_max.cd_niuke_basho
					,t_max.kbn_zaiko
					, MAX(t_max.no_seq)	AS no_seq
				FROM tr_niuke t_max
				WHERE
					(
						(
							t_max.no_seq <> @minSeqNo
							AND t_max.dt_niuke >= @dt_shukko
						)
						OR
						(
							t_max.no_seq = @minSeqNo
							AND t_max.dt_nonyu >= @dt_shukko
						)
					)
				GROUP BY
					 t_max.no_niuke
					 ,t_max.cd_niuke_basho
					 ,t_max.kbn_zaiko
				) NIUKE_DEL
			ON	IDO.no_niuke		= NIUKE_DEL.no_niuke
			AND IDO.cd_niuke_basho	= NIUKE_DEL.cd_niuke_basho
			AND IDO.kbn_zaiko		= NIUKE_DEL.kbn_zaiko

			-- ido max
			LEFT OUTER JOIN 
			(
				SELECT
					no_niuke
					,MAX(no_seq)	AS ido_no_seq_max
				FROM tmp_ido
				GROUP BY
					no_niuke
			) IDO_MAX
				ON IDO_MAX.no_niuke	= ZAIKO.no_niuke

			-- ido zaiko
			LEFT OUTER JOIN
			(
				SELECT
					no_niuke
					,cd_niuke_basho_before
					,kbn_zaiko_before
					,ISNULL(SUM(su_nonyu_jitsu), 0)		AS su_nonyu_jitsu_sum
					,ISNULL(SUM(su_nonyu_jitsu_hasu),0) AS su_nonyu_jitsu_hasu_sum
				FROM tmp_ido
				GROUP BY
					no_niuke
					,cd_niuke_basho_before
					,kbn_zaiko_before
			) IDO_BEFORE
				ON IDO_BEFORE.no_niuke					= ZAIKO.no_niuke
				AND IDO_BEFORE.cd_niuke_basho_before	= ZAIKO.cd_niuke_basho
				AND IDO_BEFORE.kbn_zaiko_before			= ZAIKO.kbn_zaiko

			---- ido zaiko current
			LEFT OUTER JOIN
			(
				SELECT
					no_niuke
					,cd_niuke_basho
					,kbn_zaiko
					,ISNULL(SUM(su_nonyu_jitsu), 0)		AS su_nonyu_jitsu_sum
					,ISNULL(SUM(su_nonyu_jitsu_hasu),0) AS su_nonyu_jitsu_hasu_sum
				FROM tmp_ido
				GROUP BY
					no_niuke
					,cd_niuke_basho
					,kbn_zaiko
			) IDO_CURRENT
				ON IDO_CURRENT.no_niuke			= ZAIKO.no_niuke
				AND IDO_CURRENT.cd_niuke_basho	= ZAIKO.cd_niuke_basho
				AND IDO_CURRENT.kbn_zaiko		= ZAIKO.kbn_zaiko
				 
			WHERE
				( HINMEI.cd_bunrui = @kbn_bunrui OR @kbn_bunrui IS NULL)
				
				AND
				(
					(IDO.cd_niuke_basho IS NOT NULL AND IDO.kbn_zaiko IS NOT NULL AND IDO.no_seq IS NOT NULL)
					OR
					(
						IDO.cd_niuke_basho IS NULL AND IDO.kbn_zaiko IS NULL AND IDO.no_seq IS NULL
						AND 
						(zaiko_su_zaiko <> 0 OR zaiko_su_zaiko_hasu <> 0)
					)
				)
			ORDER BY
				NIUKE.cd_hinmei
				,NIUKE.dt_nonyu
				,NIUKE.no_lot
				,ZAIKO.cd_niuke_basho
				,ZAIKO.kbn_zaiko
				,IDO.cd_niuke_basho
				,IDO.kbn_zaiko
		) NIUKE

	) RESULT

	WHERE
		( 
			(
				@isExcel = @false
				AND RN BETWEEN @start AND @end
			)
			OR 
			(
				@isExcel = @true
			)
		)
	ORDER BY
		cd_hinmei
		,dt_nonyu
		,no_lot
		,zaiko_cd_niuke_basho
		,zaiko_kbn_zaiko
		,ido_cd_niuke_basho
		,ido_kbn_zaiko





GO
