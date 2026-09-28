SELECT * FROM TAB; 

CREATE TABLE LECTURER
(StaffNO 			NUMBER(6) 		NOT NULL, 
 Title				VARCHAR2(3),
 FName 				VARCHAR2(30),
 LName				VARCHAR2(30),
 StreetAddress		VARCHAR2(70), 
 Suburb				VARCHAR2(40), 
 City				VARCHAR2(40), 
 PostCode			VARCHAR2(4), 
 Country				VARCHAR2(30),
 LecturerLevel		CHAR(2), 
 BankNO				CHAR(20),
 BankName			VARCHAR2(40),
 Salary				NUMBER(8,2), 
 WorkLoad			NUMBER(2,1) 	NOT NULL, 
 ResearchArea			VARCHAR2(40),
 PRIMARY KEY(StaffNo));

SELECT * FROM TAB;

INSERT INTO LECTURER (StaffNO, Title, FName, LName, StreetAddress, Suburb,City, PostCode, Country, LecturerLevel, BankNO, BankName, Salary, WorkLoad, ResearchArea)
VALUES (1000,'Dr','David','Taniar','3 Robinson Av', 'Kew', 'Melbourne', '3080', 'Australia', '5', '1000567237', 'CommBank', 89000.00, 2.0, 'O-R DB');

INSERT INTO LECTURER (StaffNO, Title, FName, LName, StreetAddress, Suburb, City, PostCode, Country, LecturerLevel, BankNO, BankName, Salary, WorkLoad, ResearchArea)
VALUES (2000,'Ms','Julie','Main','6 Algorithm Av', 'Montmorency', 'Melbourne', '3089', 'Australia', '5', '1000123456', 'CommBank', 89000.00, 2.0, 'CBR');

INSERT INTO LECTURER VALUES (3000, 'Mr', 'Daniel', 'Wright', '22 Crystal Cres', 'Alphington', 'Melbourne', '3790', 'Australia', '5', '1000654321', 'CommBank', 89000.00, 2.0, 'DB');

INSERT INTO LECTURER (StaffNO, Title, FName, LName, StreetAddress, Suburb, PostCode, Country, ResearchArea, Workload)
VALUES (4000, 'Mr', 'RaiHong', 'Lam', '12 Oracle Dr', 'Fitzroy', '3424', 'Australia', 'Data Mining', 1);

SELECT * FROM LECTURER; 

CREATE TABLE STUDENT
(StudentNO			NUMBER(6)	NOT NULL, 
 DOB				DATE, 
 FName 			VARCHAR2(30),
 LName			VARCHAR2(30),
 -- city spelt CiTTy
 CiTTy			VARCHAR2(40),
 PostCode			VARCHAR2(4), 
 Country			VARCHAR2(30),
 FeePaid			NUMBER(8,2), 
 LastFeeDate		DATE,
 PRIMARY KEY(StudentNo));

-- Q6b--
INSERT INTO STUDENT VALUES 
(30001, TO_DATE('15-JAN-2000', 'DD-MON-YYYY'), 'John', 'Smith', 'Sydney', '2000', 'Australia', 5000.00, TO_DATE('10-FEB-2023', 'DD-MON-YYYY'));

INSERT INTO STUDENT VALUES 
(30002, TO_DATE('22-MAR-2001', 'DD-MON-YYYY'), 'Sarah', 'Johnson', 'Melbourne', '3000', 'Australia', 4500.00, TO_DATE('05-JAN-2023', 'DD-MON-YYYY'));

INSERT INTO STUDENT VALUES 
(30003, TO_DATE('08-SEP-1999', 'DD-MON-YYYY'), 'Michael', 'Brown', 'Brisbane', '4000', 'Australia', 6000.00, TO_DATE('15-MAR-2023', 'DD-MON-YYYY'));

INSERT INTO STUDENT VALUES 
(30004, TO_DATE('30-NOV-2000', 'DD-MON-YYYY'), 'Emily', 'Davis', 'Perth', '6000', 'Australia', 4800.00, TO_DATE('20-FEB-2023', 'DD-MON-YYYY'));

INSERT INTO STUDENT VALUES 
(30005, TO_DATE('12-FEB-2002', 'DD-MON-YYYY'), 'David', 'Wilson', 'Adelaide', '5000', 'Australia', 5200.00, TO_DATE('01-MAR-2023', 'DD-MON-YYYY'));

ALTER TABLE STUDENT ADD 
(StreetAddress		VARCHAR2(70), 
 Suburb				VARCHAR2(40));

DESC STUDENT; 

ALTER TABLE STUDENT
DROP(CiTTy);

ALTER TABLE STUDENT
ADD (City	CHAR(40));

ALTER TABLE STUDENT
MODIFY (City	VARCHAR2(40));

UPDATE STUDENT
SET StreetAddress = '12 New St'
WHERE StudentNo = 30001;

COMMIT;

-- PART B --
Create Table SUBJECT 
As Select * 
From dtaniar.SUBJECT;

Create Table LECTURE 
As Select * 
From dtaniar. LECTURE;

Create Table TUTOR 
As Select * 
From dtaniar. TUTOR;

Create Table LAB 
As Select * 
From dtaniar. LAB;

Create Table STUDENT_ENROLMENT
As Select * 
From dtaniar. STUDENT_ENROLMENT;

Create Table LAB_SIGNUP
As Select * 
From dtaniar. LAB_SIGNUP;

-- Q17
SELECT L.FNAME, L.LNAME, S.SUBJECTCODE, S.LECTDAY, S.LECTTIME
FROM LECTURER L, LECTURE S
WHERE L.STAFFNO = S.STAFFNO;

-- Q18
SELECT FNAME, LNAME
FROM LECTURER
WHERE STAFFNO NOT IN (SELECT STAFFNO FROM LECTURE);

-- Q19
SELECT *  
FROM SUBJECT
WHERE SEMESTER = 1;

-- Q20
SELECT FNAME, LNAME, DOB, FEEPAID
FROM STUDENT
WHERE DOB BETWEEN TO_DATE('01-JAN-1991', DD-MON-YYYY) AND TO_DATE('31-DEC-1995', DD-MON-YYYY);

-- Alternatively:

SELECT 	FName, LName, DOB, FeePaid
FROM 	Student
WHERE 	to_char(DOB, 'YYYYMMDD') >= '19910101'
AND to_char(DOB, 'YYYYMMDD') <= '19941231';

-- Or, you could just retrieve the year:

SELECT	FName, LName, DOB, FeePaid
FROM		Student
WHERE 	EXTRACT(year from dob) BETWEEN 1991 AND 1994;

-- Or

SELECT 	FName, LName, DOB, FeePaid
FROM 	Student
WHERE 	to_char(DOB, 'YYYY') > '1990'
AND to_char(DOB, 'YYYY') < '1995';


-- Q21
SELECT	DISTINCT S.StudentNo, FName, LName
FROM 	Student S, Student_Enrolment SE
WHERE 	(SubjectCode = 'CSE21DB' 
OR		SubjectCode = 'CSE31DB' 
OR		SubjectCode = 'CSE41FDB') 
AND 		S.StudentNo = SE.StudentNo;

-- Alternatively:
SELECT         DISTINCT S.STUDENTNO, S.FNAME, S.LNAME
FROM            Student S, Student_Enrolment SE
WHERE         SE.SUBJECTCODE IN ('CSE21DB', 'CSE31DB', 'CSE41FDB')
AND              S.STUDENTNO=SE.STUDENTNO;

-- Or:

SELECT	DISTINCT S.StudentNo, FName, LName
FROM		Student S, Student_Enrolment SE
WHERE	SubjectCode LIKE '%DB%'
AND		S.StudentNo = SE.StudentNo;

-- Q22
SELECT T.TUTORNO, T.STUDENTNO, FNAME, LNAME
FROM TUTOR T, STUDENT S
WHERE S.STUDENTNO = T.STUDENTNO;

-- Q23
SELECT STAFFNO, FNAME, LNAME
FROM LECTURER
WHERE ResearchArea = 'Network Management';

-- Q24
SELECT AVG(NVL(SALARY,0)) AS "Average Salary"
FROM LECTURER;

-- Q25
SELECT MIN(SALARY) AS "Min Salary", MAX(SALARY) AS "Max Salary"
FROM LECTURER;

-- Q26
-- List the numbers of tutor each subject and semester
-- WRONG
SELECT T.TUTORNO, S.SEMESTER, S.SUBJECTCODE
FROM LAB L, SUBJECT S, TUTOR T
WHERE L.SUBJECTCODE = S.SUBJECTCODE AND L.TUTORNO = T.TUTORNO;

--CORRECT ANS
SELECT COUNT(T.TUTORNO), S.SEMESTER, S.NAME AS SubjectName
FROM LAB L, SUBJECT S, TUTOR T
WHERE L.SUBJECTCODE = S.SUBJECTCODE AND L.TUTORNO = T.TUTORNO
GROUP BY S.NAME, S.SEMESTER; 

-- When to use GROUP BY? 
-- Use it whenever there's an aggregate function in SELECT and when 
-- you want the results to be displayed by certain groups rather than for the table overall

 -- To group rows from a table based on the values of one or more columns


 -- Q27
 -- Total number of students in each lab, for each subject with the tutor's name
SELECT COUNT(LS.STUDENTNO) AS NumberOfStudent, S.NAME AS SubjectName, L.LABNO, ST.LNAME AS Tutor
FROM LAB L, SUBJECT S, LAB_SIGNUP LS, TUTOR T, STUDENT ST
WHERE S.SUBJECTCODE = L.SUBJECTCODE AND L.TUTORNO = T.TUTORNO AND L.LABNO = LS.LABNO AND T.STUDENTNO = ST.STUDENTNO
GROUP BY S.NAME, L.LABNO, ST.LNAME;

-- Q28
-- The cost of running all database labs per week 
SELECT SUM(T.SALARYPERHOUR * L.DURATION) AS "Databse Labs Cost Per Week"
FROM LAB L, TUTOR T, SUBJECT S
WHERE L.TUTORNO = T.TUTORNO AND S.SUBJECTCODE = L.SUBJECTCODE AND S.SUBJECTCODE LIKE '%DB%';

-- Alternatively:
SELECT	SUM(TT.SalaryPerHour * LB.Duration) as "Database Labs Cost Per Week"
FROM 	Lab LB, Tutor TT
WHERE 	LB.TutorNo = TT.TutorNo 
AND  		LB.SubjectCode LIKE '%DB%';
