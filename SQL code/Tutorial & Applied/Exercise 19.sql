-- 19.1
-- (a) Retrieve the Product that has the lowest Total Sales in 2019.
SELECT ProductName, SUM(Total_Sales) AS Total_Sales
FROM SalesFact S, TimeDim T, ProductDim P
WHERE S.TimeID = T.TimeID
  AND S.ProductID = P.ProductID
  AND T.Year = 2019
GROUP BY ProductName
HAVING SUM(Total_Sales) = (
    SELECT MIN(ProductSales)
    FROM (
        SELECT SUM(Total_Sales) AS ProductSales
        FROM SalesFact S, TimeDim T
        WHERE S.TimeID = T.TimeID
          AND T.Year = 2019
        GROUP BY ProductID
    ) AS SubQuery
);

-- (b) Retrieve the Percent Rank of the Product that has the lowest Total Sales in 2019.
SELECT ProductName, Total_Sales, Percent_Rank
FROM (
    SELECT
        ProductName,
        SUM(Total_Sales) AS Total_Sales,
        PERCENT_RANK() OVER (ORDER BY SUM(Total_Sales)) AS Percent_Rank
    FROM SalesFact S, TimeDim T, ProductDim P
    WHERE S.TimeID = T.TimeID
      AND S.ProductID = P.ProductID
      AND T.Year = 2019
    GROUP BY ProductName
) AS RankedProducts
WHERE Total_Sales = (
    SELECT MIN(ProductSales)
    FROM (
        SELECT SUM(Total_Sales) AS ProductSales
        FROM SalesFact S, TimeDim T
        WHERE S.TimeID = T.TimeID
          AND T.Year = 2019
        GROUP BY ProductID
    ) AS SubQuery
);











-- 19.2
-- (a) Display the Top-10 average property prices by suburb.
SELECT
    L.Suburb,
    SUM(TotalPrice) / SUM(NumberOfProperties) AS Avg_Price
FROM PropertyFACT F, LocationDIM L
WHERE F.LocationID = L.LocationID
GROUP BY L.Suburb
ORDER BY Avg_Price DESC
-- Use LIMIT 10, TOP 10, or ROWNUM <= 10 depending on your SQL dialect
LIMIT 10;

-- (b) Display the average price of properties by property-type description and suburb. It is not necessary 
-- to show the sub-totals or group totals or grand total.
SELECT
    P.TypeName,
    L.Suburb,
    SUM(F.TotalPrice) / SUM(F.NumberOfProperties) AS Avg_Price
FROM PropertyFACT F, PropertyTypeDIM P, LocationDIM L
WHERE F.TypeID = P.TypeID
  AND F.LocationID = L.LocationID
GROUP BY P.TypeName, L.Suburb
ORDER BY P.TypeName, L.Suburb;



-- 19.3
-- (a) Perform a Cumulative Sum of Total Order Cost of all Online orders (Instruction: use all dimensions). 
-- Note that for each City, there should be a separate Cumulative Sum.
SELECT
    L.LocationID, -- Assuming this represents City
    S.Season,
    M.SalesMethod,
    F.TotalOrderCost,
    SUM(F.TotalOrderCost) OVER (
        PARTITION BY L.LocationID
        ORDER BY S.SeasonID -- Or another logical time dimension
        ROWS UNBOUNDED PRECEDING
    ) AS Cumulative_Cost
FROM ClothingCompanyFACT F,
     SeasonDIM S,
     SalesMethodDIM M,
     LocationDIM L
WHERE F.SeasonID = S.SeasonID
  AND F.MethodID = M.MethodID
  AND F.LocationID = L.LocationID
  AND M.SalesMethod = 'Online';

-- (b) Perform another Cumulative Sum of Total Order Cost but partitioned based on the 
-- SalesMethodID: one partition for Online orders, one partition for In-Store orders and 
-- one partition for Phone Order orders. Hints: It must also be partitioned based on Location (or Suburb).
SELECT
    L.LocationID,
    M.SalesMethod,
    S.Season,
    F.TotalOrderCost,
    SUM(F.TotalOrderCost) OVER (
        PARTITION BY L.LocationID, M.SalesMethod
        ORDER BY S.SeasonID -- Or another logical time dimension
        ROWS UNBOUNDED PRECEDING
    ) AS Cumulative_Cost
FROM ClothingCompanyFACT F,
     SeasonDIM S,
     SalesMethodDIM M,
     LocationDIM L
WHERE F.SeasonID = S.SeasonID
  AND F.MethodID = M.MethodID
  AND F.LocationID = L.LocationID
  AND M.SalesMethod IN ('Online', 'In-Store', 'Phone Order');

-- (c) Show the total order costs of each source order and rank them.
SELECT
    M.SalesMethod,
    SUM(F.TotalOrderCost) AS Total_Cost,
    RANK() OVER (ORDER BY SUM(F.TotalOrderCost) DESC) AS Cost_Rank
FROM ClothingCompanyFACT F, SalesMethodDIM M
WHERE F.MethodID = M.MethodID
GROUP BY M.SalesMethod;

-- (d) Display the source order that generates the highest total order cost.
SELECT SalesMethod, Total_Cost
FROM (
    SELECT
        M.SalesMethod,
        SUM(F.TotalOrderCost) AS Total_Cost,
        RANK() OVER (ORDER BY SUM(F.TotalOrderCost) DESC) AS Cost_Rank
    FROM ClothingCompanyFACT F, SalesMethodDIM M
    WHERE F.MethodID = M.MethodID
    GROUP BY M.SalesMethod
) AS RankedMethods
WHERE Cost_Rank = 1;



