IF OBJECT_ID ('dbo.vw_kojoAndKaisha_info', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_kojoAndKaisha_info]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
機能		：会社と工場マスタ情報取得用ビュー
ビュー名	：vw_kojoAndKaisha_info
入力引数	：
備考		：
作成日		：2018.02.05 BRC kanehira
更新日		：
************************************************************/
CREATE VIEW [dbo].[vw_kojoAndKaisha_info] AS
--TODO 現状ではログインユーザーと会社マスタ、工場マスタが紐づかないため会社マスタと工場マスタのみ紐づける
--工場や会社の登録数が増える場会改修する必要あり
SELECT
kaisha.cd_kaisha
,kojo.cd_kojo
,kojo.su_keta_shosuten
FROM ma_kojo kojo
INNER JOIN ma_kaisha kaisha
ON kaisha.cd_kaisha = kojo.cd_kaisha
--TODO END
GO