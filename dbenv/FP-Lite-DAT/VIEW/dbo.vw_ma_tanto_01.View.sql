IF OBJECT_ID ('dbo.vw_ma_tanto_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_tanto_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_tanto_01]
AS
SELECT
	ma_tanto.cd_tanto AS cd_tanto
	,ma_tanto.nm_tanto AS nm_tanto
	,ISNULL(ma_tanto.flg_kyosei_hoshin, 0) AS flg_kyosei_hoshin
	,ma_tanto.flg_mishiyo AS flg_mishiyo
	,ma_tanto.dt_create AS dt_create 
	,ma_tanto.cd_create AS cd_create 
	,ma_tanto.dt_update AS dt_update
 	,ma_tanto.cd_update AS cd_update
	,aspnet_Users.UserId AS UserId 
	,aspnet_Users.LoweredUserName AS LoweredUserName
	,aspnet_Membership.Password AS Password 
	,aspnet_Roles.RoleName AS RoleName
	,aspnet_Roles.RoleName AS RoleNameText
	,aspnet_Applications.ApplicationName AS ApplicationName
	,ma_tanto.ts AS ts
	,ISNULL(ma_tanto.kbn_ma_hinmei, 0)		AS kbn_ma_hinmei
	,ISNULL(ma_tanto.kbn_ma_haigo, 0)		AS kbn_ma_haigo
	,ISNULL(ma_tanto.kbn_ma_konyusaki, 0)	AS kbn_ma_konyusaki
	,ISNULL(ma_tanto.kbn_shikomi_chohyo, 0) AS kbn_shikomi_chohyo
FROM
ma_tanto
LEFT OUTER JOIN aspnet_Users
ON aspnet_Users.UserName = ma_tanto.cd_tanto
LEFT OUTER JOIN aspnet_Membership
ON aspnet_Membership.UserId = aspnet_Users.UserId
LEFT OUTER JOIN aspnet_UsersInRoles 
ON aspnet_Users.UserId = aspnet_UsersInRoles.UserId
LEFT OUTER JOIN aspnet_Roles
ON aspnet_UsersInRoles.RoleId = aspnet_Roles.RoleId
LEFT OUTER JOIN aspnet_Applications
ON aspnet_Membership.ApplicationId = aspnet_Applications.ApplicationId
AND aspnet_Users.ApplicationId = aspnet_Applications.ApplicationId
AND aspnet_Roles.ApplicationId = aspnet_Applications.ApplicationId
GO
