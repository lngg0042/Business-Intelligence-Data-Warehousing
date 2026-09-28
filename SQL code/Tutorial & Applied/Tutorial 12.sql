drop table student;
drop table labactivities;
drop table degree;
drop table computer;

create table student
as select * 
from chapter18.student;

create table labactivities
as select * 
from chapter18.labactivities;

--showed L02 to L09
select * from labactivities;

create table degree
as select * 
from chapter18.degree;

create table computer
as select * 
from chapter18.computer;

--Level 0
-- Dimension tables
drop table loginDateDIM cascade constraints purge;
drop table LoginTimeDim cascade constraints purge;
drop table DegreeDim cascade constraints purge;
drop table StudentDim cascade constraints purge ;


create table LoginDateDim as
select distinct(LoginDate)
from LabActivities;

create table LoginTimeDim as
select distinct(LoginTime)
from LabActivities;
    
create table DegreeDim as
select DegreeCode, DegreeName, DegreeDuration
from Degree;
    
create table StudentDim as
select StudentNo, FirstName, LastName, Gender, StudyType
from Student;

-- create trigger in Student table to update StudentDim table
-- drop trigger InsertNewStudent;
drop trigger InsertNewStudent;

create or replace trigger InsertNewStudent
  after insert on Student
  for each row
  declare pragma autonomous_transaction;
begin
  insert into StudentDim
  values (:new.StudentNo, :new.FirstName, :new.LastName,
    :new.Gender, :new.StudyType);
    commit;
end InsertNewStudent;
/

-- Fact table: ComputerLabFactLevel0
drop table ComputerLabFactLevel0;

create table ComputerLabFactLevel0 as
select distinct
  LoginDate, LoginTime,
  S.DegreeCode, L.StudentNo,
  count(L.StudentNo) as Num_of_Logins
from Student S, LabActivities L
where S.StudentNo = L.StudentNo
group by
  LoginDate, LoginTime,
  S.DegreeCode, L.StudentNo;
  
-- create trigger in LabActivities table to update ComputerLabFactLevel0 table
drop trigger UpdateFactLevel0;

create or replace trigger UpdateFactLevel0
  after insert on LabActivities
  for each row
  declare
    Degree Student.DegreeCode%type;
begin
  select DegreeCode into Degree
  from Student
  where StudentNo = :new.StudentNo;
  
  insert into ComputerLabFactLevel0
  values (:new.LoginDate, :new.LoginTime,
    Degree, :new.StudentNo, 1);
end UpdateFactLevel0;
/


-- PK, FK constraint
alter table DegreeDim
add constraint DegreeDimPK primary key (DegreeCode);
    
alter table StudentDim
add constraint StudentDimPK primary key (StudentNo);

--The reason why no PK&FK constraints for loginDateDIM,loginTimeDIM
--check book ch18,page 457.PK-FK Constraints. It is very important. :) 
/*For simplicity, Login Date Dimension and Login Time
Dimension are removed from the star schema (because they are one-attribute
dimensions), and consequently, LoginDate and LoginTime attributes in the fact
become non-dimensional keys. A PK constraint is only added to the Degree Dimension and Student Dimension.
The star schema level 0 is used for demonstration purposes only -- loginDateDIM & loginTimeDIM*/
--Arthur 04/05/2022
alter table ComputerLabFactLevel0
add constraint DegreeDimFK foreign key (DegreeCode)
references DegreeDim (DegreeCode);
    
alter table ComputerLabFactLevel0
add constraint StudentDimFK foreign key (StudentNo)
references StudentDim (StudentNo);
    
alter table ComputerLabFactLevel0
add constraint FactPK
primary key (LoginDate, LoginTime, DegreeCode, StudentNo);

--level 1
--degreeDIM and studentDIM are the same as level 0
/*
create table DegreeDim as
select DegreeCode, DegreeName, DegreeDuration
from Degree;
    
create table StudentDim as
select StudentNo, FirstName, LastName, Gender, StudyType
from Student;
*/
/*
  drop table DegreeDim;
  drop table StudentDim;
  drop table SemesterDim;
  drop table TimePeriodDim;
  drop table TempComputerLabFactLevel1;
  drop table ComputerLabFactLevel1;
*/
-- Dimension tables
drop table SemesterDim cascade constraints purge;
drop table TimePeriodDim cascade constraints purge;

create table SemesterDim
(  
  SemesterID           varchar2(10),
  SemesterDescription  varchar2(20),
  StartDate            date,
  EndDate              date,
  constraint SemesterDimPK primary key (SemesterID)
);

insert into SemesterDim
values ('S1', 'Semester 1',
  to_date('01-JAN', 'DD-MON'), to_date('15-JUL', 'DD-MON'));
  
insert into SemesterDim
values ('S2', 'Semester 2',
  to_date('16-JUL', 'DD-MON'), to_date('31-DEC', 'DD-MON'));

create table TimePeriodDim
(
  TimeID            varchar2(10),
  TimeDescription   varchar2(15),
  StarTime          date,
  EndTime           date,
  constraint TimePeriodDimPK primary key (TimeID)
);

insert into TimePeriodDim 
values('1', 'Morning',
  to_date('06:00', 'HH24:MI'), to_date('11:59', 'HH24:MI'));
  
insert into TimePeriodDim 
values('2', 'Afternoon',
  to_date('12:00', 'HH24:MI'), to_date('17:59', 'HH24:MI'));
  
insert into TimePeriodDim 
values('3', 'Night',
  to_date('18:00', 'HH24:MI'), to_date('05:59', 'HH24:MI'));

-- Temp Fact table: TempComputerLabFactLevel1
drop table TempComputerLabFactLevel1;

create table TempComputerLabFactLevel1 as
select distinct
  LoginTime, LoginDate,
  S.DegreeCode, L.StudentNo
from Student S, LabActivities L
where S.StudentNo = L.StudentNo;

alter table TempComputerLabFactLevel1
add (SemesterID varchar2(10));

update TempComputerLabFactLevel1
set SemesterID = 'S1'
where to_char(LoginDate, 'MM/DD') >= '01/01'
and to_char(LoginDate, 'MM/DD') <= '07/15';

update TempComputerLabFactLevel1
set SemesterID = 'S2'
where to_char(LoginDate, 'MM/DD') >= '07/16'
and to_char(LoginDate, 'MM/DD') <= '12/31';

alter table TempComputerLabFactLevel1
add (TimeID varchar2(10));

update TempComputerLabFactLevel1
set TimeID = '1'
where to_char(LoginTime, 'HH24:MI') >= '06:00'
and to_char(LoginTime, 'HH24:MI') < '12:00';

update TempComputerLabFactLevel1
set TimeID = '2'
where to_char(LoginTime, 'HH24:MI') >= '12:00'
and to_char(LoginTime, 'HH24:MI') < '18:00';

update TempComputerLabFactLevel1
set TimeID = '3'
where to_char(LoginTime, 'HH24:MI') >= '18:00'
or to_char(LoginTime, 'HH24:MI') < '06:00';

select * from TempComputerLabFactLevel1;

-- create trigger in ComputerLabFactLevel0 table to update TempComputerLabFactLevel1 table
drop trigger UpdateTempFactLevel1;

create or replace trigger UpdateTempFactLevel1
  after insert on ComputerLabFactLevel0
  for each row
  declare
  TempSemesterID     SemesterDim.SemesterID%type;
  TempTimeID         TimePeriodDim.TimeID%type;
  
begin
  if (to_char(:new.LoginDate, 'MM/DD') >= '01/01')
    and (to_char(:new.LoginDate, 'MM/DD') <= '07/15') then
    TempSemesterID := 'S1';
  else
    TempSemesterID := 'S2';
  end if;

  if (to_char(:new.LoginTime, 'HH24:MI') >= '06:00')
    and (to_char(:new.LoginTime, 'HH24:MI') < '12:00') then
    TempTimeID := '1';
  elsif (to_char(:new.LoginTime, 'HH24:MI') >= '12:00')
    and (to_char(:new.LoginTime, 'HH24:MI') < '18:00') then
    TempTimeID := '2';
  else
    TempTimeID := '3';
  end if;
  
  insert into TempComputerLabFactLevel1
  values (:new.LoginTime, :new.LoginDate,
  :new.DegreeCode, :new.StudentNo, TempSemesterID, TempTimeID);
  
end UpdateTempFactLevel1;
/

-- Final Fact table : ComputerLabFactLevel1
drop table ComputerLabFactLevel1;

create table ComputerLabFactLevel1 as
select 
  SemesterID, TimeID, DegreeCode, StudentNo,
  count(StudentNo) as Num_of_Logins
from TempComputerLabFactLevel1
group by SemesterID, TimeID, DegreeCode, StudentNo;

-- create trigger in TempComputerFactLabLevel1 table to update ComputerLabFactLevel1 table
-- drop trigger UpdateFactLevel1;
drop trigger UpdateFactLevel1;

create or replace trigger UpdateFactLevel1
  after insert on TempComputerLabFactLevel1 -- runs after new record is inserted into the table
  for each row
  declare
    IsFound number; -- count of existing matching records in another table
begin
  select count(*) into IsFound
  from ComputerLabFactLevel1
  where  SemesterID = :new.SemesterID
    and TimeID = :new.TimeID
    and DegreeCode = :new.DegreeCode
    and StudentNo = :new.StudentNo;

  if IsFound <> 0 then -- if matching records does exists
    -- existing row is updated, Num_of_Logins increases by 1
    update ComputerLabFactLevel1
    set Num_of_Logins = Num_of_Logins + 1
    where SemesterID = :new.SemesterID
      and TimeID = :new.TimeID
      and DegreeCode = :new.DegreeCode
      and StudentNo = :new.StudentNo;
  else
    -- if no matching record is found, then the trigger inserts a new row
    insert into ComputerLabFactLevel1 
    values (:new.SemesterID, :new.TimeID, :new.DegreeCode, :new.StudentNo, 1); 
   end if;
end UpdateFactLevel1;
/

-- PK, FK constraint
alter table ComputerLabFactLevel1
add constraint SemesterDimFK foreign key (SemesterID)
references SemesterDim (SemesterID);

alter table ComputerLabFactLevel1
add constraint TimePeriodDimFK foreign key (TimeID)
references TimePeriodDim (TimeID);

alter table ComputerLabFactLevel1
add constraint DegreeDim1FK foreign key (DegreeCode)
references DegreeDim (DegreeCode);

alter table ComputerLabFactLevel1
add constraint StudentDim1FK foreign key (StudentNo)
references StudentDim (StudentNo);

alter table ComputerLabFactLevel1
add constraint Fact1PK 
primary key (SemesterID, TimeID, DegreeCode, StudentNo);

--level 2
-- Level 2 Star Schema 
/*
  drop table DegreeDim;
  drop table SemesterDim;
  drop table TimePeriodDim;
  drop view ComputerLabFactLevel2;
*/
-- Dimension tables
----degreeDIM,TimeperiodDIM and semesterDIM are the same as level 1
/*create table DegreeDim as
select DegreeCode, DegreeName, DegreeDuration
from Degree;

create table SemesterDim
(  
  SemesterID           varchar2(10),
  SemesterDescription  varchar2(20),
  StartDate            date,
  EndDate              date,
  constraint SemesterDimPK primary key (SemesterID)
);

insert into SemesterDim
values ('S1', 'Semester 1',
  to_date('01-JAN', 'DD-MON'), to_date('15-JUL', 'DD-MON'));
  
insert into SemesterDim
values ('S2', 'Semester 2',
  to_date('16-JUL', 'DD-MON'), to_date('31-DEC', 'DD-MON'));


create table TimePeriodDim
(
  TimeID            varchar2(10),
  TimeDescription   varchar2(15),
  StarTime          date,
  EndTime           date,
  constraint TimePeriodDimPK primary key (TimeID)
);

insert into TimePeriodDim 
values('1', 'Morning',
  to_date('06:00', 'HH24:MI'), to_date('11:59', 'HH24:MI'));
  
insert into TimePeriodDim 
values('2', 'Afternoon',
  to_date('12:00', 'HH24:MI'), to_date('17:59', 'HH24:MI'));
  
insert into TimePeriodDim 
values('3', 'Night',
  to_date('18:00', 'HH24:MI'), to_date('05:59', 'HH24:MI'));
*/

-- Fact table : ComputerLabFactLevel2 
drop view ComputerLabFactLevel2;

create or replace view ComputerLabFactLevel2 as
select SemesterID, TimeID, DegreeCode,
  sum(Num_of_Logins) as Num_of_Logins
from ComputerLabFactLevel1
group by SemesterID, TimeID, DegreeCode;

--test insert one change all
insert into Student values ('S08','Tony','Liu','Male',
to_date('13/08/1994','dd/mm/yyyy'),'Full Time','D03');

select * from student;
COMMIT;

-- Test : insert two new records in LabActivities Table:S1(semesterID),3(timeid),D03(degreeCode)


INSERT INTO labactivities VALUES (
    'L12',
    'S08',
    TO_DATE('01/03/2020', 'dd/mm/yyyy'),
    TO_DATE('01/03/2020 18:16:43','dd/mm/yyyy hh24:mi:ss'),
    'C02'
);


select * from LabActivities;

--select * from LabActivities;

select * from COMPUTERLABFACTLEVEL0;

select * from ComputerLabFactLevel1;

select * from ComputerLabFactLevel2;