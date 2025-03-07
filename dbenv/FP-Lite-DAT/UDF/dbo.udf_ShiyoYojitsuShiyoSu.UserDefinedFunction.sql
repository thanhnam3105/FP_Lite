IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'udf_ShiyoYojitsuShiyoSu') AND xtype IN (N'FN', N'IF', N'TF')) 
DROP FUNCTION [dbo].[udf_ShiyoYojitsuShiyoSu]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[udf_ShiyoYojitsuShiyoSu]
	(
        @wt_shikomi DECIMAL(12, 6)
        ,@ritsu_hiju DECIMAL(6, 4)
        ,@ritsu_budomari DECIMAL(5, 2)
		,@ritsu_budomari_mei DECIMAL(5, 2)
        ,@su_batch_jisseki decimal(12, 6)
        ,@su_batch_jisseki_hasu decimal(12, 6)
        ,@ritsu_jisseki decimal(12, 6)
        ,@ritsu_jisseki_hasu decimal(12, 6)
	)
RETURNS DECIMAL(30, 6)
AS
	BEGIN
        DECLARE @ret DECIMAL(30, 6)

        SET @ret = CEILING(CASE WHEN @ritsu_budomari = 0 THEN 0
                        ELSE ((ISNULL(@wt_shikomi, 0) * ISNULL(@ritsu_jisseki, 0) * ISNULL(@su_batch_jisseki, 0)
                                / (ISNULL(@ritsu_budomari, 100) / 100))
                                + (ISNULL(@wt_shikomi, 0) * ISNULL(@ritsu_jisseki_hasu, 0) * ISNULL(@su_batch_jisseki_hasu, 0)
                                    / (ISNULL(@ritsu_budomari, 100) / 100))) --/ ISNULL(@ritsu_budomari_mei,100) * 100
                        END * 1000000) / 1000000
	RETURN @ret
	END
GO
