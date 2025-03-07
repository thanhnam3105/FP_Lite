IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoRecipeMaster_delete_han') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoRecipeMaster_delete_han]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,okada.k>
-- Create date: <Create Date,,2013.07.18>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_HaigoRecipeMaster_delete_han]
	@cd_haigo varchar(14)
	,@no_han decimal(4,0)
AS
BEGIN

	DELETE FROM ma_haigo_recipe
	WHERE 
		cd_haigo = @cd_haigo
		AND no_han = @no_han

END
GO
