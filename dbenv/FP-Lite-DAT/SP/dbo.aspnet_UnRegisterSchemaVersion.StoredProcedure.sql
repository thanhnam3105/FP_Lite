IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aspnet_UnRegisterSchemaVersion') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[aspnet_UnRegisterSchemaVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_UnRegisterSchemaVersion]
    @Feature                   nvarchar(128),
    @CompatibleSchemaVersion   nvarchar(128)
AS
BEGIN
    DELETE FROM dbo.aspnet_SchemaVersions
        WHERE   Feature = LOWER(@Feature) AND @CompatibleSchemaVersion = CompatibleSchemaVersion
END
GO
