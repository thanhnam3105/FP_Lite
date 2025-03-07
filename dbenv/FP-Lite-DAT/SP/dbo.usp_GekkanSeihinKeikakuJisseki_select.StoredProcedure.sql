IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GekkanSeihinKeikakuJisseki_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GekkanSeihinKeikakuJisseki_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author,,kobayashi.y>
-- Create date: <Create Date,,2014.1.8>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GekkanSeihinKeikakuJisseki_select]
    @no_lot_seihin varchar(MAX)
    ,@true smallint
    ,@count int output
AS
BEGIN

SELECT DISTINCT
	shikakari.no_lot_seihin
FROM tr_keikaku_shikakari shikakari
WHERE
	shikakari.no_lot_shikakari IN
(

	SELECT
		summary.no_lot_shikakari
	FROM su_keikaku_shikakari summary
	WHERE
		summary.no_lot_shikakari IN
		(
			SELECT 
				shikakariSub.no_lot_shikakari
			FROM tr_keikaku_shikakari shikakariSub
			WHERE 
				shikakariSub.no_lot_seihin IN 
				(
					SELECT 
						Id 
					FROM udf_SplitCommaValue(@no_lot_seihin)
				)
		)
		AND 
		(
			(
				summary.flg_shikomi = @true
			)OR(
				summary.flg_label = @true
			)OR(
				summary.flg_label_hasu = @true
			)
		)
)
END
GO
