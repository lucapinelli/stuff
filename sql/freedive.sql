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
  count(case when MaxDepth between 21 and 21.999 then 1 end) "21",
  count(case when MaxDepth between 22 and 22.999 then 1 end) "22",
  count(case when MaxDepth between 23 and 23.999 then 1 end) "23",
  count(case when MaxDepth between 24 and 24.999 then 1 end) "24",
  count(case when MaxDepth between 25 and 25.999 then 1 end) "26",
  count(case when MaxDepth between 26 and 26.999 then 1 end) "26",
  count(case when MaxDepth between 27 and 27.999 then 1 end) "27",
  count(case when MaxDepth between 28 and 28.999 then 1 end) "28",
  count(case when MaxDepth between 29 and 29.999 then 1 end) "29",
  count(case when MaxDepth between 30 and 30.999 then 1 end) "30",
  count(case when MaxDepth between 31 and 31.999 then 1 end) "31",
  count(case when MaxDepth >= 32 then 1 end) "32+"
from freedive
where MaxDepth >= 21
group by Year, Month
order by Year, Month

-- Duration count matrix
select
  Year,
  Month,
  count(case when Duration between  84 and  89 then 1 end) "1:24",
  count(case when Duration between  90 and  95 then 1 end) "1:30",
  count(case when Duration between  96 and 101 then 1 end) "1:36",
  count(case when Duration between 102 and 107 then 1 end) "1:42",
  count(case when Duration between 108 and 113 then 1 end) "1:48",
  count(case when Duration between 114 and 119 then 1 end) "1:54",
  count(case when Duration between 120 and 125 then 1 end) "2:00",
  count(case when Duration between 126 and 131 then 1 end) "2:06",
  count(case when Duration between 132 and 137 then 1 end) "2:12",
  count(case when Duration between 138 and 143 then 1 end) "2:18",
  count(case when Duration between 144 and 149 then 1 end) "2:24",
  count(case when Duration >= 150 then 1 end) "2:30+"
from freedive
where Duration >= 84
group by Year, Month
order by Year, Month

-- Depth target count
select Year, Month, count(*) count, cast(round(avg(MaxDepth)) as integer) depth
from FreeDive
where MaxDepth > 22
group by Year, Month
order by Year, Month

-- Duration target count
select Year, Month, count(*) count, cast(round(avg(Duration)) as integer) seconds
from FreeDive
where Duration > 90 -- 1'30"
group by Year, Month
order by Year, Month

-- ---------- --
-- Cold Times --
-- ---------- --

-- MaxDepth
select Year, Month, max(MaxDepth) MaxDepth
from FreeDive
where Temperature <= 16
group by Year, Month
order by max(MaxDepth) desc

-- Top MaxDepth
select DiveDate, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from FreeDive
where Temperature <= 16
order by MaxDepth desc, DiveDate
limit 10

-- ApneaTime
select Year, Month, max(ApneaTime) ApneaTime
from FreeDive
where Temperature <= 16
group by Year, Month
order by max(ApneaTime) desc

-- Top ApneaTime
select DiveDate, ApneaTime, AvgDepth, MaxDepth, Temperature, Serie
from FreeDive
where Temperature <= 16
order by Duration desc, DiveDate
limit 10
