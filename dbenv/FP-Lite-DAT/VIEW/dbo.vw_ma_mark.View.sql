IF OBJECT_ID ('dbo.vw_ma_mark', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_mark]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_mark]
AS
SELECT
	cd_mark
	,cd_mark + ':' + nm_mark as nm_mark
FROM ma_mark
GO
