IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'aspnet_CheckSchemaVersion') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[aspnet_CheckSchemaVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_CheckSchemaVersion]
    @Feature                   nvarchar(128),
    @CompatibleSchemaVersion   nvarchar(128)
AS
BEGIN
    IF (EXISTS( SELECT  *
                FROM    dbo.aspnet_SchemaVersions
                WHERE   Feature = LOWER( @Feature ) AND
                        CompatibleSchemaVersion = @CompatibleSchemaVersion ))
        RETURN 0

    RETURN 1
END
GO
