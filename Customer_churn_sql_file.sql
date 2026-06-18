CREATE DATABASE customer_churn_analysis;
USE customer_churn_analysis;


-- Total Records --  
SELECT COUNT(*) as Total_records
FROM customers ;

-- Check Null / Blank Values 
SELECT COUNT(*) as total_records,
SUM(CASE WHEN TotalCharges IS NULL OR TotalCharges = " " THEN 1 ELSE 0 END ) AS null_total_charges
FROM customers;


-- Find Duplicate Customers ID

SELECT customerID , COUNT(*) as duplicate_count
FROM customers
GROUP BY customerID
HAVING COUNT(*) > 1 ;



-- Churn Distribution  
SELECT Churn , COUNT(*) as customers 
FROM customers
GROUP BY Churn ;


-- Contract Type Distribution

SELECT Contract , COUNT(*) as total_customers
FROM customers
GROUP BY Contract ;


--  Paymnet Method

SELECT PaymentMethod , COUNT(*) as total_customets
FROM customers
GROUP BY PaymentMethod ;


-- Churn Rate

SELECT COUNT(*) as Total_customers,
SUM(CASE WHEN Churn = "Yes" THEN 1 ELSE 0 END ) AS churn_customers,
SUM(CASE WHEN Churn = "Yes"  THEN 1 ELSE 0 END ) * 100.0 / COUNT(*) as churn_rate_per
FROM customers ;

--  churn Rate by contract type

SELECT  Contract , COUNT(*) AS total_customers,
SUM(CASE WHEN Churn = "Yes" THEN 1 ELSE 0 END ) as Churn_customers,
SUM(CASE WHEN Churn = "Yes" THEN 1 ELSE 0 END) * 100.0 / COUNT(*)  AS churn_rate
FROM customers
GROUP BY Contract
ORDER BY Churn_rate DESC ;


-- Churn Rate by Payment Method 

SELECT PaymentMethod , COUNT(*) AS total_customers,
SUM(CASE WHEN Churn = "Yes" THEN 1 ELSE 0 END) AS churn_customers,
ROUND(SUM(CASE WHEN Churn = "Yes" THEN 1 ELSE 0 END) * 100.0 / COUNT(*) ,2 )as churn_rate
FROM customers
GROUP BY PaymentMethod 
ORDER BY churn_rate DESC ;


-- Churn Rate by Internet service

SELECT InternetService , 
COUNT(*) as total_customers,
SUM(CASE WHEN Churn = "Yes" THEN 1 ELSE 0 END ) AS churn_customers,
SUM(CASE WHEN Churn = "Yes" THEN 1 ELSE 0 END ) * 100.0 / COUNT(*) AS churn_rate
FROM customers
GROUP BY InternetService
ORDER BY churn_rate DESC ;


-- Revenue Loss by churn 

SELECT ROUND(SUM(MonthlyCharges) ,2)as monthly_revenue_loss
FROM customers
WHERE Churn = "Yes" ;


-- Churn Rate by senior citizen

SELECT SeniorCitizen , COUNT(*) as Total_castomers,
SUM(CASE WHEN Churn = "Yes" THEN 1 ELSE 0 END ) as churn_customers,
SUM(CASE WHEN Churn = "Yes" THEN 1 ELSE 0 END ) * 100.0 / COUNT(*) AS churn_rate
FROM customers
GROUP BY SeniorCitizen
ORDER BY churn_rate DESC ;



-- Churn Rate by Tenure Group

SELECT CASE 
           WHEN tenure <= 12 THEN "0-12 Months"
           WHEN tenure <= 24 THEN "13-24 Months"
           WHEN tenure <= 48 THEN "25-48 Months"
ELSE "49 + Months"
END as tenure_group,
COUNT(*) AS total_customers,
SUM(CASE WHEN Churn = "Yes" THEN 1 ELSE 0 END) as churn_customers
FROM customers
GROUP BY tenure_group 
ORDER BY total_customers DESC ;


--  avg monthly charges by churn status

SELECT Churn ,
ROUND(AVG(MonthlyCharges) ,2)as avg_monthly_charges
FROM customers
GROUP BY Churn ; 


-- High Risk Customers

SELECT  customerId ,tenure,monthlycharges,contract,paymentmethod,churn
FROM customers
WHERE tenure <= 12 AND MonthlyCharges >= 70 AND Churn = "Yes"
ORDER BY Monthlycharges ;


-- Loyal Customers 

SELECT customerid , monthlycharges , tenure , contract , churn
FROM customers
WHERE tenure >= 48 AND Churn = "No"
ORDER BY tenure DESC ; 

-- New customers

SELECT COUNT(*) as  new_customers
FROM customers
WHERE tenure <= 6; 


--  Premium Customers

SELECT customerid, monthlycharges,totalcharges,contract
FROM customers
WHERE monthlycharges >= 90
ORDER BY Monthlycharges DESC ;
 

-- customer segmentation 

SELECT CASE 
           WHEN tenure <= 12 AND monthlycharges >= 70 THEN "High Risk"
           WHEN tenure >= 48 AND churn = "No" THEN "Loyal Customers"
           WHEN tenure <= 6 THEN "New Customers"
           WHEN monthlycharges >= 90 THEN "Premium Customers"
           ELSE "Regular Customers" 
           END as customer_segment,
           COUNT(*) as total_customers
FROM customers
GROUP BY customer_segment
ORDER BY total_customers DESC ;



-- Revenue by customers segment

SELECT 
       CASE 
           WHEN tenure <= 12 AND monthlycharges >= 70 THEN "High Risk"
           WHEN tenure >= 48 AND Churn = "No" THEN "Loyal Customers"
           WHEN tenure <= 6 THEN "New Customers"
           WHEN monthlycharges >= 90 THEN "Premium Customers"
           ELSE "Regular customers"
           END as customer_segment,
           ROUND(SUM(monthlycharges),2) as total_revenue
FROM customers
GROUP BY customer_segment
ORDER BY total_revenue ;


--  Retention Opportunity Customers 

SELECT customerid, contract , paymentmethod , tenure , monthlycharges,techsupport , onlinesecurity , churn
FROM customers
WHERE contract = "Month-to-month" AND techsupport = "No" AND onlinesecurity = "No"
ORDER BY monthlycharges DESC ;

           
           
           

