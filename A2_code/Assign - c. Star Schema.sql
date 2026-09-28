-- DESIGN TASK A
-- DIMENSIONS
SELECT * FROM ADDRESS;
SELECT * FROM STAFF;
SELECT * FROM EQUIPMENT;
SELECT * FROM HIRE;
SELECT * FROM CATEGORY;
SELECT * FROM SALES;
SELECT * FROM CUSTOMER;
SELECT * FROM CUSTOMER_TYPE;

select categoryID, avg(total_sales_prices)
from SalesFACT
where categoryID = 14
group by categoryID;

DESC ADDRESS;
DESC STAFF;
DESC EQUIPMENT;
DESC HIRE;
DESC CATEGORY;
DESC SALES;
DESC CUSTOMER;
DESC CUSTOMER_TYPE;

DROP TABLE TimeDIM;
DROP TABLE SalesFACT;
DROP TABLE SalesPriceScaleDIM;
DROP TABLE BranchDIM;
DROP TABLE CategoryDIM;
DROP TABLE CustomerTypeDIM;
DROP TABLE HireFACT;

SELECT * FROM TimeDIM;
SELECT * FROM SalesFACT;
SELECT * FROM SalesPriceScaleDIM;
SELECT * FROM BranchDIM;
SELECT * FROM CategoryDIM;
SELECT * FROM CustomerTypeDIM;
SELECT * FROM HireFACT;

DESC TimeDim;
DESC SalesFACT;
DESC SalesPriceScaleDIM;
DESC BranchDIM;
DESC CategoryDIM;
DESC CustomerTypeDIM;
DESC HireFACT;

-- TIME
CREATE TABLE TimeDIM AS
SELECT DISTINCT
    TO_NUMBER(TO_CHAR(dt, 'YYYYMM')) AS TimeID,  -- surrogate key
    TO_NUMBER(TO_CHAR(dt, 'MM')) AS Month,
    TO_NUMBER(TO_CHAR(dt, 'YYYY')) AS Year
FROM (
    SELECT START_DATE AS dt FROM HIRE
    UNION
    SELECT SALES_DATE AS dt FROM SALES
);

ALTER TABLE TimeDIM ADD(
    Season VARCHAR2(20)
);

UPDATE TimeDIM
SET Season = CASE
    WHEN Month BETWEEN 9 AND 11 THEN 'Spring'
    WHEN Month IN (12, 1, 2)   THEN 'Summer'
    WHEN Month BETWEEN 3 AND 5 THEN 'Autumn'
    WHEN Month BETWEEN 6 AND 8 THEN 'Winter'
END;


-- CUSTOMER TYPE
CREATE TABLE CustomerTypeDIM AS
SELECT CUSTOMER_TYPE_ID AS CustomerTypeID, DESCRIPTION AS CustomerTypeDesc
FROM CUSTOMER_TYPE;

-- CATEGORY
CREATE TABLE CategoryDIM AS
SELECT CATEGORY_ID AS CategoryID, CATEGORY_DESCRIPTION as CategoryDesc
FROM CATEGORY;

-- BRANCH
CREATE TABLE BranchDIM AS
SELECT DISTINCT COMPANY_BRANCH AS BranchName
FROM STAFF;


-- SalesPriceScaleDIM
CREATE TABLE SalesPriceScaleDIM (
    SalesPriceScaleID NUMBER(1) PRIMARY KEY,
    SalesPriceScaleDesc VARCHAR2(20),
    MinValue NUMBER(7),
    MaxValue NUMBER(7)
);

INSERT INTO SalesPriceScaleDIM (SalesPriceScaleID, SalesPriceScaleDesc, MinValue, MaxValue)
VALUES (1, 'Low', 0, 4999);

INSERT INTO SalesPriceScaleDIM (SalesPriceScaleID, SalesPriceScaleDesc, MinValue, MaxValue)
VALUES (2, 'Medium', 5000, 10000);

INSERT INTO SalesPriceScaleDIM (SalesPriceScaleID, SalesPriceScaleDesc, MinValue, MaxValue)
VALUES (3, 'High', 10001, NULL);



-- SalesFACT
CREATE TABLE SalesFACT AS
SELECT
    -- Time surrogate key (YYYYMM)
    TO_NUMBER(TO_CHAR(sal.SALES_DATE, 'YYYYMM')) AS TimeID,
    e.CATEGORY_ID AS CategoryID,
    
    -- Sales price scale (bucket by total sales price)
    CASE 
        WHEN sal.UNIT_SALES_PRICE < 5000 THEN 1
        WHEN sal.UNIT_SALES_PRICE BETWEEN 5000 AND 10000 THEN 2
        ELSE 3
    END AS SalesPriceScaleID,

    sal.QUANTITY AS Quantity_Sold,
    sal.TOTAL_SALES_PRICE AS Total_Sales_Prices
FROM SALES sal
JOIN EQUIPMENT e ON sal.EQUIPMENT_ID = e.EQUIPMENT_ID;



-- HireFACT
CREATE TABLE HireFACT AS
SELECT
    -- Time surrogate key (YYYYMM)
    TO_NUMBER(TO_CHAR(h.START_DATE, 'YYYYMM')) AS TimeID,
      
    e.CATEGORY_ID AS CategoryID,
    c.CUSTOMER_TYPE_ID AS CustomerTypeID,
    s.COMPANY_BRANCH AS BranchName,
    
    h.QUANTITY AS Quantity_Hired,
    h.TOTAL_HIRE_PRICE AS Total_Hire_Prices
FROM HIRE h
JOIN EQUIPMENT e ON h.EQUIPMENT_ID = e.EQUIPMENT_ID
JOIN CUSTOMER c ON h.CUSTOMER_ID = c.CUSTOMER_ID
JOIN STAFF s ON h.STAFF_ID = s.STAFF_ID;

-- SeasonDim Tutorial 4 (where Month)
-- SalesPriceScale Tutorial 4 (where Total_Sales_Price)

commit;
