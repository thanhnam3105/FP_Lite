IF OBJECT_ID ('dbo.vw_aspnet_UsersInRoles', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_aspnet_UsersInRoles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[vw_aspnet_UsersInRoles]
  AS SELECT [dbo].[aspnet_UsersInRoles].[UserId], [dbo].[aspnet_UsersInRoles].[RoleId]
  FROM [dbo].[aspnet_UsersInRoles]
GO
