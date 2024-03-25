-- echo && clip_cat && echo && echo ".mode columns
-- $(clip_cat)
-- " | sqlite3 DM420240324.db

-- FreeDive VIEW
-- drop view FreeDive
create view FreeDive
as
select
  DiveId,
  datetime(((StartTime / 10000000) - (1970 * 365 * 24 * 60 * 60) - (112 * 24 * 60 * 60)), 'unixepoch') DiveDate,
  Duration,
  (Duration / 60) || ':' || substr('0' || (Duration % 60), -2, 2) as ApneaTime,
  AvgDepth,
  MaxDepth,
  BottomTemperature as Temperature,
  DiveNumberInSerie as Serie
from dive
where mode = 3 --freedive

-- Monthly Temperature
select *
from (
	select
		strftime('%m', date(DiveDate)) Month,
		min(Temperature) MinTemperature,
		round(avg(Temperature), 0) AvgTemperature,
		max(Temperature) MaxTemperature
	from FreeDive
	where Serie > 3
	group by strftime('%m', date(DiveDate)) -- Month
)
order by Month

-- Last 30 days
select *
from (
  select
    strftime('%Y-%m-%d', date(DiveDate)) DiveDay,
    max(ApneaTime) ApneaTime,
    max(AvgDepth) AvgDepth,
    max(MaxDepth) MaxDepth,
    min(Temperature) Temperature
  from FreeDive
  group by strftime('%Y-%m-%d', date(DiveDate)) -- DiveDay
  order by strftime('%Y-%m-%d', date(DiveDate)) desc -- DiveDay
  limit 30
)
order by DiveDay

-- Top ApneaTime
select DiveDate, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from FreeDive
order by Duration desc, DiveDate
limit 10

-- Top MaxDepth
select DiveDate, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from FreeDive
order by MaxDepth desc, DiveDate
limit 10

-- Top AvgDepth
select DiveDate, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from FreeDive
order by AvgDepth desc, DiveDate
limit 10

-- Dayly Report: Top ApneaTime
-- this can have duplicates if in the same day we have multiple record with the same max duration
select DiveDate, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from FreeDive
join (
  select date(DiveDate) Date, max(Duration) Max
  from FreeDive
  group by date(DiveDate) -- group by day
  order by max(Duration) desc
  limit 10
) Top on Top.Date = date(FreeDive.DiveDate) and Top.Max = FreeDive.Duration

-- Dayly Report: Top ApneaTime
select DiveDate, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from FreeDive
join (
  select min(DiveId) id
  from FreeDive
  join (
    select date(DiveDate) Date, max(Duration) Max
    from FreeDive
    group by date(DiveDate) -- group by day
    order by max(Duration) desc
  ) Top on Top.Date = date(DiveDate) and Top.Max = Duration
  group by Duration
  order by Duration desc
  limit 10
) TopRef where TopRef.id = DiveId
order by Duration desc

-- Monthly Report: Top ApneaTime
-- this can have multiple records with same month
select strftime('%Y-%m', date(DiveDate)) DiveMonth, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from FreeDive
join (
  select strftime('%Y-%m', date(DiveDate)) Month, max(Duration) Max
  from FreeDive
  group by strftime('%Y-%m', date(DiveDate)) -- group by month
  order by max(Duration) desc
) Top on Top.Month = strftime('%Y-%m', date(FreeDive.DiveDate)) and Top.Max = FreeDive.Duration
order by FreeDive.Duration desc

-- Monthly Report: Top ApneaTime
select strftime('%Y-%m', date(DiveDate)) DiveMonth, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from FreeDive
join (
  select min(DiveId) id
  from FreeDive
  join (
    select strftime('%Y-%m', date(DiveDate)) Month, max(Duration) Max
    from FreeDive
    group by strftime('%Y-%m', date(DiveDate)) -- group by month
    order by max(Duration) desc
  ) Top on Top.Month = strftime('%Y-%m', date(DiveDate)) and Top.Max = Duration
  group by Duration
  order by Duration desc
) TopRef where TopRef.id = DiveId
order by Duration desc

-- Dayly Report: Top MaxDepth
-- this can have multiple records with the same day if in the same day we have multiple record with the same max(MaxDepth)
select DiveDate, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from FreeDive
join (
  select date(DiveDate) date, max(MaxDepth) Max
  from FreeDive
  group by date(DiveDate) -- group by day
  order by max(MaxDepth) desc
  limit 10
) Top on Top.Date = date(FreeDive.DiveDate) and Top.Max = FreeDive.MaxDepth
order by FreeDive.MaxDepth desc

-- Monthly Report: Top MaxDepth
-- this can have multiple records with same month
select strftime('%Y-%m', date(DiveDate)) DiveMonth, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from FreeDive
join (
  select strftime('%Y-%m', date(DiveDate)) Month, max(MaxDepth) Max
  from FreeDive
  group by strftime('%Y-%m', date(DiveDate)) -- group by month
  order by max(MaxDepth) desc
) Top on Top.Month = strftime('%Y-%m', date(FreeDive.DiveDate)) and Top.Max = FreeDive.MaxDepth
order by FreeDive.MaxDepth desc

-- Monthly Report: Top MaxDepth
select strftime('%Y-%m', date(DiveDate)) DiveMonth, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from FreeDive
join (
  select min(DiveId) id
  from FreeDive
  join (
    select strftime('%Y-%m', date(DiveDate)) Month, max(MaxDepth) Max
    from FreeDive
    group by strftime('%Y-%m', date(DiveDate)) -- group by month
    order by max(MaxDepth) desc
  ) Top on Top.Month = strftime('%Y-%m', date(DiveDate)) and Top.Max = MaxDepth
  group by MaxDepth
  order by MaxDepth desc
) TopRef where TopRef.id = DiveId
order by MaxDepth desc

-- Dayly Report: Top AvgDepth
-- this can have multiple records with the same day if in the same day we have multiple record with the same max(AvgDepth)
select DiveDate, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from FreeDive
join (
  select date(DiveDate) date, max(AvgDepth) max
  from FreeDive
  group by date(DiveDate) -- group by day
  order by max(AvgDepth) desc
  limit 10
) Top on Top.Date = date(FreeDive.DiveDate) and Top.Max = FreeDive.AvgDepth
order by FreeDive.AvgDepth desc

-- Monthly Report: Top AvgDepth
-- this can have multiple records with same month
select strftime('%Y-%m', date(DiveDate)) DiveMonth, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from FreeDive
join (
  select strftime('%Y-%m', date(DiveDate)) Month, max(AvgDepth) Max
  from FreeDive
  group by strftime('%Y-%m', date(DiveDate)) -- group by month
  order by max(AvgDepth) desc
) Top on Top.Month = strftime('%Y-%m', date(FreeDive.DiveDate)) and Top.Max = FreeDive.AvgDepth
order by FreeDive.AvgDepth desc

-- Monthly Report: Top MaxDepth
select strftime('%Y-%m', date(DiveDate)) DiveMonth, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from FreeDive
join (
  select min(DiveId) id
  from FreeDive
  join (
    select strftime('%Y-%m', date(DiveDate)) Month, max(AvgDepth) Max
    from FreeDive
    group by strftime('%Y-%m', date(DiveDate)) -- group by month
    order by max(AvgDepth) desc
  ) Top on Top.Month = strftime('%Y-%m', date(DiveDate)) and Top.Max = AvgDepth
  group by AvgDepth
  order by AvgDepth desc
) TopRef where TopRef.id = DiveId
order by AvgDepth desc
