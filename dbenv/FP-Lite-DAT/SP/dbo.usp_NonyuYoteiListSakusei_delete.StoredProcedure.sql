IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NonyuYoteiListSakusei_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NonyuYoteiListSakusei_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:		higashiya.s
-- Create date: 2013.07.23
-- Description:	納入予定リスト作成：納入予実トラン削除処理
-- =======================================================
CREATE PROCEDURE [dbo].[usp_NonyuYoteiListSakusei_delete]
	 @no_nonyu varchar(13)

AS
BEGIN

-- ======================
-- 納入予実トラン削除処理
-- ======================
DELETE
	tr_nonyu
WHERE
	no_nonyu = @no_nonyu

END
GO
