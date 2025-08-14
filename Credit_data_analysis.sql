CREATE DATABASE credit_score_analysis;
USE credit_score_analysis;

CREATE TABLE credit_data (
	Month INT,
    Age FLOAT,
    Occupation VARCHAR(100),
	Annual_Income FLOAT,
    Monthly_Inhand_Salary FLOAT,
	Num_Bank_Accounts FLOAT,
    Num_Credit_Card INT,
    Interest_Rate INT,
    Num_of_Loan FLOAT,
    Delay_from_due_date FLOAT,
    Num_of_Delayed_Payment FLOAT,
    Changed_Credit_Limit FLOAT,
    Num_Credit_Inquiries INT,
    Credit_Mix VARCHAR(50),
    Outstanding_Debt FLOAT,
    Credit_Utilization_Ratio FLOAT,
    Credit_History_Age INT,
    Payment_of_Min_Amount VARCHAR(20),
    Total_EMI_per_month FLOAT,
    Amount_invested_monthly FLOAT,
    Monthly_Balance FLOAT,
    Credit_Score VARCHAR(20),
    is_train TINYINT(1),
    Spending_Level VARCHAR(20),
    Payment_Value VARCHAR(20)
);

-- Phase 1: Overview of dataset excluding Credit_Score

-- Age Distribution
SELECT 
	MIN(Age) AS Min_Age,
    MAX(Age) AS Max_Age,
    AVG(Age) AS Avg_Age
FROM credit_data;

SELECT
	CASE
		WHEN Age BETWEEN 10 AND 18 THEN '10-18'
		WHEN Age BETWEEN 18 AND 30 THEN '18-30'
		WHEN Age BETWEEN 30 AND 40 THEN '30-40'
		WHEN Age BETWEEN 40 AND 50 THEN '40-50'
		WHEN Age BETWEEN 50 AND 60 THEN '50-60'
		WHEN Age BETWEEN 60 AND 70 THEN '60-70'
		ELSE '70+'
	END AS Age_Group,
    COUNT(*) AS Count
FROM credit_data
GROUP BY Age_Group
ORDER BY Age_Group;

-- Occupation Breakdown
SELECT Occupation, COUNT(*) AS Count
FROM credit_data
GROUP BY Occupation
ORDER BY Count;

-- Occupation-wise Financial Distribution
SELECT 
	Occupation,
    COUNT(*) AS Count,
    ROUND(AVG(Annual_Income), 2) AS Avg_Annual_Income,
    ROUND(AVG(Monthly_Inhand_Salary), 2) AS Avg_Inhand_Salary,
    ROUND(AVG(Outstanding_Debt), 2) AS Avg_Debt,
    ROUND(AVG(Credit_Utilization_Ratio), 2) AS Avg_Credit_Util
FROM credit_data
GROUP BY Occupation
ORDER BY Count DESC;

-- Annual Income Distribution (Binned)
SELECT
	CASE
		WHEN Annual_Income < 50000 THEN '<50K'
        WHEN Annual_Income BETWEEN 50000 AND 100000 THEN '50K-100K'
        WHEN Annual_Income BETWEEN 100000 AND 300000 THEN '100K-300K'
        WHEN Annual_Income BETWEEN 300000 AND 600000 THEN '300K-600K'
        WHEN Annual_Income BETWEEN 600000 AND 1000000 THEN '600K-1M'
		ELSE '1M+'
	END AS Income_Bracket,
    COUNT(*) AS Count
FROM credit_data
GROUP BY Income_Bracket
ORDER BY FIELD(Income_Bracket, '<50K', '50K-100K', '100K-300K', '300K-600K', '600K-1M', '1M+');

-- Monthly_Inhand_Salary vs. Annual_Income
SELECT
  ROUND(AVG(Monthly_Inhand_Salary), 2) AS Avg_Monthly_Salary,
  ROUND(AVG(Annual_Income / 12), 2) AS Expected_Monthly_From_Income
FROM credit_data;

-- Spending Behavior vs Demographics
SELECT 
  Spending_Level,
  COUNT(*) AS Count,
  ROUND(AVG(Age), 2) AS Avg_Age,
  ROUND(AVG(Annual_Income), 2) AS Avg_Income,
  ROUND(AVG(Amount_invested_monthly), 2) AS Avg_Invest,
  ROUND(AVG(Monthly_Balance), 2) AS Avg_Balance
FROM credit_data
GROUP BY Spending_Level
ORDER BY Count DESC;

-- Credit History and Debt Patterns
SELECT 
  ROUND(AVG(Credit_History_Age/12), 2) AS Avg_Credit_History_Years, -- Original values in months
  ROUND(AVG(Outstanding_Debt), 2) AS Avg_Outstanding_Debt,
  ROUND(AVG(Num_of_Loan), 2) AS Avg_Num_Loan,
  ROUND(AVG(Num_of_Delayed_Payment), 2) AS Avg_Delays,
  ROUND(AVG(Interest_Rate), 2) AS Avg_Interest_Rate
FROM credit_data;

-- Credit Mix and Payment Behavior
SELECT 
  Credit_Mix,
  COUNT(*) AS Total_Count,
  COUNT(CASE WHEN Payment_Value = 'Small' THEN 1 END) AS Small_Payment_Count,
  COUNT(CASE WHEN Payment_Value = 'Medium' THEN 1 END) AS Medium_Payment_Count,
  COUNT(CASE WHEN Payment_Value = 'Large' THEN 1 END) AS Large_Payment_Count,
  ROUND(AVG(Total_EMI_per_month), 2) AS Avg_EMI,
  ROUND(AVG(Num_Credit_Inquiries), 2) AS Avg_Inquiries
FROM credit_data
GROUP BY Credit_Mix
ORDER BY Total_Count DESC;

-- Delayed Payment Patterns by Occupation
SELECT Occupation, ROUND(AVG(Num_of_Delayed_Payment), 2) AS Avg_Delay
FROM credit_data
GROUP BY Occupation
ORDER BY Avg_Delay DESC;

-- Overspending Detection
SELECT 
	Occupation, 
    COUNT(*) AS Overspending_Customers
FROM credit_data
WHERE (Total_EMI_per_month + Amount_invested_monthly) > Monthly_Inhand_Salary
GROUP BY Occupation
ORDER BY Overspending_Customers DESC;

-- Utilization Ratio Segmentation
SELECT 
	CASE
		WHEN Credit_Utilization_Ratio < 30 THEN 'Low Usage (<30%)'
        WHEN Credit_Utilization_Ratio BETWEEN 30 AND 60 THEN 'Moderate Usage (30%-60%)'
        WHEN Credit_Utilization_Ratio BETWEEN 60 AND 90 THEN 'High Usage (60%-90%)'
        ELSE 'Very High Usage (>90%)'
	END AS Usage_Category,
    COUNT(*) AS Count
FROM credit_data
GROUP BY Usage_Category;

-- Negative Changed Credit Limit Analysis
SELECT
    COUNT(*) AS Reduced_Limit_Customers
FROM credit_data
WHERE Changed_Credit_Limit < 0;

-- Minimum Payment Behavior Profiling by Age Group
WITH Age_Payment_CTE AS (
    SELECT 
        CASE
            WHEN Age BETWEEN 10 AND 18 THEN '10-18'
            WHEN Age BETWEEN 18 AND 30 THEN '18-30'
            WHEN Age BETWEEN 30 AND 40 THEN '30-40'
            WHEN Age BETWEEN 40 AND 50 THEN '40-50'
            WHEN Age BETWEEN 50 AND 60 THEN '50-60'
            WHEN Age BETWEEN 60 AND 70 THEN '60-70'
            ELSE '70+'
        END AS Age_Group,
        Payment_of_Min_Amount,
        COUNT(*) AS Count
    FROM credit_data
    GROUP BY Age_Group, Payment_of_Min_Amount
),
Totals AS (
    SELECT Age_Group, SUM(Count) AS Total FROM Age_Payment_CTE GROUP BY Age_Group
)
SELECT 
    a.Age_Group,
    a.Payment_of_Min_Amount,
    a.Count,
    ROUND(a.Count * 100.0 / t.Total, 2) AS Percentage
FROM Age_Payment_CTE a
JOIN Totals t ON a.Age_Group = t.Age_Group
ORDER BY a.Age_Group, a.Payment_of_Min_Amount DESC;

-- Phase 2: Analysis of Train dataset with original Credit_Score values

-- Credit Score Distribution
SELECT
	Credit_Score, COUNT(*) AS Count
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score
ORDER BY Count DESC;

-- Credit Score vs. Age Group
SELECT
  CASE
    WHEN Age BETWEEN 10 AND 18 THEN '10-18'
    WHEN Age BETWEEN 18 AND 30 THEN '18-30'
    WHEN Age BETWEEN 30 AND 40 THEN '30-40'
    WHEN Age BETWEEN 40 AND 50 THEN '40-50'
    WHEN Age BETWEEN 50 AND 60 THEN '50-60'
    WHEN Age BETWEEN 60 AND 70 THEN '60-70'
    ELSE '70+'
  END AS Age_Group,
  Credit_Score,
  COUNT(*) AS Count
FROM credit_data
WHERE is_train = 1
GROUP BY Age_Group, Credit_Score
ORDER BY Age_Group, Credit_Score;

-- Credit Score vs. Occupation
SELECT
	Occupation,
    Credit_Score, COUNT(*) AS Count
FROM credit_data
WHERE is_train = 1
GROUP BY Occupation, Credit_Score
ORDER BY Occupation, Credit_Score;

-- Credit Score vs. Annual Income Band
SELECT
  CASE
    WHEN Annual_Income < 100000 THEN '<1L'
    WHEN Annual_Income BETWEEN 100000 AND 500000 THEN '1L–5L'
    WHEN Annual_Income BETWEEN 500000 AND 1000000 THEN '5L–10L'
    ELSE '10L+'
  END AS Income_Band,
  Credit_Score,
  COUNT(*) AS Count
FROM credit_data
WHERE is_train = 1
GROUP BY Income_Band, Credit_Score
ORDER BY Income_Band, Credit_Score;

-- Credit Score vs. Spending Level
SELECT Spending_Level, Credit_Score, COUNT(*) AS Count
FROM credit_data
WHERE is_train = 1
GROUP BY Spending_Level, Credit_Score
ORDER BY Spending_Level, Credit_Score;

-- Credit_Score vs. Interest_Rate (Faulty outliers throwing averages off)
SELECT
	Credit_Score, COUNT(*) AS Count,
    ROUND(AVG(Interest_Rate), 2) AS Avg_Interest_Rate
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score
ORDER BY Credit_Score;

-- Average credit history age by credit score
SELECT 
  Credit_Score,
  ROUND(AVG(Credit_History_Age)/12, 2) AS Avg_History_Age_Years
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score
ORDER BY Credit_Score;

-- Credit history age distribution by credit score (binned in years)
SELECT 
  Credit_Score,
  CASE 
    WHEN Credit_History_Age < 12 THEN '< 1 Year'
    WHEN Credit_History_Age BETWEEN 12 AND 60 THEN '1-5 Years'
    WHEN Credit_History_Age BETWEEN 60 AND 120 THEN '5-10 Years'
    WHEN Credit_History_Age BETWEEN 120 AND 240 THEN '10-20 Years'
    WHEN Credit_History_Age BETWEEN 240 AND 360 THEN '20-30 Years'
    WHEN Credit_History_Age BETWEEN 360 AND 480 THEN '30-40 Years'
    ELSE '40+ Years'
  END AS History_Age_Bin,
  COUNT(*) AS Count_Customers
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score, History_Age_Bin
ORDER BY Credit_Score, History_Age_Bin;

-- Average Loan Activity by Credit Score
SELECT 
  Credit_Score,
  ROUND(AVG(Num_of_Loan), 2) AS Avg_Loans,
  ROUND(AVG(Num_Bank_Accounts), 2) AS Avg_Bank_Accounts
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score
ORDER BY Credit_Score;

-- Repayment Delays
SELECT 
  Credit_Score,
  ROUND(AVG(Num_of_Delayed_Payment), 2) AS Avg_Delayed_Payments,
  ROUND(AVG(Delay_from_due_date), 2) AS Avg_Days_Late
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score
ORDER BY Credit_Score;

-- Late Payment Impact
SELECT 
  CASE 
    WHEN Num_of_Delayed_Payment >= 6 THEN '6+ Delays'
    WHEN Num_of_Delayed_Payment >= 3 THEN '3-5 Delays'
    WHEN Num_of_Delayed_Payment >= 1 THEN '1-2 Delays'
    ELSE 'No Delays'
  END AS Delay_Band,
  Credit_Score,
  COUNT(*) AS Count_Customers,
  ROUND(AVG(Num_of_Delayed_Payment), 2) AS Avg_Delays
FROM credit_data
WHERE is_train = 1
GROUP BY Delay_Band, Credit_Score
ORDER BY Delay_Band, Credit_Score;

-- Spending & Debt Ratios
SELECT 
  Credit_Score,
  ROUND(AVG(Monthly_Inhand_Salary), 2) AS Avg_Salary,
  ROUND(AVG(Outstanding_Debt), 2) AS Avg_Debt,
  ROUND(AVG(Credit_Utilization_Ratio), 2) AS Avg_Credit_Utilization
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score
ORDER BY Credit_Score;

-- High Utilization vs Credit Score
SELECT 
  CASE 
    WHEN Credit_Utilization_Ratio >= 70 THEN 'High Utilization'
    WHEN Credit_Utilization_Ratio >= 35 THEN 'Moderate Utilization'
    ELSE 'Low Utilization'
  END AS Utilization_Band,
  Credit_Score,
  COUNT(*) AS Count_Customers,
  ROUND(AVG(Credit_Utilization_Ratio), 2) AS Avg_Utilization
FROM credit_data
WHERE is_train = 1
GROUP BY Utilization_Band, Credit_Score
ORDER BY Utilization_Band, Credit_Score;

-- Loan Interest & EMIs
SELECT 
  Credit_Score,
  ROUND(AVG(Amount_invested_monthly), 2) AS Avg_Monthly_Investment,
  ROUND(AVG(Total_EMI_per_month), 2) AS Avg_EMI
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score
ORDER BY Credit_Score;

-- Multi-Factor Risk Buckets
SELECT 
	CASE 
		WHEN Credit_Utilization_Ratio > 70 
			AND Num_of_Delayed_Payment >= 3
			AND (Total_EMI_per_month / NULLIF(Monthly_Inhand_Salary,0)) > 0.5
		THEN 'High Risk'
		WHEN Credit_Utilization_Ratio > 35 
			AND Num_of_Delayed_Payment BETWEEN 1 AND 2
		THEN 'Medium Risk'
		ELSE 'Low Risk'
	END AS Risk_Bucket,
  Credit_Score,
  COUNT(*) AS Customer_Count
FROM credit_data
WHERE is_train = 1
GROUP BY Risk_Bucket, Credit_Score
ORDER BY Risk_Bucket, Credit_Score;

-- High-Risk vs. Low-Risk Financial Habits
SELECT 
    CASE 
        WHEN Credit_Score IN ('Poor') THEN 'High Risk'
        WHEN Credit_Score IN ('Good') THEN 'Low Risk'
        ELSE 'Medium Risk'
    END AS Risk_Category,
    ROUND(AVG(Num_of_Delayed_Payment), 2) AS Avg_Delays,
    ROUND(AVG(Credit_Utilization_Ratio), 2) AS Avg_Utilization,
    ROUND(AVG(Num_of_Loan), 2) AS Avg_Loans
FROM credit_data
WHERE is_train = 1
GROUP BY Risk_Category;

-- Distribution of credit limit changes by credit score
SELECT 
  Credit_Score,
  CASE 
    WHEN Changed_Credit_Limit > 0 THEN 'Increase'
    WHEN Changed_Credit_Limit < 0 THEN 'Decrease'
    ELSE 'No Change'
  END AS Credit_Limit_Change_Type,
  COUNT(*) AS Count_Customers,
  ROUND(AVG(Changed_Credit_Limit), 2) AS Avg_Change
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score, Credit_Limit_Change_Type
ORDER BY Credit_Score, Credit_Limit_Change_Type;

-- Average magnitude of increase/decrease in credit limit by credit score
SELECT 
  Credit_Score,
  ROUND(AVG(CASE WHEN Changed_Credit_Limit > 0 THEN Changed_Credit_Limit END), 2) AS Avg_Increase,
  ROUND(AVG(CASE WHEN Changed_Credit_Limit < 0 THEN Changed_Credit_Limit END), 2) AS Avg_Decrease
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score
ORDER BY Credit_Score;

-- Phase 3: Analysis of Test dataset with predicted Credit_Score values

-- Credit Score Distribution (predicted)
SELECT
	Credit_Score, COUNT(*) AS Count
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score
ORDER BY Count DESC;

-- Credit Score vs. Age Group
SELECT
  CASE
    WHEN Age BETWEEN 10 AND 18 THEN '10-18'
    WHEN Age BETWEEN 18 AND 30 THEN '18-30'
    WHEN Age BETWEEN 30 AND 40 THEN '30-40'
    WHEN Age BETWEEN 40 AND 50 THEN '40-50'
    WHEN Age BETWEEN 50 AND 60 THEN '50-60'
    WHEN Age BETWEEN 60 AND 70 THEN '60-70'
    ELSE '70+'
  END AS Age_Group,
  Credit_Score,
  COUNT(*) AS Count
FROM credit_data
WHERE is_train = 0
GROUP BY Age_Group, Credit_Score
ORDER BY Age_Group, Credit_Score;

-- Credit Score vs. Occupation
SELECT
	Occupation,
    Credit_Score, COUNT(*) AS Count
FROM credit_data
WHERE is_train = 0
GROUP BY Occupation, Credit_Score
ORDER BY Occupation, Credit_Score;

-- Credit Score vs. Annual Income Band
SELECT
  CASE
    WHEN Annual_Income < 100000 THEN '<1L'
    WHEN Annual_Income BETWEEN 100000 AND 500000 THEN '1L–5L'
    WHEN Annual_Income BETWEEN 500000 AND 1000000 THEN '5L–10L'
    ELSE '10L+'
  END AS Income_Band,
  Credit_Score,
  COUNT(*) AS Count
FROM credit_data
WHERE is_train = 0
GROUP BY Income_Band, Credit_Score
ORDER BY Income_Band, Credit_Score;

-- Credit Score vs. Spending Level
SELECT Spending_Level, Credit_Score, COUNT(*) AS Count
FROM credit_data
WHERE is_train = 0
GROUP BY Spending_Level, Credit_Score
ORDER BY Spending_Level, Credit_Score;

-- Average credit history age by credit score
SELECT 
  Credit_Score,
  ROUND(AVG(Credit_History_Age)/12, 2) AS Avg_History_Age_Years
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score
ORDER BY Credit_Score;

-- Credit history age distribution by credit score (binned in years)
SELECT 
  Credit_Score,
  CASE 
    WHEN Credit_History_Age < 12 THEN '< 1 Year'
    WHEN Credit_History_Age BETWEEN 12 AND 60 THEN '1-5 Years'
    WHEN Credit_History_Age BETWEEN 60 AND 120 THEN '5-10 Years'
    WHEN Credit_History_Age BETWEEN 120 AND 240 THEN '10-20 Years'
    WHEN Credit_History_Age BETWEEN 240 AND 360 THEN '20-30 Years'
    WHEN Credit_History_Age BETWEEN 360 AND 480 THEN '30-40 Years'
    ELSE '40+ Years'
  END AS History_Age_Bin,
  COUNT(*) AS Count_Customers
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score, History_Age_Bin
ORDER BY Credit_Score, History_Age_Bin;

-- Average Loan Activity by Credit Score
SELECT 
  Credit_Score,
  ROUND(AVG(Num_of_Loan), 2) AS Avg_Loans,
  ROUND(AVG(Num_Bank_Accounts), 2) AS Avg_Bank_Accounts
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score
ORDER BY Credit_Score;

-- Repayment Delays
SELECT 
  Credit_Score,
  ROUND(AVG(Num_of_Delayed_Payment), 2) AS Avg_Delayed_Payments,
  ROUND(AVG(Delay_from_due_date), 2) AS Avg_Days_Late
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score
ORDER BY Credit_Score;

-- Late Payment Impact
SELECT 
  CASE 
    WHEN Num_of_Delayed_Payment >= 6 THEN '6+ Delays'
    WHEN Num_of_Delayed_Payment >= 3 THEN '3-5 Delays'
    WHEN Num_of_Delayed_Payment >= 1 THEN '1-2 Delays'
    ELSE 'No Delays'
  END AS Delay_Band,
  Credit_Score,
  COUNT(*) AS Count_Customers,
  ROUND(AVG(Num_of_Delayed_Payment), 2) AS Avg_Delays
FROM credit_data
WHERE is_train = 0
GROUP BY Delay_Band, Credit_Score
ORDER BY Delay_Band, Credit_Score;

-- Spending & Debt Ratios
SELECT 
  Credit_Score,
  ROUND(AVG(Monthly_Inhand_Salary), 2) AS Avg_Salary,
  ROUND(AVG(Outstanding_Debt), 2) AS Avg_Debt,
  ROUND(AVG(Credit_Utilization_Ratio), 2) AS Avg_Credit_Utilization
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score
ORDER BY Credit_Score;

-- High Utilization vs Credit Score
SELECT 
  CASE 
    WHEN Credit_Utilization_Ratio >= 70 THEN 'High Utilization'
    WHEN Credit_Utilization_Ratio >= 35 THEN 'Moderate Utilization'
    ELSE 'Low Utilization'
  END AS Utilization_Band,
  Credit_Score,
  COUNT(*) AS Count_Customers,
  ROUND(AVG(Credit_Utilization_Ratio), 2) AS Avg_Utilization
FROM credit_data
WHERE is_train = 0
GROUP BY Utilization_Band, Credit_Score
ORDER BY Utilization_Band, Credit_Score;

-- Loan Interest & EMIs
SELECT 
  Credit_Score,
  ROUND(AVG(Amount_invested_monthly), 2) AS Avg_Monthly_Investment,
  ROUND(AVG(Total_EMI_per_month), 2) AS Avg_EMI
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score
ORDER BY Credit_Score;

-- Multi-Factor Risk Buckets
SELECT 
	CASE 
		WHEN Credit_Utilization_Ratio > 70 
         AND Num_of_Delayed_Payment >= 3
         AND (Total_EMI_per_month / NULLIF(Monthly_Inhand_Salary,0)) > 0.5
		THEN 'High Risk'
		WHEN Credit_Utilization_Ratio > 35 
         AND Num_of_Delayed_Payment BETWEEN 1 AND 2
		THEN 'Medium Risk'
		ELSE 'Low Risk'
	END AS Risk_Bucket,
  Credit_Score,
  COUNT(*) AS Customer_Count
FROM credit_data
WHERE is_train = 0
GROUP BY Risk_Bucket, Credit_Score
ORDER BY Risk_Bucket, Credit_Score;

-- High-Risk vs. Low-Risk Financial Habits
SELECT 
    CASE 
        WHEN Credit_Score IN ('Poor') THEN 'High Risk'
        WHEN Credit_Score IN ('Good') THEN 'Low Risk'
        ELSE 'Medium Risk'
    END AS Risk_Category,
    ROUND(AVG(Num_of_Delayed_Payment), 2) AS Avg_Delays,
    ROUND(AVG(Credit_Utilization_Ratio), 2) AS Avg_Utilization,
    ROUND(AVG(Num_of_Loan), 2) AS Avg_Loans
FROM credit_data
WHERE is_train = 0
GROUP BY Risk_Category;

-- Distribution of credit limit changes by credit score
SELECT 
  Credit_Score,
  CASE 
    WHEN Changed_Credit_Limit > 0 THEN 'Increase'
    WHEN Changed_Credit_Limit < 0 THEN 'Decrease'
    ELSE 'No Change'
  END AS Credit_Limit_Change_Type,
  COUNT(*) AS Count_Customers,
  ROUND(AVG(Changed_Credit_Limit), 2) AS Avg_Change
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score, Credit_Limit_Change_Type
ORDER BY Credit_Score, Credit_Limit_Change_Type;

-- Average magnitude of increase/decrease in credit limit by credit score
SELECT 
  Credit_Score,
  ROUND(AVG(CASE WHEN Changed_Credit_Limit > 0 THEN Changed_Credit_Limit END), 2) AS Avg_Increase,
  ROUND(AVG(CASE WHEN Changed_Credit_Limit < 0 THEN Changed_Credit_Limit END), 2) AS Avg_Decrease
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score
ORDER BY Credit_Score;

-- Phase 4: Compartive Analysis (Original vs Predicted Patterns)

-- Credit Score Distribution (compared)
SELECT
	'Train' AS Dataset,
	Credit_Score, COUNT(*) AS Count
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score

UNION ALL

SELECT
	'Test' AS Dataset,
	Credit_Score, COUNT(*) AS Count
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score

ORDER BY Credit_Score, Dataset;

-- Credit Score vs. Age Group (compared)
SELECT
  'Train' AS Dataset,
  CASE
    WHEN Age BETWEEN 10 AND 18 THEN '10-18'
    WHEN Age BETWEEN 18 AND 30 THEN '18-30'
    WHEN Age BETWEEN 30 AND 40 THEN '30-40'
    WHEN Age BETWEEN 40 AND 50 THEN '40-50'
    WHEN Age BETWEEN 50 AND 60 THEN '50-60'
    WHEN Age BETWEEN 60 AND 70 THEN '60-70'
    ELSE '70+'
  END AS Age_Group,
  Credit_Score,
  COUNT(*) AS Count
FROM credit_data
WHERE is_train = 1
GROUP BY Age_Group, Credit_Score

UNION ALL

SELECT
  'Test' AS Dataset,
  CASE
    WHEN Age BETWEEN 10 AND 18 THEN '10-18'
    WHEN Age BETWEEN 18 AND 30 THEN '18-30'
    WHEN Age BETWEEN 30 AND 40 THEN '30-40'
    WHEN Age BETWEEN 40 AND 50 THEN '40-50'
    WHEN Age BETWEEN 50 AND 60 THEN '50-60'
    WHEN Age BETWEEN 60 AND 70 THEN '60-70'
    ELSE '70+'
  END AS Age_Group,
  Credit_Score,
  COUNT(*) AS Count
FROM credit_data
WHERE is_train = 0
GROUP BY Age_Group, Credit_Score

ORDER BY Age_Group, Credit_Score, Dataset;

-- Credit Score vs. Occupation (compared)
SELECT
	'Train' AS Dataset,
	Occupation,
    Credit_Score, COUNT(*) AS Count
FROM credit_data
WHERE is_train = 1
GROUP BY Occupation, Credit_Score

UNION ALL

SELECT
	'Test' AS Dataset,
	Occupation,
    Credit_Score, COUNT(*) AS Count
FROM credit_data
WHERE is_train = 0
GROUP BY Occupation, Credit_Score

ORDER BY Occupation, Credit_Score, Dataset;

-- Credit Score vs. Annual Income Band (compared)
SELECT
  'Train' AS Dataset,
  CASE
    WHEN Annual_Income < 100000 THEN '<100k'
    WHEN Annual_Income BETWEEN 100000 AND 500000 THEN '100k–500k'
    WHEN Annual_Income BETWEEN 500000 AND 1000000 THEN '500k–1M'
    ELSE '1M+'
  END AS Income_Band,
  Credit_Score,
  COUNT(*) AS Count
FROM credit_data
WHERE is_train = 1
GROUP BY Income_Band, Credit_Score

UNION ALL

SELECT
  'Test' AS Dataset,
  CASE
    WHEN Annual_Income < 100000 THEN '<100k'
    WHEN Annual_Income BETWEEN 100000 AND 500000 THEN '100k–500k'
    WHEN Annual_Income BETWEEN 500000 AND 1000000 THEN '500k–1M'
    ELSE '1M+'
  END AS Income_Band,
  Credit_Score,
  COUNT(*) AS Count
FROM credit_data
WHERE is_train = 0
GROUP BY Income_Band, Credit_Score

ORDER BY FIELD(Income_Band, '<100k', '100k–500k', '500k–1M', '1M+'), Credit_Score, Dataset;

-- Credit Score vs. Spending Level (compared)
SELECT 
	'Train' AS Dataset,
    Spending_Level, 
    Credit_Score, COUNT(*) AS Count
FROM credit_data
WHERE is_train = 1
GROUP BY Spending_Level, Credit_Score

UNION ALL

SELECT 
	'Test' AS Dataset,
	Spending_Level, 
    Credit_Score, COUNT(*) AS Count
FROM credit_data
WHERE is_train = 0
GROUP BY Spending_Level, Credit_Score

ORDER BY Spending_Level, Credit_Score, Dataset;

-- Average credit history age by credit score (compared)
SELECT 
  'Train' AS Dataset,
  Credit_Score,
  ROUND(AVG(Credit_History_Age)/12, 2) AS Avg_History_Age_Years
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score

UNION ALL

SELECT 
  'Test' AS Dataset,
  Credit_Score,
  ROUND(AVG(Credit_History_Age)/12, 2) AS Avg_History_Age_Years
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score

ORDER BY Credit_Score, Dataset;

-- Credit history age distribution by credit score (binned in years) (compared)
SELECT 
  'Train' AS Dataset,
  Credit_Score,
  CASE 
    WHEN Credit_History_Age < 12 THEN '< 1 Year'
    WHEN Credit_History_Age BETWEEN 12 AND 60 THEN '1-5 Years'
    WHEN Credit_History_Age BETWEEN 60 AND 120 THEN '5-10 Years'
    WHEN Credit_History_Age BETWEEN 120 AND 240 THEN '10-20 Years'
    WHEN Credit_History_Age BETWEEN 240 AND 360 THEN '20-30 Years'
    WHEN Credit_History_Age BETWEEN 360 AND 480 THEN '30-40 Years'
    ELSE '40+ Years'
  END AS History_Age_Bin,
  COUNT(*) AS Count_Customers
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score, History_Age_Bin

UNION ALL

SELECT 
  'Test' AS Dataset,
  Credit_Score,
  CASE 
    WHEN Credit_History_Age < 12 THEN '< 1 Year'
    WHEN Credit_History_Age BETWEEN 12 AND 60 THEN '1-5 Years'
    WHEN Credit_History_Age BETWEEN 60 AND 120 THEN '5-10 Years'
    WHEN Credit_History_Age BETWEEN 120 AND 240 THEN '10-20 Years'
    WHEN Credit_History_Age BETWEEN 240 AND 360 THEN '20-30 Years'
    WHEN Credit_History_Age BETWEEN 360 AND 480 THEN '30-40 Years'
    ELSE '40+ Years'
  END AS History_Age_Bin,
  COUNT(*) AS Count_Customers
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score, History_Age_Bin

ORDER BY Credit_Score, History_Age_Bin, Dataset;

-- Average Loan Activity by Credit Score (compared)
SELECT 
  'Train' AS Dataset,
  Credit_Score,
  ROUND(AVG(Num_of_Loan), 2) AS Avg_Loans,
  ROUND(AVG(Num_Bank_Accounts), 2) AS Avg_Bank_Accounts
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score

UNION ALL

SELECT 
  'Test' AS Dataset,
  Credit_Score,
  ROUND(AVG(Num_of_Loan), 2) AS Avg_Loans,
  ROUND(AVG(Num_Bank_Accounts), 2) AS Avg_Bank_Accounts
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score

ORDER BY Credit_Score, Dataset;

-- Repayment Delays (compared)
SELECT 
  'Train' AS Dataset,
  Credit_Score,
  ROUND(AVG(Num_of_Delayed_Payment), 2) AS Avg_Delayed_Payments,
  ROUND(AVG(Delay_from_due_date), 2) AS Avg_Days_Late
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score

UNION ALL

SELECT 
  'Test' AS Dataset,
  Credit_Score,
  ROUND(AVG(Num_of_Delayed_Payment), 2) AS Avg_Delayed_Payments,
  ROUND(AVG(Delay_from_due_date), 2) AS Avg_Days_Late
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score

ORDER BY Credit_Score, Dataset;

-- Late Payment Impact (compared)
SELECT 
  'Train' AS Dataset,
  CASE 
    WHEN Num_of_Delayed_Payment >= 6 THEN '6+ Delays'
    WHEN Num_of_Delayed_Payment >= 3 THEN '3-5 Delays'
    WHEN Num_of_Delayed_Payment >= 1 THEN '1-2 Delays'
    ELSE 'No Delays'
  END AS Delay_Band,
  Credit_Score,
  COUNT(*) AS Count_Customers,
  ROUND(AVG(Num_of_Delayed_Payment), 2) AS Avg_Delays
FROM credit_data
WHERE is_train = 1
GROUP BY Delay_Band, Credit_Score

UNION ALL

SELECT 
  'Test' AS Dataset,
  CASE 
    WHEN Num_of_Delayed_Payment >= 6 THEN '6+ Delays'
    WHEN Num_of_Delayed_Payment >= 3 THEN '3-5 Delays'
    WHEN Num_of_Delayed_Payment >= 1 THEN '1-2 Delays'
    ELSE 'No Delays'
  END AS Delay_Band,
  Credit_Score,
  COUNT(*) AS Count_Customers,
  ROUND(AVG(Num_of_Delayed_Payment), 2) AS Avg_Delays
FROM credit_data
WHERE is_train = 0
GROUP BY Delay_Band, Credit_Score

ORDER BY Delay_Band, Credit_Score, Dataset;

-- Spending & Debt Ratios (compared)
SELECT 
  'Train' AS Dataset,
  Credit_Score,
  ROUND(AVG(Monthly_Inhand_Salary), 2) AS Avg_Salary,
  ROUND(AVG(Outstanding_Debt), 2) AS Avg_Debt,
  ROUND(AVG(Credit_Utilization_Ratio), 2) AS Avg_Credit_Utilization
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score

UNION ALL

SELECT 
  'Test' AS Dataset,
  Credit_Score,
  ROUND(AVG(Monthly_Inhand_Salary), 2) AS Avg_Salary,
  ROUND(AVG(Outstanding_Debt), 2) AS Avg_Debt,
  ROUND(AVG(Credit_Utilization_Ratio), 2) AS Avg_Credit_Utilization
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score

ORDER BY Credit_Score, Dataset;

-- High Utilization vs Credit Score (compared)
SELECT 
  'Train' AS Dataset,
  CASE 
    WHEN Credit_Utilization_Ratio >= 70 THEN 'High Utilization'
    WHEN Credit_Utilization_Ratio >= 35 THEN 'Moderate Utilization'
    ELSE 'Low Utilization'
  END AS Utilization_Band,
  Credit_Score,
  COUNT(*) AS Count_Customers,
  ROUND(AVG(Credit_Utilization_Ratio), 2) AS Avg_Utilization
FROM credit_data
WHERE is_train = 1
GROUP BY Utilization_Band, Credit_Score

UNION ALL

SELECT 
  'Test' AS Dataset,
  CASE 
    WHEN Credit_Utilization_Ratio >= 70 THEN 'High Utilization'
    WHEN Credit_Utilization_Ratio >= 35 THEN 'Moderate Utilization'
    ELSE 'Low Utilization'
  END AS Utilization_Band,
  Credit_Score,
  COUNT(*) AS Count_Customers,
  ROUND(AVG(Credit_Utilization_Ratio), 2) AS Avg_Utilization
FROM credit_data
WHERE is_train = 0
GROUP BY Utilization_Band, Credit_Score

ORDER BY Utilization_Band, Credit_Score, Dataset;

-- Loan Interest & EMIs (compared)
SELECT 
  'Train' AS Dataset,
  Credit_Score,
  ROUND(AVG(Amount_invested_monthly), 2) AS Avg_Monthly_Investment,
  ROUND(AVG(Total_EMI_per_month), 2) AS Avg_EMI
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score

UNION ALL

SELECT 
  'Test' AS Dataset,
  Credit_Score,
  ROUND(AVG(Amount_invested_monthly), 2) AS Avg_Monthly_Investment,
  ROUND(AVG(Total_EMI_per_month), 2) AS Avg_EMI
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score

ORDER BY Credit_Score, Dataset;

-- Multi-Factor Risk Buckets
SELECT 
    'Train' AS Dataset,
	CASE 
		WHEN Credit_Utilization_Ratio > 70 
			AND Num_of_Delayed_Payment >= 3
			AND (Total_EMI_per_month / NULLIF(Monthly_Inhand_Salary,0)) > 0.5
		THEN 'High Risk'
		WHEN Credit_Utilization_Ratio > 35 
			AND Num_of_Delayed_Payment BETWEEN 1 AND 2
		THEN 'Medium Risk'
		ELSE 'Low Risk'
	END AS Risk_Bucket,
	Credit_Score,
	COUNT(*) AS Customer_Count
FROM credit_data
WHERE is_train = 1
GROUP BY Risk_Bucket, Credit_Score

UNION ALL

SELECT 
    'Test' AS Dataset,
	CASE 
		WHEN Credit_Utilization_Ratio > 70 
			AND Num_of_Delayed_Payment >= 3
			AND (Total_EMI_per_month / NULLIF(Monthly_Inhand_Salary,0)) > 0.5
		THEN 'High Risk'
		WHEN Credit_Utilization_Ratio > 35 
			AND Num_of_Delayed_Payment BETWEEN 1 AND 2
		THEN 'Medium Risk'
		ELSE 'Low Risk'
	END AS Risk_Bucket,
	Credit_Score,
	COUNT(*) AS Customer_Count
FROM credit_data
WHERE is_train = 0
GROUP BY Risk_Bucket, Credit_Score

ORDER BY Risk_Bucket, Credit_Score, Dataset;

-- High-Risk vs. Low-Risk Financial Habits (compared)
SELECT 
	'Train' AS Dataset,
    CASE 
        WHEN Credit_Score IN ('Poor') THEN 'High Risk'
        WHEN Credit_Score IN ('Good') THEN 'Low Risk'
        ELSE 'Medium Risk'
    END AS Risk_Category,
    ROUND(AVG(Num_of_Delayed_Payment), 2) AS Avg_Delays,
    ROUND(AVG(Credit_Utilization_Ratio), 2) AS Avg_Utilization,
    ROUND(AVG(Num_of_Loan), 2) AS Avg_Loans
FROM credit_data
WHERE is_train = 1
GROUP BY Risk_Category

UNION ALL

SELECT 
	'Test' AS Dataset,
    CASE 
        WHEN Credit_Score IN ('Poor') THEN 'High Risk'
        WHEN Credit_Score IN ('Good') THEN 'Low Risk'
        ELSE 'Medium Risk'
    END AS Risk_Category,
    ROUND(AVG(Num_of_Delayed_Payment), 2) AS Avg_Delays,
    ROUND(AVG(Credit_Utilization_Ratio), 2) AS Avg_Utilization,
    ROUND(AVG(Num_of_Loan), 2) AS Avg_Loans
FROM credit_data
WHERE is_train = 0
GROUP BY Risk_Category

ORDER BY Risk_Category, Dataset;

-- Distribution of credit limit changes by credit score (compared)
SELECT 
  'Train' AS Dataset,
  Credit_Score,
  CASE 
    WHEN Changed_Credit_Limit > 0 THEN 'Increase'
    WHEN Changed_Credit_Limit < 0 THEN 'Decrease'
    ELSE 'No Change'
  END AS Credit_Limit_Change_Type,
  COUNT(*) AS Count_Customers,
  ROUND(AVG(Changed_Credit_Limit), 2) AS Avg_Change
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score, Credit_Limit_Change_Type

UNION ALL

SELECT 
  'Test' AS Dataset,
  Credit_Score,
  CASE 
    WHEN Changed_Credit_Limit > 0 THEN 'Increase'
    WHEN Changed_Credit_Limit < 0 THEN 'Decrease'
    ELSE 'No Change'
  END AS Credit_Limit_Change_Type,
  COUNT(*) AS Count_Customers,
  ROUND(AVG(Changed_Credit_Limit), 2) AS Avg_Change
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score, Credit_Limit_Change_Type

ORDER BY Credit_Score, Credit_Limit_Change_Type, Dataset;

-- Average magnitude of increase/decrease in credit limit by credit score (compared)
SELECT 
  'Train' AS Dataset,
  Credit_Score,
  ROUND(AVG(CASE WHEN Changed_Credit_Limit > 0 THEN Changed_Credit_Limit END), 2) AS Avg_Increase,
  ROUND(AVG(CASE WHEN Changed_Credit_Limit < 0 THEN Changed_Credit_Limit END), 2) AS Avg_Decrease
FROM credit_data
WHERE is_train = 1
GROUP BY Credit_Score

UNION ALL

SELECT 
  'Test' AS Dataset,
  Credit_Score,
  ROUND(AVG(CASE WHEN Changed_Credit_Limit > 0 THEN Changed_Credit_Limit END), 2) AS Avg_Increase,
  ROUND(AVG(CASE WHEN Changed_Credit_Limit < 0 THEN Changed_Credit_Limit END), 2) AS Avg_Decrease
FROM credit_data
WHERE is_train = 0
GROUP BY Credit_Score

ORDER BY Credit_Score, Dataset;












