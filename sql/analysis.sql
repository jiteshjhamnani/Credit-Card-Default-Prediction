
-- CREDIT CARD DEFAULT PREDICTION
-- SQL ANALYSIS
--
-- Database: credit_risk.db
-- Table: customers
--
-- This file contains SQL queries used to analyze customer
-- credit information and payment default patterns.




-- QUERY 1
-- Find the total number of customers in the database.


SELECT
    COUNT(*) AS total_customers
FROM customers;



-- QUERY 2
-- Find the number of customers who defaulted and
-- who did not default.
--
-- Default = 0 → No default
-- Default = 1 → Default


SELECT
    `Default`,
    COUNT(*) AS customer_count
FROM customers
GROUP BY `Default`
ORDER BY `Default`;



-- QUERY 3
-- Calculate the overall percentage of customers
-- who defaulted on their payment.


SELECT
    ROUND(
        AVG(`Default`) * 100,
        2
    ) AS default_rate_percentage
FROM customers;



-- QUERY 4
-- Analyze the default rate based on education level.
--
-- This helps identify whether default rates differ
-- across different education groups.


SELECT
    EDUCATION,
    COUNT(*) AS total_customers,
    SUM(`Default`) AS total_defaults,
    ROUND(
        AVG(`Default`) * 100,
        2
    ) AS default_rate_percentage
FROM customers
GROUP BY EDUCATION
ORDER BY default_rate_percentage DESC;



-- QUERY 5
-- Analyze the default rate based on marital status.
--
-- This helps compare default behavior across
-- different marital-status groups.


SELECT
    MARRIAGE,
    COUNT(*) AS total_customers,
    SUM(`Default`) AS total_defaults,
    ROUND(
        AVG(`Default`) * 100,
        2
    ) AS default_rate_percentage
FROM customers
GROUP BY MARRIAGE
ORDER BY default_rate_percentage DESC;



-- QUERY 6
-- Find the average credit limit for customers who
-- defaulted versus customers who did not default.


SELECT
    `Default`,
    COUNT(*) AS customer_count,
    ROUND(
        AVG(LIMIT_BAL),
        2
    ) AS average_credit_limit
FROM customers
GROUP BY `Default`;



-- QUERY 7
-- Find the average bill amount for customers based
-- on their default status.
--
-- BILL_AMT1 represents the most recent bill amount
-- available in the dataset.


SELECT
    `Default`,
    COUNT(*) AS customer_count,
    ROUND(
        AVG(BILL_AMT1),
        2
    ) AS average_bill_amount
FROM customers
GROUP BY `Default`;



-- QUERY 8
-- Find the average payment amount for customers
-- based on their default status.


SELECT
    `Default`,
    COUNT(*) AS customer_count,
    ROUND(
        AVG(PAY_AMT1),
        2
    ) AS average_payment_amount
FROM customers
GROUP BY `Default`;



-- QUERY 9
-- Find the top 10 customers with the highest
-- credit limits.
--
-- Useful for identifying customers with the
-- largest available credit.


SELECT
    
    LIMIT_BAL,
    AGE,
    EDUCATION,
    MARRIAGE,
    `Default`
FROM customers
ORDER BY LIMIT_BAL DESC
LIMIT 10;



-- QUERY 10
-- Find customers who have a high credit limit
-- (500,000 or more) and still defaulted.
--
-- This can help identify high-credit-limit
-- customers who represent potential risk.

SELECT
   
    LIMIT_BAL,
    AGE,
    EDUCATION,
    MARRIAGE,
    `Default`
FROM customers
WHERE LIMIT_BAL >= 500000
  AND `Default` = 1
ORDER BY LIMIT_BAL DESC;

-- QUERY 11
-- Calculate default rate for different age groups.
--
-- This helps identify age groups with relatively
-- higher default rates.

SELECT
    AGE,
    COUNT(*) AS total_customers,
    SUM(`Default`) AS total_defaults,
    ROUND(
        AVG(`Default`) * 100,
        2
    ) AS default_rate_percentage
FROM customers
GROUP BY AGE
HAVING COUNT(*) >= 50
ORDER BY default_rate_percentage DESC;


-- QUERY 12
-- Categorize customers into credit-limit groups
-- and calculate the default rate for each group.
--
-- This demonstrates the SQL CASE statement.

SELECT
    CASE
        WHEN LIMIT_BAL < 100000 THEN 'Low'
        WHEN LIMIT_BAL < 300000 THEN 'Medium'
        WHEN LIMIT_BAL < 500000 THEN 'High'
        ELSE 'Very High'
    END AS credit_limit_category,

    COUNT(*) AS total_customers,

    SUM(`Default`) AS total_defaults,

    ROUND(
        AVG(`Default`) * 100,
        2
    ) AS default_rate_percentage

FROM customers

GROUP BY credit_limit_category

ORDER BY default_rate_percentage DESC;


-- QUERY 13
-- Rank customers according to their credit limit.
--
-- This demonstrates the SQL RANK() window function.

SELECT
    
    LIMIT_BAL,
    AGE,
    `Default`,

    RANK() OVER (
        ORDER BY LIMIT_BAL DESC
    ) AS credit_limit_rank

FROM customers

ORDER BY credit_limit_rank

LIMIT 20;


-- QUERY 14
-- Use a Common Table Expression (CTE) to calculate
-- default statistics by education level.
--
-- This demonstrates the use of WITH / CTE.

WITH education_stats AS (

    SELECT
        EDUCATION,
        COUNT(*) AS total_customers,
        SUM(`Default`) AS total_defaults

    FROM customers

    GROUP BY EDUCATION
)

SELECT
    EDUCATION,
    total_customers,
    total_defaults,

    ROUND(
        100.0 * total_defaults / total_customers,
        2
    ) AS default_rate_percentage

FROM education_stats

ORDER BY default_rate_percentage DESC;


-- QUERY 15
-- Analyze the relationship between education level
-- and default status.
--
-- This shows how many customers in each education
-- category defaulted versus did not default.
SELECT
    EDUCATION,
    `Default`,
    COUNT(*) AS customer_count

FROM customers

GROUP BY
    EDUCATION,
    `Default`

ORDER BY
    EDUCATION,
    `Default`;


-- QUERY 16
-- Find customers with low credit limits who defaulted.
--
-- This identifies potentially vulnerable customers
-- with relatively low available credit.
SELECT
  
    LIMIT_BAL,
    AGE,
    EDUCATION,
    MARRIAGE,
    `Default`

FROM customers

WHERE LIMIT_BAL < 100000
  AND `Default` = 1

ORDER BY LIMIT_BAL ASC;


-- QUERY 17
-- Compare average repayment status between
-- defaulted and non-defaulted customers.
--
-- PAY_0 represents the repayment status for
-- the most recent month.

SELECT
    `Default`,
    COUNT(*) AS customer_count,
    ROUND(
        AVG(PAY_0),
        2
    ) AS average_repayment_status

FROM customers

GROUP BY `Default`;


-- QUERY 18
-- Find the customers with the highest outstanding
-- bill amount in the most recent month.

SELECT
   
    BILL_AMT1,
    LIMIT_BAL,
    PAY_AMT1,
    `Default`

FROM customers

ORDER BY BILL_AMT1 DESC

LIMIT 10;


-- QUERY 19
-- Find customers whose latest bill amount is greater
-- than their credit limit.
--
-- These customers may represent higher credit exposure.

SELECT
    
    LIMIT_BAL,
    BILL_AMT1,
    PAY_AMT1,
    `Default`

FROM customers

WHERE BILL_AMT1 > LIMIT_BAL

ORDER BY BILL_AMT1 DESC;


-- QUERY 20
-- Create an overall risk summary using a CTE.
--
-- This combines customer count, total defaults,
-- and default rate into one result.

WITH risk_summary AS (

    SELECT
        COUNT(*) AS total_customers,
        SUM(`Default`) AS total_defaults

    FROM customers
)

SELECT
    total_customers,
    total_defaults,

    ROUND(
        100.0 * total_defaults / total_customers,
        2
    ) AS overall_default_rate

FROM risk_summary;