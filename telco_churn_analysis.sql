-- ============================================================
--        TELCO CUSTOMER CHURN ANALYSIS
--        Tool    : MySQL
--        Dataset : Telco Customer Churn (Kaggle)
--        Author  : Nagesh Prakash Nagolkar
--        Date    : 21-04-2024
-- ============================================================


-- ------------------------------------------------------------
-- SETUP
-- ------------------------------------------------------------

CREATE DATABASE customer_churn_db;
USE customer_churn_db;


-- ============================================================
-- SECTION 1 : DATA CLEANING & QUALITY CHECK
-- ============================================================

-- Preview dataS
SELECT *
FROM customers
LIMIT 20;


-- Q1. Check for duplicate customers
SELECT customerid,
	   COUNT(*) AS occurrences
FROM customers
GROUP BY customerid
HAVING COUNT(*) > 1;
-- Result: No duplicate customers found


-- Q2. Check distinct values in Churn column
SELECT DISTINCT churn
FROM customers;
-- Result: 'Yes', 'No'


-- Q3. Null value audit
SELECT
    COUNT(*) AS total_rows,
    COUNT(CASE WHEN customerid IS NULL THEN 1 END) AS null_customerid,
    COUNT(CASE WHEN totalcharges IS NULL THEN 1 END) AS null_totalcharges,
    COUNT(CASE WHEN monthlycharges IS NULL THEN 1 END) AS null_monthlycharges,
    COUNT(CASE WHEN tenure IS NULL THEN 1 END) AS null_tenure
FROM customers;


-- ============================================================
-- SECTION 2 : CHURN OVERVIEW
-- ============================================================

-- Q4. Total number of customers
SELECT COUNT(*) AS total_customers
FROM customers;


-- Q5. Total churned customers
SELECT COUNT(*) AS churned_customers
FROM customers
WHERE churn = 'Yes';


-- Q6. Overall churn rate
SELECT
       ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS churn_rate_pct
FROM customers;
-- Result: 26.58%


-- Q7. Gender-wise customer distribution
SELECT
    gender,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY gender;


-- Q8. Senior citizen vs churn
SELECT
    CASE WHEN seniorcitizen = 1 THEN 'Senior' ELSE 'Non-Senior' END AS citizen_type,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY seniorcitizen;


-- ============================================================
-- SECTION 3 : REVENUE IMPACT
-- ============================================================

-- Q9. Monthly revenue at risk from churned customers
SELECT
    ROUND(SUM(monthlycharges), 2) AS monthly_revenue_at_risk
FROM customers
WHERE churn = 'Yes';
-- Result: $139,130.85


-- Q10. Average monthly charges — churned vs retained
SELECT
    churn,
    ROUND(AVG(monthlycharges),2) AS avg_monthly_charges,
    ROUND(AVG(totalcharges),2) AS avg_total_charges
FROM customers
GROUP BY churn;


-- Q11. High-value churned customers (MonthlyCharges > $80)
SELECT
    customerid,
    tenure,
    contract,
    monthlycharges,
    totalcharges
FROM customers
WHERE churn = 'Yes'  AND monthlycharges > 80
ORDER BY monthlycharges DESC;


-- ============================================================
-- SECTION 4 : CHURN DRIVERS ANALYSIS
-- ============================================================

-- Q12. Churn rate by contract type
SELECT
    contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY contract
ORDER BY churn_rate_pct DESC;
-- Result: Month-to-month 42.71% | One year 11.28% | Two year 2.85%


-- Q13. Churn rate by tenure bucket
SELECT
    CASE
        WHEN tenure <  12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        ELSE '24+ months'
    END AS tenure_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY tenure_group
ORDER BY MIN(tenure);
-- Result: 0-12 months 48.54% | 13-24 months 29.10% | 24+ months 14.04%


-- Q14. Churn rate by internet service
SELECT
    internetservice,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY internetservice
ORDER BY churn_rate_pct DESC;
-- Result: Fiber optic 41.89% | DSL 19.00% | No internet 7.43%


-- Q15. Churn rate by monthly charge group
SELECT
    CASE
        WHEN monthlycharges <  50 THEN 'Low'
        WHEN monthlycharges BETWEEN 50 AND 80  THEN 'Medium'
        ELSE  'High'
    END  AS charge_group,
    COUNT(*)   AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)  AS churned,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY charge_group
ORDER BY churn_rate_pct DESC;


-- Q16. Churn rate by payment method
SELECT
    paymentmethod,
    COUNT(*)  AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)  AS churn_rate_pct
FROM customers
GROUP BY paymentmethod
ORDER BY churn_rate_pct DESC;


-- Q17. Impact of TechSupport on churn
SELECT
    techsupport,
    COUNT(*)  AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)  AS churn_rate_pct
FROM customers
GROUP BY techsupport
ORDER BY churn_rate_pct DESC;


-- Q18. Churn rate by number of services subscribed
SELECT
    (CASE WHEN onlinesecurity  = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN techsupport     = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN deviceprotection= 'Yes' THEN 1 ELSE 0 END)  AS total_services,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY total_services
ORDER BY total_services;


-- Q19. Customers with no protective services
SELECT COUNT(*) AS customers_with_no_services
FROM customers
WHERE onlinesecurity  = 'No'
  AND techsupport     = 'No'
  AND deviceprotection= 'No';


-- Q20. Top 5 churn contributing segments
SELECT
    contract,
    internetservice,
    COUNT(*) AS churned_customers
FROM customers
WHERE churn = 'Yes'
GROUP BY contract, internetservice
ORDER BY churned_customers DESC
LIMIT 5;


-- Q21. Top 5 risky segments (contract + payment + internet)
SELECT
    contract,
    paymentmethod,
    internetservice,
    COUNT(*) AS churned_customers
FROM customers
WHERE churn = 'Yes'
GROUP BY contract, paymentmethod, internetservice
ORDER BY churned_customers DESC
LIMIT 5;


-- ============================================================
-- SECTION 5 : CUSTOMER SEGMENTATION
-- ============================================================

-- Q22. Loyal customers (long tenure, not churned)
SELECT
    customerid,
    tenure,
    contract,
    monthlycharges
FROM customers
WHERE tenure > 24
  AND churn  = 'No'
ORDER BY tenure DESC;


-- Q23. Customers likely to upgrade (low charges, stable tenure)
SELECT
    customerid,
    tenure,
    contract,
    monthlycharges
FROM customers
WHERE churn          = 'No'
  AND monthlycharges < 50
  AND tenure         > 12
ORDER BY tenure DESC;


-- Q24. Tenure and average monthly charges trend
SELECT
    tenure,
    ROUND(AVG(monthlycharges), 2) AS avg_monthly_charges,
    COUNT(*) AS total_customers
FROM customers
GROUP BY tenure
ORDER BY tenure;


-- ============================================================
-- SECTION 6 : RISK SCORING MODEL
-- ============================================================

-- Q25. Simple high-risk customer flag
SELECT
    customerid,
    tenure,
    contract,
    monthlycharges,
    churn,
    CASE
        WHEN tenure   <  12
         AND contract  = 'Month-to-month'
         AND monthlycharges > 70 THEN 'High Risk'
        ELSE   'Low Risk'
    END AS risk_category
FROM customers
ORDER BY risk_category;


-- Q26. Multi-condition risk scoring with summary
WITH risk_scored AS (
    SELECT
        customerid,
        tenure,
        contract,
        monthlycharges,
        CASE
            WHEN contract     = 'Month-to-month'
             AND tenure       < 12
             AND techsupport  = 'No'
             AND onlinesecurity = 'No'  THEN 'Very High Risk'
            WHEN tenure       < 24      THEN 'Medium Risk'
            ELSE                             'Low Risk'
        END AS risk_level
    FROM customers
    WHERE churn = 'No'
)
SELECT
    risk_level,
    COUNT(*)      AS customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)      AS pct_of_active
FROM risk_scored
GROUP BY risk_level
ORDER BY customers DESC;


-- Q27. Churn prediction label for all customers
SELECT
    customerid,
    tenure,
    contract,
    techsupport,
    CASE
        WHEN tenure   <  12
         AND contract  = 'Month-to-month'
         AND techsupport = 'No'  THEN 'Likely to Churn'
        ELSE    'Safe'
    END AS churn_prediction
FROM customers
ORDER BY churn_prediction;


-- ============================================================
-- SECTION 7 : ADVANCED SQL — WINDOW FUNCTIONS
-- ============================================================

-- Q28. Rank customers by monthly charges (highest paying first)
SELECT
    customerid,
    churn,
    monthlycharges,
    RANK() OVER (ORDER BY monthlycharges DESC) AS rank_by_charges
FROM customers
WHERE churn = 'Yes'
ORDER BY rank_by_charges
LIMIT 20;


-- Q29. Dense rank customers by total charges
SELECT
    customerid,
    totalcharges,
    DENSE_RANK() OVER (ORDER BY totalcharges DESC) AS rank_position
FROM customers
ORDER BY rank_position
LIMIT 20;


-- Q30. Churn contribution % by contract type (window function)
SELECT
    contract,
    COUNT(*)   AS churned_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)  AS contribution_pct
FROM customers
WHERE churn = 'Yes'
GROUP BY contract
ORDER BY contribution_pct DESC;


-- Q31. Monthly charge quartiles vs churn rate (Using Chatgpt Solve This Query)
WITH quartiles AS (
    SELECT
        customerid,
        churn,
        monthlycharges,
        NTILE(4) OVER (ORDER BY monthlycharges) AS charge_quartile
    FROM customers
)
SELECT
    charge_quartile,
    CONCAT('$', MIN(monthlycharges), ' – $', MAX(monthlycharges)) AS charge_range,
    COUNT(*)                                                        AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)                 AS churned,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)                                    AS churn_rate_pct
FROM quartiles
GROUP BY charge_quartile
ORDER BY charge_quartile;


-- ============================================================
-- END OF ANALYSIS
-- ============================================================
