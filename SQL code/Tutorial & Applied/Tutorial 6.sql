---------------------------------------------------- 
-- Step 1: create the dimensions 
---------------------------------------------------- 
-- create Country Venue Dimension 
create table CountryVenueDim as 
select distinct C.CountryCode, C.CountryName, T.TestPrice from PTETEST.Test_Venue T, PTETEST.Country C 
where T.CountryCode = C.CountryCode; 

-- create Citizenship Dimension 
create table CitizenshipDim as 
select distinct 
 C.CountryCode as Citizenship, 
 C.CountryName 
from PTETEST.Student S, PTETEST.Country C 
where S.Citizenship = C.CountryCode; 

-- create Year Dimension 
create table YearDim as 
select distinct to_char(TestDate, 'YYYY') as Year 
from PTETEST.Test; 

-- create Grade Dimension 
create table GradeDim 
(Grade varchar2(3), 
Description varchar2(20), 
MinScore number, 
MaxScore number); 
-- populate Grade Dimension's data 
insert into GradeDim values ('4.5', 'Functional', 30, 35); insert into GradeDim values ('5', 'Vocational', 36, 49); insert into GradeDim values ('6', 'Competent', 50, 64); insert into GradeDim values ('7', 'Proficient', 65, 78); insert into GradeDim values ('8-9', 'Superior', 79, 90); 
-- create Test Component Dimension 
create table TestComponentDim 
(TestComponent varchar2(20));

-- populate Test Component Dimension's data 
insert into TestComponentDim values ('Listening'); 
insert into TestComponentDim values ('Reading'); 
insert into TestComponentDim values ('Writing'); 
insert into TestComponentDim values ('Speaking'); 
insert into TestComponentDim values ('Overall'); 

---------------------------------------------------- 
-- Step 2: create a temp fact table  
---------------------------------------------------- 
-- create Temporary Fact table 
create table TempFact as 
select 
 TV.CountryCode, 
 S.Citizenship, 
 to_char(T.TestDate, 'YYYY') as Year, 
 TR.ListeningScore, 
 TR.ReadingScore, 
 TR.WritingScore, 
 TR.SpeakingScore, 
 TR.OverallScore, 
 TR.RegistrationID 
from PTETEST.Test_Venue TV, PTETEST.Test T, PTETEST.Student S,  PTETEST.Test_Result TR 
where TV.VenueID = T.VenueID 
and T.TestNo = TR.TestNo 
and TR.RegistrationID = S.RegistrationID; 

-- add columns in the tempfact table to store each grade component alter table TempFact 
alter table TempFact 
add (GradeOverall varchar2(3), 
 GradeListening varchar2(3), 
 GradeReading varchar2(3), 
 GradeWriting varchar2(3), 
 GradeSpeaking varchar2(3) 
); 

-- converting each score (e.g. Listening score, etc) to a grade -- the grade is based on the band scale in Table 1 
update TempFact
set GradeOverall = 
 (case 
 when OverallScore >= 30 and OverallScore <= 35 then '4.5'  when OverallScore >= 36 and OverallScore <= 49 then '5'  when OverallScore >= 50 and OverallScore <= 64 then '6'  when OverallScore >= 65 and OverallScore <= 78 then '7'  when OverallScore >= 79 and OverallScore <= 90 then '8-9'  end); 
update TempFact set GradeListening =  
 (case 
 when ListeningScore >= 30 and ListeningScore <= 35 then '4.5'  when ListeningScore >= 36 and ListeningScore <= 49 then '5'  when ListeningScore >= 50 and ListeningScore <= 64 then '6'  when ListeningScore >= 65 and ListeningScore <= 78 then '7'  when ListeningScore >= 79 and ListeningScore <= 90 then '8-9'  end); 
  
update TempFact set GradeReading =  
 (case 
 when ReadingScore >= 30 and ReadingScore <= 35 then '4.5'  when ReadingScore >= 36 and ReadingScore <= 49 then '5'  when ReadingScore >= 50 and ReadingScore <= 64 then '6'  when ReadingScore >= 65 and ReadingScore <= 78 then '7'  when ReadingScore >= 79 and ReadingScore <= 90 then '8-9'  end); 
  
update TempFact set GradeWriting =  
 (case 
 when WritingScore >= 30 and WritingScore <= 35 then '4.5'  when WritingScore >= 36 and WritingScore <= 49 then '5'  when WritingScore >= 50 and WritingScore <= 64 then '6'  when WritingScore >= 65 and WritingScore <= 78 then '7'  when WritingScore >= 79 and WritingScore <= 90 then '8-9'  end); 
  
update TempFact set GradeSpeaking =  
 (case 
 when SpeakingScore >= 30 and SpeakingScore <= 35 then '4.5'  when SpeakingScore >= 36 and SpeakingScore <= 49 then '5'  when SpeakingScore >= 50 and SpeakingScore <= 64 then '6'  when SpeakingScore >= 65 and SpeakingScore <= 78 then '7'  when SpeakingScore >= 79 and SpeakingScore <= 90 then '8-9'  end);

---------------------------------------------------- 
-- Step 3: create temporary fact table  
-- for each test component 
---------------------------------------------------- 
create table OverallFact as 
select 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeOverall As Grade, 
 'Overall' as TestComponent, 
 count(RegistrationID) as Total_Students_Overall 
from TempFact 
group by 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeOverall, 
 'Overall'; 

create table ListeningFact as  
select 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeListening As Grade, 
 'Listening' as TestComponent, 
 count(RegistrationID) as Total_Students_Overall 
from TempFact 
group by 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeListening, 
 'Listening'; 

create table ReadingFact as  
select 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeReading As Grade, 
 'Reading' as TestComponent,
 count(RegistrationID) as Total_Students_Overall 
from TempFact 
group by 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeReading, 
 'Reading'; 

create table WritingFact as 
select 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeWriting As Grade, 
 'Writing' as TestComponent, 
 count(RegistrationID) as Total_Students_Overall 
from TempFact 
group by 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeWriting, 
 'Writing'; 

create table SpeakingFact as  
select 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeSpeaking As Grade, 
 'Speaking' as TestComponent, 
 count(RegistrationID) as Total_Students_Overall 
from TempFact 
group by 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeSpeaking, 
 'Speaking'; 

---------------------------------------------------- 
-- Step 4: create the final fact table  
---------------------------------------------------- 
create table FinalFact as 
select 
 CountryCode, 
 Citizenship,
 Year, 
 Grade, 
 TestComponent, 
 Total_Students_Overall as Total_Students 
from OverallFact 
union 
 select * from ListeningFact 
union 
 select * from ReadingFact 
union 
 select * from WritingFact 
union 
 select * from SpeakingFact; 

-- TASK A: The Reports
--a) How many students received a Competent grade in their overall score? 
SELECT g.grade, g.description as grade_description, t.testcomponent,  SUM(f.total_students) as number_of_students 
FROM FinalFact f, TestComponentDim t, GradeDim g 
WHERE f.grade = g.grade 
AND f.testcomponent = t.testcomponent 
AND g.description = 'Competent' 
AND t.testcomponent = 'Overall' 
GROUP BY g.grade, g.description, t.testcomponent;

-- b) How many students took the test in 2017? 
SELECT year, f.testcomponent, sum(total_students) 
FROM finalfact  f JOIN testcomponentdim t 
ON f.testcomponent = t.testcomponent 
where year = '2017' AND f.testcomponent = 'Overall'
GROUP BY year,f.testcomponent;

-- Note: The answer below is INCORRECT. If you check the operational database  (specifically in the test_result table), there are only 11 records of students taking the test in  2017. If you do not take into consideration of the test components when querying the data  warehouse, the result of the query is incorrect as it will sum up all the number of students of  all components as shown in the result below. 
SELECT y.year, SUM(f.total_students) as number_of_students 
FROM FinalFact f, YearDim y 
WHERE f.year = y.year 
AND y.year = '2017' 
GROUP BY y.year; 

-- c) How many Korean citizen students took test? 
SELECT c.countryname, t.testcomponent, 
 SUM(f.total_students) as number_of_students 
FROM FinalFact f, TestComponentDim t, CitizenshipDim c WHERE f.citizenship = c.citizenship 
AND f.testcomponent = t.testcomponent 
AND c.countryname = 'Korea' 
GROUP BY c.countryname, t.testcomponent; 

-- d) How many students took the test in Australia? 
SELECT c.countrycode, c.countryname, t.testcomponent,  SUM(f.total_students) as number_of_students 
FROM FinalFact f, TestComponentDim t, CountryVenueDim c WHERE f.countrycode = c.countrycode 
AND f.testcomponent = t.testcomponent 
AND c.countryname = 'Australia' 
GROUP BY c.countrycode, c.countryname, t.testcomponent; 
-- The result of total_student is the same if you specify only 1 component since 1 test the student needs to test for 4 components. Hence, for the number of students you may specify only 1 component.

SELECT c.countrycode, c.countryname,   SUM(f.total_students) as number_of_students 
FROM FinalFact f, TestComponentDim t, CountryVenueDim c WHERE f.countrycode = c.countrycode 
AND f.testcomponent = t.testcomponent 
AND c.countryname = 'Australia' and t.testcomponent = 'Overall'
GROUP BY c.countrycode, c.countryname, t.testcomponent; 

-- e) How many Chinese students received a Proficient Grade in the Listening part in 2017? 
SELECT c.countryname as citizenship, 
 g.grade,  
 g.description AS grade_description, 
 t.testcomponent, 
 y.year, 
 SUM(f.total_students) as number_of_students 
FROM FinalFact f, 
 TestComponentDim t, 
 CitizenshipDim c, 
 GradeDim g, 
 YearDim y 
WHERE f.testcomponent = t.testcomponent 
AND f.citizenship = c.citizenship 
AND f.grade = g.grade 
AND f.year = y.year 
AND c.countryname = 'China' 
AND g.description = 'Proficient' 
AND t.testcomponent = 'Listening' 
GROUP BY c.countryname, g.grade, g.description, t.testcomponent,  y.year; 





-- TASK B: Q1.Star Schema - Pivoted Fact Table Version
-- create Country Venue Dimension 
create table CountryVenueDim as 
select distinct C.CountryCode, C.CountryName, T.TestPrice from PTETEST.Test_Venue T, PTETEST.Country C 
where T.CountryCode = C.CountryCode; 
-- Country Venue Dimension can be created by joining two tables from the operational database: -- Test Venue and Country, in order to get the Country Code, Country Name, and Test Price attributes. 
-- create Citizenship Dimension 
create table CitizenshipDim as 
select distinct 
 C.CountryCode as Citizenship, 
 C.CountryName 
from PTETEST.Student S, PTETEST.Country C 
where S.Citizenship = C.CountryCode; 
-- For the Citizenship Dimension, it is also a join between Student and Country tables from the  operational database, in order to get the Citizenship (which is the Country Code), and Country Name. 
-- create Year Dimension 
create table YearDim as 
select distinct to_char(TestDate, 'YYYY') as Year 
from PTETEST.Test; 
-- For the Year dimension, it is basically an extraction from the Test Date attribute in the Test table. 
-- create Grade Dimension 
create table GradeDim 
(Grade varchar2(3), 
Description varchar2(20), 
MinScore number, 
MaxScore number); 
-- populate Grade Dimension's data 
insert into GradeDim values ('4.5', 'Functional', 30, 35); insert into GradeDim values ('5', 'Vocational', 36, 49); insert into GradeDim values ('6', 'Competent', 50, 64); insert into GradeDim values ('7', 'Proficient', 65, 78); insert into GradeDim values ('8-9', 'Superior', 79, 90); 
-- The Grade Dimensions cannot be extracted from the operational database, thus it must be created  manually.

---------------------------------------------------- 
-- Step 2: create a temp fact table  
---------------------------------------------------- 
-- Note: This step is similar to the step in Task A. 
-- create Temporary Fact table 
create table TempFact as 
select 
 TV.CountryCode, 
 S.Citizenship, 
 to_char(T.TestDate, 'YYYY') as Year, 
 TR.ListeningScore, 
 TR.ReadingScore, 
 TR.WritingScore, 
 TR.SpeakingScore, 
 TR.OverallScore, 
 TR.RegistrationID 
from PTETEST.Test_Venue TV, PTETEST.Test T, PTETEST.Student S,  PTETEST.Test_Result TR 
where TV.VenueID = T.VenueID 
and T.TestNo = TR.TestNo 
and TR.RegistrationID = S.RegistrationID; 

-- add columns in the tempfact table to store each grade component 
alter table TempFact 
add (GradeOverall varchar2(3), 
 GradeListening varchar2(3), 
 GradeReading varchar2(3), 
 GradeWriting varchar2(3), 
 GradeSpeaking varchar2(3) 
); 

-- converting each score (e.g. Listening score, etc) to a grade -- the grade is based on the band scale in Table 1 update TempFact 
set GradeOverall = 
 (case 
 when OverallScore >= 30 and OverallScore <= 35 then '4.5'  
 when OverallScore >= 36 and OverallScore <= 49 then '5'  
 when OverallScore >= 50 and OverallScore <= 64 then '6'  
 when OverallScore >= 65 and OverallScore <= 78 then '7'  
 when OverallScore >= 79 and OverallScore <= 90 then '8-9'  end); 

update TempFact set GradeListening =  
 (case 
 when ListeningScore >= 30 and ListeningScore <= 35 then '4.5'  
 when ListeningScore >= 36 and ListeningScore <= 49 then '5'  
 when ListeningScore >= 50 and ListeningScore <= 64 then '6'  
 when ListeningScore >= 65 and ListeningScore <= 78 then '7'
 when ListeningScore >= 79 and ListeningScore <= 90 then '8-9'  end); 
  
update TempFact set GradeReading =  
 (case 
 when ReadingScore >= 30 and ReadingScore <= 35 then '4.5'  
 when ReadingScore >= 36 and ReadingScore <= 49 then '5'  
 when ReadingScore >= 50 and ReadingScore <= 64 then '6'  
 when ReadingScore >= 65 and ReadingScore <= 78 then '7'  
 when ReadingScore >= 79 and ReadingScore <= 90 then '8-9'  end); 
  
update TempFact set GradeWriting =  
 (case 
 when WritingScore >= 30 and WritingScore <= 35 then '4.5'  
 when WritingScore >= 36 and WritingScore <= 49 then '5'  
 when WritingScore >= 50 and WritingScore <= 64 then '6'  
 when WritingScore >= 65 and WritingScore <= 78 then '7'  
 when WritingScore >= 79 and WritingScore <= 90 then '8-9'  end); 
  
update TempFact set GradeSpeaking =  
 (case 
 when SpeakingScore >= 30 and SpeakingScore <= 35 then '4.5'  
 when SpeakingScore >= 36 and SpeakingScore <= 49 then '5'  
 when SpeakingScore >= 50 and SpeakingScore <= 64 then '6'  
 when SpeakingScore >= 65 and SpeakingScore <= 78 then '7'  
 when SpeakingScore >= 79 and SpeakingScore <= 90 then '8-9'  end); 

 ---------------------------------------------------- 
-- Step 3: create temporary fact table  
-- for each test component 
---------------------------------------------------- 
create table OverallFact as 
select 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeOverall As Grade, 
 'Overall' as TestComponent, 
 count(RegistrationID) as Total_Students_Overall 
from TempFact 
group by 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeOverall, 
 'Overall';

create table ListeningFact as  
select 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeListening As Grade, 
 'Listening' as TestComponent, 
 count(RegistrationID) as Total_Students_Overall from TempFact 
group by 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeListening, 
 'Listening'; 
create table ReadingFact as  
select 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeReading As Grade, 
 'Reading' as TestComponent, 
 count(RegistrationID) as Total_Students_Overall from TempFact 
group by 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeReading, 
 'Reading'; 
create table WritingFact as 
select 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeWriting As Grade, 
 'Writing' as TestComponent, 
 count(RegistrationID) as Total_Students_Overall from TempFact 
group by 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeWriting, 
 'Writing'; 
create table SpeakingFact as  
select 
 CountryCode, 
 Citizenship, 
 Year,
 GradeSpeaking As Grade, 
 'Speaking' as TestComponent, 
 count(RegistrationID) as Total_Students_Overall 
from TempFact 
group by 
 CountryCode, 
 Citizenship, 
 Year, 
 GradeSpeaking, 
 'Speaking'; 

---------------------------------------------------- 
-- Step 4: create a Cartesian Product of all  
-- dimensions in order to get all possible 
-- combinations of the dimensions 
---------------------------------------------------- 
-- NOTE: In general, when a fact table is created, it may not contain all possible combinations from all  records of all dimensions. The reason is that the fact table is created by a join (an inner join) operation.  Consequently, combinations of records from the dimension tables that do not have any value for the fact  measure will not be included in the fact table – simply put, there is no zero values in the fact measure. 
-- If we create a fact table as in the star schema with Pivoted Fact Table that has five fact measures:  Total Students with Listening, with Reading, with Writing, with Speaking, and with Overall Score; it is  expected that we should have 60 records in the final fact table (2 countries of test venues, 6 countries of  citizenship, 1 year, and 5 grades) and we also have to keep track of the zero values. 
-- In order to achieve this, first we need to get all possible combinations from all dimensions, which is a Cartesian Product between all dimensions. 
create table AllDimensions as 
select 
 CO.CountryCode, 
 CI.Citizenship, 
 Y.Year, 
 G.Grade 
from 
 CountryVenueDim CO, 
 CitizenshipDim CI, 
 YearDim Y, 
 GradeDim G; 
---------------------------------------------------- 
-- Step 5: create temporary fact table  
-- for each test component 
---------------------------------------------------- 
create table OverallFactNew as 
select 
 A.CountryCode, 
 A.Citizenship, 
 A.Year, 
 A.Grade, 
 nvl(O.Total_Students_Overall, 0) 
 as Total_Students_Overall 
from AllDimensions A, OverallFact O 
where A.CountryCode = O.CountryCode(+) 
and A.Citizenship = O.Citizenship(+) 
and A.Year = O.Year(+) 
and A.Grade = O.Grade(+); -- left

-- outer join: preserve rows even when no matches exist


-- five temporary fact tables
create table ListeningFactNew as 
select 
 A.CountryCode, 
 A.Citizenship, 
 A.Year, 
 A.Grade, 
 nvl(O.Total_Students_Overall, 0) 
 as Total_Students_Listening 
from AllDimensions A, ListeningFact O 
where A.CountryCode = O.CountryCode(+) 
and A.Citizenship = O.Citizenship(+) 
and A.Year = O.Year(+) 
and A.Grade = O.Grade(+); 
create table ReadingFactNew as 
select 
 A.CountryCode, 
 A.Citizenship, 
 A.Year, 
 A.Grade, 
 nvl(O.Total_Students_Overall, 0) 
 as Total_Students_Reading 
from AllDimensions A, ReadingFact O 
where A.CountryCode = O.CountryCode(+) 
and A.Citizenship = O.Citizenship(+) 
and A.Year = O.Year(+) 
and A.Grade = O.Grade(+); 
create table WritingFactNew as 
select 
 A.CountryCode, 
 A.Citizenship, 
 A.Year, 
 A.Grade, 
 nvl(O.Total_Students_Overall, 0) 
 as Total_Students_Writing 
from AllDimensions A, WritingFact O
where A.CountryCode = O.CountryCode(+) 
and A.Citizenship = O.Citizenship(+) 
and A.Year = O.Year(+) 
and A.Grade = O.Grade(+); 
create table SpeakingFactNew as 
select 
 A.CountryCode, 
 A.Citizenship, 
 A.Year, 
 A.Grade, 
 nvl(O.Total_Students_Overall, 0) 
 as Total_Students_Speaking 
from AllDimensions A, SpeakingFact O 
where A.CountryCode = O.CountryCode(+) 
and A.Citizenship = O.Citizenship(+) 
and A.Year = O.Year(+) 
and A.Grade = O.Grade(+); 

---------------------------------------------------- 
-- Step 6: create the final fact table  
---------------------------------------------------- 
create table FinalFact2 as 
select 
 O.CountryCode, 
 O.Citizenship, 
 O.Year, 
 O.Grade, 
 O.Total_Students_Overall, 
 L.Total_Students_Listening, 
 R.Total_Students_Reading, 
 W.Total_Students_Writing, 
 S.Total_Students_Speaking 
from 
 OverallFactNew O, 
 ListeningFactNew L, 
 ReadingFactNew R, 
 WritingFactNew W,
 SpeakingFactNew S 
where O.CountryCode = L.CountryCode 
and L.CountryCode = R.CountryCode 
and R.CountryCode = W.CountryCode 
and W.CountryCode = S.CountryCode 
and O.Citizenship = L.Citizenship 
and L.Citizenship = R.Citizenship 
and R.Citizenship = W.Citizenship 
and W.Citizenship = S.Citizenship 
and O.Year = L.Year 
and L.Year = R.Year 
and R.Year = W.Year 
and W.Year = S.Year 
and O.Grade = L.Grade 
and L.Grade = R.Grade 
and R.Grade = W.Grade 
and W.Grade = S.Grade; 

---------------------------------------------------- 
-- Step 7: delete unnecessary data in 
-- the final fact table  
---------------------------------------------------- 
delete from FinalFact2 
where Total_Students_Overall = 0 
and Total_Students_Listening = 0 
and Total_Students_Reading = 0 
and Total_Students_Writing = 0 
and Total_Students_Speaking = 0;  
-- The Final Fact table only contains eleven records since all records that comprise all zero values for  all test components are removed.

-- Task B: Q3. The Reports  
-- a) How many students received a Competent grade in their overall score? 
SELECT g.grade, g.description as grade_description, 
 SUM(f.total_students_overall) AS total_students_overall FROM FinalFact2 f, GradeDim g 
WHERE f.grade = g.grade 
AND g.description = 'Competent' 
GROUP BY g.grade, g.description; 

-- b) How many students took the test in 2017? 
SELECT y.year, 
 SUM(f.total_students_overall) as total_students_overall,  SUM(f.total_students_listening) as total_students_listening,  SUM(f.total_students_reading) as total_students_reading,   SUM(f.total_students_writing) as total_students_writing,   SUM(f.total_students_speaking) as total_students_speaking FROM FinalFact2 f, YearDim y 
WHERE f.year = y.year 
AND y.year = '2017' 
GROUP BY y.year; 

-- c) How many Korean citizen students took test? 
SELECT c.countryname, 
 SUM(f.total_students_overall) as total_students_overall,  SUM(f.total_students_listening) as total_students_listening,  SUM(f.total_students_reading) as total_students_reading,   SUM(f.total_students_writing) as total_students_writing,   SUM(f.total_students_speaking) as total_students_speaking FROM FinalFact2 f, CitizenshipDim c 
WHERE f.citizenship = c.citizenship 
AND c.countryname = 'Korea' 
GROUP BY c.countryname; 

-- d) How many students took the test in Australia? 
SELECT c.countrycode, 
 c.countryname, 
 SUM(f.total_students_overall) as total_students_overall,  SUM(f.total_students_listening) as total_students_listening,  SUM(f.total_students_reading) as total_students_reading,   SUM(f.total_students_writing) as total_students_writing,   SUM(f.total_students_speaking) as total_students_speaking
FROM FinalFact2 f, CountryVenueDim c 
WHERE f.countrycode = c.countrycode 
AND c.countryname = 'Australia' 
GROUP BY c.countrycode, c.countryname; 

-- e) How many Chinese students received a Proficient Grade in the Listening part in 2017? 
SELECT c.countryname as citizenship,  
 g.grade,  
 g.description AS grade_description, 
 y.year, 
 SUM(f.total_students_listening) as total_students_listening FROM FinalFact2 f, CitizenshipDim c, GradeDim g, YearDim y WHERE f.citizenship = c.citizenship 
AND f.grade = g.grade 
AND f.year = y.year 
AND c.countryname = 'China' 
AND g.description = 'Proficient' 
GROUP BY c.countryname, g.grade, g.description, y.year; 

-- f) How many Japanese students received a Competent Grade in 2017? 
SELECT c.countryname as citizenship,  
 g.grade,  
 g.description AS grade_description, 
 y.year, 
 SUM(f.total_students_overall) as total_students_overall,  SUM(f.total_students_listening) as total_students_listening,  SUM(f.total_students_reading) as total_students_reading,   SUM(f.total_students_writing) as total_students_writing,   SUM(f.total_students_speaking) as total_students_speaking FROM FinalFact2 f, CitizenshipDim c, GradeDim g, YearDim y WHERE f.citizenship = c.citizenship 
AND f.grade = g.grade 
AND f.year = y.year 
AND c.countryname = 'Japan' 
AND g.description = 'Competent' 
GROUP BY c.countryname, g.grade, g.description, y.year; 
