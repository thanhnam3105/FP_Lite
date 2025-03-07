IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_RecipeTenkai_Shikakari_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_RecipeTenkai_Shikakari_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================
-- Author:		<Author,,sueyoshi.y>
-- Create date: <Create Date,,2013.10.22>
-- Last Update: 2016.09.07 cho.k
-- Description:	仕掛品トランのSUM対象のデータを取得する
-- ======================================================
CREATE PROCEDURE [dbo].[usp_RecipeTenkai_Shikakari_select]
	@dt_seizo datetime,
	@cd_shokuba varchar(10),
	@cd_line varchar(10),
    @cd_shikakari_hin varchar(14),
    @no_lot_seihin varchar(14),
    @data_key varchar(14)
AS
	/* SET NOCOUNT ON */

	SELECT
		data_key
		,dt_seizo
		,dt_hitsuyo
		,no_lot_seihin
		,no_lot_shikakari
		,no_lot_shikakari_oya
		,cd_shokuba
		,cd_line
		,cd_shikakari_hin
		,wt_shikomi_keikaku
		,wt_shikomi_jisseki
		,su_kaiso_shikomi
		,dt_update
		,wt_haigo_keikaku
		,wt_haigo_jisseki
		,su_batch_yotei
		,su_batch_jisseki
		,ritsu_bai
		,cd_hinmei
		,wt_hitsuyo
	FROM 
		tr_keikaku_shikakari tr_shikakari
	WHERE 
			dt_seizo = CONVERT(datetime, '' + @dt_seizo + '')
		AND cd_shokuba =  '' + @cd_shokuba  + ''
		AND cd_line = '' + @cd_line + ''
		AND cd_shikakari_hin = '' + @cd_shikakari_hin + ''
		AND ((@no_lot_seihin IS NULL AND no_lot_seihin IS NOT NULL)
			  OR no_lot_seihin <> @no_lot_seihin OR no_lot_seihin IS NULL)
		AND (@data_key IS NULL OR data_key <> @data_key)
		-- 対象の仕掛品の計画が確定していないこと、仕込実績がないこと
		AND NOT EXISTS (SELECT * FROM su_keikaku_shikakari su_shikakari
		                 WHERE  
		                 su_shikakari.no_lot_shikakari = tr_shikakari.no_lot_shikakari
		                 AND( su_shikakari.flg_jisseki = 1
		                 OR su_shikakari.flg_shikomi = 1)
		                )
GO
