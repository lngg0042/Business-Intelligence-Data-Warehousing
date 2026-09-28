-- A. Aggregate exercises using CUBE and ROLLUP
-- Group By 
SELECT  
 time_id As Period,  
 c.emp_num AS Pilot, 
 mod_code As Model, 
 SUM(tot_fuel)  
FROM dw.charter_fact c, dw.pilot p 
WHERE c.emp_num = p.emp_num 
AND time_id LIKE '19951%' 
AND mod_code = 'C-90A' 
AND p.pil_license = 'COM' 
GROUP BY time_id, c.emp_num, mod_code 
ORDER BY time_id; 

-- CUBE (without DECODE) 
SELECT  
 time_id As Period,  
 c.emp_num AS Pilot, 
 mod_code As Model, 
 SUM(tot_fuel)  
FROM dw.charter_fact c, dw.pilot p 
WHERE c.emp_num = p.emp_num 
AND time_id LIKE '19951%' 
AND mod_code = 'C-90A' 
AND p.pil_license = 'COM' 
GROUP BY CUBE (time_id, c.emp_num, mod_code) ORDER BY time_id; 

-- CUBE (with GROUPING) 
SELECT  
 time_id As Period,  
 c.emp_num AS Pilot, 
 mod_code As Model, 
 SUM(tot_fuel), 
 GROUPING(time_id) As PeriodGroup,  
 GROUPING(c.emp_num) AS PilotGroup, 
 GROUPING(mod_code) As ModelGroup 
FROM dw.charter_fact c, dw.pilot p 
WHERE c.emp_num = p.emp_num 
AND time_id LIKE '19951%' 
AND mod_code = 'C-90A' 
AND p.pil_license = 'COM' 
GROUP BY CUBE (time_id, c.emp_num, mod_code) ORDER BY time_id; 

-- Cube 
SELECT  
 DECODE(GROUPING(time_id), 1, 'All Periods',  time_id) As Period,  
 DECODE(GROUPING(c.emp_num), 1, 'All Pilots',  c.emp_num) AS Pilot, 
 DECODE(GROUPING(mod_code), 1, 'All Models',  mod_code) As Model, 
 SUM(tot_fuel)  
FROM dw.charter_fact c, dw.pilot p 
WHERE c.emp_num = p.emp_num 
AND time_id LIKE '19951%' 
AND mod_code = 'C-90A' 
AND p.pil_license = 'COM' 
GROUP BY CUBE (time_id, c.emp_num, mod_code) ORDER BY time_id; 

-- Partial Cube 
SELECT  
 DECODE(GROUPING(time_id), 1, 'All Periods',  time_id) As Period,  
 DECODE(GROUPING(c.emp_num), 1, 'All Pilots',  c.emp_num) AS Pilot, 
 DECODE(GROUPING(mod_code), 1, 'All Models',  mod_code) As Model, 
 SUM(tot_fuel)  
FROM dw.charter_fact c, dw.pilot p 
WHERE c.emp_num = p.emp_num 
AND time_id LIKE '19951%' 
AND mod_code = 'C-90A' 
AND p.pil_license = 'COM' 
GROUP BY CUBE (time_id, c.emp_num), mod_code ORDER BY time_id; 

-- Roll up 
SELECT  
 DECODE(GROUPING(time_id), 1, 'All Periods',  time_id) As Period, 
 DECODE(GROUPING(c.emp_num), 1, 'All Pilots',  c.emp_num) AS Pilot, 
 DECODE(GROUPING(mod_code), 1, 'All Models',  mod_code) As Model, 
 SUM(tot_fuel)  
FROM dw.charter_fact c, dw.pilot p 
WHERE c.emp_num = p.emp_num 
AND time_id LIKE '19951%' 
AND mod_code = 'C-90A' 
AND p.pil_license = 'COM' 
GROUP BY ROLLUP (time_id, c.emp_num, mod_code) ORDER BY time_id; 

-- Partial Roll up 
SELECT  
 DECODE(GROUPING(time_id), 1, 'All Periods', time_id)  As Period,  
 DECODE(GROUPING(c.emp_num), 1, 'All Pilots',  c.emp_num) AS Pilot, 
 DECODE(GROUPING(mod_code), 1, 'All Models',  mod_code) As Model, 
 SUM(tot_fuel)  
FROM dw.charter_fact c, dw.pilot p 
WHERE c.emp_num = p.emp_num 
AND time_id LIKE '19951%' 
AND mod_code = 'C-90A'
AND p.pil_license = 'COM' 
GROUP BY ROLLUP (time_id, c.emp_num), mod_code 
ORDER BY time_id; 


-- B. ROW_NUMBER(), DENSE_RANK(), RANK(), and PERCENT_RANK()  
-- 1.
SELECT time_year, time_month,  
RANK() OVER (ORDER BY time_year, time_month) AS time_rank  FROM dw.time; 

-- 2.
Select mod_code, time_id, sum(TOT_CHAR_HOURS), 
 ROW_NUMBER() Over (Order By Sum(TOT_CHAR_HOURS)) AS Row_Num From dw.Charter_Fact 
Where time_id LIKE '1996%' 
Group By mod_code, time_id;

-- 3.
Select mod_code, time_id, sum(TOT_CHAR_HOURS), 
 dense_rank() Over (Order By Sum(TOT_CHAR_HOURS)) AS dense_rank From dw.Charter_Fact 
Where time_id LIKE '1996%' 
Group By mod_code, time_id;

-- 4.
Select mod_code, time_id, sum(TOT_CHAR_HOURS),  Rank() Over (Order By Sum(TOT_CHAR_HOURS)) AS Rank From dw.Charter_Fact 
Where time_id LIKE '1996%' 
Group By mod_code, time_id;

-- 5.
SELECT dw.time.time_id, Total, percent_rank 
FROM ( 
 SELECT  
 time_id,  
 SUM(revenue) AS Total,  
 PERCENT_RANK () OVER (ORDER BY SUM(revenue)) AS percent_rank  FROM dw.charter_fact  
 GROUP BY time_id 
) t, dw.time  
WHERE t.time_id = dw.time.time_id 
AND percent_rank >= 0.9 
ORDER BY percent_rank DESC; 

-- C. Cumulative and Moving Aggregate Questions 
-- 1.
Select time_id, SUM(revenue), 
 TO_CHAR(SUM(SUM(revenue)) 
 OVER(ORDER BY time_id ROWS UNBOUNDED PRECEDING),  '9,999,999.99') AS Cumulative_Rev 
From dw.Charter_Fact 
Where time_id LIKE '1995%' 
Group By time_id;

-- 2.
Select time_id, SUM(revenue), 
 TO_CHAR(AVG(SUM(revenue)) 
 OVER(ORDER BY time_id ROWS 2 PRECEDING),  '9,999,999.99') AS Moving_3_Months_Avg 
From dw.Charter_Fact 
Where time_id LIKE '1995%' 
Group By time_id;

-- 4.
SELECT t.time_year, f.mod_code, 
 SUM(f.tot_fuel)as Total, 
 TO_CHAR(SUM(SUM(f.tot_fuel)) 
 OVER(PARTITION BY t.time_year ORDER BY time_year  ROWS UNBOUNDED PRECEDING),'9,999,999.99') AS  Cum_fuel_year, 
 TO_CHAR(SUM(SUM(f.tot_fuel)) 
 OVER(PARTITION BY f.mod_code ORDER BY f.mod_code   ROWS UNBOUNDED PRECEDING),'9,999,999.99') AS   Cum_fuel_model 
FROM dw.charter_fact f, dw.time t 
WHERE f.time_id = t.time_id 
GROUP BY t.time_year, f.mod_code 
ORDER BY time_year; 



