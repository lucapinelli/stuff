-- https://www.sqlitetutorial.net/sqlite-functions/
-- https://www.sqlitetutorial.net/sqlite-math-functions/

-- echo && clip_cat | bp -l sql && echo && echo ".mode columns
-- $(clip_cat)
-- " | sqlite3 DM*.db

-- FreeDive VIEW
-- drop view FreeDive;
create view FreeDive
as
select
  DiveId,
  cast(strftime('%Y', date(datetime(((StartTime / 10000000) - (1970 * 365 * 24 * 60 * 60) - (112 * 24 * 60 * 60)), 'unixepoch'))) as int) Year,
  cast(strftime('%m', date(datetime(((StartTime / 10000000) - (1970 * 365 * 24 * 60 * 60) - (112 * 24 * 60 * 60)), 'unixepoch'))) as int) Month,
  cast(strftime('%d', date(datetime(((StartTime / 10000000) - (1970 * 365 * 24 * 60 * 60) - (112 * 24 * 60 * 60)), 'unixepoch'))) as int) Day,
  cast(strftime('%W', date(datetime(((StartTime / 10000000) - (1970 * 365 * 24 * 60 * 60) - (112 * 24 * 60 * 60)), 'unixepoch'))) as int) Week,
  datetime(((StartTime / 10000000) - (1970 * 365 * 24 * 60 * 60) - (112 * 24 * 60 * 60)), 'unixepoch') DiveDate,
  Duration,
  (Duration / 60) || ':' || substr('0' || (Duration % 60), -2, 2) as ApneaTime,
  AvgDepth,
  MaxDepth,
  BottomTemperature as Temperature,
  DiveNumberInSerie as Serie
from dive
where mode = 3 --freedive

-- only dives made on 2024-07-09
select *
from freedive
where DiveDate between '2024-07-09' and '2024-07-10'
order by DiveDate

-- dive with depth >= 15mt, group by day, sort by avg depth
select
  Year,
  Month,
  Day,
  count(*),
  cast(ceil(avg(Duration)) as integer) avg_time,
  cast(ceil(avg(MaxDepth)) as integer) avg_depth
from freedive
where MaxDepth >= 15
group by Year, Month, Day
order by avg(MaxDepth) desc, Year, Month, Day

-- compare years depths
select
  Year,
  count(*),
  cast(ceil(avg(Duration)) as integer) avg_time,
  cast(ceil(avg(MaxDepth)) as integer) avg_depth
from freedive
where MaxDepth > 15
group by Year
order by count(*) desc, Year

-- compare years durations
select
  Year,
  count(*),
  cast(ceil(avg(Duration)) as integer) avg_time,
  cast(ceil(avg(MaxDepth)) as integer) avg_depth
from freedive
where Duration > 90
group by Year
order by count(*) desc, Year

-- compare 12 month ago Duration
select DiveDate, Duration, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from freedive
where (Year <= 2023 and Month <= 06)
  or (Year = 2024 and Month = 06)
order by Duration desc, DiveDate
limit 10

-- compare 12 month ago MaxDepth
select DiveDate, Duration, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from freedive
where (Year <= 2023 and Month <= 06)
  or (Year = 2024 and Month = 06)
order by MaxDepth desc, DiveDate
limit 10

-- compare 12 month ago AvgDepth
select DiveDate, Duration, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from freedive
where (Year <= 2023 and Month <= 06)
  or (Year = 2024 and Month = 06)
order by AvgDepth desc, DiveDate
limit 10

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

-- ApneaTime
select Year, Month, max(ApneaTime) ApneaTime
from FreeDive
group by Year, Month
--order by Year, Month
order by max(ApneaTime) desc

-- MaxDepth
select Year, Month, max(MaxDepth) MaxDepth
from FreeDive
group by Year, Month
--order by Year, Month
order by max(MaxDepth) desc

-- AvgDepth
select Year, Month, max(AvgDepth) AvgDepth
from FreeDive
group by Year, Month
--order by Year, Month
order by max(AvgDepth) desc
