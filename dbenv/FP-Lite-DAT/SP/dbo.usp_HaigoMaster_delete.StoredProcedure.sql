IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoMaster_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoMaster_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,okada.k>
-- Create date: <Create Date,,2013.05.30>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_HaigoMaster_delete]
	@cd_haigo varchar(14)
AS
BEGIN

	DELETE FROM ma_haigo_mei
	WHERE 
		cd_haigo = @cd_haigo

END
GO
