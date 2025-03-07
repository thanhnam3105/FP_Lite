IF OBJECT_ID ('dbo.vw_user_info', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_user_info]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
機能		：ログイン情報取得用ビュー
ビュー名	：vw_user_info
入力引数	：
備考		：
作成日		：2013.06.25 okada.k
更新日		：
************************************************************/
CREATE VIEW [dbo].[vw_user_info] as
SELECT
	users.UserName AS cd_tanto
	,tanto.nm_tanto AS nm_tanto
	,tanto.nm_shozoku AS nm_shozoku
	,tanto.kbn_ma_hinmei
	,tanto.kbn_ma_haigo
	,tanto.kbn_ma_konyusaki
	,tanto.kbn_shikomi_chohyo
FROM aspnet_Users users 
INNER JOIN ma_tanto tanto
ON users.UserName = tanto.cd_tanto
WHERE ISNULL(tanto.flg_mishiyo,0) = 0
GO
