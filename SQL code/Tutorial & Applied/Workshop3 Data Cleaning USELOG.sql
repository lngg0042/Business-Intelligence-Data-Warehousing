---- DATA CLEANING- USELOG----
select * from dw.student;
select * from dw.major;
select * from dw.class;
select * from dw.uselog;

select COUNT(*) from dw.student;

 --first create the dimensions 
--create semester dimension 
create table semesterDIM 
(SemID      varchar2(10), 
 Sem_Desc   varchar2(20), 
 begin_date date, 
 end_date   date); 

-- create time dimension (note do not use time as a -- table name, it is a reserve keyword) 
create table labtimeDIM 
(TimeID     number, 
Time_Desc   varchar2(15), 
begin_time  date, 
end_time    date);

-- create major and class dimensions 
create table majorDIM as 
select * from dw.major; 

create table classDIM as 
select * from dw.class;

-- the above tables are made in my own account, so we don't need to write dw. again.
select * from classDIM; -- just checking if the class dimension is made correctly

-- populate semester dimension  
-- (the begin and end date can be changed)
insert into semesterDIM values ('S1', 'Semester1', 
to_date('01-JAN', 'DD-MON'), to_date('15-JUL', 'DD-MON')); 
insert into semesterDIM values ('S2', 'Semester2', 
to_date('16-JUL', 'DD-MON'), to_date('31-DEC', 'DD-MON')); --populate labtime dimension 
insert into labtimeDIM values(1, 'morning', to_date('06:01', 
'HH24:MI'), to_date('12:00', 'HH24:MI')); 
insert into labtimeDIM values(2, 'afternoon', to_date('12:01', 
'HH24:MI'), to_date('18:00', 'HH24:MI')); 
insert into labtimeDIM values(3, 'night', to_date('18:01', 
'HH24:MI'), to_date('06:00', 'HH24:MI'));

-- NOTICE: We havent created any primary or foreign key. This is a passive datahouse ware, this is a consistent datahouse, we do not need it. 
--         we only need it in active data waregouses

-- secondly, create a temp table to extract from uselog table 
create table tempfact_uselog as 
select U.log_date , U.log_time, 
U.student_ID, S.class_id, S.major_code 
from dw.uselog U, dw.student S 
where U.student_id = S.student_id; 

SELECT TO_CHAR(Log_Date, 'DD-MM-YYYY'),
TO_CHAR(Log_Time, 'HH24:MM'),
Student_ID, Class_ID, Major_Code
from tempfact_Uselog;

-- add a column in the tempfact table to store timeid 
-- (cannot directly do this in the tempfact table because
-- log_time was of DATE type and timeid is of NUMBER type). 
alter table tempfact_uselog 
add (timeid number); 
update tempfact_uselog 
set timeid = 1 
where  to_char(log_time, 'HH24:MI') >= '06:01' 
and to_char(log_time, 'HH24:MI') <='12:00'; 
-- 62832 rows update

update tempfact_uselog 
set timeid = 2 
where  to_char(log_time, 'HH24:MI') >= '12:01' 
and to_char(log_time, 'HH24:MI') <='18:00'; 
-- 76113 rows updated. 

-- note that we use OR in the last update statement to -- include the time between 18:01 and 06:00. 
update tempfact_uselog 
set timeid = 3 
where to_char(log_time, 'HH24:MI') >= '18:01' 
or to_char(log_time, 'HH24:MI') <='06:00'; 
-- 31665 rows updated. 

-- alternatively, you may want to update timeid=3 
 -- for all other records where the time_id is still empty 
    -- update tempfact_uselog 
    -- set timeid = 3 
    -- where timeid is NULL; 


 -- add a column in the tempfact_uselog table to store semid 
 -- (cannot directly do this in the test table because 
 -- log_date was of DATE type and semid is of VARCHAR type.) 
alter table tempfact_uselog 
add (semid varchar2(10)); -- populate the new attribute semid by summarizing 
-- the date(log_date) 
update tempfact_uselog 
set semid = 'S1' 
where to_char(log_date, 'MMDD') >= '0101' 
and to_char(log_date, 'MMDD') <= '0715'; -- 91188 rows updated. 

update tempfact_uselog 
set semid = 'S2' 
where to_char(log_date, 'MMDD') >= '0716' 
and to_char(log_date, 'MMDD') <= '1231'; 
-- 79422 rows updated.

-- Now, create the fact table,
-- make sure to include the TOTAL aggregate. 
-- This is an aggregate table of the earlier tempfact table. 
create table fact_uselog as 
select t.semid, t.timeid, t.class_id, t.major_code, 
count(t.student_id) as total_usage 
from tempfact_uselog t 
group by t.semid, t.timeid, t.class_id, t.major_code;

select * from fact_uselog;


--- PART B ---

--There are several questions that you need to ask yourself about the data: 
--  1. How many records in the operational database? 
--  2. How many records in the data warehouse? 
--  3. What kind of data is in the operational database? 
--  4. How do the tables look like in the data warehouse?

-- Basic data exploration:
Select count(*) from dw.student; 
     --37951 
Select count(*) from dw.uselog; 
    -- 108267 
Select count(*) from dw.major;  
    --  172 
Select count(*) from dw.class;  
    --   10 


-- What does ... look like?
Select * from dw.student;
Select * from dw.uselog;
Select * from dw.major;
Select * from dw.class;


-- 9)
-- temp fact table and fact uselog table check
Select count(*) from tempfact_uselog;  -- 170610
Select count(*) from fact_uselog; --1363


-- Cleaning dirty data in dw.student to not have duplicate records
-- In assignment, we need to clean the dirty data ourselves too
select count(DISTINCT student_id)
FROM DW.Student;

SELECT Student_ID, COUNT(*)
FROM DW.student
Group by student_ID
HAVING COUNT(*)>1;

DROP TABLE Student CASCADE CONSTRAINT PURGE;

CREATE TABLE Student
AS SELECT DISTINCT *
FROM DW.STUDENT;


create table tempfact_uselog as
select U.log_date , U.log_time,
U.student_ID, S.class_id, S.major_code
from dw.uselog U, dw.student S
where U.student_id = S.student_id;

-- there is problem in tempfact_uselog as it has 62343 more records
-- It should be 108267 rather than 170610 records
Select count(*) from tempfact_uselog;  -- 170610

-- Check visually
Select * from dw.uselog;
Select * from tempfact_uselog;

-- Or, rather:
-- 12)
-- content dw.uselog from operational database
Select log_date, 
to_char(log_time, 'HH24:MI') as log_time,
student_ID, act
From dw.uselog;

-- content from data warehousing
Select log_date,
to_char(log_time, 'HH24:MI') as log_time,
student_ID
From tempfact_uselog; -- duplicate student ID having the same log time
	  
select *
from dw.student
where dw.student.student_id = '38RVRR377'; -- exists twice

-- Many students duplicated
select student_id, COUNT(*)
from dw.student
group by student_id
having count(*) > 1;


--- PART C ---
-- RESOLVE: Add DISTINCT
DROP TABLE tempfact_uselog2 CASCADE CONSTRAINT PURGE;

create table tempfact_uselog2 as
select distinct U.log_date, U.log_time, U.student_ID, S.class_id, S.major_code
from dw.uselog U, dw.student S
where U.student_id = S.student_id;


-- check if there are illegal students in dw.uselog
select * from dw.uselog
where student_id NOT IN
(select student_id from dw.student);
-- no rows selected


-- check if there are illegal majors in dw.student
select *
from dw.uselog, dw.student
where dw.uselog.student_id = dw.student.student_id
and dw.student.major_code NOT IN
 (select major_code from dw.major);
-- no rows selected


-- check if there are invalid class in dw.student
select *
from dw.uselog, dw.student
where dw.uselog.student_id = dw.student.student_id
and dw.student.class_id NOT IN
 (select class_id from dw.class);
-- no rows selected


-- check if there are records in uselog not in tempfact_uselog
select *
from dw.uselog
where log_date NOT IN
 (select log_date from tempfact_uselog)
and log_time NOT IN
 (select log_time from tempfact_uselog)
and student_id NOT IN
 (select student_id from tempfact_uselog);
-- no rows selected


-- dw.uselog incorrect 108267
-- tempfact_uselog2 correct 108261 
select
 to_char(log_time, 'HH24:MI') log_time,
 log_date,
 student_id,
 act,
 count(*)
from dw.uselog
group by log_time, log_date, student_id, act
having count(*) > 1;



-- 18)
alter table tempfact_uselog2
add (timeid number);
update tempfact_uselog2
set timeid = 1
where to_char(log_time, 'HH24:MI') >= '06:01'
and to_char(log_time, 'HH24:MI') <='12:00';
-- 39921 rows updated.

-- 19)
update tempfact_uselog2
set timeid = 2
where to_char(log_time, 'HH24:MI') >= '12:01'
and to_char(log_time, 'HH24:MI') <='18:00';
-- 48261 rows updated.

-- 20)
update tempfact_uselog2
set timeid = 3
where to_char(log_time, 'HH24:MI') >= '18:01'
or to_char(log_time, 'HH24:MI') <='06:00';
-- 20079 rows updated.

-- 21)
alter table tempfact_uselog2
add (semid varchar2(10));
update tempfact_uselog2
set semid = 'S1'
where to_char(log_date, 'MMDD') >= '0101'
and to_char(log_date, 'MMDD') <= '0715';
-- 57612 rows updated.

-- 22)
update tempfact_uselog2
set semid = 'S2'
where to_char(log_date, 'MMDD') >= '0716'
and to_char(log_date, 'MMDD') <= '1231';
-- 50649 rows updated.


create table fact_uselog2 as
select t.semid, t.timeid, t.class_id,
t.major_code, count(t.student_id) as total_usage
from tempfact_uselog2 t
group by t.semid, t.timeid, t.class_id, t.major_code;

--fact table before data cleaning process
select *
from fact_uselog
order by semid, timeid, class_id, major_code;

--fact table after data cleaning process
select *
from fact_uselog2
order by semid, timeid, class_id, major_code;


select log_date, to_char(log_time, 'HH24:MI'), student_id,
class_id, major_code, timeid, semid
from tempfact_uselog
where semid = 'S2'
and timeid=3 and major_code='UNIL'
order by log_date;

--query a) answer
select u.timeid, l.time_desc, sum(u.total_usage)
from fact_uselog2 u, labtimeDIM l
where u.timeid = l.timeid
group by u.timeid, l.time_desc;


--query b) answer
select u.timeid, u.major_code, u.class_id, sum(u.total_usage)
from fact_uselog2 u
group by u.timeid, u.major_code, u.class_id;
-- 773 rows

--alternative solution which gives more meaningful results
select t.time_desc, m.major_name, c.class_description, sum(u.total_usage)
from fact_uselog2 u, majorDIM m, classDIM c, labtimeDIM t
where u.major_code = m.major_code
and u.class_id = c.class_id
and u.timeid = t.timeid
group by t.time_desc, m.major_name, c.class_description;
-- 722 rows

select * from MajorDIM; -- Same description hence alternative solution not accurate

--query c) answer
select u.major_code, u.semid, sum(u.total_usage)
from fact_uselog2 u
group by u.major_code, u.semid;
-- 207 rows selected.