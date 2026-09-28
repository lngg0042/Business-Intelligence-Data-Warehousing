-- Lab 02a

CREATE TABLE SUBJECT2 (
    Ucode VARCHAR2(10) NOT NULL,
    Utitle VARCHAR2(20) NOT NULL,
    Ucredit NUMBER(2),
    PRIMARY KEY (Ucode)
);

INSERT INTO SUBJECT2 VALUES('IT001', 'Database', 5);
INSERT INTO SUBJECT2 VALUES('IT002', 'Java', 5);
INSERT INTO SUBJECT2 VALUES('IT003', 'SAP', 10);
INSERT INTO SUBJECT2 VALUES('IT004', 'Network', 5);
INSERT INTO SUBJECT2 VALUES('IT005', 'ASP.net', 5);

Create Table STUDENT2
As Select *
From dtaniar.STUDENT2;

desc student2;
describe student2;

select * from student2;

-- e)
Insert Into STUDENT2 Values ('10008', 'Miller', 'Larry', 'M', to_date('22-07-1973', 'DD-MM-YYYY'), 211);
Insert Into STUDENT2 Values ('10009', 'Smith', 'Leonard', 'M', to_date('26-05-1985', 'DD-MM-YYYY'), 211);
Insert Into STUDENT2 Values ('10010', 'Brown', 'Menson', 'M', to_date('12-07-1983', 'DD-MM-YYYY'), 112);
-- Or
insert ALL 
    into STUDENT2
    VALUES ('10008','Miler','Larry','M', to_date('22-Jul-73','DD-MON-YY'),211)
    into STUDENT2
    VALUES ('10009','Smith','Leonard','M', to_date('26-May-85','DD-MON-YY'),211)
    into STUDENT2
    VALUES ('10010','Brown','Menson','M', to_date('12-Jul-83','DD-MON-YY'),112)
select * from dual;

-- Dummy table that Oracle users can use when running queries not based on actual table
select * from dual;

-- f)
Create Table OFFERING2
As Select *
From dtaniar.OFFERING2;

Create Table ENROLLMENT2
As Select *
From dtaniar.ENROLLMENT2;

-- g)
-- 1)
select count(st.sid) as Number_of_student
from Student2 st, Offering2 o, Enrollment2 e, Subject2 s
where st.SID = e.SID
and e.OID = o.OID
and s.Ucode = o.Ucode
and o.Ocampus = 'Main'
and s.Utitle = 'Database';
-- Or
select count(st.sid) as Number_of_student
from Student2 st, Offering2 o, Enrollment2 e, Subject2 s
where st.SID = e.SID
and e.OID = o.OID
and s.Ucode = o.Ucode
and o.Ocampus = 'Main'
and s.Utitle = 'Database';


-- 2)
select sum(e.score) as TotalScore
from Offering2 o, Enrollment2 e, Subject2 s
where e.OID = o.OID
and s.Ucode = o.Ucode
and o.Ocampus = 'Main'
and s.Utitle = 'Database';
-- Or
select SUM(e.score) as Total_score
from Offering2 o join Enrollment2 e on e.OID = o.OID 
join Subject2 s on s.Ucode = o.Ucode
where o.Ocampus = 'Main'
and s.Utitle = 'Database';

-- 3)
select count(*) as Number_of_student
from Offering2 o, Enrollment2 e, Subject2 s
where e.OID = o.OID
and s.Ucode = o.Ucode
and o.oyear = 2009
and o.osem = 2
and s.Utitle = 'Java';
-- Or
select count(st.sid) as Number_of_student
from Student2 st join Enrollment2 e on st.SID = e.SID
join Offering2 o on e.OID = o.OID join Subject2 s on s.Ucode = o.Ucode
where s.Utitle = 'Java'
and o.Osem = 2
and o.Oyear = 2009;

-- 4)
select SUM(e.score) as Total_score
from Offering2 o, Enrollment2 e, Subject2 s
where e.OID = o.OID
and s.Ucode = o.Ucode
and s.Utitle = 'Java'
and o.Osem = 2
and o.Oyear = 2009;

-- 5)
select count(*) as Number_of_student
from Offering2 o, Enrollment2 e, Subject2 s
where e.OID = o.OID
and s.Ucode = o.Ucode
and e.Grade = 'HD'
and s.Utitle = 'SAP'
and o.Osem = 1
and o.Oyear = 2009;
 -- OR
select count(st.sid) as Number_of_student
from Student2 st, Offering2 o, Enrollment2 e, Subject2 s
where st.SID = e.SID
and e.OID = o.OID
and s.Ucode = o.Ucode
and e.Grade = 'HD'
and s.Utitle = 'SAP'
and o.Osem = 1
and o.Oyear = 2009;

-- h)
-- star schema

-- i)
--Campus dimension
Create table campus_dim as
SELECT distinct Ocampus
FROM Offering2;

--Semester_year dimension
Create table sem_year_dim as
SELECT distinct Oyear||Osem as sem_id, Oyear, Osem
FROM Offering2;

--Subject Dimension
Create table subject_dim as
SELECT *
FROM subject2;

--Grade Dimension
Create table grade_dim as
SELECT distinct Grade
FROM Enrollment2;

-- j)
create table student_enrollment_fact as
SELECT o.Ocampus, o.Oyear||o.Osem as sem_id, s.Ucode, e.Grade,
count(st.sid) as num_of_student, sum(e.score) as Total_score
FROM subject2 s, enrollment2 e, offering2 o, student2 st
WHERE e.OID = o.OID
and s.Ucode = o.Ucode
and st.SID = e.SID
GROUP BY o.Ocampus, o.Oyear||o.Osem, s.Ucode, e.Grade;
-- Or
create table student_enrollment_fact as
SELECT o.Ocampus, o.Oyear||o.Osem as sem_id, s.Ucode, e.Grade,
count(e.sid) as num_of_student, sum(e.score) as Total_score
FROM subject2 s, enrollment2 e, offering2 o
WHERE e.OID = o.OID
and s.Ucode = o.Ucode
GROUP BY o.Ocampus, o.Oyear||o.Osem, s.Ucode, e.Grade;
-- Or
create table student_enrollment_fact as
SELECT o.Ocampus, o.Oyear||o.Osem as sem_id, o.Ucode, e.Grade,
count(e.sid) as num_of_student, sum(e.score) as Total_score
FROM enrollment2 e, offering2 o
WHERE e.OID = o.OID
GROUP BY o.Ocampus, o.Oyear||o.Osem, o.Ucode, e.Grade;


-- k)
-- don't use avg function?
SELECT s.utitle, sum(f.Total_score)/sum(f.num_of_student) as Avg_score
from student_enrollment_fact f, subject_dim s, sem_year_dim y
WHERE f.ucode = s.ucode
AND f.sem_id = y.sem_id
AND y.oyear = 2009
Group by s.utitle;

-- l)
SELECT s.utitle, sum(f.Total_score)/sum(f.num_of_student) as Avg_score
from student_enrollment_fact f, subject_dim s, campus_dim c
WHERE f.ucode = s.ucode
AND f.ocampus = c.ocampus
AND c.ocampus = 'Main'
Group by s.utitle;

-- m)
SELECT s.utitle, sum(f.Total_score)/sum(f.num_of_student) as Avg_score
from student_enrollment_fact f, subject_dim s, grade_dim g
WHERE f.ucode = s.ucode
AND f.grade = g.grade
AND s.utitle = 'Database'
AND g.grade = 'N'
Group by s.utitle;

------- LAB O2B -------
-- PART I
/*
  drop table AgentDim;
  drop table CountryDim;
  drop table CourseDim;
  drop table YearDim;
  drop table CollegeFact;
*/

-- Agent Dimension
create table AgentDim as
select * from opdb.Agent;

select * from AgentDim;

--Country Dimension
create table CountryDim as 
select distinct Country
from opdb.Student;

select * from CountryDim;

--Course Dimension
create table CourseDim as
select CourseCode, CourseName, Duration, CourseLevel
from opdb.Course;

select * from CourseDim;

--Year Dimension
create table YearDim as
select distinct EnrolmentYear
from opdb.Enrolment;

select * from YearDim;

--Fact Table
create table CollegeFact as
select
  S.Country,
  E.AgentNo,
  E.CourseCode,
  E.EnrolmentYear,
  count(p.PaymentNo) as Number_of_payments,
  sum(P.Amount) as Total_Income
from opdb.Student S, opdb.Enrolment E, opdb.Payment P
where E.EnrolmentNo = P.EnrolmentNo
  and E.StudentID = S.StudentID
group by
  S.Country,
  E.AgentNo,
  E.CourseCode,
  E.EnrolmentYear;
  
select * from CollegeFact;

-- Tasks (not sure if is correct)
-- a
-- Wrong
select sum(f.Total_Income) as Australia_Total_Income
from CountryDim c, CollegeFact f
where f.country = c.country 
and f.country = 'Australia';
-- Correct
select country,sum(Total_income) as total_income
from CollegeFact
where upper(country) = upper('Australia')
group by country;


-- b
-- Wrong
select c.coursename, sum(total_income) as total_income
from coursedim c, CollegeFact f
where c.coursecode = f.coursecode
group by c.coursename;
-- Correct
select f.coursecode,c.courseName,sum(Total_income) as total_income
from CollegeFact f join courseDIM c on f.coursecode = c.coursecode
group by f.coursecode,c.courseName;


-- c
-- Wrong
select sum(f.total_income) as total_income
from YearDim y, coursedim c, collegefact f
where c.coursename = 'Master of Data Science'
and c.coursecode = 'C6003'
and c.coursecode = f.coursecode
and f.enrolmentyear = y.enrolmentyear
and y.ENROLMENTYEAR = 2019
group by coursename;
-- Correct
select EnrolmentYear, CourseCode, sum(Total_Income) as Total_Income
from CollegeFact
where EnrolmentYear = 2019 and
	CourseCode = 'C6003'
group by EnrolmentYear, CourseCode;


-- d
select a.agentname, sum(f.total_income) as total_income
from collegefact f, agentdim a
where a.agentname = 'New Star Agent' and a.agentno = c.agentno
group by a.agentname;


-- PART II
/*
  drop table ProdCategoryDim;
  drop table BranchDim;
  drop table TimeDim;
  drop table TempFact;
  drop table SalesFact;
*/

-- ProdCategory Dimension
create table ProdCategoryDim as
select * from opdb.Category;

select * from ProdCategoryDim;

-- Branch Dimension
create table BranchDim as
select * from opdb.Branch;

select * from BranchDim;

--Time Dimension 
create table TimeDim
(
  Quarter number(1),
  Description varchar2(20)
);

insert into TimeDim values (1, 'Jan-Mar');
insert into TimeDim values (2, 'Apr-Jun');
insert into TimeDim values (3, 'Jul-Sep');
insert into TimeDim values (4, 'Oct-Dec');

select * from TimeDim;

-- TempFact Table (manually created TimeDim)
create table TempFact as
select S.SalesDate, B.BranchID, C.CategoryID, S.TotalPrice
from opdb.Branch B, opdb.Sales S, opdb.Product P, opdb.Category C
where B.BranchID = S.BranchID
and S.ProductNo = P.ProductNo
and P.CategoryID = C.CategoryID;

alter table TempFact
add (Quarter number(1));

update TempFact
set Quarter = 1
where to_char(SalesDate, 'MM') >= '01'
and to_char(SalesDate, 'MM') <= '03';

update TempFact
set Quarter = 2
where to_char(SalesDate, 'MM') >= '04'
and to_char(SalesDate, 'MM') <= '06';

update TempFact
set Quarter = 3
where to_char(SalesDate, 'MM') >= '07'
and to_char(SalesDate, 'MM') <= '09';

update TempFact
set Quarter = 4
where Quarter is null;

select * from TempFact;

-- SalesFact Table
create table SalesFact as
select Quarter, BranchID, CategoryID,
sum(TotalPrice) as Total_Sales
from TempFact
group by Quarter, BranchID, CategoryID;

select * from SalesFact;

-- Tasks
-- a
select Quarter, sum(Total_Sales) as Total_Sales
from SalesFact
group by Quarter;


-- b
select BranchID, CategoryID, sum(Total_Sales) as Total_Sales
from SalesFact
group by BranchID, CategoryID;

-- c
select s.Quarter, p.CategoryDesc, sum(Total_Sales) as Total_Sales
from SalesFact s, ProdCategoryDIM p
where p.CategoryID = s.CategoryID
and s.Quarter = 1
and p.CategoryDesc = 'Kitchen supplies'
group by p.CategoryDesc, s.Quarter;


-- PART III

/*
  drop table ProdCategoryDim;
  drop table BranchDim;
  drop table TimeDim2;
  drop table SalesFact2;
*/

-- Prodcategory Dimension
create table ProdCategoryDim as
select * from opdb.Category;

select * from ProdCategoryDim;

-- Branch Dimension
create table BranchDim as
select * from opdb.Branch;

select * from BranchDim;

--Time Dimension
create table TimeDim2 as
select distinct to_char(salesdate, 'MONTH') as Month
from opdb.Sales;

-- Better implementation of Time Dimension
CREATE TABLE TimeDim2 AS
SELECT DISTINCT
   	TO_CHAR(salesdate, 'MM') AS MM,
   	TO_CHAR(salesdate, 'MONTH') AS Month_desc
FROM opdb.Sales;

select * from TimeDim2;

-- SalesFact2 Table
create table SalesFact2 as
select to_char(S.salesdate, 'MONTH') as Month, S. BranchID, P. CategoryID,
sum(S.TotalPrice) as Total_Sales
from opdb.Sales S, opdb.Product P
where S.productno = P.productno
group by to_char(S.salesdate, 'MONTH'), BranchID, CategoryID;

select * from SalesFact;

-- Tasks
-- a
select Month, sum(Total_Sales) as Total_Sales
from SalesFact2
group by Month;

-- b
-- branches and product categories
select B.BranchID, B.Address, P.CategoryDesc, sum(S.Total_Sales) as Total_Sales
from SalesFact2 S, BranchDim B, ProdCategoryDim P
where B.BranchID = S.BranchID and
	P.CategoryID = S.CategoryID
group by B.BranchID, B.Address, P.CategoryDesc;

