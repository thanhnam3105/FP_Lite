IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryoLotToroku_select_02') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryoLotToroku_select_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <SangVM>
-- Create date: <Create Date: 2016/03>
-- Last Update: <2016/04/13 SangVM>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GenryoLotToroku_select_02]
	@dt_hiduke 		DATETIME
	, @cd_hinmei	VARCHAR(14)
	, @no_lot 		VARCHAR(14)
AS
BEGIN
	DECLARE @flg_mishiyo	SMALLINT
	DECLARE @no_seq			DECIMAL(8, 0)

	SET @flg_mishiyo = 0
	SET @no_seq = 1

	SELECT
		TRACE.flg_henko
		, SHI.no_lot_shikakari
		, SHI.dt_seizo
		, SHI.cd_shikakari_hin
		, TRACE.cd_hinmei
		, TRACE.cd_hinmei AS cd_hinmei_old
		, HIN.nm_hinmei_ja
		, HIN.nm_hinmei_en
		, HIN.nm_hinmei_zh
		, HIN.nm_hinmei_vi
		, HIN.nm_hinmei_ryaku
		, HIN.cd_tani_shiyo
		, TANI.nm_tani AS nm_tani_shiyo
		, HIN.nm_nisugata_hyoji
		, HIN.flg_trace_taishogai
		, TRACE.no_kotei
		, TRACE.no_tonyu
		, TRACE.kbn_hin
		, ISNULL(CAST(Trace.no_niuke AS VARCHAR(14)), NULL) AS no_niuke
		, TR_NIU.no_lot
		, TRACE.biko
	FROM tr_lot_trace TRACE
	
	INNER JOIN su_keikaku_shikakari SHI
	ON SHI.no_lot_shikakari = TRACE.no_lot_shikakari
	AND CAST(SHI.dt_seizo AS DATE) = CAST(@dt_hiduke AS DATE)
	AND SHI.cd_shikakari_hin = @cd_hinmei
	AND SHI.no_lot_shikakari = @no_lot

	LEFT JOIN ma_hinmei HIN
	ON TRACE.cd_hinmei = HIN.cd_hinmei
	AND HIN.flg_mishiyo = @flg_mishiyo

	LEFT JOIN ma_tani TANI
	ON HIN.cd_tani_shiyo = TANI.cd_tani

	LEFT JOIN tr_niuke TR_NIU
	ON TRACE.no_niuke = TR_NIU.no_niuke
	AND TR_NIU.no_seq = @no_seq

END