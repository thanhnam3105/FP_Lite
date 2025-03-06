IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_select_06') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_select_06]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*****************************************************
�@�\        �F�׎���́@�ԕi�ς݂���������
�t�@�C����  �Fusp_NiukeNyuryoku_select_06
���͈���    �F@no_niuke
�o�͈���    �F
�߂�l      �F
�쐬��      �F2020.03.02  BRC Sato.t
�X�V��      �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_select_06] 
    @no_niuke        VARCHAR(14)
AS
BEGIN
    SELECT
       no_niuke
    FROM
        tr_niuke
    WHERE
        no_niuke = @no_niuke
        AND kbn_nyushukko = '8'
END

GO
