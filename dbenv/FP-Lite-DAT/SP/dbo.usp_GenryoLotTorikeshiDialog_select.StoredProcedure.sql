IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryoLotTorikeshiDialog_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryoLotTorikeshiDialog_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <SangVM>
-- Create date: <Create Date: 2016/03>
-- Last Update: <2019/08/27 nakamura.r
--            : <2019/11/18 BRC.kanehira>
-- Description: <Description,,>
--            : <‰×Žó—\’è“ú‚ðtm_nonyu_yotei‚ÅŽæ“¾‚·‚é‚æ‚¤‚ÉC³B,2019/11/18>
--            : <•ª”[ƒf[ƒ^‚ðŽæ“¾‚·‚é‚æ‚¤‚ÉC³,2019/11/18>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GenryoLotTorikeshiDialog_select]
	@kbn_hin 				SMALLINT
	, @cd_hinmei			VARCHAR(14)
	, @no_seq 				DECIMAL(8)
	, @no_lot_shikakari		VARCHAR(14)
	, @no_kotei				DECIMAL(4, 0)
	, @no_tonyu				DECIMAL(4, 0)
AS
BEGIN

	SELECT DISTINCT
		niuke.cd_hinmei
		,niuke.flg_trace_taishogai
		,niuke.no_lot_shikakari
		,niuke.no_kotei
		,niuke.kbn_hin
		,niuke.no_niuke
		,niuke.dt_niuke
		,niuke.no_lot
		,niuke.dt_kigen
		,niuke.dt_nonyu
		,niuke.no_seq
	FROM
	(
		SELECT
			HIN.cd_hinmei
			,HIN.flg_trace_taishogai
			,TR_LOT.no_lot_shikakari
			,TR_LOT.no_kotei
			,TR_LOT.kbn_hin
			,TR_LOT.no_niuke
			,ISNULL(TR_NYU.dt_nonyu,TR_NIU.tm_nonyu_yotei) AS dt_niuke
			,TR_NIU.no_lot
			,TR_NIU.dt_kigen
			,TR_NIU.dt_nonyu
			,TR_NIU.no_seq
		FROM
			ma_hinmei HIN
			
		INNER JOIN
			tr_lot_trace TR_LOT
		ON
			HIN.cd_hinmei = TR_LOT.cd_hinmei
			AND TR_LOT.cd_hinmei = @cd_hinmei
			AND TR_LOT.kbn_hin = @kbn_hin
			AND TR_LOT.no_kotei = @no_kotei
			AND TR_LOT.no_tonyu = @no_tonyu

		INNER JOIN
			tr_niuke TR_NIU
		ON
			TR_LOT.no_niuke = TR_NIU.no_niuke
			AND TR_NIU.no_seq = @no_seq
			AND TR_LOT.no_lot_shikakari = @no_lot_shikakari
	
		LEFT OUTER JOIN
			tr_nonyu TR_NYU_JISEKI
		ON
			TR_NIU.no_nonyu = TR_NYU_JISEKI.no_nonyu
			AND TR_NYU_JISEKI.flg_yojitsu = 1
			
		LEFT OUTER JOIN
			tr_nonyu TR_NYU
		ON
			TR_NYU_JISEKI.no_nonyu = TR_NYU.no_nonyu
			AND TR_NYU.flg_yojitsu = 0
			
		UNION
		
		SELECT
			HIN.cd_hinmei
			,HIN.flg_trace_taishogai
			,TR_LOT.no_lot_shikakari
			,TR_LOT.no_kotei
			,TR_LOT.kbn_hin
			,TR_LOT.no_niuke
			,ISNULL(TR_NYU.dt_nonyu,TR_NIU.tm_nonyu_yotei) AS dt_niuke
			,TR_NIU.no_lot
			,TR_NIU.dt_kigen
			,TR_NIU.dt_nonyu
			,TR_NIU.no_seq
		FROM
			ma_hinmei HIN
			
		INNER JOIN
			tr_lot_trace TR_LOT
		ON
			HIN.cd_hinmei = TR_LOT.cd_hinmei
			AND TR_LOT.cd_hinmei = @cd_hinmei
			AND TR_LOT.kbn_hin = @kbn_hin
			AND TR_LOT.no_kotei = @no_kotei
			AND TR_LOT.no_tonyu = @no_tonyu

		INNER JOIN
			tr_niuke TR_NIU
		ON
			TR_LOT.no_niuke = TR_NIU.no_niuke
			AND TR_NIU.no_seq = @no_seq
			AND TR_LOT.no_lot_shikakari = @no_lot_shikakari
		
		LEFT OUTER JOIN
			tr_nonyu TR_NYU_JISEKI
		ON
			TR_NIU.no_nonyu = TR_NYU_JISEKI.no_nonyu
			AND TR_NYU_JISEKI.flg_yojitsu = 1
			
		LEFT OUTER JOIN
			tr_nonyu TR_NYU
		ON
			TR_NYU_JISEKI.no_nonyu_yotei = TR_NYU.no_nonyu
			AND TR_NYU.flg_yojitsu = 0
	) niuke

	/*
	SELECT
		HIN.cd_hinmei
		, HIN.flg_trace_taishogai
		, TR_LOT.no_lot_shikakari
		, TR_LOT.no_kotei
		, TR_LOT.kbn_hin
		, TR_LOT.no_niuke
		, ISNULL(TR_NYU.dt_nonyu,TR_NIU.dt_niuke) AS dt_niuke
		, TR_NIU.no_lot
		, TR_NIU.dt_kigen
		, TR_NIU.dt_nonyu
		, TR_NIU.no_seq
	FROM ma_hinmei HIN

	INNER JOIN tr_lot_trace TR_LOT
	ON HIN.cd_hinmei = TR_LOT.cd_hinmei
	AND TR_LOT.cd_hinmei = @cd_hinmei
	AND TR_LOT.kbn_hin = @kbn_hin
	AND TR_LOT.no_kotei = @no_kotei
	AND TR_LOT.no_tonyu = @no_tonyu

	INNER JOIN tr_niuke TR_NIU
	ON TR_LOT.no_niuke = TR_NIU.no_niuke
	AND TR_NIU.no_seq = @no_seq
	AND TR_LOT.no_lot_shikakari = @no_lot_shikakari
	
	LEFT OUTER JOIN tr_nonyu TR_NYU_JISEKI
	ON TR_NIU.no_nonyu = TR_NYU_JISEKI.no_nonyu
	AND TR_NYU_JISEKI.flg_yojitsu = 1
	
	LEFT OUTER JOIN tr_nonyu TR_NYU
	ON TR_NYU_JISEKI.no_nonyu_yotei = TR_NYU.no_nonyu
	AND TR_NYU.flg_yojitsu = 0
	*/
END

