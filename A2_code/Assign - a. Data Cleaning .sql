select * from MonEquip.ADDRESS;
select * from MonEquip.CATEGORY; 
-- null
select * from MonEquip.CUSTOMER; 
-- duplicate: CUST_ID 52
-- inconsistent: Female vs Male
select * from MonEquip.CUSTOMER_TYPE; 
-- duplicate: type
select * from MonEquip.EQUIPMENT; 
-- null & inconsistent manufacturer name
select * from MonEquip.HIRE;
-- relationship problems: invalid FK values
-- inconsistent: transaction date
-- incorrect/invalid values
select * from MonEquip.SALES;
-- incorrect/invalid values
select * from MonEquip.STAFF;





-- Chap 20. DATA CLEANING
-- duplication problems **

-- CUSTOMER
select CUSTOMER_ID, COUNT(*)
from MonEquip.CUSTOMER
group by CUSTOMER_ID
having count(*) > 1; -- cust_id: 52


select CUSTOMER_TYPE_ID, NAME, GENDER, ADDRESS_ID, PHONE, EMAIL, COUNT(*)
from MonEquip.CUSTOMER
group by CUSTOMER_TYPE_ID, NAME, GENDER, ADDRESS_ID, PHONE, EMAIL
having count(*) > 1; -- cust_id: 52 (non PK)


-- CUSTOMER_TYPE
select CUSTOMER_TYPE_ID, COUNT(*)
from MonEquip.CUSTOMER_TYPE
group by CUSTOMER_TYPE_ID
having count(*) > 1; -- duplicated

-- ADDRESS
select ADDRESS_ID, COUNT(*)
from MonEquip.ADDRESS
group by ADDRESS_ID
having count(*) > 1;

select STREET_NUMBER, STREET_NAME, SUBURB, STATE, POSTCODE, COUNT(*)
from MonEquip.ADDRESS
group by STREET_NUMBER, STREET_NAME, SUBURB, STATE, POSTCODE
having count(*) > 1;

-- EQUIPMENT
select EQUIPMENT_ID, COUNT(*)
from MonEquip.EQUIPMENT
group by EQUIPMENT_ID
having count(*) > 1;

select EQUIPMENT_NAME, MANUFACTURER, COUNT(*)
from MonEquip.EQUIPMENT
group by EQUIPMENT_NAME, MANUFACTURER
having count(*) > 1;

-- HIRE
select HIRE_ID, COUNT(*)
from MonEquip.HIRE
group by HIRE_ID
having count(*) > 1;

-- SALES
select SALES_ID, COUNT(*)
from MonEquip.SALES
group by SALES_ID
having count(*) > 1;

-- STAFF
select STAFF_ID, COUNT(*)
from MonEquip.STAFF
group by STAFF_ID
having count(*) > 1;

select FIRST_NAME, LAST_NAME, PHONE, COUNT(*)
from MonEquip.STAFF
group by FIRST_NAME, LAST_NAME, PHONE
having count(*) > 1;











-- relationship problems
-- CUSTOMER
select * 
from MonEquip.CUSTOMER
where ADDRESS_ID not in 
(select ADDRESS_ID
from MonEquip.ADDRESS);

select * 
from MonEquip.CUSTOMER
where CUSTOMER_TYPE_ID not in 
(select CUSTOMER_TYPE_ID
from MonEquip.CUSTOMER_TYPE);

-- EQUIPMENT
select * 
from MonEquip.EQUIPMENT
where CATEGORY_ID not in 
(select CATEGORY_ID
from MonEquip.CATEGORY);

-- HIRE **
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

-- SALES
select * 
from MonEquip.SALES
where EQUIPMENT_ID not in 
(select EQUIPMENT_ID
from MonEquip.EQUIPMENT);

select * 
from MonEquip.SALES
where STAFF_ID not in 
(select STAFF_ID
from MonEquip.STAFF); 

select * 
from MonEquip.SALES
where CUSTOMER_ID not in 
(select CUSTOMER_ID
from MonEquip.CUSTOMER); 









-- inconsistent values
-- transaction from April 2018 to December 2020

-- CUSTOMER **
select *
from MonEquip.CUSTOMER
where GENDER not in ('Male', 'Female'); -- inconsistent values (Male, Female) vs (M, F)

-- HIRE ** 
select * 
from MonEquip.HIRE
WHERE START_DATE < DATE '2018-04-01' OR END_DATE > DATE '2020-12-31'; -- invalid date (not within transaction period)

-- SALES
select * 
from MonEquip.SALES
WHERE SALES_DATE < DATE '2018-04-01' OR SALES_DATE > DATE '2020-12-31'; -- invalid date (not within transaction period) XX

-- STAFF
select *
from MonEquip.STAFF
where GENDER not in ('Male', 'Female'); -- inconsistent values (Male, Female) vs (M, F)

-- EQUIPMENT
select distinct manufacturer
from MonEquip.EQUIPMENT
order by manufacturer;










-- incorrect values/ invalid values
-- ADDRESS
select *
from MonEquip.ADDRESS
where length(POSTCODE) != 4; -- postcode invalid

-- select distinct STATE
-- from MonEquip.ADDRESS; -- invalid state values

select *
from MonEquip.ADDRESS
where STREET_NUMBER <= 0; -- street number issue

-- CUSTOMER
select * 
from MonEquip.CUSTOMER
where length(PHONE) < 8; -- invalid phone

select *
from MonEquip.CUSTOMER
where EMAIL not like '%@%'; -- invalid email

-- EQUIPMENT
select * 
from MonEquip.EQUIPMENT
where EQUIPMENT_PRICE <= 0; -- negative or zero price

-- HIRE **
select * 
from MonEquip.Hire
where UNIT_HIRE_PRICE <= 0 OR TOTAL_HIRE_PRICE < 0; -- negative total_hire_price

select * 
from MonEquip.HIRE
where TOTAL_HIRE_PRICE != ((End_Date - Start_Date) * Unit_Hire_Price * Quantity); -- revenue formula mismatch

select * 
from MonEquip.HIRE
where End_Date < Start_Date; -- invalid date

SELECT * 
from MonEquip.HIRE
WHERE Quantity <= 0; -- quantity issue XX

-- SALES **
SELECT * 
from MonEquip.SALES
WHERE Quantity <= 0; -- quantity issue

SELECT * 
from MonEquip.SALES
WHERE Total_Sales_Price != Unit_Sales_Price * Quantity; -- revenue mismatch

-- STAFF
select * 
from MonEquip.STAFF
where length(PHONE) < 8; -- invalid phone

select *
from MonEquip.STAFF
where EMAIL not like '%@%'; -- invalid email











-- null values problem
-- PK or FK, numeric or calculated fields, mandatory business attributes cannot be null

-- ADDRESS
select *
from MonEquip.ADDRESS
where ADDRESS_ID is null; 

select * 
from MonEquip.ADDRESS
where STREET_NAME is null or SUBURB is null or STATE is null or POSTCODE is null;

-- CATEGORY 
select *
from MonEquip.CATEGORY
where CATEGORY_ID is null or CATEGORY_DESCRIPTION is null;

-- CUSTOMER 
select *
from MonEquip.CUSTOMER
where CUSTOMER_ID is null or CUSTOMER_TYPE_ID is null or ADDRESS_ID is null; 

-- select *
-- from MonEquip.CUSTOMER
-- where NAME is null or PHONE is null or EMAIL is null; 

-- EQUIPMENT
select * 
from MonEquip.EQUIPMENT
where EQUIPMENT_ID is null or EQUIPMENT_PRICE is null or EQUIPMENT_NAME is null or MANUFACTURER is null or MANUFACTURE_YEAR is null;

-- HIRE
select * 
from MonEquip.HIRE
where EQUIPMENT_ID is null or CUSTOMER_ID is null or STAFF_ID is null or UNIT_HIRE_PRICE is null or TOTAL_HIRE_PRICE is null;

-- SALES
select * 
from MonEquip.SALES
where SALES_ID is null or CUSTOMER_ID is null or STAFF_ID is null or UNIT_SALES_PRICE is null or TOTAL_SALES_PRICE is null or EQUIPMENT_ID  is null;

-- STAFF
select * 
from MonEquip.STAFF
where STAFF_ID is null or COMPANY_BRANCH is null;

-- select * 
-- from MonEquip.STAFF
-- where FIRST_NAME is null or LAST_NAME is null or PHONE is null or EMAIL is null;









-- NEW NULL METHOD

-- ADDRESS
select *
from MonEquip.ADDRESS
where ADDRESS_ID is null
   or trim(ADDRESS_ID) = '' or upper(trim(ADDRESS_ID)) = 'NULL'
   or trim(STREET_NAME) = '' or upper(trim(STREET_NAME)) = 'NULL'
   or trim(SUBURB) = '' or upper(trim(SUBURB)) = 'NULL'
   or trim(STATE) = '' or upper(trim(STATE)) = 'NULL'
   or trim(POSTCODE) = '' or upper(trim(POSTCODE)) = 'NULL';

-- CATEGORY 
select *
from MonEquip.CATEGORY
where CATEGORY_ID is null
   or trim(CATEGORY_ID) = ''
   or upper(trim(CATEGORY_ID)) = 'NULL'
   or CATEGORY_DESCRIPTION is null
   or trim(CATEGORY_DESCRIPTION) = ''
   or upper(trim(CATEGORY_DESCRIPTION)) = 'NULL';

-- CUSTOMER 
select *
from MonEquip.CUSTOMER
where CUSTOMER_ID is null
   or trim(CUSTOMER_ID) = ''
   or upper(trim(CUSTOMER_ID)) = 'NULL'
   or CUSTOMER_TYPE_ID is null
   or trim(CUSTOMER_TYPE_ID) = ''
   or upper(trim(CUSTOMER_TYPE_ID)) = 'NULL'
   or ADDRESS_ID is null
   or trim(ADDRESS_ID) = ''
   or upper(trim(ADDRESS_ID)) = 'NULL'
   or NAME is null or trim(NAME) = '' or upper(trim(NAME)) = 'NULL'
   or PHONE is null or trim(PHONE) = '' or upper(trim(PHONE)) = 'NULL'
   or EMAIL is null or trim(EMAIL) = '' or upper(trim(EMAIL)) = 'NULL';

-- EQUIPMENT
select *
from MonEquip.EQUIPMENT
where EQUIPMENT_ID is null or trim(EQUIPMENT_ID) = '' or upper(trim(EQUIPMENT_ID)) = 'NULL'
   or EQUIPMENT_PRICE is null
   or EQUIPMENT_NAME is null or trim(EQUIPMENT_NAME) = '' or upper(trim(EQUIPMENT_NAME)) = 'NULL'
   or MANUFACTURER is null or trim(MANUFACTURER) = '' or upper(trim(MANUFACTURER)) = 'NULL'
   or MANUFACTURE_YEAR is null;

-- HIRE
select *
from MonEquip.HIRE
where EQUIPMENT_ID is null or trim(EQUIPMENT_ID) = '' or upper(trim(EQUIPMENT_ID)) = 'NULL'
   or CUSTOMER_ID is null or trim(CUSTOMER_ID) = '' or upper(trim(CUSTOMER_ID)) = 'NULL'
   or STAFF_ID is null or trim(STAFF_ID) = '' or upper(trim(STAFF_ID)) = 'NULL'
   or UNIT_HIRE_PRICE is null
   or TOTAL_HIRE_PRICE is null;

-- SALES
select *
from MonEquip.SALES
where SALES_ID is null or trim(SALES_ID) = '' or upper(trim(SALES_ID)) = 'NULL'
   or CUSTOMER_ID is null or trim(CUSTOMER_ID) = '' or upper(trim(CUSTOMER_ID)) = 'NULL'
   or STAFF_ID is null or trim(STAFF_ID) = '' or upper(trim(STAFF_ID)) = 'NULL'
   or UNIT_SALES_PRICE is null
   or TOTAL_SALES_PRICE is null
   or EQUIPMENT_ID is null or trim(EQUIPMENT_ID) = '' or upper(trim(EQUIPMENT_ID)) = 'NULL';

-- STAFF
select *
from MonEquip.STAFF
where STAFF_ID is null or trim(STAFF_ID) = '' or upper(trim(STAFF_ID)) = 'NULL'
   or COMPANY_BRANCH is null or trim(COMPANY_BRANCH) = '' or upper(trim(COMPANY_BRANCH)) = 'NULL';


