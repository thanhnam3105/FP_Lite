IF OBJECT_ID ('dbo.vw_ma_tani_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_tani_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_tani_01]
AS
SELECT            tani.cd_tani, tani.nm_tani, hai.cd_haigo, hai.no_han, tani.flg_mishiyo
FROM              dbo.ma_tani AS tani LEFT OUTER JOIN
                        dbo.ma_haigo_mei AS hai ON tani.cd_tani = hai.kbn_kanzan
GO
