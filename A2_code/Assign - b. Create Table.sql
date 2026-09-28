select * from MonEquip.ADDRESS;
select * from MonEquip.CATEGORY; 
-- null
select * from MonEquip.CUSTOMER; 
-- duplicate: CUST_ID 52
-- inconsistent: Female vs Male
select * from MonEquip.CUSTOMER_TYPE; 
-- duplicate: type
select * from MonEquip.EQUIPMENT; 
-- MANUFACTURER INCONSISTENT AND THE NULL
select * from MonEquip.HIRE;
-- relationship problems: invalid FK values
-- inconsistent: transaction date
-- incorrect/invalid values
select * from MonEquip.SALES;
-- incorrect/invalid values
select * from MonEquip.STAFF;



select * from ADDRESS;
select * from CATEGORY; 
-- null
select * from CUSTOMER; 
-- duplicate: CUST_ID 52
-- inconsistent: Female vs Male
select * from CUSTOMER_TYPE; 
-- duplicate: type
select * from EQUIPMENT; 
-- MANUFACTURER INCONSISTENT AND THE NULL
select * from HIRE;
-- relationship problems: invalid FK values
-- inconsistent: transaction date
-- incorrect/invalid values
select * from SALES;
-- incorrect/invalid values
select * from STAFF;


-- CLEAN TABLE DATA
-- CUSTOMER
CREATE TABLE CUSTOMER AS
SELECT DISTINCT *
FROM MonEquip.CUSTOMER;

UPDATE CUSTOMER
SET GENDER = CASE 
    WHEN UPPER(GENDER) IN ('M', 'MALE') THEN 'Male'
    WHEN UPPER(GENDER) IN ('F', 'FEMALE') THEN 'Female'
    ELSE 'Other'
END;

select CUSTOMER_ID, COUNT(*)
from CUSTOMER
group by CUSTOMER_ID
having count(*) > 1; 

select *
from CUSTOMER
where GENDER not in ('Male', 'Female'); -- inconsistent values (Male, Female) vs (M, F)

-- ADDRESS
CREATE TABLE ADDRESS AS
SELECT *
FROM MonEquip.ADDRESS;

-- CUSTOMER_TYPE
CREATE TABLE CUSTOMER_TYPE AS
SELECT CUSTOMER_TYPE_ID,
       INITCAP(LOWER(DESCRIPTION)) AS DESCRIPTION
FROM MonEquip.CUSTOMER_TYPE
GROUP BY CUSTOMER_TYPE_ID, INITCAP(LOWER(DESCRIPTION));


-- SALES
CREATE TABLE SALES AS
SELECT DISTINCT *
FROM MonEquip.SALES;
-- only one column
UPDATE SALES
SET QUANTITY = ABS(TOTAL_SALES_PRICE/UNIT_SALES_PRICE)
WHERE QUANTITY <= 0;

-- check
SELECT * 
from SALES
WHERE Quantity <= 0; -- quantity issue

SELECT * 
from SALES
WHERE Total_Sales_Price != Unit_Sales_Price * Quantity; -- revenue mismatch

-- STAFF
CREATE TABLE STAFF AS
SELECT DISTINCT *
FROM MonEquip.STAFF;

-- HIRE
CREATE TABLE HIRE AS 
SELECT 
    H.HIRE_ID,
    H.START_DATE,
    H.END_DATE,
    H.EQUIPMENT_ID,
    H.QUANTITY,
    H.UNIT_HIRE_PRICE,
    H.TOTAL_HIRE_PRICE,
    H.CUSTOMER_ID,
    H.STAFF_ID
FROM MonEquip.HIRE H
JOIN EQUIPMENT E ON H.EQUIPMENT_ID = E.EQUIPMENT_ID
JOIN CUSTOMER C ON H.CUSTOMER_ID = C.CUSTOMER_ID
JOIN STAFF S ON H.STAFF_ID = S.STAFF_ID
WHERE h.START_DATE >= DATE '2018-04-01'
AND h.END_DATE <= DATE '2020-12-31'
AND h.END_DATE >= h.START_DATE;

UPDATE HIRE
SET TOTAL_HIRE_PRICE = 
    CASE
        WHEN END_DATE = START_DATE 
            THEN 0.5 * UNIT_HIRE_PRICE * QUANTITY
        ELSE (END_DATE - START_DATE) * UNIT_HIRE_PRICE * QUANTITY
    END
WHERE TOTAL_HIRE_PRICE != 
    CASE
        WHEN END_DATE = START_DATE 
            THEN 0.5 * UNIT_HIRE_PRICE * QUANTITY
        ELSE (END_DATE - START_DATE) * UNIT_HIRE_PRICE * QUANTITY
    END;



-- staff id 174 & 123 & 223 & 85 referential integrity 
-- staff id 123 have start date and end date terbalik but removed in referential integrity
-- other issue pun resolve left update the total hire price

-- CREATE TABLE HIRE AS 
-- SELECT *
-- FROM MonEquip.HIRE H
-- WHERE H.START_DATE >= DATE '2018-04-01'
--   AND H.END_DATE <= DATE '2020-12-31'
--   AND H.END_DATE >= H.START_DATE
--   AND H.EQUIPMENT_ID IN (SELECT EQUIPMENT_ID FROM EQUIPMENT)
--   AND H.CUSTOMER_ID  IN (SELECT CUSTOMER_ID FROM CUSTOMER)
--   AND H.STAFF_ID     IN (SELECT STAFF_ID FROM STAFF);

-- check
select * 
from HIRE
where EQUIPMENT_ID not in 
(select EQUIPMENT_ID
from EQUIPMENT); -- invalid FK values

select * 
from HIRE
where CUSTOMER_ID not in 
(select CUSTOMER_ID
from CUSTOMER); -- invalid FK values

select * 
from HIRE
where STAFF_ID not in 
(select STAFF_ID
from STAFF); -- invalid FK values

-- staff id 123
select * 
from HIRE
WHERE START_DATE < DATE '2018-04-01' OR END_DATE > DATE '2020-12-31'; -- invalid date (not within transaction period)

-- staff id 85 & 223
select * 
from Hire
where UNIT_HIRE_PRICE <= 0 OR TOTAL_HIRE_PRICE < 0; -- negative total_hire_price

-- staff id 123
select * 
from HIRE
where End_Date < Start_Date; -- invalid date

-- only issue need to be further resolve
SELECT *
from HIRE
WHERE TOTAL_HIRE_PRICE != 
      CASE
          WHEN END_DATE = START_DATE THEN 0.5 * UNIT_HIRE_PRICE * QUANTITY
          ELSE (END_DATE - START_DATE) * UNIT_HIRE_PRICE * QUANTITY
END;



-- CATEGORY
CREATE TABLE CATEGORY AS
SELECT *
from MonEquip.CATEGORY;

delete from CATEGORY
where CATEGORY_ID is null
   or trim(CATEGORY_ID) = ''
   or upper(trim(CATEGORY_ID)) = 'NULL'
   or CATEGORY_DESCRIPTION is null
   or trim(CATEGORY_DESCRIPTION) = ''
   or upper(trim(CATEGORY_DESCRIPTION)) = 'NULL';
-- check
select *
from CATEGORY
where CATEGORY_ID is null
   or trim(CATEGORY_ID) = ''
   or upper(trim(CATEGORY_ID)) = 'NULL'
   or CATEGORY_DESCRIPTION is null
   or trim(CATEGORY_DESCRIPTION) = ''
   or upper(trim(CATEGORY_DESCRIPTION)) = 'NULL';





-- MANUFACTURER EUIPMENT (INCONSISTENT hitachi and null 158)
select distinct MANUFACTURER
from MonEquip.EQUIPMENT
order by MANUFACTURER;

select EQUIPMENT_ID, MANUFACTURER, CATEGORY_ID
from MonEquip.EQUIPMENT
where upper(trim(MANUFACTURER)) = 'HITACHI';

-- Clean
CREATE TABLE EQUIPMENT AS
SELECT *
FROM MonEquip.Equipment;

UPDATE EQUIPMENT
SET MANUFACTURER = 'Hitachi', CATEGORY_ID = 12
WHERE EQUIPMENT_ID = 158;

SELECT EQUIPMENT_ID, MANUFACTURER, CATEGORY_ID
FROM EQUIPMENT
WHERE EQUIPMENT_ID = 158;





-- duplication problems 
-- CUSTOMER
select CUSTOMER_ID, COUNT(*)
from MonEquip.CUSTOMER
group by CUSTOMER_ID
having count(*) > 1; -- cust_id: 52

-- select CUSTOMER_TYPE_ID, NAME, GENDER, ADDRESS_ID, PHONE, EMAIL, COUNT(*)
-- from MonEquip.CUSTOMER
-- group by CUSTOMER_TYPE_ID, NAME, GENDER, ADDRESS_ID, PHONE, EMAIL
-- having count(*) > 1; -- cust_id: 52 (non PK)

-- CUSTOMER_TYPE
select CUSTOMER_TYPE_ID, COUNT(*)
from MonEquip.CUSTOMER_TYPE
group by CUSTOMER_TYPE_ID
having count(*) > 1; -- duplicated


-- relationship problems
-- HIRE 
select * 
from MonEquip.HIRE
where EQUIPMENT_ID not in 
(select EQUIPMENT_ID
from MonEquip.EQUIPMENT); -- invalid FK values

select * 
from MonEquip.HIRE
where CUSTOMER_ID not in 
(select CUSTOMER_ID
from MonEquip.CUSTOMER); -- invalid FK values

select * 
from MonEquip.HIRE
where STAFF_ID not in 
(select STAFF_ID
from MonEquip.STAFF); -- invalid FK values



-- inconsistent values
-- CUSTOMER 
select *
from MonEquip.CUSTOMER
where GENDER not in ('Male', 'Female'); -- inconsistent values (Male, Female) vs (M, F)

-- HIRE 
select * 
from MonEquip.HIRE
WHERE START_DATE < DATE '2018-04-01' OR END_DATE > DATE '2020-12-31'; -- invalid date (not within transaction period)

-- EQUIPMENT
select distinct manufacturer
from MonEquip.EQUIPMENT
order by manufacturer;





-- incorrect/ invalid values
-- HIRE 
select * 
from MonEquip.Hire
where UNIT_HIRE_PRICE <= 0 OR TOTAL_HIRE_PRICE < 0; -- negative total_hire_price

-- select * 
-- from MonEquip.HIRE
-- where TOTAL_HIRE_PRICE != ((End_Date - Start_Date) * Unit_Hire_Price * Quantity); -- revenue formula mismatch

SELECT *
FROM HIRE
WHERE TOTAL_HIRE_PRICE != 
      CASE
          WHEN END_DATE = START_DATE THEN 0.5 * UNIT_HIRE_PRICE * QUANTITY
          ELSE (END_DATE - START_DATE) * UNIT_HIRE_PRICE * QUANTITY
END;



select * 
from MonEquip.HIRE
where End_Date < Start_Date; -- invalid date

-- SALES 
SELECT * 
from MonEquip.SALES
WHERE Quantity <= 0; -- quantity issue

SELECT * 
from MonEquip.SALES
WHERE Total_Sales_Price != Unit_Sales_Price * Quantity; -- revenue mismatch


-- null
-- CATEGORY 
select *
from MonEquip.CATEGORY
where CATEGORY_ID is null
   or trim(CATEGORY_ID) = ''
   or upper(trim(CATEGORY_ID)) = 'NULL'
   or CATEGORY_DESCRIPTION is null
   or trim(CATEGORY_DESCRIPTION) = ''
   or upper(trim(CATEGORY_DESCRIPTION)) = 'NULL';

COMMIT;