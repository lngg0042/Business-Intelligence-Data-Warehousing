-- 9.1 Surrogate Keys
-- an artificial, system-generated unique identifier for a database record that has no business meaning

-- a)
-- create Sex dimension
CREATE TABLE SexDim AS
SELECT DISTINCT Sex
FROM Student;
-- add surrogate column and populate it 
ALTER TABLE SexDim ADD (SexID NUMBER(2));

-- drop sequence if exists, then create
DROP SEQUENCE Sex_seq_ID;

CREATE SEQUENCE Sex_seq_ID
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 99999999
  MINVALUE 1
  NOCYCLE;

UPDATE SexDim
SET SexID = Sex_seq_ID.NEXTVAL;

-- create a TempFact that carries Sex (or SexID) from Student
-- then populate SexID by lookup:
CREATE TABLE TempFact AS
SELECT Suburb, Sex
FROM Student;

ALTER TABLE TempFact ADD (SexID NUMBER(2));

UPDATE TempFact TF
SET TF.SexID =
  (SELECT S.SexID
   FROM SexDim S
   WHERE S.Sex = TF.Sex);

-- final Fact Table
CREATE TABLE Fact AS
SELECT SuburbID, SexID, COUNT(*) AS TotalStudents
FROM TempFact
GROUP BY SuburbID, SexID;


-- b)
-- FIRST schema: Without surrogate key
-- from Fact
SELECT SUM(TotalStudents) AS TotalStudentsInCaulfield
FROM Fact
WHERE Suburb = 'Caulfield';

-- or from Student
SELECT COUNT(*) AS TotalStudentsInCaulfield
FROM Student
WHERE Suburb = 'Caulfield';

-- SECOND schema: subrubID in the key in Suburb Dimension
SELECT SUM(f.TotalStudents) AS TotalStudentsInCaulfield
FROM Fact f
JOIN SuburbDim s ON f.SuburbID = s.SuburbID
WHERE s.Suburb = 'Caulfield';

-- COMPARE & CONTRAST

-- Without surrogate: simpler query — you can filter by Suburb directly (no join required). 
-- This is fast and human-readable but assumes the Suburb value in Fact is authoritative and consistent.

-- With surrogate: you must join from Fact to SuburbDim to translate SuburbID → Suburb. 
-- That is slightly more work at query time, but surrogate keys protect against inconsistent or non-unique source IDs 
-- (useful when integrating multiple systems) and can be more efficient for joins and indexing at scale.


-- c)
-- using ROW_NUMBER()
CREATE TABLE SuburbDim AS
SELECT Suburb,
       Postcode,
       ROW_NUMBER() OVER (ORDER BY Suburb) AS SuburbID
FROM (
  SELECT DISTINCT Suburb, Postcode
  FROM Student
) t;

-- change to ORDER BY Postcode, Suburb if you prefer deterministic ordering by postcode first.
-- Some DBMS require an explicit CAST to integer for SuburbID (e.g., CAST(ROW_NUMBER() ... AS INTEGER) AS SuburbID).



-- 9.2 Dimension-Less Keys
-- V1: Star Schema with two dimensions - Suburb & Sex
SELECT s.Suburb,
       x.Sex,
       f.TotalStudents
FROM Fact f
JOIN SuburbDim s ON f.SuburbID = s.SuburbID
JOIN SexDim x    ON f.SexID    = x.SexID;

-- V2: Star Schema with a dimension-less key of Sex
-- If Suburb still references SuburbDim but Sex is stored directly in Fact:
SELECT s.Suburb,
       f.Sex,
       f.TotalStudents
FROM Fact f
JOIN SuburbDim s ON f.SuburbID = s.SuburbID;

-- Or if neither dimension is surrogate and both textual in Fact
SELECT Suburb, Sex, TotalStudents
FROM Fact;

-- COMPARE & CONTRAST
-- Version 1
-- requires joins
-- store only keys in the Fact table and look up readable labels via joins
-- normalizes textual attributes, reduces repeated text in Fact and
-- centralizes attribute metadata (useful for consistent descriptions, hierarchies, slowly changing attributes, etc.).

-- Version 2
-- Pros
-- keep Sex directly in Fact,so don't require a join
-- acceptable when the attribute is stable, small domain
-- Cons
-- lose the ability to store extra attributes about Sex (like descriptions, codes, translations)
-- duplicate the textual value in every Fact row
