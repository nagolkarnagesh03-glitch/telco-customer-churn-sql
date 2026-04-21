# telco-customer-churn-sql
Customer Churn Analysis using SQL on Telco dataset


# 📊 Telco Customer Churn Analysis — SQL Project

![SQL](https://img.shields.io/badge/SQL-MySQL-blue) ![Status](https://img.shields.io/badge/Status-Completed-green) ![Dataset](https://img.shields.io/badge/Dataset-Telco%20Churn-orange)

## 📌 Project Overview

This project analyzes customer churn behavior for a Telecom company using **pure SQL**. The goal is to identify key churn drivers, segment at-risk customers, and provide actionable business recommendations to reduce churn rate.

> **Business Problem:** The telecom company is losing **26.58% of its customers** and **$139,130 in monthly revenue**. As a data analyst, the task is to find *who* is churning, *why* they are churning, and *which customers* are at risk next.

---

## 📁 Dataset

| Property | Details |
|---|---|
| Source | [Kaggle — Telco Customer Churn](https://www.kaggle.com/datasets/blastchar/telco-customer-churn) |
| Rows | 7,043 customers |
| Columns | 21 |
| Key Fields | CustomerID, tenure, Contract, MonthlyCharges, TotalCharges, Churn |

---

## 🛠️ Tools Used

- **MySQL** — All analysis and querying
- **MySQL Workbench** — Query editor
- **GitHub** — Version control and portfolio

---

## 🗂️ Project Structure

```
telco-churn-sql/
│
├── README.md                  ← You are here
├── data/
│   └── telco_churn.csv        ← Raw dataset
├── sql/
│   ├── 01_data_cleaning.sql   ← Duplicate check, null audit
│   ├── 02_churn_overview.sql  ← Overall churn rate, distribution
│   ├── 03_revenue_impact.sql  ← Revenue lost, high-value churners
│   ├── 04_churn_drivers.sql   ← Contract, tenure, internet service
│   ├── 05_risk_scoring.sql    ← Risk model, at-risk customers
│   └── 06_advanced.sql        ← Window functions, rankings
└── insights/
    └── key_findings.md        ← Business summary
```

---

## 💡 Key Business Insights

### 1. 🔴 Overall Churn Rate — 26.58%
Over 1 in 4 customers is churning. This is significantly above the healthy industry benchmark of 5–7%, indicating an urgent retention problem.

### 2. 🔴 Contract Type is the #1 Churn Driver

| Contract | Churn Rate |
|---|---|
| Month-to-month | **42.71%** |
| One year | 11.28% |
| Two year | **2.85%** |

Month-to-month customers churn at **15x the rate** of two-year contract customers. Converting even 10% of month-to-month customers to annual contracts would drastically reduce churn.

### 3. 🔴 New Customers Are Leaving Fast

| Tenure Group | Churn Rate |
|---|---|
| 0–12 months | **48.54%** |
| 13–24 months | 29.10% |
| 24+ months | 14.04% |

Nearly **1 in 2 new customers** churns within the first year. This points to a weak onboarding experience and unmet early expectations.

### 4. 🟡 Fiber Optic Users Churn Despite Paying More

| Internet Service | Churn Rate |
|---|---|
| Fiber Optic | **41.89%** |
| DSL | 19.00% |
| No Internet | 7.43% |

Fiber Optic customers pay a premium but churn at more than **2x the rate** of DSL users — a strong signal of service quality dissatisfaction.

### 5. 🔴 $139,130 Monthly Revenue at Risk
Churned customers represent **$139,130 in monthly recurring revenue**. Targeted win-back campaigns focused on high-value churners (MonthlyCharges > $80) could recover a significant portion of this.

---

## 📈 Sample Queries

### Overall Churn Rate
```sql
SELECT
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers;
-- Result: 26.58%
```

### Churn Rate by Contract Type
```sql
SELECT
    contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY contract
ORDER BY churn_rate_pct DESC;
-- Result: Month-to-month 42.71% | One year 11.28% | Two year 2.85%
```

### Customer Risk Scoring Model
```sql
WITH risk AS (
    SELECT customerid,
           CASE
               WHEN contract = 'Month-to-month'
                    AND tenure < 12
                    AND techsupport = 'No'
                    AND onlinesecurity = 'No' THEN 'Very High Risk'
               WHEN tenure < 24              THEN 'Medium Risk'
               ELSE                               'Low Risk'
           END AS risk_level
    FROM customers
    WHERE churn = 'No'
)
SELECT risk_level,
       COUNT(*) AS customers,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM risk
GROUP BY risk_level
ORDER BY customers DESC;
```

---

## 📋 Business Recommendations

| Priority | Action | Target Segment |
|---|---|---|
| 🔴 High | Offer discount to upgrade from month-to-month to annual contract | Month-to-month customers, tenure < 12 months |
| 🔴 High | Improve onboarding experience for new customers | Tenure < 12 months, 48.54% churn rate |
| 🔴 High | Win-back campaign for high-value churned customers | Churned, MonthlyCharges > $80 |
| 🟡 Medium | Investigate & fix Fiber Optic service quality issues | Fiber Optic users, 41.89% churn rate |
| 🟡 Medium | Bundle TechSupport + OnlineSecurity free for 3 months | New customers without services |
| 🟢 Low | Loyalty rewards program | Tenure > 24 months, churn rate only 14.04% |

---

## 🔍 Analysis Performed (27 Queries)

### 1. Data Cleaning & Quality Check
- Duplicate customer check → No duplicates found
- Null value audit across all columns
- Distinct value validation for Churn column

### 2. Churn Overview
- Overall churn rate → **26.58%**
- Gender-wise customer distribution
- Senior citizen vs churn analysis

### 3. Revenue Impact
- Monthly revenue at risk → **$139,130.85**
- Average monthly charges: churned vs retained customers
- Top high-value churned customers (MonthlyCharges > $80)

### 4. Churn Drivers Analysis
- Contract type → Month-to-month **42.71%** vs Two year **2.85%**
- Tenure buckets → New customers **48.54%** churn rate
- Internet service → Fiber Optic **41.89%** vs DSL **19.00%**
- Payment method → Electronic check users show higher churn
- Services → Customers without TechSupport & OnlineSecurity churn more

### 5. Risk Scoring Model
- Multi-condition risk scoring using `CASE WHEN`
- Customers flagged as: `Very High Risk` / `Medium Risk` / `Low Risk`
- Risk factors: Contract + Tenure + TechSupport + OnlineSecurity

### 6. Advanced SQL (Window Functions)
- `RANK()` — Customers ranked by monthly charges
- `DENSE_RANK()` — Customers ranked by total charges
- `SUM() OVER()` — Churn contribution % by contract type

---

## 🚀 How to Run This Project

1. Clone this repository
```bash
git clone https://github.com/yourusername/telco-churn-sql.git
```

2. Create database and import data
```sql
CREATE DATABASE customer_churn_db;
USE customer_churn_db;
-- Import telco_churn.csv using MySQL Workbench Import Wizard
```

3. Run SQL files in order
```
01_data_cleaning.sql → 02_churn_overview.sql → 03_revenue_impact.sql
→ 04_churn_drivers.sql → 05_risk_scoring.sql → 06_advanced.sql
```

---

## 👤 Author

**Nagesh Nagolkar**
- LinkedIn: [linkedin.com/in/yourprofile](https://www.linkedin.com/jobs/)
- GitHub: [github.com/yourusername](https://github.com/yourusername)
- Email: your.email@gmail.com

---

*This project is part of my Data Analyst portfolio. Built using MySQL on the Telco Customer Churn dataset from Kaggle.*
