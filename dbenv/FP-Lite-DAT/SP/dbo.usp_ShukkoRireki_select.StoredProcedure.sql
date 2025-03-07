
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShukkoRireki_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShukkoRireki_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：get data for page ShukkoRireki
ファイル名	：usp_ShukkoRireki_select
入力引数	：@dt_shukko_from, @dt_shukko_to, @cd_shokuba
			  , @no_lot, @cd_hinmei, @nm_tanto
出力引数	：
戻り値		：data by condition
作成日		：2018.07.16
更新日      ：2018.07.16
更新日      ：2018.12.05 BRC.kanehira 移動出庫画面で表示される荷受場所を表示するように修正
更新日      ：2019.06.28 nakamura.r 職場コードをVarcharにするように変更（BQPにて型変換で異常終了したため対応
*****************************************************/
CREATE PROCEDURE [dbo].[usp_ShukkoRireki_select] 
	@dt_shukko_from			DATETIME      --出庫日（開始）
	,@dt_shukko_to			DATETIME	  --出庫日（終了）
	,@cd_shokuba			SMALLINT      --職場
    ,@no_lot				VARCHAR(14)   --ロットNo.
    ,@cd_hinmei				VARCHAR(14)   --品コード
	,@nm_tanto			    NVARCHAR(50)  --出庫担当者
	,@skip					DECIMAL(10)
    ,@top					DECIMAL(10)
	,@isExcel				BIT			  -- export excel: { 0, 1 }

AS
	DECLARE @start DECIMAL(10);
	DECLARE	@end   DECIMAL(10)
			,@true					BIT
			,@false					BIT
			,@cd_shokuba_search     varchar(10);

	SET @start = @skip + 1;
	SET @end   = @skip + @top;
	SET @dt_shukko_from = CAST(@dt_shukko_from AS DATE);
	SET @dt_shukko_from = (DATEADD(mi,-DATEDIFF(mi, GETUTCDATE(), GETDATE()), @dt_shukko_from));
	SET @dt_shukko_to = CAST(@dt_shukko_to AS DATE);
	SET @dt_shukko_to = (DATEADD(mi,-DATEDIFF(mi, GETUTCDATE(), GETDATE()), @dt_shukko_to));
	SET @dt_shukko_to = DATEADD(DAY,1, @dt_shukko_to);
	SET	@true	= 1;
	SET	@false	= 0;
	SET @cd_shokuba_search = @cd_shokuba;

BEGIN
	WITH cte AS
		(
			SELECT 
				ROW_NUMBER() OVER (ORDER BY dt_shukko_jikan, cd_hinmei, dt_nyuko, tm_nyuko, no_lot, kbn_zaiko) AS RN,
				dt_shukko_jikan,
				cd_hinmei,
				nm_hinmei_ja,
				nm_hinmei_en,
				nm_hinmei_zh,
				nm_hinmei_vi,
				dt_nyuko,
				tm_nyuko,
				no_lot,
				dt_seizo,
				dt_shomi_kigen,
				nm_hozon,
				shukko_su_zaiko,
				shukko_su_zaiko_hasu,
				nm_shokuba,
				shukko_tantosha,
				nm_niuke_basho,
				biko

			FROM 
				(
					SELECT
						shukko_rireki.dt_shukko									AS dt_shukko_jikan,
						niuke.cd_hinmei,
						hinmei.nm_hinmei_ja,
						hinmei.nm_hinmei_en,
						hinmei.nm_hinmei_vi,
						hinmei.nm_hinmei_zh,
						niuke.dt_nonyu											AS dt_nyuko,
						niuke.tm_nonyu_jitsu									AS tm_nyuko,
						niuke.no_lot,
						niuke.dt_seizo,
						niuke.dt_kigen											AS dt_shomi_kigen,
						zaiko.nm_kbn_zaiko										AS nm_hozon,
						shukko_rireki.su_shukko									AS shukko_su_zaiko,
						shukko_rireki.su_shukko_hasu							AS shukko_su_zaiko_hasu,
						shokoba.nm_shokuba										AS nm_shokuba,
						tanto.nm_tanto											AS shukko_tantosha,
						shukko_rireki.kbn_zaiko,
						maNiuke.nm_niuke										AS nm_niuke_basho,
						shukko_rireki.biko

					FROM
						tr_shukko_rireki										AS shukko_rireki

						LEFT OUTER JOIN ma_kbn_zaiko							AS zaiko
						ON shukko_rireki.kbn_zaiko	= zaiko.kbn_zaiko
		
						LEFT OUTER JOIN ma_shokuba								AS shokoba
						ON shukko_rireki.cd_shokuba	= shokoba.cd_shokuba		

						LEFT OUTER JOIN ma_tanto								AS tanto
						ON shukko_rireki.cd_create  = tanto.cd_tanto

						LEFT OUTER JOIN tr_niuke								AS niuke
						ON shukko_rireki.no_niuke	= niuke.no_niuke
						AND niuke.no_seq	= 1

						LEFT OUTER JOIN ma_hinmei								AS hinmei
						ON niuke.cd_hinmei = hinmei.cd_hinmei

						LEFT OUTER JOIN ma_niuke								AS maNiuke
						--ON niuke.cd_niuke_basho		= maNiuke.cd_niuke_basho
						ON shukko_rireki.cd_niuke_basho = maNiuke.cd_niuke_basho

					WHERE 
							(@no_lot IS NULL OR niuke.no_lot = @no_lot)
						AND (@nm_tanto IS NULL OR (tanto.nm_tanto LIKE '%'+@nm_tanto+'%'))
						AND (@cd_hinmei IS NULL OR niuke.cd_hinmei = @cd_hinmei)
						AND (@dt_shukko_from IS NULL OR shukko_rireki.dt_shukko >= @dt_shukko_from)
						AND (@dt_shukko_to IS NULL OR  shukko_rireki.dt_shukko <  @dt_shukko_to)
						AND (@cd_shokuba_search IS NULL OR (shukko_rireki.cd_shokuba = @cd_shokuba_search))
				) AS DATA
		)

		SELECT
			cnt,
			dt_shukko_jikan,
			cd_hinmei,
			nm_hinmei_ja,
			nm_hinmei_en,
			nm_hinmei_zh,
			nm_hinmei_vi,
			dt_nyuko,
			tm_nyuko,
			no_lot,
			dt_seizo,
			dt_shomi_kigen,
			nm_hozon,
			shukko_su_zaiko,
			shukko_su_zaiko_hasu,
			nm_shokuba,
			shukko_tantosha,
			nm_niuke_basho,
			biko
		FROM
			(
				SELECT
					MAX(RN) OVER() AS cnt
					,*
				FROM cte
			) cte_row
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
END
