IF OBJECT_ID ('dbo.vw_ma_hakari_02', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_hakari_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_hakari_02]
AS
SELECT
	cd_hakari AS cd_hakari
	,cd_hakari + '：' + nm_hakari AS nm_hakari
	,cd_tani AS cd_tani
	,flg_mishiyo AS flg_mishiyo
FROM ma_hakari
GO
