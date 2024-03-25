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
