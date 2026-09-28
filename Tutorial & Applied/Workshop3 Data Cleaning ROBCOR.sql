--- LAB 3b ROBCOR ---

--First create the dimensions
create table time_dim As
select Distinct to_char(char_date, 'YYYYMM') as Time_ID,
                to_char(char_date, 'Month') as Time_Month,
                to_char(char_date, 'YYYY') as Time_Year
from dw.Charter;

create table model_dim as
select * from dw.model;

create table pilot_dim as
select * from dw.pilot;

--Second, create the Charter_fact (the fact table) table
create table charter_fact as
select C.Char_Pilot as EMP_Num,
       M.Mod_Code,
       to_char(C.Char_Date, 'YYYYMM') as Time_ID,
       sum(C.Char_Hours_Flown) as Tot_Char_Hours, 
       sum(C.Char_Fuel_Gallons) as Tot_Fuel,
       sum(C.Char_Distance * M.Mod_chg_mile) as Revenue
from   dw.Charter C, dw.Model M, dw.Aircraft A
where  C.AC_Number=A.AC_Number and A.Mod_Code=M.Mod_Code
group by C.Char_Pilot, M.Mod_Code, to_char(C.Char_Date, 'YYYYMM');


--  PART A: Data Exploration -- 
-- 1)
select count(*) from dw.pilot; 
select * from dw.pilot;
select * from dw.customer;
select * from dw.charter;
select * from dw.aircraft;
select * from dw.model;
select * from dw.employee;
select * from dw.pilot_1; -- Table does not exist

-- However, dw.charter table have all the attributes complete, including
-- Char_pilot and Char_copilot attributes

-- 3)
-- The charter table will be affected as the char_copilot 

-- 4)
-- The pilot 1 table have 1-to-many relationship with charter
-- One pilot can be in many charter
select * from dw.charter;
select distinct char_copilot from dw.charter;

-- 5)
-- E/R diagram is not accurate
-- Therefore revised E/R diagram is: pg 5 Data Cleaning Robcor

-- Whether the copilot is pilot
select * from dw.charter
where char_pilot = char_copilot;
-- To check every plane have pilot
select * from dw.charter
where char_pilot is null;

-- To check how many flights with copilots
select count(*) from dw.charter
where char_copilot is null;
-- To check how many flights without copilots
select count(*) from dw.charter 
where char_copilot is not null;

-- Check pilot 101
select count(*) from dw.charter 
where char_pilot = 101;

select count(*) from dw.charter
where char_copilot = 101;

select count(*) from dw.charter 
where char_pilot = 101 or char_copilot = 101;

select count(*) from dw.charter
where char_pilot = char_copilot;



-- 2. Duplicate records but do not affect data warehouse
select char_trip, count(*)
from dw.charter
group by char_trip
having count(*) > 1;

select * from dw.charter
where char_trip = 10268;


-- 3. Should we consider copilot when calculating the fact table?
-- Charter_fact (We do not consider copilot)
create table charter_fact as
select C.Char_Pilot as EMP_Num, M.Mod_Code,
    to_char(C.Char_Date, 'YYYYMM') as Time_ID,
    sum(C.Char_Hours_Flown) as Tot_Char_Hours,
    sum(C.Char_Fuel_Gallons) as Tot_Fuel,
    sum(C.Char_Distance * M.Mod_chg_mile) as Revenue
from dw.Charter C, dw.Model M, dw.Aircraft A
where C.AC_Number=A.AC_Number and A.Mod_Code=M.Mod_Code
group by C.Char_Pilot, M.Mod_Code, to_char(C.Char_Date, 'YYYYMM');

-- Explore pilot 101
select *
from charter_fact
where emp_num=101
order by time_id;

-- Check employee 101 as pilot and copilot in April 1997
select *
from dw.charter
where to_char(char_date, 'YYYYMM') = '199704'
and (char_pilot = 101 or char_copilot = 101);

-- Charter_fact2 (to consider co-pilot)
create table charter_fact2 as
select C.Char_coPilot as EMP_Num,
 M.Mod_Code,
 to_char(C.Char_Date, 'YYYYMM') as Time_ID,
 sum(C.Char_Hours_Flown) as Tot_Char_Hours,
 sum(C.Char_Fuel_Gallons) as Tot_Fuel,
 sum(C.Char_Distance * M.Mod_chg_mile) as Revenue
from dw.Charter C, dw.Model M, dw.Aircraft A
where C.AC_Number=A.AC_Number and A.Mod_Code=M.Mod_Code
group by C.Char_Pilot, M.Mod_Code, to_char(C.Char_Date, 'YYYYMM');

-- See the records of copilot 101
select *
from charter_fact2
where emp_num=101
order by time_id;

-- How many records are there in both fact tables
select count(*) from charter_fact;
select count(*) from charter_fact2;
select count(*) from charter_fact where emp_num = 101;
select count(*) from charter_fact2 where emp_num = 101;

-- Combine two star schemas
select * from charter_fact
union
select * from charter_fact2;

-- Merging two fact tables
create table charter_fact3 as
select time_id,
 mod_code,
 emp_num,
 sum(tot_char_hours) as tot_char_hours,
 sum(tot_fuel) as tot_fuel,
 sum(revenue) as revenue
from (
 select * from charter_fact
 union
 select * from charter_fact2)
group by time_id, mod_code, emp_num;


-- ??
select m.mod_code, count(*) 
from dw.model m
group by m.mod_code
having count(*) > 1;


-- How many records are there in the 3 fact tables
select count(*) from charter_fact;
select count(*) from charter_fact2;
select count(*) from charter_fact3;

-- Employee 101 
select *
from charter_fact
where emp_num=101
order by time_id;

select *
from charter_fact2
where emp_num=101
order by time_id;

select *
from charter_fact3
where emp_num=101
order by time_id;

-- Only correct when the emp_num is pilot and co-pilot

-- Fact measures of pilots and co-pilots from two facts
select emp_num, sum(tot_char_hours), sum(tot_fuel), sum(revenue)
from charter_fact
group by emp_num
order by emp_num;

select emp_num, sum(tot_char_hours), sum(tot_fuel), sum(revenue)
from charter_fact2
group by emp_num
order by emp_num;

-- 8)
-- Merge the above two facts by only taking emp_num dimension
create table charter_fact3b as
select emp_num,
 sum(tot_char_hours) as tot_char_hours,
 sum(tot_fuel) as tot_fuel,
 sum(revenue) as revenue
from (
 select * from charter_fact
 union
 select * from charter_fact2)
group by emp_num
order by emp_num;

-- Or

create table charter_fact3b as
select emp_num,
 sum(tot_char_hours) as tot_char_hours,
 sum(tot_fuel) as tot_fuel,
 sum(revenue) as revenue
from (
 select emp_num,
 sum(tot_char_hours) as tot_char_hours,
 sum(tot_fuel) as tot_fuel,
 sum(revenue) as revenue
 from charter_fact
 group by emp_num
 union
 select emp_num,
 sum(tot_char_hours) as tot_char_hours,
 sum(tot_fuel) as tot_fuel,
 sum(revenue) as revenue
 from charter_fact2
 group by emp_num)
group by emp_num
order by emp_num;

select * from charter_fact3b;

-- 
create table charter_fact3c as
select emp_num, sum(tot_char_hours) as tot_char_hours
from (
 select * from charter_fact
 union
 select * from charter_fact2)
group by emp_num
order by emp_num;

-- Query first two charter facts directly
select emp_num, sum(tot_char_hours) as tot_char_hours
from (
 select * from charter_fact
 union
 select * from charter_fact2)
group by emp_num
order by emp_num;






-- 7)
-- Relationship problems, missing data, inconsistencies and incorrect value

-- 8)
-- Answer business need; The question did not ask us to differentiate copilot and pilot


-- May not reflect the total hours flown by each pilot

-- Missing info as 
-- NO totalco_char_pilot


-- PART B: Data Cleaning and Exploration of Star Schema -- 