-- 5.1
-- Example SQL (create & populate dims + fact)
-- Time dimension (monthly)
create table TimeDim as
select distinct
  to_char(S.SalesDate,'YYYYMM') as TimeID,
  to_char(S.SalesDate,'YYYY') as Year,
  to_char(S.SalesDate,'MM') as Month
from Sales S;

-- Store dimension
create table StoreDim as
select distinct StoreID, StoreName, Address
from Store;

-- Author dimension
create table AuthorDim as
select distinct A.AuthorID, A.AuthorName
from Author A;

-- Category dimension
create table CategoryDim as
select distinct C.CategoryID, C.CategoryName
from Category C;

-- Book dimension
create table BookDim as
select distinct B.BookID, B.Title, B.PublisherID, B.CategoryID, B.AuthorID
from Book B;

-- Fact table: BookSalesFact (one row per SalesDetails line)
create table BookSalesFact as
select
  to_char(S.SalesDate,'YYYYMM')        as TimeID,
  S.StoreID,
  SD.BookID,
  sum(SD.Quantity)                     as QtySold,
  sum(SD.Quantity * SD.UnitPrice)      as TotalPrice
from Sales S
join SalesDetails SD on S.SalesNo = SD.SalesNo
group by to_char(S.SalesDate,'YYYYMM'), S.StoreID, SD.BookID;

-- Example queries that answer the requested questions
-- 1) Total sales for each store in a month (e.g., 202301)
select f.StoreID, st.StoreName, sum(f.TotalPrice) as TotalSales
from BookSalesFact f
join StoreDim st on f.StoreID = st.StoreID
where f.TimeID = '202301'
group by f.StoreID, st.StoreName
order by TotalSales desc;

-- 2) How many books sold in each category (over all time)
select b.CategoryID, c.CategoryName, sum(f.QtySold) as TotalQty
from BookSalesFact f
join BookDim b on f.BookID = b.BookID
join CategoryDim c on b.CategoryID = c.CategoryID
group by b.CategoryID, c.CategoryName
order by TotalQty desc;

-- 3) Category with highest sales (by revenue)
select b.CategoryID, c.CategoryName, sum(f.TotalPrice) as Revenue
from BookSalesFact f
join BookDim b on f.BookID = b.BookID
join CategoryDim c on b.CategoryID = c.CategoryID
group by b.CategoryID, c.CategoryName
order by Revenue desc
fetch first 1 row only;

-- 4) Which author sold highest number of books
select b.AuthorID, a.AuthorName, sum(f.QtySold) as TotalBooksSold
from BookSalesFact f
join BookDim b on f.BookID = b.BookID
join AuthorDim a on b.AuthorID = a.AuthorID
group by b.AuthorID, a.AuthorName
order by TotalBooksSold desc
fetch first 1 row only;


-- 5.2
-- Example SQL (populate dims and fact)
-- Time dimension
create table TimeDim as
select distinct to_char(ContractStartDate,'YYYYMM') as TimeID,
       to_char(ContractStartDate,'YYYY') as Year,
       to_char(ContractStartDate,'MM') as Month
from Contract;

-- Location dimension
create table LocationDim as
select distinct LocationID, City, Region
from Subscriber;    -- or whatever table holds subscriber/store location

-- Channel dimension
create table ChannelDim as
select distinct ChannelID, ChannelName, Genre
from Channel;

-- Contract dimension with ListAgg (stores channels as single string) and WeightFactor
create table ContractDim as
select
  C.ContractID,
  C.SubscriberID,
  C.ContractStartDate,
  C.ContractValue,
  1.0 / count(CC.ChannelID)                as WeightFactor,
  listagg(CC.ChannelID, '_') within group (order by CC.ChannelID) as ChannelList
from Contract C
join ContractChannelBridge CC on C.ContractID = CC.ContractID
group by C.ContractID, C.SubscriberID, C.ContractStartDate, C.ContractValue;

-- Bridge table likely exists in operational DB; create copy
create table ContractChannelBridge as
select ContractID, ChannelID
from ContractChannelBridge_source;  -- adapt to your source name

-- Fact: allocate contract revenue to channels using WeightFactor (approximate)
create table ChannelRevenueFact as
select
  to_char(C.ContractStartDate,'YYYYMM') as TimeID,
  S.LocationID,
  CC.ChannelID,
  count(distinct C.ContractID) as NumContracts,
  sum(C.ContractValue * (1.0 / cnt.channels_per_contract)) as RevenueAllocated
from Contract C
join Subscriber S on C.SubscriberID = S.SubscriberID
join ContractChannelBridge CC on C.ContractID = CC.ContractID
join (
  select ContractID, count(*) as channels_per_contract
  from ContractChannelBridge
  group by ContractID
) cnt on C.ContractID = cnt.ContractID
group by to_char(C.ContractStartDate,'YYYYMM'), S.LocationID, CC.ChannelID;

-- 5.3
-- Time dim
create table TimeDim as
select distinct to_char(S.ServiceDate,'YYYYMM') as TimeID,
       to_char(S.ServiceDate,'YYYY') as Year,
       to_char(S.ServiceDate,'MM') as Month
from Service S;

-- Vehicle dim
create table VehicleDim as
select distinct V.VehicleID, V.RegistrationNo, V.Make, V.Model, V.DeptID
from Vehicle V;

-- Department dim
create table DepartmentDim as
select distinct DeptID, DeptName, CampusID
from Department;

-- User dim
create table UserDim as
select distinct U.UserID, U.UserName, U.DeptID
from Staff U;

-- Service dim with listagg of users and weight factor (example)
create table ServiceDim as
select
  S.ServiceID,
  S.ServiceDate,
  S.TotalCost,
  1.0 / count(SU.UserID) as WeightFactor,
  listagg(SU.UserID, '_') within group (order by SU.UserID) as UserList
from Service S
join ServiceUserBridge SU on S.ServiceID = SU.ServiceID
group by S.ServiceID, S.ServiceDate, S.TotalCost;

-- Bridge: ServiceUserBridge (service-level many-to-many)
create table ServiceUserBridge as
select ServiceID, UserID
from ServiceUserBridge_source;

-- Fact: allocate costs to departments and users using weight factor
create table VehicleServiceFact as
select
  to_char(S.ServiceDate,'YYYYMM') as TimeID,
  V.VehicleID,
  V.DeptID,
  sum(1) as ServiceCount,
  sum(S.TotalCost) as TotalServiceCost,
  sum(S.TotalCost * (1.0 / cnt.users_per_service)) as AllocatedToUsers -- total allocated (should equal total)
from Service S
join Vehicle V on S.VehicleID = V.VehicleID
join (
  select ServiceID, count(UserID) as users_per_service
  from ServiceUserBridge
  group by ServiceID
) cnt on S.ServiceID = cnt.ServiceID
group by to_char(S.ServiceDate,'YYYYMM'), V.VehicleID, V.DeptID;
-- Queries for the require report
-- 1) total service cost each month/year
select t.TimeID, t.Year, t.Month, sum(f.TotalServiceCost) as TotalCost
from VehicleServiceFact f
join TimeDim t on f.TimeID = t.TimeID
group by t.TimeID, t.Year, t.Month
order by t.TimeID;

-- 2) how many times a car is serviced each month (per vehicle)
select f.VehicleID, vd.RegistrationNo, f.TimeID, sum(f.ServiceCount) as ServicesThisMonth
from VehicleServiceFact f
join VehicleDim vd on f.VehicleID = vd.VehicleID
group by f.VehicleID, vd.RegistrationNo, f.TimeID
order by vd.RegistrationNo, f.TimeID;

-- 3) total service cost per department
select d.DeptID, d.DeptName, sum(f.TotalServiceCost) as DeptTotalCost
from VehicleServiceFact f
join DepartmentDim d on f.DeptID = d.DeptID
group by d.DeptID, d.DeptName
order by DeptTotalCost desc;

-- 4) approximate cost per user (using WeightFactor via ServiceDim)
select u.UserID, u.UserName, sum(s.TotalCost * s.WeightFactor) as ApproxUserCost
from ServiceDim s
join ServiceUserBridge su on s.ServiceID = su.ServiceID
join UserDim u on su.UserID = u.UserID
group by u.UserID, u.UserName
order by ApproxUserCost desc;


-- 5.4
-- (a)
create table TimeDim as
select distinct to_char(S.ServiceDate,'YYYYMM') as TimeID,
       to_char(S.ServiceDate,'YYYY') as Year,
       to_char(S.ServiceDate,'MM') as Month
from Service S;

create table BrandDim as
select distinct C.BrandName
from Car C;

create table MechanicDim as
select distinct MechanicID, MechanicName
from Mechanic;

create table PartDim as
select distinct D.PartNo, P.Description
from Service_Details D
left join Part P on D.PartNo = P.PartNo;

-- Example SQL
-- Service-level fact: one row per service
create table CarServiceFact_Service as
select
  to_char(S.ServiceDate,'YYYYMM') as TimeID,
  C.BrandName,
  S.MechanicID,
  count(distinct S.ServiceNo) as Number_of_Services
from Service S
join Car C on S.RegistrationNo = C.RegistrationNo
group by to_char(S.ServiceDate,'YYYYMM'), C.BrandName, S.MechanicID;

-- Service-part-level fact: one row per part used in a service
create table CarServiceFact_Parts as
select
  to_char(S.ServiceDate,'YYYYMM') as TimeID,
  C.BrandName,
  S.MechanicID,
  D.PartNo,
  sum(D.Quantity) as TotalPartQty,
  sum(D.Quantity * D.PartUnitCost) as TotalPartCost
from Service S
join Service_Details D on S.ServiceNo = D.ServiceNo
join Car C on S.RegistrationNo = C.RegistrationNo
group by to_char(S.ServiceDate,'YYYYMM'), C.BrandName, S.MechanicID, D.PartNo;

-- (b)
-- Fact: TotalServiceCost at service-part granularity
create table CarServiceCostFact as
select
  to_char(S.ServiceDate,'YYYYMM') as TimeID,
  C.BrandName,
  S.MechanicID,
  D.PartNo,
  sum(D.Quantity * D.PartUnitCost) + sum(NVL(D.LabourCost,0)) as TotalServiceCost -- adapt columns
from Service S
join Service_Details D on S.ServiceNo = D.ServiceNo
join Car C on S.RegistrationNo = C.RegistrationNo
group by to_char(S.ServiceDate,'YYYYMM'), C.BrandName, S.MechanicID, D.PartNo;
