IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'udf_SeizoNippoUchiwake_select') AND xtype IN (N'FN', N'IF', N'TF')) 
DROP FUNCTION [dbo].[udf_SeizoNippoUchiwake_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ADMAX kakuta.y
-- Create date: 2015.12.21
-- Update date: 2018.01.30
-- Description:	»‘¢“ú•ñ‚Ì“à–óŒŸõ
-- =============================================
CREATE FUNCTION [dbo].[udf_SeizoNippoUchiwake_select]
(	
	@seihinCode			VARCHAR(14)
	,@seihinLotNumber	VARCHAR(13)
	,@anbunKubunSeizo	VARCHAR(1)
	,@anbunKubunZan		VARCHAR(1)
	,@mishiyoFlagShiyo	SMALLINT
)
RETURNS @uchiwakeTable TABLE
(
	dt_seizo DATETIME
	,cd_hinmei VARCHAR(14)
	,nm_hinmei_ja NVARCHAR(50)
	--,nm_hinmei_en VARCHAR(50)
	,nm_hinmei_en NVARCHAR(50)
	,nm_hinmei_zh NVARCHAR(50)
	,nm_hinmei_vi NVARCHAR(50)
	,su_zaiko DECIMAL(12, 6)
	,su_shiyo DECIMAL(12, 6)

	,no_seq_shiyo_yojitsu_anbun VARCHAR(14)
	,su_shiyo_shikakari DECIMAL(12, 6)
	,no_seq_shiyo_yojitsu VARCHAR(14)
	,no_lot_seihin VARCHAR(14)
	,no_lot_shikakari VARCHAR(14)
	,con_su_shiyo DECIMAL(12, 6)
	,dt_shomi DATETIME
	,no_juni_hyoji SMALLINT
)
AS
BEGIN
	INSERT INTO @uchiwakeTable
	SELECT
		shikakarizan.dt_seizo
		,shikakarizan.cd_hinmei
		,shikakarizan.nm_hinmei_ja
		,shikakarizan.nm_hinmei_en
		,shikakarizan.nm_hinmei_zh
		,shikakarizan.nm_hinmei_vi
		,shikakarizan.su_zaiko
		,shikakarizan.su_shiyo

		,shikakarizan.no_seq_shiyo_yojitsu_anbun
		,shikakarizan.su_shiyo_shikakari
		,shikakarizan.no_seq_shiyo_yojitsu
		,shikakarizan.no_lot_seihin
		,shikakarizan.no_lot_shikakari
		,shikakarizan.con_su_shiyo
		,shikakarizan.dt_shomi
		,shikakarizan.no_juni_hyoji
	FROM
		(
			SELECT
				anbun.dt_shiyo_shikakari AS 'dt_seizo'
				,zanShiyoMst.cd_hinmei
				,ISNULL(hinmei.nm_hinmei_ja, '') AS 'nm_hinmei_ja'
				,ISNULL(hinmei.nm_hinmei_en, '') AS 'nm_hinmei_en'
				,ISNULL(hinmei.nm_hinmei_zh, '') AS 'nm_hinmei_zh'
				,ISNULL(hinmei.nm_hinmei_vi, '') AS 'nm_hinmei_vi'
				,ISNULL(anbun.su_shiyo_shikakari, 0) - ISNULL(zanShiyoSum.su_shiyo_sum, 0) AS 'su_zaiko'
				,ISNULL(zanShiyoMeisai.su_shiyo, 0) AS 'su_shiyo'

				,anbun.no_seq AS no_seq_shiyo_yojitsu_anbun
				,anbun.su_shiyo_shikakari
				,zanShiyoMeisai.no_seq_shiyo_yojitsu
				,zanShiyoMeisai.no_lot AS 'no_lot_seihin'
				,anbun.no_lot_shikakari
				,ISNULL(zanShiyoMeisai.su_shiyo, 0) AS 'con_su_shiyo'
				,DATEADD(DAY, (ISNULL(hinmei.dd_shomi, 0) - 1), anbun.dt_shiyo_shikakari) AS 'dt_shomi'
				,zanShiyoMst.no_juni_hyoji

			FROM ma_shikakari_zan_shiyo zanShiyoMst

			LEFT OUTER JOIN ma_hinmei hinmei
			ON zanShiyoMst.cd_hinmei = hinmei.cd_hinmei

			LEFT OUTER JOIN su_keikaku_shikakari summary
			ON hinmei.cd_haigo = summary.cd_shikakari_hin

			LEFT OUTER JOIN tr_sap_shiyo_yojitsu_anbun anbun
			ON summary.no_lot_shikakari = anbun.no_lot_shikakari

			LEFT OUTER JOIN tr_shiyo_shikakari_zan zanShiyoMeisai
			ON anbun.no_seq = zanShiyoMeisai.no_seq_shiyo_yojitsu_anbun
			AND zanShiyoMeisai.no_lot = @seihinLotNumber
			AND zanShiyoMeisai.kbn_shiyo_jisseki_anbun = @anbunKubunSeizo

			LEFT OUTER JOIN tr_shiyo_yojitsu shiyoYojitsu
			ON zanShiyoMeisai.no_seq_shiyo_yojitsu = shiyoYojitsu.no_seq
			LEFT OUTER JOIN
			(
				SELECT
					SUM(zan.su_shiyo) AS su_shiyo_sum
					,zan.no_seq_shiyo_yojitsu_anbun
				FROM tr_shiyo_shikakari_zan zan
				INNER JOIN tr_sap_shiyo_yojitsu_anbun anbunZan
				ON zan.no_seq_shiyo_yojitsu_anbun = anbunZan.no_seq
				WHERE
					anbunZan.kbn_shiyo_jisseki_anbun = @anbunKubunZan
				GROUP BY zan.no_seq_shiyo_yojitsu_anbun
			) zanShiyoSum
			ON anbun.no_seq = zanShiyoSum.no_seq_shiyo_yojitsu_anbun
			WHERE
				zanShiyoMst.cd_seihin = @seihinCode
				AND zanShiyoMst.flg_mishiyo = @mishiyoFlagShiyo
				AND hinmei.flg_mishiyo = @mishiyoFlagShiyo
				AND anbun.kbn_shiyo_jisseki_anbun = @anbunKubunZan

		) shikakarizan
	WHERE
		shikakarizan.su_shiyo > 0
		OR shikakarizan.su_zaiko > 0
	ORDER BY shikakarizan.dt_seizo, shikakarizan.no_juni_hyoji

RETURN
END





GO
