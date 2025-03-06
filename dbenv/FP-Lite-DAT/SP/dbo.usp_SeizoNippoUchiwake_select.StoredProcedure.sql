IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoNippoUchiwake_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoNippoUchiwake_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ADMAX kakuta.y
-- Create date: 2015.12.10
-- Description:	êªë¢ì˙ïÒÇÃì‡ñÛåüçıópSELECT
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeizoNippoUchiwake_select]
	@seihinCode			VARCHAR(14)
	,@seihinLotNumber	VARCHAR(13)
	,@anbunKubunSeizo	VARCHAR(1)
	,@anbunKubunZan		VARCHAR(1)
	,@mishiyoFlagShiyo	SMALLINT
AS
BEGIN
	
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
	FROM udf_SeizoNippoUchiwake_select(@seihinCode, @seihinLotNumber, @anbunKubunSeizo, @anbunKubunZan, @mishiyoFlagShiyo) shikakarizan
	ORDER BY shikakarizan.dt_seizo, shikakarizan.no_juni_hyoji

END



GO
