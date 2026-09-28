-- Exercise 21.1
-- 1. Glucose-Albumin Dataset (17 data points)
--  Table glucode_albumin with columns x (Glucode) and y (Albumin)
-- intercept 2.4959 & slope 0.0077
SELECT
    slope,
    (y_bar_max - (slope * x_bar_max)) AS intercept
FROM (
    SELECT
        SUM((x - x_bar) * (y - y_bar)) / SUM((x - x_bar) * (x - x_bar)) AS slope,
        MAX(x_bar) AS x_bar_max,
        MAX(y_bar) AS y_bar_max
    FROM (
        SELECT AVG(x) AS x_bar, AVG(y) AS y_bar
        FROM glucose_albumin
    ) av, glucose_albumin
);

-- 2. Age-WBC Dataset (49 data points)
-- Table age_wbc with columns x (Age) and y (WBC)
-- intercept 20.1455 & slope -0.0918 (-ve slope)
SELECT
    slope,
    (y_bar_max - (slope * x_bar_max)) AS intercept
FROM (
    SELECT
        SUM((x - x_bar) * (y - y_bar)) / SUM((x - x_bar) * (x - x_bar)) AS slope,
        MAX(x_bar) AS x_bar_max,
        MAX(y_bar) AS y_bar_max
    FROM (
        SELECT AVG(x) AS x_bar, AVG(y) AS y_bar
        FROM age_wbc
    ) av, age_wbc
);


-- Exercise 21.2
-- In Goodnotes


-- Exercise 21.3 (REGRESSION TREE)
-- The number of subscribers (x-axis) is partitioned first
-- followed by the total hours of viewing (y-axis) in the subsequent nodes.
IF Subscribers < 1.5e7 THEN
    IF Viewing_Hours < 2.5e8 THEN
        Prediction = exp(5.26)  // ~$192,000
    ELSE
        Prediction = exp(6.78)  // ~$880,000
ELSE
    IF Viewing_Hours < 7.5e8 THEN
        Prediction = exp(7.45)  // ~$1,730,000
    ELSE
        Prediction = exp(9.21)  // ~$10,000,000

-- each "IF" condition creates a split
-- the final "Prediction" is the leaf node value for that branch
