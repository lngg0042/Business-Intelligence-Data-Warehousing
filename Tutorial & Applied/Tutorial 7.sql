create table timedim
as select distinct
    to_char(salesdate,'yyyymm') as timeid,
    to_char(salesdate,'mm') as month,
    to_char(salesdate, 'yyyy') as year
from dtaniar.sales5;

create table storedim
as select * from dtaniar.store5;

create table categorydim
as select * from dtaniar.category5;

create table StarRatingDim
( StarID Number(1),
StarDescription Varchar2(15));

Insert Into StarRatingDim Values (0, 'Unknown');
Insert Into StarRatingDim Values (1, 'Poor');
Insert Into StarRatingDim Values (2, 'Not Good');
INsert Into StarRatingDim Values (3, 'Average');
Insert Into StarRatingDim Values (4, 'Good');
Insert Into StarRatingDim Values (5, 'Excellent');


create table reviewfact as
select
    b.CATEGORYID,
    r.STARS as starid,
    count(*) as num_of_review
from dtaniar.book5 b, dtaniar.review5 r
where b.isbn=r.isbn
group by b.CATEGORYID, r.STARS;

create table TempBookWithStar as
select
    B.ISBN,
    B.CategoryID,
    NVL(R.Stars,0) As Star
From dtaniar.book5 B, dtaniar.review5 R 
Where B.ISBN = R.ISBN(+);

--select * 
--from TempBookWithStar 
--where ISBN='0316465186';
-- Book 0316465186 is the one that does not have any reviews, and the star is 0

Create table TempBookWithAvgStar
As SELECT
    ISBN,
    CategoryID,
    Round(Avg(Star)) As Avg_Star
From TempBookWithStar
Group By ISBN, CategoryID;

Create Table BookSalesFact as
Select
  T.CategoryID,
  To_Char(S.SalesDate, 'YYYYMM') As TimeID,
  S.StoreID,
  T.Avg_star as StarID,
  sum(sd.quantity) as Num_of_Books,
  Sum(SD.TotalPrice) As Total_Sales
From
  TempBookWithAvgStar T, 
  dtaniar.Sales5 S, 
  dtaniar.SalesDetails5 SD
Where T.ISBN=sd.ISBN and sd.SALESID= s.SALESID
Group by 
  T.CategoryID,
  To_Char(S.SalesDate, 'YYYYMM'),
  S.StoreID,
  T.Avg_star;


-- The tempfact table should include the books without reviews. 
-- Thus, we have to use OUTER JOIN to create the tempfact table. 
SELECT * 
FROM dtaniar.book5 b, dtaniar.review5 r
WHERE b.ISBN=r.ISBN(+);

SELECT * 
FROM dtaniar.book5 b 
  LEFT OUTER JOIN dtaniar.review5 r
  ON b.ISBN=r.ISBN;

-- What are the total sales for each bookstore in a month?
select 
  s.STOREID, 
  t.MONTH, 
  sum(f.total_sales) as total_sales
from storedim s, timedim t, booksalesfact f
where s.STOREID=f.STOREID and f.timeid = t.timeid
group by s.STOREID, t.MONTH
order by s.STOREID, t.MONTH;

-- What is the number of books sold for each category?
select 
  c.CATEGORYID, 
  c.CATEGORYDESCRIPTION, 
  sum(f.num_of_books) as total_num_books
from booksalesfact f, categorydim c
where f.categoryid = c.categoryid
group by c.CATEGORYID, c.CATEGORYDESCRIPTION
order by c.CATEGORYID, c.CATEGORYDESCRIPTION;

-- What is the book category with the highest number of books sold?
select * from (
  select 
    c.CATEGORYID, 
    c.CATEGORYDESCRIPTION, 
    sum(f.num_of_books) as total_num_books
  from booksalesfact f, categorydim c
  where f.categoryid = c.categoryid
  group by c.CATEGORYID, c.CATEGORYDESCRIPTION
  order by total_num_books desc)
where rownum =1;


-- What is the number of reviews for each category?
select 
  c.CATEGORYID, 
  c.CATEGORYDESCRIPTION, 
  sum(f.num_of_review) as number_of_reviews 
from reviewfact f, categorydim c
where f.categoryid = c.categoryid
group by c.CATEGORYID, c.CATEGORYDESCRIPTION
order by c.CATEGORYID, c.CATEGORYDESCRIPTION;


-- How many 5-star reviews for each category?
select 
  c.CATEGORYID, 
  c.CATEGORYDESCRIPTION,         
  sum(f.NUM_OF_REVIEW) as number_of_5star_reviews
from 
  reviewfact f, 
  categorydim c, 
  starratingdim s
where f.categoryid = c.categoryid 
and s.starid = f.starid
and s.STARID=5
group by c.CATEGORYID, c.CATEGORYDESCRIPTION
order by c.CATEGORYID, c.CATEGORYDESCRIPTION;

