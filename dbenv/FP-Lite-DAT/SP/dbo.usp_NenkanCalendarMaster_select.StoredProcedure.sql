IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NenkanCalendarMaster_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NenkanCalendarMaster_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_NenkanCalendarMaster_select]

 @yy_nendo			AS VARCHAR(4) -- 年度
 ,@cd_kaisha		AS VARCHAR(13) -- 会社コード
 ,@cd_kojo			AS VARCHAR(13) -- 工場コード
 ,@dt_nendo_start	AS INT -- 年度開始日
 ,@cd_user			AS VARCHAR(10) -- ログインユーザーID
 ,@lang				AS VARCHAR(2) -- 言語
 ,@Japanese			AS VARCHAR(2) -- 日本語
 ,@English			AS VARCHAR(2) -- 英語
 ,@Chinese			AS VARCHAR(2) -- 中国語
 ,@Vietnamese		AS VARCHAR(2)
 ,@add_hh			AS INT -- 標準時間と現地時間の差分
AS
BEGIN

--declare @add_hh as int

-- 標準時間と現地時間の差分をhh単位で取得
--set @add_hh = datediff(hh, GETUTCDATE(), getdate())


if (select count(*) from ma_calendar where yy_nendo = @yy_nendo) = 0
begin
	declare @year varchar(4)
	declare @utc_date datetime
	declare @dt_utc_hiduke datetime
	declare @count int
	declare @day int
	declare @month int
	declare @startDate datetime
	--declare @diff_second int
	declare @utcdate datetime = GETUTCDATE()
	declare @loopDate int
	
	set @year = @yy_nendo
	-- 標準時間と現地時間の差分を秒単位で取得
	--set @diff_second = datediff(second, getdate(), getutcdate())
	
	-- 検索対象の西暦を取得
	if @dt_nendo_start > 6
	begin
		set @year = @year - 1
	end
	
	-- カウントアップ用UTC日付
	--set @utc_date = dateadd(second, @diff_second, (@year + '/' + cast(@dt_nendo_start as varchar) + '/01')) -- 年度開始日付
	set @utc_date = @year + '/' + cast(@dt_nendo_start as varchar) + '/01 10:00:00' -- 年度開始日付
	
	--- 作成する日数を取得する
	SELECT @loopDate = DATEDIFF(DAY, @utc_date, DATEADD(YEAR, 1, @utc_date))	

	set @dt_utc_hiduke = @utc_date -- カウントアップ
	while datediff(d, @utc_date, @dt_utc_hiduke) < @loopDate
	begin
		--set @utcdate = GETUTCDATE()
		insert into ma_calendar
        (
            yy_nendo
			,dt_hizuke 
			,flg_kyujitsu
			,flg_shukujitsu
			,dt_create
			,cd_create
			,dt_update
			,cd_update
        )
		values (
			@yy_nendo
			,@dt_utc_hiduke 
			,0
			,0
			,@utcdate
			,@cd_user
			,@utcdate
			,@cd_user
			)
			
		set @dt_utc_hiduke = dateadd(d, 1, @dt_utc_hiduke)
	end
	
end

declare @yobi varchar(10) -- 曜日2

if @lang = @Japanese
begin
    set language Japanese
end

if @lang = @English OR @lang = @Vietnamese
begin
    set language English
end

if @lang = @Chinese
begin
    set language 'Simplified Chinese'
end

select
	dt_hizuke
    --,case @lang when @Japanese then left(datename(weekday, dateadd(hh, @add_hh, dt_hizuke)), 1)
    --            when @English then left(datename(weekday, dateadd(hh, @add_hh, dt_hizuke)), 3)
    --            when @Chinese then right(datename(weekday, dateadd(hh, @add_hh, dt_hizuke)), 1)
    ,case @lang when @Japanese then left(datename(weekday, dt_hizuke), 1)
                when @English then left(datename(weekday, dt_hizuke), 3)
                when @Chinese then right(datename(weekday, dt_hizuke), 1)
				WHEN @Vietnamese THEN 
							CASE LEFT(DATENAME(WEEKDAY, DATEADD(hh, @add_hh, dt_hizuke)), 3)
								WHEN 'Sun' THEN 'CN'
								WHEN 'Mon' THEN 'T2'
								WHEN 'Tue' THEN 'T3'
								WHEN 'Wed' THEN 'T4'
								WHEN 'Thu' THEN 'T5'
								WHEN 'Fri' THEN 'T6'
								ELSE 'T7'
							END
    end as dt_yobi
    ,flg_kyujitsu
    ,flg_shukujitsu
    ,ts
    ,cd_create
    ,dt_create
from ma_calendar
where yy_nendo = @yy_nendo
--order by day(dateadd(hh, @add_hh, dt_hizuke))
order by dt_hizuke




------------	

end
GO
