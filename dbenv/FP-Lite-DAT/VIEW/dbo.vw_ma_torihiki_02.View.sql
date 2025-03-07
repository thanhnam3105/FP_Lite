IF OBJECT_ID ('dbo.vw_ma_torihiki_02', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_torihiki_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_torihiki_02]
AS
SELECT
	dbo.ma_torihiki.cd_torihiki
	,dbo.ma_torihiki.nm_torihiki
	,dbo.ma_konyu.cd_torihiki AS cd_torihiki_konyu
	,dbo.ma_konyu.flg_mishiyo AS flg_mishiyo_konyu
	,dbo.ma_torihiki.flg_mishiyo AS flg_mishiyo_torihiki
	,dbo.ma_konyu.cd_hinmei
FROM dbo.ma_torihiki 
INNER JOIN dbo.ma_konyu 
ON dbo.ma_torihiki.cd_torihiki = dbo.ma_konyu.cd_torihiki
GO
