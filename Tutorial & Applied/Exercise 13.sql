-- 13.1
-- STEP 1: Create Temporary Fact Tables for New Measures
-- 1. NumPropertiesInMarket & TotalDaysInMarket (From Inspection Database)
-- Assumption: A property is "on the market" from its ListedDate until the current date (or until it is sold, but this requires SoldDate from another DB, which complicates the example).
-- For simplicity, this calculates for the month it was listed. A more complex solution would track its status across months.
create table PropertyTempFact5 as
select
    P.Postcode,
    to_char(P.ListedDate, 'YYYYMM') as MonthID,
    0 as TotalPropertiesAuction,
    0 as TotalSuccessfulAuction,
    0 as NumNewListing,
    0 as TotalPropertiesSold,
    0 as TotalSoldPrice,
    count(*) as NumPropertiesInMarket, -- Count of properties newly listed that month
    sum(trunc(sysdate) - trunc(P.ListedDate)) as TotalDaysInMarket, -- Total days on market for that month's listings
    0 as NumPropertiesforInspection,
    0 as NumOfPeopleInspection
from "Inspection.Property" P
group by P.Postcode, to_char(P.ListedDate, 'YYYYMM');

-- 2. NumPropertiesforInspection & NumOfPeopleInspection (From Inspection Database)
create table PropertyTempFact6 as
select
    P.Postcode,
    to_char(I.InspectionDate, 'YYYYMM') as MonthID,
    0 as TotalPropertiesAuction,
    0 as TotalSuccessfulAuction,
    0 as NumNewListing,
    0 as TotalPropertiesSold,
    0 as TotalSoldPrice,
    0 as NumPropertiesInMarket,
    0 as TotalDaysInMarket,
    count(distinct I.PropertyNo) as NumPropertiesforInspection, -- Number of unique properties inspected
    count(*) as NumOfPeopleInspection -- Number of visitor records (if same person inspects multiple times, they are counted multiple times)
from "Inspection.Inspection" I, "Inspection.Property" P, "Inspection.Visitor" V
where I.PropertyNo = P.PropertyNo
and I.InspectionNo = V.InspectionNo
group by P.Postcode, to_char(I.InspectionDate, 'YYYYMM');


-- STEP 2: Modify the Final Fact Table Creation
create table PropertyFact as
select
    Postcode, MonthID,
    sum(TotalPropertiesAuction) as TotalPropertiesAuction,
    sum(TotalSuccessfulAuction) as TotalSuccessfulAuction,
    sum(NumNewListing) as NumNewListing,
    sum(TotalPropertiesSold) as TotalPropertiesSold,
    sum(TotalSoldPrice) as TotalSoldPrice,
    sum(NumPropertiesInMarket) as NumPropertiesInMarket,
    sum(TotalDaysInMarket) as TotalDaysInMarket,
    sum(NumPropertiesforInspection) as NumPropertiesforInspection,
    sum(NumOfPeopleInspection) as NumOfPeopleInspection
from (
    -- Original four temporary fact tables (from pages 34-35)
    select * from PropertyTempFact1
    union all
    select * from PropertyTempFact2
    union all
    select * from PropertyTempFact3
    union all
    select * from PropertyTempFact4
    -- New temporary fact tables for Exercise 13.1
    union all
    select * from PropertyTempFact5
    union all
    select * from PropertyTempFact6
)
group by Postcode, MonthID;


-- EXERCISE 13.2: Integrated Bookshop Star Schema
-- two separate operational databses: In-Shop Sales and Online Sales
-- STEP 1: Create the Dimensions
-- Book Dimension (Combined from both databases)
create table BookDim as
select distinct *
from (
    select B.ISBN, B.Title, B.Description, B.PublishedYear, B.PublisherID, B.CategoryID
    from "InShopSales.Book" B
    union
    select B.ISBN, B.Title, B.Description, B.PublishedYear, B.PublisherID, B.CategoryID
    from "OnlineSales.Book" B
);

-- Time Dimension (Combined from sales dates in both databases)
create table MonthDim as
select distinct *
from (
    select distinct
        to_char(S.SalesDate, 'YYYYMM') as MonthYear,
        to_char(S.SalesDate, 'Q') as Quarter,
        to_char(S.SalesDate, 'YYYY') as Year
    from "InShopSales.Sales" S
    union
    select distinct
        to_char(S.SalesDate, 'YYYYMM') as MonthYear,
        to_char(S.SalesDate, 'Q') as Quarter,
        to_char(S.SalesDate, 'YYYY') as Year
    from "OnlineSales.OnlineSales" S
);




-- STEP 2: Create Temporary Fact Tables from Each Source
-- Fact data from In-Shop Sales
create table InShopTempFact as
select
    SD.ISBN,
    to_char(S.SalesDate, 'YYYYMM') as MonthYear,
    sum(SD.Quantity) as TotalBooksSold,
    sum(SD.TotalPrice) as TotalPrice
from "InShopSales.SalesDetails" SD, "InShopSales.Sales" S
where SD.SalesID = S.SalesID
group by SD.ISBN, to_char(S.SalesDate, 'YYYYMM');

-- Fact data from Online Sales
create table OnlineTempFact as
select
    SD.ISBN,
    to_char(S.SalesDate, 'YYYYMM') as MonthYear,
    sum(SD.Quantity) as TotalBooksSold,
    sum(SD.TotalPrice) as TotalPrice
from "OnlineSales.SalesDetails" SD, "OnlineSales.OnlineSales" S
where SD.SalesID = S.SalesID
group by SD.ISBN, to_char(S.SalesDate, 'YYYYMM');


-- STEP 3: Create the Final Integrated Fact Table
create table BookSalesFact as
select
    ISBN,
    MonthYear,
    sum(TotalBooksSold) as TotalBooksSold,
    sum(TotalPrice) as TotalPrice
from (
    select * from InShopTempFact
    union all
    select * from OnlineTempFact
)
group by ISBN, MonthYear;