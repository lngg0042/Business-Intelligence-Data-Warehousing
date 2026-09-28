-- 14.1 Computer Lab Usage SQL Schema
-- Level 2 Star Schema (Highly Aggregated)
-- Dimension Tables
CREATE TABLE SemesterDIM (
    SemesterID VARCHAR(10) PRIMARY KEY,
    SemesterDescription VARCHAR(50),
    StartDate DATE,
    EndDate DATE
);

CREATE TABLE TimePeriodDIM (
    TimeID INT PRIMARY KEY,
    TimeDescription VARCHAR(50),
    StartTime TIME,
    EndTime TIME
);

CREATE TABLE DegreeDIM (
    DegreeCode VARCHAR(10) PRIMARY KEY,
    DegreeName VARCHAR(100),
    DegreeDuration INT,
    Faculty VARCHAR(100)
);

-- Fact Table
CREATE TABLE ComputerLabFACT_Level2 (
    SemesterID VARCHAR(10),
    TimeID INT,
    DegreeCode VARCHAR(10),
    Num_of_Logins INT,
    PRIMARY KEY (SemesterID, TimeID, DegreeCode),
    FOREIGN KEY (SemesterID) REFERENCES SemesterDIM(SemesterID),
    FOREIGN KEY (TimeID) REFERENCES TimePeriodDIM(TimeID),
    FOREIGN KEY (DegreeCode) REFERENCES DegreeDIM(DegreeCode)
);

-- Level 1 Star Schema (More Detailed)
-- Dimension Tables
CREATE TABLE SemesterDIM (
    SemesterID VARCHAR(10) PRIMARY KEY,
    SemesterDescription VARCHAR(50),
    StartDate DATE,
    EndDate DATE
);

CREATE TABLE TimePeriodDIM (
    TimeID INT PRIMARY KEY,
    TimeDescription VARCHAR(50),
    StartTime TIME,
    EndTime TIME
);

CREATE TABLE DegreeDIM (
    DegreeCode VARCHAR(10) PRIMARY KEY,
    DegreeName VARCHAR(100),
    DegreeDuration INT,
    Faculty VARCHAR(100)
);

-- Fact Table
CREATE TABLE ComputerLabFACT_Level2 (
    SemesterID VARCHAR(10),
    TimeID INT,
    DegreeCode VARCHAR(10),
    Num_of_Logins INT,
    PRIMARY KEY (SemesterID, TimeID, DegreeCode),
    FOREIGN KEY (SemesterID) REFERENCES SemesterDIM(SemesterID),
    FOREIGN KEY (TimeID) REFERENCES TimePeriodDIM(TimeID),
    FOREIGN KEY (DegreeCode) REFERENCES DegreeDIM(DegreeCode)
);

-- Level 0 Star Schema (Most Detailed/ No Aggregation)
-- Dimension Tables (Replaced)
CREATE TABLE LoginDateDIM (
    LoginDate DATE PRIMARY KEY
);

CREATE TABLE LoginTimeDIM (
    LoginTime TIME PRIMARY KEY
);

-- Fact Table (No Fact Measure)
CREATE TABLE ComputerLabFACT_Level0 (
    LoginDate DATE,
    LoginTime TIME,
    DegreeCode VARCHAR(10),
    StudentNo INT,
    -- Num_of_Logins is omitted as it would always be 1
    PRIMARY KEY (LoginDate, LoginTime, DegreeCode, StudentNo),
    FOREIGN KEY (LoginDate) REFERENCES LoginDateDIM(LoginDate),
    FOREIGN KEY (LoginTime) REFERENCES LoginTimeDIM(LoginTime),
    FOREIGN KEY (DegreeCode) REFERENCES DegreeDIM(DegreeCode),
    FOREIGN KEY (StudentNo) REFERENCES StudentDIM(StudentNo)
);


-- 14.2 Purchase Order SQL Schemas
-- Level 4 Star Schema
CREATE TABLE LocationDIM (
    Postcode VARCHAR(10),
    Suburb VARCHAR(50),
    PRIMARY KEY (Postcode, Suburb)
);

CREATE TABLE SeasonDIM (
    SeasonID VARCHAR(10) PRIMARY KEY,
    SeasonDesc VARCHAR(50),
    StartDate DATE,
    EndDate DATE
);

CREATE TABLE OrderingMethodDIM (
    OrderingMethod VARCHAR(20) PRIMARY KEY
);

CREATE TABLE PurchaseOrderFACT_Level4 (
    Postcode VARCHAR(10),
    Suburb VARCHAR(50),
    SeasonID VARCHAR(10),
    OrderingMethod VARCHAR(20),
    TotalOrderQuantity INT,
    TotalOrderCost DECIMAL(15,2),
    PRIMARY KEY (Postcode, Suburb, SeasonID, OrderingMethod),
    FOREIGN KEY (Postcode, Suburb) REFERENCES LocationDIM(Postcode, Suburb),
    FOREIGN KEY (SeasonID) REFERENCES SeasonDIM(SeasonID),
    FOREIGN KEY (OrderingMethod) REFERENCES OrderingMethodDIM(OrderingMethod)
);

-- Level 3 Star Schema
CREATE TABLE OrderDateDIM (
    OrderDate DATE PRIMARY KEY
);

CREATE TABLE PurchaseOrderFACT_Level3 (
    Postcode VARCHAR(10),
    Suburb VARCHAR(50),
    OrderDate DATE,
    OrderingMethod VARCHAR(20),
    TotalOrderQuantity INT,
    TotalOrderCost DECIMAL(15,2),
    PRIMARY KEY (Postcode, Suburb, OrderDate, OrderingMethod),
    FOREIGN KEY (Postcode, Suburb) REFERENCES LocationDIM(Postcode, Suburb),
    FOREIGN KEY (OrderDate) REFERENCES OrderDateDIM(OrderDate),
    FOREIGN KEY (OrderingMethod) REFERENCES OrderingMethodDIM(OrderingMethod)
);

-- Level 2 Star Schema
CREATE TABLE CustomerDIM (
    CustID INT PRIMARY KEY,
    LastName VARCHAR(50),
    FirstName VARCHAR(50),
    Address VARCHAR(100),
    Suburb VARCHAR(50),
    Postcode VARCHAR(10)
);

CREATE TABLE PurchaseOrderFACT_Level2 (
    CustID INT,
    OrderDate DATE,
    OrderingMethod VARCHAR(20),
    TotalOrderQuantity INT,
    TotalOrderCost DECIMAL(15,2),
    PRIMARY KEY (CustID, OrderDate, OrderingMethod),
    FOREIGN KEY (CustID) REFERENCES CustomerDIM(CustID),
    FOREIGN KEY (OrderDate) REFERENCES OrderDateDIM(OrderDate),
    FOREIGN KEY (OrderingMethod) REFERENCES OrderingMethodDIM(OrderingMethod)
);

-- Level 1 Star Schema
CREATE TABLE PurchaseOrderDIM (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    PayMethod VARCHAR(20),
    OrderingMethod VARCHAR(20)
);

CREATE TABLE PurchaseOrderFACT_Level1 (
    CustID INT,
    OrderID INT,
    TotalOrderQuantity INT,
    TotalOrderCost DECIMAL(15,2),
    PRIMARY KEY (CustID, OrderID),
    FOREIGN KEY (CustID) REFERENCES CustomerDIM(CustID),
    FOREIGN KEY (OrderID) REFERENCES PurchaseOrderDIM(OrderID)
);

-- Level 0 Star Schemas
-- Minimal Level-0 (Fig. 14.16): Core transaction between Purchase Order and Item.
CREATE TABLE ItemDIM (
    ItemID INT PRIMARY KEY,
    QuantityOnHand INT,
    ProductID INT,
    ProductSize VARCHAR(20),
    ProductColour VARCHAR(20)
);

CREATE TABLE PurchaseOrderFACT_Level0_Minimal (
    OrderID INT,
    ItemID INT,
    TotalOrderQuantity INT, -- This is the quantity for that specific item in the order
    TotalOrderCost DECIMAL(15,2), -- This is (OrderPrice * Quantity) for that line
    PRIMARY KEY (OrderID, ItemID),
    FOREIGN KEY (OrderID) REFERENCES PurchaseOrderDIM(OrderID),
    FOREIGN KEY (ItemID) REFERENCES ItemDIM(ItemID)
);

-- Complete Level-0 (Fig. 14.15): Includes all related dimensions (Customer, Product).
CREATE TABLE ProductDIM (
    ProductID INT PRIMARY KEY,
    CurrentPrice DECIMAL(10,2),
    ProductDescription TEXT,
    ProductCategory VARCHAR(50)
);

CREATE TABLE PurchaseOrderFACT_Level0_Complete (
    CustID INT,
    OrderID INT,
    ItemID INT,
    ProductID INT,
    TotalOrderQuantity INT,
    TotalOrderCost DECIMAL(15,2),
    PRIMARY KEY (OrderID, ItemID), -- Core transaction is still (OrderID, ItemID)
    FOREIGN KEY (CustID) REFERENCES CustomerDIM(CustID),
    FOREIGN KEY (OrderID) REFERENCES PurchaseOrderDIM(OrderID),
    FOREIGN KEY (ItemID) REFERENCES ItemDIM(ItemID),
    FOREIGN KEY (ProductID) REFERENCES ProductDIM(ProductID)
);

