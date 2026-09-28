Create Table Warehouse
(WarehouseID  Varchar2(10) Not Null,
 Location     Varchar2(10) Not Null,
 Primary Key (WarehouseID)
);

Create Table Truck
(TruckID        Varchar2(10) Not Null,
 VolCapacity    Number(5,2), 
 WeightCategory Varchar2(10),
 CostPerKm      Number(5,2),
 Primary Key (TruckID)
);

Create Table Trip 
(TripID   Varchar2(10) Not Null,
 TripDate Date,
 TotalKm  Number(5),
 TruckID  Varchar2(10),
 Primary Key (TripID),
 Foreign Key (TruckID) References Truck(TruckID)
);

Create Table TripFrom
(TripID      Varchar2(10) Not Null,
 WarehouseID Varchar2(10) Not Null,
 Primary Key (TripID, WarehouseID),
 Foreign Key (TripID) References Trip(TripID),
 Foreign Key (WarehouseID) References Warehouse(WarehouseID)
);

Create Table Store
(StoreID      Varchar2(10) Not Null,
 StoreName    Varchar2(20),
 StoreAddress Varchar2(20),
 Primary Key (StoreID)
);

Create Table Destination
(TripID       Varchar2(10) Not Null,
 StoreID      Varchar2(10) Not Null,
 Primary Key (TripID, StoreID),
 Foreign Key (TripID) References Trip(TripID),
 Foreign Key (StoreID) References Store(StoreID)
);

--Insert Records to Operational Database
Insert Into Warehouse Values ('W1','Warehouse1');
Insert Into Warehouse Values ('W2','Warehouse2');
Insert Into Warehouse Values ('W3','Warehouse3');
Insert Into Warehouse Values ('W4','Warehouse4');
Insert Into Warehouse Values ('W5','Warehouse5');

Insert Into Truck Values ('Truck1', 250, 'Medium', 1.2);
Insert Into Truck Values ('Truck2', 300, 'Medium', 1.5);
Insert Into Truck Values ('Truck3', 100, 'Small',  0.8);
Insert Into Truck Values ('Truck4', 550, 'Large',  2.3);
Insert Into Truck Values ('Truck5', 650, 'Large',  2.5);

Insert Into Trip Values ('Trip1', to_date('14-Apr-2013', 'DD-MON-YYYY'), 370, 'Truck1');
Insert Into Trip Values ('Trip2', to_date('14-Apr-2013', 'DD-MON-YYYY'), 570, 'Truck2');
Insert Into Trip Values ('Trip3', to_date('14-Apr-2013', 'DD-MON-YYYY'), 250, 'Truck3');
Insert Into Trip Values ('Trip4', to_date('15-Jul-2013', 'DD-MON-YYYY'), 450, 'Truck1');
Insert Into Trip Values ('Trip5', to_date('15-Jul-2013', 'DD-MON-YYYY'), 175, 'Truck2');

Insert Into TripFrom Values ('Trip1', 'W1');
Insert Into TripFrom Values ('Trip1', 'W4');
Insert Into TripFrom Values ('Trip1', 'W5');
Insert Into TripFrom Values ('Trip2', 'W1');
Insert Into TripFrom Values ('Trip2', 'W2');
Insert Into TripFrom Values ('Trip3', 'W1');
Insert Into TripFrom Values ('Trip3', 'W5');
Insert Into TripFrom Values ('Trip4', 'W1');
Insert Into TripFrom Values ('Trip5', 'W4');
Insert Into TripFrom Values ('Trip5', 'W5');

Insert Into Store Values ('M1', 'Myer City', 'Melbourne');
Insert Into Store Values ('M2', 'Myer Chaddy', 'Chadstone');
Insert Into Store Values ('M3', 'Myer HiPoint', 'High Point');
Insert Into Store Values ('M4', 'Myer West', 'Doncaster');
Insert Into Store Values ('M5', 'Myer North', 'Northland');
Insert Into Store Values ('M6', 'Myer South', 'Southland');
Insert Into Store Values ('M7', 'Myer East', 'Eastland');
Insert Into Store Values ('M8', 'Myer Knox', 'Knox');

Insert Into Destination Values ('Trip1', 'M1');
Insert Into Destination Values ('Trip1', 'M2');
Insert Into Destination Values ('Trip1', 'M4');
Insert Into Destination Values ('Trip1', 'M3');
Insert Into Destination Values ('Trip1', 'M8');
Insert Into Destination Values ('Trip2', 'M4');
Insert Into Destination Values ('Trip2', 'M1');
Insert Into Destination Values ('Trip2', 'M2');

-- Insert Statements for Trips 3,4,5
Insert into Destination Values ('Trip3', 'M1');
Insert into Destination Values ('Trip3', 'M5');
Insert into Destination Values ('Trip3', 'M6');

Insert into Destination Values ('Trip4', 'M5');
Insert into Destination Values ('Trip4', 'M6');
Insert into Destination Values ('Trip4', 'M7');
Insert into Destination Values ('Trip4', 'M8');

Insert into Destination Values ('Trip5', 'M3');
Insert into Destination Values ('Trip5', 'M7');






-------------------- Model 1: using a Bridge Table ----------------
-- a.
Create table TruckDim1 as
Select *
From Truck;

-- b.
Drop table TripSeasonTempDim1;

Create table TripSeasonTempDim1 as 
select 
    extract(month from TRIPDATE) as Month,
    extract(year from TRIPDATE) as Year
from Trip;

Alter table TripSeasonTempDim1 add(
    SeasonID Varchar2(10),
    Seasonperiod Varchar2(10)
);

update TripSeasonTempDim1
set Seasonperiod = 'Spring'
where Month in (9,10,11);

update TripSeasonTempDim1
set Seasonperiod = 'Summer'
where Month in (12,01,02);

update TripSeasonTempDim1
set Seasonperiod = 'Autumn'
where Month in (03,04,05);

update TripSeasonTempDim1
set Seasonperiod = 'Winter'
where Month in (06,07,08);

update TripSeasonTempDim1
set SeasonID = 'S1'
where Seasonperiod = 'Spring';

update TripSeasonTempDim1
set SeasonID = 'S2'
where Seasonperiod = 'Summer';

update TripSeasonTempDim1
set SeasonID = 'S3'
where Seasonperiod = 'Autumn';

update TripSeasonTempDim1
set SeasonID = 'S4'
where Seasonperiod = 'Winter';

create table TripSeasonDim1 as
select distinct SeasonID, Seasonperiod
from TripSeasonTempDim1;

-- Insert into TripSeason1 Values ('S1', 'Summer');
-- Insert into TripSeason1 Values ('S2', 'Autumn');
-- Insert into TripSeason1 Values ('S3', 'Winter');
-- Insert into TripSeason1 Values ('S4', 'Spring');

-- c.
Create table TripDim1 as
Select TRIPID, TRIPDATE, TOTALKM
From Trip;

-- d.
Create table BridgeTableDim1 as
Select *
From Destination;

-- e.
Create table StoreDim1 as
Select *
From Store;

-- f.
Drop table tempfact;
Create table tempfact as
Select R.TruckID, R.TripID, T.CostPerKM, R.TotalKM,
extract(month from TRIPDATE) as Month,
extract(year from TRIPDATE) as Year
From Truck T 
Join Trip R on T.TRUCKID = R.TRUCKID;

ALTER table tempfact
add (Seasonperiod Varchar(20));

update tempfact
set Seasonperiod = 'Spring'
where Month in (9,10,11);

update tempfact
set Seasonperiod = 'Summer'
where Month in (12,01,02);

update tempfact
set Seasonperiod = 'Autumn'
where Month in (03,04,05);

update tempfact
set Seasonperiod = 'Winter'
where Month in (06,07,08);

ALTER table tempfact
add (SeasonID Varchar(20));

update tempfact
set SeasonID = 'S1'
where Seasonperiod = 'Spring';

update tempfact
set SeasonID = 'S2'
where Seasonperiod = 'Summer';

update tempfact
set SeasonID = 'S3'
where Seasonperiod = 'Autumn';

update tempfact
set SeasonID = 'S4'
where Seasonperiod = 'Winter';

Create table TruckFact1 as
Select TruckID, SeasonID, TripID, (CostPerKM * TotalKM) as Total_Delivery_Cost
From tempfact;

-- Display
select * from TruckFact1;

-------------------- Model 2: add a Weight attribute in the Bridge ----------------
-- a.
Create table TruckDim2 as
select * 
from Truck;

-- b.
Drop table TripSeasonTempDim2;

Create table TripSeasonTempDim2 as 
select 
    extract(month from TRIPDATE) as Month,
    extract(year from TRIPDATE) as Year
from Trip;

Alter table TripSeasonTempDim2 add(
    SeasonID Varchar2(10),
    Seasonperiod Varchar2(10)
);

update TripSeasonTempDim2
set Seasonperiod = 'Spring'
where Month in (9,10,11);

update TripSeasonTempDim2
set Seasonperiod = 'Summer'
where Month in (12,01,02);

update TripSeasonTempDim2
set Seasonperiod = 'Autumn'
where Month in (03,04,05);

update TripSeasonTempDim2
set Seasonperiod = 'Winter'
where Month in (06,07,08);

update TripSeasonTempDim2
set SeasonID = 'S1'
where Seasonperiod = 'Spring';

update TripSeasonTempDim2
set SeasonID = 'S2'
where Seasonperiod = 'Summer';

update TripSeasonTempDim2
set SeasonID = 'S3'
where Seasonperiod = 'Autumn';

update TripSeasonTempDim2
set SeasonID = 'S4'
where Seasonperiod = 'Winter';

create table TripSeasonDim2 as
select distinct SeasonID, Seasonperiod
from TripSeasonTempDim2;


-- d.
Create table BridgeTableDim2 as
Select *
From Destination;

-- e.
Create table StoreDim2 as
Select *
From Store;

-- from the answers c.
-- select statements to construct
select * from trip;
select * from destination;

select t.tripid, t.tripdate, t.totalkm, count(*)
from trip t, destination d
where t.tripid = d.tripid
group by t.tripid, t.tripdate, t.totalkm;

select t.tripid, t.tripdate, t.totalkm, 1.0/count(*)
from trip t, destination d
where t.tripid = d.tripid
group by t.tripid, t.tripdate, t.totalkm;

-- final ans
Create Table TripDim2 As
select t.tripid, t.tripdate, t.totalkm, 1.0/count(*) as weightfactor
from trip t, destination d
where t.tripid = d.tripid
group by t.tripid, t.tripdate, t.totalkm;

-- f.
Drop table tempfact2;
Create table tempfact2 as
Select R.TruckID, R.TripID, T.CostPerKM, R.TotalKM,
extract(month from TRIPDATE) as Month,
extract(year from TRIPDATE) as Year
From Truck T 
Join Trip R on T.TRUCKID = R.TRUCKID;

ALTER table tempfact2
add (Seasonperiod Varchar(20));

update tempfact2
set Seasonperiod = 'Spring'
where Month in (9,10,11);

update tempfact2
set Seasonperiod = 'Summer'
where Month in (12,01,02);

update tempfact2
set Seasonperiod = 'Autumn'
where Month in (03,04,05);

update tempfact2
set Seasonperiod = 'Winter'
where Month in (06,07,08);

ALTER table tempfact2
add (SeasonID Varchar(20));

update tempfact2
set SeasonID = 'S1'
where Seasonperiod = 'Spring';

update tempfact2
set SeasonID = 'S2'
where Seasonperiod = 'Summer';

update tempfact2
set SeasonID = 'S3'
where Seasonperiod = 'Autumn';

update tempfact2
set SeasonID = 'S4'
where Seasonperiod = 'Winter';

Create table TruckFact2 as
Select TruckID, SeasonID, TripID, (CostPerKM * TotalKM) as Total_Delivery_Cost
From tempfact2;

-- g.
Select S.StoreId, S.StoreName,
  sum(Total_delivery_Cost * Weight_Factor) as "Total Cost for Store"
from
  TruckFact2 F, TripDim2 T,
  StoreDim2 S, BridgeTableDim2 B
where F.TripId = T.TripId
and   T.TripId = B.TripId
and   B.StoreId = S.StoreId
group by S.StoreId, S.StoreName
order by S.StoreId, S.StoreName;

-------------------------- Model 3: A ListAGG version ----------------------------------
-- a.
Create table TruckDim3 as
select * 
from Truck;

-- b.
Drop table TripSeasonTempDim3;

Create table TripSeasonTempDim3 as 
select 
    extract(month from TRIPDATE) as Month,
    extract(year from TRIPDATE) as Year
from Trip;

Alter table TripSeasonTempDim3 add(
    SeasonID Varchar2(10),
    Seasonperiod Varchar2(10)
);

update TripSeasonTempDim3
set Seasonperiod = 'Spring'
where Month in (9,10,11);

update TripSeasonTempDim3
set Seasonperiod = 'Summer'
where Month in (12,01,02);

update TripSeasonTempDim3
set Seasonperiod = 'Autumn'
where Month in (03,04,05);

update TripSeasonTempDim3
set Seasonperiod = 'Winter'
where Month in (06,07,08);

update TripSeasonTempDim3
set SeasonID = 'S1'
where Seasonperiod = 'Spring';

update TripSeasonTempDim3
set SeasonID = 'S2'
where Seasonperiod = 'Summer';

update TripSeasonTempDim3
set SeasonID = 'S3'
where Seasonperiod = 'Autumn';

update TripSeasonTempDim3
set SeasonID = 'S4'
where Seasonperiod = 'Winter';

create table TripSeasonTempDim3 as
select distinct SeasonID, Seasonperiod
from TripSeasonTempDim3;

-- c.
Create table StoreDim3 as
Select *
From Store;

-- d.
Create table BridgeTableDim3 as
Select *
From Destination;

-- e. from the answers
Select T.TripID, T.TripDate, T.TotalKm, 1.0/count(D.StoreID) As
WeightFactor , LISTAGG (D.StoreID, '_') Within Group (Order By D.StoreID) 
As StoreGroupList
From Trip T, Destination D
Where T.TripID = D.TripID
Group By T.TripID, T.TripDate, T.TotalKm;


Create Table TripDim3 As
Select T.TripID, T.TripDate, T.TotalKm, 1.0/count(D.StoreID) As WeightFactor , LISTAGG (D.StoreID, '_') Within Group (Order By D.StoreID) As StoreGroupList
From Trip T, Destination D
Where T.TripID = D.TripID
Group By T.TripID, T.TripDate, T.TotalKm;


-- f.
Drop table tempfact3;
Create table tempfact3 as
Select R.TruckID, R.TripID, T.CostPerKM, R.TotalKM,
extract(month from TRIPDATE) as Month,
extract(year from TRIPDATE) as Year
From Truck T 
Join Trip R on T.TRUCKID = R.TRUCKID;

ALTER table tempfact3
add (Seasonperiod Varchar(20));

update tempfact3
set Seasonperiod = 'Spring'
where Month in (9,10,11);

update tempfact3
set Seasonperiod = 'Summer'
where Month in (12,01,02);

update tempfact3
set Seasonperiod = 'Autumn'
where Month in (03,04,05);

update tempfact3
set Seasonperiod = 'Winter'
where Month in (06,07,08);

ALTER table tempfact3
add (SeasonID Varchar(20));

update tempfact3
set SeasonID = 'S1'
where Seasonperiod = 'Spring';

update tempfact3
set SeasonID = 'S2'
where Seasonperiod = 'Summer';

update tempfact3
set SeasonID = 'S3'
where Seasonperiod = 'Autumn';

update tempfact3
set SeasonID = 'S4'
where Seasonperiod = 'Winter';

Create table TruckFact3 as
Select TruckID, SeasonID, TripID, (CostPerKM * TotalKM) as Total_Delivery_Cost
From tempfact3;

