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

-- dayly report
select Year, Month, Day, max(Duration) max_duration, max(MaxDepth) max_depth
from freedive
group by Year, Month, Day
having max(Duration) > 100
  or max(MaxDepth) > 13
order by Year, Month, Day

-- compare 12 month ago Duration
select DiveDate, Duration, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from freedive
where (Year < strftime('%Y', date('now')) and Month <= strftime('%m', date('now')))
  or (Year = strftime('%Y', date('now')) and Month = strftime('%m', date('now')))
order by Duration desc, DiveDate
limit 10

-- compare 12 month ago MaxDepth
select DiveDate, Duration, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from freedive
where (Year < strftime('%Y', date('now')) and Month <= strftime('%m', date('now')))
  or (Year = strftime('%Y', date('now')) and Month = strftime('%m', date('now')))
order by MaxDepth desc, DiveDate
limit 10

-- compare 12 month ago AvgDepth
select DiveDate, Duration, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from freedive
where (Year < strftime('%Y', date('now')) and Month <= strftime('%m', date('now')))
  or (Year = strftime('%Y', date('now')) and Month = strftime('%m', date('now')))
order by AvgDepth desc, DiveDate
limit 10

-- Monthly Temperature
select *
from (
	select
		strftime('%m', date(DiveDate)) Month,
		min(Temperature) MinTemp,
		cast(ceil(avg(Temperature)) as int) AvgTemp,
		max(Temperature) MaxTemp
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

-- MaxDepth count metrix
select
  Year,
  Month,
  count(case when MaxDepth between 19 and 20 then 1 end) d19,
  count(case when MaxDepth between 20 and 21 then 1 end) d20,
  count(case when MaxDepth between 21 and 22 then 1 end) d21,
  count(case when MaxDepth between 22 and 23 then 1 end) d22,
  count(case when MaxDepth between 23 and 24 then 1 end) d23,
  count(case when MaxDepth between 24 and 25 then 1 end) d24,
  count(case when MaxDepth >= 25 then 1 end) d25
from freedive
where MaxDepth > 19
group by Year, Month
order by Year, Month

-- Duration count matrix
select
  Year,
  Month,
  count(case when Duration between 108 and 114 then 1 end) "1:48",
  count(case when Duration between 114 and 120 then 1 end) "1:54",
  count(case when Duration between 120 and 126 then 1 end) "2:00",
  count(case when Duration between 126 and 132 then 1 end) "2:06",
  count(case when Duration between 132 and 138 then 1 end) "2:12",
  count(case when Duration between 138 and 144 then 1 end) "2:18",
  count(case when Duration between 144 and 150 then 1 end) "2:24",
  count(case when Duration >= 150 then 1 end) "2:30"
from freedive
where Duration > 108
group by Year, Month
order by Year, Month

-- Depth target count
select Year, Month, count(*) count, avg(MaxDepth) depth
from FreeDive
where MaxDepth > 21
group by Year, Month
order by Year, Month

-- Duration target count
select Year, Month, count(*) count, avg(Duration) seconds
from FreeDive
where Duration > 108 -- 1'48"
group by Year, Month
order by Year, Month
