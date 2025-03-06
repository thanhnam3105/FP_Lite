IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KuradashiErr_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KuradashiErr_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：移動出庫画面　庫出受信
ファイル名	：usp_KuradashiErr_select
入力引数	：@dt_search,@hinKbn,@miJusin
出力引数	：
戻り値		：
作成日		：2014.11.05  ADMAX endo.y
更新日		：
*****************************************************/
CREATE  PROCEDURE [dbo].[usp_KuradashiErr_select](
	@dt_search		DATETIME	--検索条件/出庫日
	,@hinKbn		SMALLINT	--検索条件/品区分
	,@miJusin		SMALLINT	--受信区分.未受信
	,@flg_kakutei	SMALLINT	--確定フラグ.確定
	,@cd_niuke_basho VARCHAR(10)--検索条件/荷受場所
	,@cd_bunrui		VARCHAR(10)	--検索条件/分類	
)
AS
BEGIN
	--カンマ区切り処理		
	SELECT 
		REPLACE((
			SELECT tr_kuradashi.cd_hinmei AS [data()]
			FROM tr_kuradashi
			INNER JOIN ma_hinmei mh
				ON tr_kuradashi.cd_hinmei = mh.cd_hinmei
					AND mh.kbn_hin = @hinKbn
			WHERE kbn_status = @miJusin
				AND dt_shukko = @dt_search
				AND flg_kakutei = @flg_kakutei
				AND (( @cd_bunrui = '') OR (mh.cd_bunrui = @cd_bunrui))
				AND (( @cd_niuke_basho = '') OR (mh.cd_niuke_basho = @cd_niuke_basho))
			ORDER BY tr_kuradashi.cd_hinmei
	FOR XML PATH('')),' ',',') as cd_hinmei
END
GO
