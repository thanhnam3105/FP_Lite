IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_JikaGenryoLotTorikeshiDialog_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_JikaGenryoLotTorikeshiDialog_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <SangVM>
-- Create date: <Create Date: 2016/03>
-- Last Update: <2016/03/30 SangVM>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_JikaGenryoLotTorikeshiDialog_select]
	@kbn_hin 				SMALLINT
	, @cd_hinmei			VARCHAR(14)
	, @no_lot_shikakari		VARCHAR(14)
	, @no_kotei				DECIMAL(4, 0)
	, @no_tonyu				DECIMAL(4, 0)
AS
BEGIN

BEGIN
	SELECT
		HIN.cd_hinmei
		, HIN.nm_hinmei_ja
		, HIN.nm_hinmei_en
		, HIN.nm_hinmei_zh
		, HIN.nm_hinmei_vi
		, HIN.nm_hinmei_ryaku
		, HIN.flg_trace_taishogai
		, TR_LOT.no_lot_shikakari
		, TR_LOT.no_kotei
		, TR_LOT.kbn_hin
		, TR_LOT.no_niuke
		, TR_SEI.no_lot_seihin
		, TR_SEI.dt_seizo
		, TR_SEI.su_seizo_jisseki
		, TR_SEI.dt_shomi
	FROM (
		SELECT *
		FROM ma_hinmei
		WHERE cd_hinmei = @cd_hinmei
	) HIN

	INNER JOIN tr_lot_trace TR_LOT
	ON HIN.cd_hinmei = TR_LOT.cd_hinmei
	AND TR_LOT.kbn_hin = @kbn_hin
	AND TR_LOT.no_lot_shikakari = @no_lot_shikakari 
	AND TR_LOT.no_kotei = @no_kotei
	AND TR_LOT.no_tonyu = @no_tonyu

	INNER JOIN tr_keikaku_seihin TR_SEI
	ON TR_LOT.no_niuke = TR_SEI.no_lot_seihin    
END


END