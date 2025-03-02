create database space_missions;
use space_missions;
select database();

-- Cleaning

alter table space_missions
rename column ï»¿Company to Company;

update space_missions
set Date = str_to_date(Date,'%d-%m-%Y');

alter table space_missions
modify column Date date;

alter table space_missions
modify column Time time;

select count(Price) from space_missions where Price != "";

select trim(Price) from space_missions;

update space_missions
set Price = 
case
	when Price = '' then 0
    else Price
end
;

alter table space_missions
modify column Price decimal(5,2);


-- What is the total number of missions launched by each company?

select count(Company) from space_missions;
select count(distinct Company) from space_missions;

select
Company,
count(Mission) as Total_Missions
from space_missions
group by Company;


-- Which year had the most space missions, and how many were launched?

select
year(Date) as year,
count(Mission) as Total_Mission_Launched
from space_missions
group by year
order by Total_Mission_Launched desc
limit 1;


-- What percentage of missions resulted in success for each company?

select
Company,
round((
(count(MissionStatus)/
(select count(MissionStatus) from space_missions))
*100),2) as success_prcent
from space_missions
where MissionStatus = 'Success'
group by Company;


-- Find the top 5 companies based on the number of missions launched.

select
Company,
count(Mission) as Total_Mission_Launched
from space_missions
group by Company
order by Total_Mission_Launched desc
limit 5;


-- What is the average cost of missions for each company (consider only available data)?

select
Company,
round(avg(Price),2) as average_cost
from space_missions
group by Company;


-- Which rockets have been used the most for space missions?

select count(Rocket) from space_missions;
select count( distinct Rocket) from space_missions;

select
Rocket,
count(*) as no_of_used
from space_missions
group by Rocket
order by no_of_used desc;


-- How many missions have been launched from each location?

select count(Location) from space_missions;
select count(distinct Location) from space_missions;

select
Location,
count(*) as total_mission_launced
from space_missions
group by Location;


-- Which location had the highest number of successful missions?

select
Location,
count(MissionStatus) as total_successful_missions
from space_missions
where MissionStatus = 'Success'
group by Location
order by total_successful_missions desc
limit 1;


-- List the companies and the number of failed missions they had.

select
Company,
count(MissionStatus) as total_failed_missions
from space_missions
where MissionStatus = 'Failure'
group by Company;


-- How many rockets have the status "Retired," and which companies operated them?

select
Company,
count(RocketStatus) as total_retired_rockets
from space_missions
where RocketStatus = 'Retired'
group by Company;


-- Find the earliest and latest mission dates for each company.

select
Company,
min(Date) as earliest,
max(Date) as latest
from space_missions
group by Company;


-- Which company has conducted the most expensive mission, and what was the cost?

select
Company,
Price
from space_missions
where Price = (select max(Price) from space_missions);


-- For each year, how many successful and failed missions occurred?

with success_missions as
(select
year(Date) as year,
count(MissionStatus) as total_successful_missions
from space_missions
where MissionStatus = 'Success'
group by year),

failed_missions as
(select
year(Date) as year,
count(MissionStatus) as total_failed_missions
from space_missions
where MissionStatus != 'Success'
group by year)

select
success_missions.year,
success_missions.total_successful_missions,
failed_missions.total_failed_missions
from success_missions
join failed_missions
on success_missions.year = failed_missions.year;


-- What is the success rate of missions launched by each company?

select
Company,
round(((
count(MissionStatus)/
(select count(MissionStatus) from space_missions)
)*100),2)
as success_ratio
from space_missions
where MissionStatus = 'Success'
group by Company;


-- Which company had the highest proportion of failed missions compared to its total launches?

select
Company,
count(Mission) as total_missions,
round(((
count(MissionStatus)/
(select count(MissionStatus) from space_missions)
)*100),2)
as failure_ratio
from space_missions
where MissionStatus = 'Failure'
group by Company
order by failure_ratio desc
limit 1;


-- List the top 5 most expensive missions and their details (company, location, rocket, status).

with expensive_missions as 
(select
Price
from space_missions
order by Price desc
limit 5)

select
Company,
Location,
Rocket,
MissionStatus
from space_missions
where Price in (select Price from expensive_missions)
limit 5;



-- Find the number of missions launched each month across all years.

select
monthname(Date) as month,
count(Mission) as total_missions_launched
from space_missions
group by month
order by
case month
when 'January' then 1
when 'February' then 2
when 'March' then 3
when 'April' then 4
when 'May' then 5
when 'June' then 6
when 'July' then 7
when 'August' then 8
when 'September' then 9
when 'October' then 10
when 'November' then 11
when 'December' then 12
end;


-- What is the distribution of mission statuses (success/failure/partial failure) for rockets that are retired?

select
round((count(case when MissionStatus = 'Success' then 1 end)/
(select count(MissionStatus) from space_missions))*100,2) as success_ratio,

round((count(case when MissionStatus = 'Partial Failure' then 1 end)/
(select count(MissionStatus) from space_missions))*100,2) as Partial_failure_ratio,

round((count(case when MissionStatus = 'Failure' then 1 end)/
(select count(MissionStatus) from space_missions))*100,2) as Failure_ratio

from space_missions
group by RocketStatus
having RocketStatus = 'Retired';



-- Identify the number of missions launched by decade (e.g., 1950s, 1960s).

select
case
	when year(Date) >=1950 and year(Date) < 1960 then 1950
    when year(Date) >=1960 and year(Date) < 1970 then 1960
    when year(Date) >=1970 and year(Date) < 1980 then 1970
    when year(Date) >=1980 and year(Date) < 1990 then 1980
    when year(Date) >=1990 and year(Date) < 2000 then 1990
end
as decade,
count(Mission) as total_missions_launched
from space_missions
group by decade;



-- What is the breakdown of missions launched during day vs night (use the time field)?

select
case
	when hour(Time) >12 then "Night"
    else "Day"
end
as Period,
count(Mission) as total_mission_launched
from space_missions
group by Period;
