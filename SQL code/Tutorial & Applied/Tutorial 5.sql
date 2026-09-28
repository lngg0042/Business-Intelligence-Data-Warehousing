--CUSTOMER 
create table CUSTOMER as 
select CUSTOMERID as CUSTOMER_ID, name as CUSTOMER_NAME, ADDRESS,  SUBURB, POSTCODE, STATE 
from DTANIAR.CUSTOMER4; 
alter table CUSTOMER add constraint CUSTOMER_PK primary key  ( CUSTOMER_ID ) ; 
--BOOK 
create table BOOK 
 ( 
 BOOK_ID varchar2(20) not null , 
 BOOK_TITLE varchar2(200), 
 AUTHOR varchar2(200) 
 ) ; 

alter table BOOK add constraint BOOK_PK primary key ( BOOK_ID ); 

insert into BOOK values('C1', 'CSIRO Diet', 'CSIRO Team'); insert into BOOK values('H6', 'Harry Potter 6', 'Rowling'); insert into BOOK values('DV', 'Da Vinci Code', 'Dan Brown'); 
--BOOK PRICE HISTORY 
create table BOOK_PRICE_HISTORY 
 ( 
 BOOK_ID varchar2(20) not null , 
 START_DATE varchar2(10) null , 
 END_DATE varchar2(10) not null , 
 PRICE number, 
 REMARKS varchar2(100) 
 ) ; 

alter table BOOK_PRICE_HISTORY add constraint BOOK_PRICE_HISTORY_PK  primary key ( BOOK_ID, START_DATE, END_DATE ) ; 

alter table BOOK_PRICE_HISTORY add constraint BOOK_PRICE_HISTORY_BOOK_FK  foreign key ( BOOK_ID ) references BOOK ( BOOK_ID ) ; 

insert into BOOK_PRICE_HISTORY values('C1', 'Jan2007', 'Jul2007', 45.95,  'Full Price');  
insert into BOOK_PRICE_HISTORY values('C1', 'Aug2007', 'Oct2007', 36.75,  '20% Discount');  
insert into BOOK_PRICE_HISTORY values('C1', 'Nov2007', 'Jan2008', 23.00,  'Half Price'); 
insert into BOOK_PRICE_HISTORY values('C1', 'Feb2008', 'Now', 45.95,  'Full Price'); 
insert into BOOK_PRICE_HISTORY values('H6', 'Jan2007', 'Mar2007', 21.95,  'Launching'); 
insert into BOOK_PRICE_HISTORY values('H6', 'Apr2007', 'Feb2008', 30.95,  'Full Price'); 
insert into BOOK_PRICE_HISTORY values('H6', 'Jan2008', 'Now', 10.00,  'End of Product Sale');
insert into BOOK_PRICE_HISTORY values('DV', 'Jan2007', 'Now', 27.95,  'Full Price'); 

--BRANCH 
create table BRANCH 
 ( 
 BRANCH_ID varchar2(100) not null , 
 BRANCH_ADDRESS varchar2(200) 
 ) ; 

alter table BRANCH add constraint BRANCH_PK primary key ( BRANCH_ID ) ; 

insert into BRANCH values('City', 'VIC3622'); 
insert into BRANCH values('Chadstone', 'Chadstone VIC3234'); insert into BRANCH values('Camberwell', 'Camberwell VIC2451'); 
--TRANSACTION 
create table BOOK_TRANSACTION 
 ( 
 TRANSACTION_ID number not null , 
 BRANCH_ID varchar2 (100) not null , 
 CUSTOMER_ID varchar2 (20) not null , 
 BOOK_ID varchar2 (20) not null , 
 TRANSACTION_DATE date , 
 QUANTITY number 
 ) ; 

alter table BOOK_TRANSACTION add constraint BOOK_TRANSACTION_PK primary  key ( TRANSACTION_ID ) ; 
alter table BOOK_TRANSACTION add constraint TRANSACTION_BOOK_FK foreign  key ( BOOK_ID ) references BOOK ( BOOK_ID ) ; 
alter table BOOK_TRANSACTION add constraint TRANSACTION_BRANCH_FK  foreign key ( BRANCH_ID ) references BRANCH ( BRANCH_ID ) ; 

alter table BOOK_TRANSACTION add constraint TRANSACTION_CUSTOMER_FK  foreign key ( CUSTOMER_ID ) references CUSTOMER ( CUSTOMER_ID ) ; 

create sequence BOOK_TRANSACTION_TRANSACTION_I start with 1 ; 

-- automatically assigns the next number from the sequence
-- the trigger will only fire if the new row being inserted has no value for transaction_id
create or replace trigger BOOK_TRANSACTION_TRANSACTION_I before  insert on BOOK_TRANSACTION for each row when (new.TRANSACTION_ID is  null)  
begin  
 :new.TRANSACTION_ID := BOOK_TRANSACTION_TRANSACTION_I.NEXTVAL; end; 
/ 

insert into BOOK_TRANSACTION values(null, 'City', 'Cus1', 'C1',  to_date('Mar 2008', 'Mon YYYY'), 2); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus2', 'C1',  to_date('Mar 2008', 'Mon YYYY'), 3); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus2', 'H6',  to_date('Mar 2008', 'Mon YYYY'), 10); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus3', 'H6',  to_date('Mar 2008', 'Mon YYYY'), 5); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus3', 'DV',  to_date('Mar 2008', 'Mon YYYY'), 10); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus4', 'DV',  to_date('Mar 2008', 'Mon YYYY'), 13);
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus4', 'C1',  to_date('Mar 2008', 'Mon YYYY'), 10); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus5', 'C1',  to_date('Mar 2008', 'Mon YYYY'), 5); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus4', 'H6',  to_date('Mar 2008', 'Mon YYYY'), 3); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus3', 'DV',  to_date('Mar 2008', 'Mon YYYY'), 2); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus3', 'C1',  to_date('Mar 2008', 'Mon YYYY'), 1); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus2', 'H6',  to_date('Mar 2008', 'Mon YYYY'), 1); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus1', 'DV',  to_date('Mar 2008', 'Mon YYYY'), 2); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus4', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 10); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus3', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 5); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus2', 'H6',  to_date('Dec 2007', 'Mon YYYY'), 5); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus2', 'H6',  to_date('Dec 2007', 'Mon YYYY'), 1); 
insert into BOOK_TRANSACTION values(null, 'City', 'Cus5', 'DV',  to_date('Dec 2007', 'Mon YYYY'), 6); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus4', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 5); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus3', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 5); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus2', 'H6',  to_date('Dec 2007', 'Mon YYYY'), 4); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus1', 'H6',  to_date('Dec 2007', 'Mon YYYY'), 4); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus4', 'DV',  to_date('Dec 2007', 'Mon YYYY'), 1); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus1', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 9); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus3', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 9); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus2', 'H6',  to_date('Dec 2007', 'Mon YYYY'), 3); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus1', 'DV',  to_date('Dec 2007', 'Mon YYYY'), 2); 
insert into BOOK_TRANSACTION values(null, 'Chadstone', 'Cus4', 'DV',  to_date('Dec 2007', 'Mon YYYY'), 1); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus1', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 9); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus3', 'C1',  to_date('Dec 2007', 'Mon YYYY'), 9); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus2', 'H6',  to_date('Dec 2007', 'Mon YYYY'), 3); 
insert into BOOK_TRANSACTION values(null, 'Camberwell', 'Cus1', 'DV',  to_date('Dec 2007', 'Mon YYYY'), 2);
commit; 





-- Solution 1
-- a.
create table BOOK_DIM as select distinct * from BOOK;
select * from BOOK_DIM;

-- b.
-- TIME_DIM 
create table TIME_DIM as  
select distinct 
 to_char(TRANSACTION_DATE, 'MonYYYY') as TIME_ID, 
 to_char(TRANSACTION_DATE, 'Mon') as MONTH, 
 to_char(TRANSACTION_DATE, 'YYYY') as YEAR 
from BOOK_TRANSACTION;
select * from TIME_DIM; 

-- c.
-- BRANCH_DIM 
create table BRANCH_DIM as select distinct * from BRANCH; select * from BRANCH_DIM; 

-- d.
-- BOOK_SALES_FACT1 
create table BOOK_SALES_FACT1 as 
select to_char(T.TRANSACTION_DATE, 'MonYYYY') as TIME_ID,  BK.BOOK_ID, BR.BRANCH_ID, 
 sum(T.QUANTITY) as NUMBER_OF_BOOKS_SOLD 
from BOOK_TRANSACTION T, BOOK BK, BRANCH BR 
where T.BRANCH_ID = BR.BRANCH_ID 
and T.BOOK_ID = BK.BOOK_ID 
group by to_char(T.TRANSACTION_DATE, 'MonYYYY'), BK.BOOK_ID,  BR.BRANCH_ID; 
select * from BOOK_SALES_FACT1  
order by TIME_ID desc, BRANCH_ID desc, NUMBER_OF_BOOKS_SOLD asc; 

-- e.
select * from BOOK_SALES_FACT1;





-- Solution 2: add a Temporal Bridge (history of book prices)
-- a.
-- incorporate the temporal values of book price, we add a temporal/bridge table
-- BOOK_PRICE_DIM (TEMPORAL DIMENSION) 
create table BOOK_PRICE_DIM as select distinct * from  
BOOK_PRICE_HISTORY; 
select * from BOOK_PRICE_DIM;

-- b.
-- BOOK SALES REPORT 2 (CORRECT PRICE REPORT) 
select F.TIME_ID as "Month", F.BRANCH_ID as "Branch", F.BOOK_ID  as "Book ID",  
 B.BOOK_TITLE as "Book Title", B.AUTHOR, BP.PRICE,   F.NUMBER_OF_BOOKS_SOLD as "No of Books Sold" 
from BOOK_SALES_FACT1 F, BOOK_PRICE_DIM BP, BOOK_DIM B where F.BOOK_ID = B.BOOK_ID 
and BP.BOOK_ID = B.BOOK_ID 
and to_date(F.TIME_ID, 'MonYYYY') >= to_date(BP.START_DATE,  'MonYYYY')  
and to_date(F.TIME_ID, 'MonYYYY') <= case BP.END_DATE when  'Now' then SYSDATE  
 else to_date(BP.END_DATE, 'MonYYYY') 
 end 
order by F.TIME_ID desc, F.BRANCH_ID desc, F.NUMBER_OF_BOOKS_SOLD  asc;




-- Solution 3: add a new Fact: Total Sales (correct price)
-- a.
create table BOOK_SALES_FACT2 as 
select * from BOOK_SALES_FACT1; 

-- b.
alter table BOOK_SALES_FACT2 add (TOTAL_SALES NUMBER); 

-- c.
declare  
 cursor PRICE_CURSOR is select * from BOOK_PRICE_DIM; -- iterates all rows from the table
 VALID_END_DATE DATE; -- to hold and processed end date for each row
begin
 for ITEM in PRICE_CURSOR loop 
 -- Change END_DATE = 'Now' to valid date value  
 if ITEM.END_DATE = 'Now' then 
 VALID_END_DATE := SYSDATE; 
 else  
 VALID_END_DATE := to_date(ITEM.END_DATE, 'MonYYYY');  
end if; 
 -- update value for TOTAL_SALES in BOOK_SALES_FACT2  
 update BOOK_SALES_FACT2 
 set TOTAL_SALES = NUMBER_OF_BOOKS_SOLD * ITEM.PRICE 
 where BOOK_ID = ITEM.BOOK_ID 
 and to_date(TIME_ID, 'MonYYYY') >=  to_date(ITEM.START_DATE, 'MonYYYY')  
 and to_date(TIME_ID, 'MonYYYY') <= VALID_END_DATE;  end loop; 
end; 
/ 

select * from BOOK_SALES_FACT2; 

