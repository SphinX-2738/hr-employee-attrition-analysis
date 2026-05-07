-- ============================================
-- HR Employee Attrition Analysis — SQL Queries
-- Author: Ankur Sharma
-- Dataset: IBM HR Employee Attrition (Real Data)
-- Source: IBM Watson Analytics Sample Dataset
-- Enriched to: 5,000 employee records
-- Tool: MySQL Workbench
-- Overall Attrition Rate: 28.66%
-- ============================================

-- ─────────────────────────────────────────────
-- PRE-PROCESSING: Fix carriage return characters
-- Run these before any queries
-- ─────────────────────────────────────────────

SET SQL_SAFE_UPDATES = 0;
UPDATE employees SET Attrition = TRIM(REPLACE(Attrition, '\r', ''));
UPDATE employees SET Department = TRIM(REPLACE(Department, '\r', ''));
UPDATE employees SET JobRole = TRIM(REPLACE(JobRole, '\r', ''));
UPDATE employees SET OverTime = TRIM(REPLACE(OverTime, '\r', ''));
UPDATE employees SET Gender = TRIM(REPLACE(Gender, '\r', ''));
UPDATE employees SET MaritalStatus = TRIM(REPLACE(MaritalStatus, '\r', ''));
UPDATE employees SET BusinessTravel = TRIM(REPLACE(BusinessTravel, '\r', ''));
UPDATE employees SET EducationField = TRIM(REPLACE(EducationField, '\r', ''));
SET SQL_SAFE_UPDATES = 1;

-- ─────────────────────────────────────────────
-- BEGINNER QUERIES
-- ─────────────────────────────────────────────

-- Query 1: Overall attrition rate
-- Business Question: What percentage of employees have left the company?
SELECT 
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrited,
    SUM(CASE WHEN Attrition = 'No' THEN 1 ELSE 0 END) AS Retained,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Rate_Pct
FROM employees;
-- Result: 28.66% attrition rate — above healthy benchmark of 10-15%

-- Query 2: Attrition rate by department
-- Business Question: Which department has the biggest attrition problem?
SELECT 
    Department,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrited,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Rate_Pct,
    ROUND(AVG(MonthlyIncome), 2) AS Avg_Monthly_Income,
    ROUND(AVG(Age), 1) AS Avg_Age
FROM employees
GROUP BY Department
ORDER BY Attrition_Rate_Pct DESC;
-- Result: Sales 32.82% — nearly double Research & Development

-- Query 3: Top 5 job roles by attrition rate
-- Business Question: Which specific roles are bleeding talent?
SELECT 
    JobRole,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrited,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Rate_Pct,
    ROUND(AVG(MonthlyIncome), 2) AS Avg_Monthly_Income
FROM employees
GROUP BY JobRole
ORDER BY Attrition_Rate_Pct DESC
LIMIT 5;
-- Result: Sales Representative 52.89% — more than half leave every cycle

-- Query 4: Average monthly income — attrited vs retained
-- Business Question: Are we paying attrited employees less than retained ones?
SELECT 
    Attrition,
    COUNT(*) AS Total_Employees,
    ROUND(AVG(MonthlyIncome), 2) AS Avg_Monthly_Income,
    ROUND(AVG(MonthlyIncome) * 12, 2) AS Avg_Annual_Salary,
    ROUND(AVG(YearsAtCompany), 1) AS Avg_Years_At_Company,
    ROUND(AVG(Age), 1) AS Avg_Age
FROM employees
GROUP BY Attrition;
-- Result: Attrited earn $6,132/month vs significantly more for retained employees

-- ─────────────────────────────────────────────
-- INTERMEDIATE QUERIES
-- ─────────────────────────────────────────────

-- Query 5: Impact of overtime on attrition
-- Business Question: Is overworking employees driving them to leave?
SELECT 
    OverTime,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrited,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Rate_Pct,
    ROUND(AVG(MonthlyIncome), 2) AS Avg_Monthly_Income,
    ROUND(AVG(WorkLifeBalance), 2) AS Avg_WorkLife_Balance
FROM employees
GROUP BY OverTime
ORDER BY Attrition_Rate_Pct DESC;
-- Result: Overtime Yes = 39.83% vs No = 24.31% — workload is a primary driver

-- Query 6: Attrition by job satisfaction level
-- Business Question: Does job satisfaction predict who will leave?
SELECT 
    JobSatisfaction,
    CASE JobSatisfaction
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'High'
        WHEN 4 THEN 'Very High'
    END AS Satisfaction_Label,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrited,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Rate_Pct,
    ROUND(AVG(MonthlyIncome), 2) AS Avg_Monthly_Income
FROM employees
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction;
-- Result: Low satisfaction = 34.67% vs Very High = 26.21%

-- Query 7: Attrition by age band
-- Business Question: Which age groups are most likely to leave?
SELECT 
    CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '01 - Early Career (18-25)'
        WHEN Age BETWEEN 26 AND 35 THEN '02 - Growth Phase (26-35)'
        WHEN Age BETWEEN 36 AND 45 THEN '03 - Mid Career (36-45)'
        WHEN Age BETWEEN 46 AND 55 THEN '04 - Senior (46-55)'
        WHEN Age BETWEEN 56 AND 60 THEN '05 - Near Retirement (56-60)'
    END AS Age_Band,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrited,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Rate_Pct,
    ROUND(AVG(MonthlyIncome), 2) AS Avg_Monthly_Income
FROM employees
GROUP BY Age_Band
ORDER BY Age_Band;
-- Result: Early career employees (18-25) have the highest attrition rate

-- Query 8: Estimated total cost of attrition
-- Business Question: What is this attrition problem actually costing the business?
SELECT 
    COUNT(*) AS Total_Attrited,
    ROUND(AVG(MonthlyIncome), 2) AS Avg_Monthly_Income,
    ROUND(AVG(MonthlyIncome) * 12, 2) AS Avg_Annual_Salary,
    ROUND(SUM(MonthlyIncome) * 12 * 0.5, 2) AS Replacement_Cost_Low,
    ROUND(SUM(MonthlyIncome) * 12 * 2.0, 2) AS Replacement_Cost_High
FROM employees
WHERE Attrition = 'Yes';
-- Result: $52.7M (low) to $210.8M (high) in estimated replacement costs

-- ─────────────────────────────────────────────
-- ADVANCED QUERIES
-- ─────────────────────────────────────────────

-- Query 9: Rank departments by attrition rate and income gap
-- Business Question: Which departments have the worst combination of high attrition AND income gap?
WITH dept_stats AS (
    SELECT 
        Department,
        COUNT(*) AS Total_Employees,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrited,
        ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Rate_Pct,
        ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN MonthlyIncome END), 2) AS Avg_Income_Attrited,
        ROUND(AVG(CASE WHEN Attrition = 'No' THEN MonthlyIncome END), 2) AS Avg_Income_Retained
    FROM employees
    GROUP BY Department
)
SELECT 
    Department,
    Total_Employees,
    Attrited,
    Attrition_Rate_Pct,
    Avg_Income_Attrited,
    Avg_Income_Retained,
    ROUND(Avg_Income_Retained - Avg_Income_Attrited, 2) AS Income_Gap,
    RANK() OVER (ORDER BY Attrition_Rate_Pct DESC) AS Attrition_Rank
FROM dept_stats
ORDER BY Attrition_Rank;
-- Result: Sales has highest attrition AND largest income gap — double crisis

-- Query 10: High risk employees not yet attrited — retention target list
-- Business Question: Which current employees are most likely to leave next?
SELECT 
    EmployeeNumber,
    Age,
    Department,
    JobRole,
    JobLevel,
    MonthlyIncome,
    OverTime,
    JobSatisfaction,
    WorkLifeBalance,
    YearsAtCompany,
    YearsSinceLastPromotion,
    ROUND(MonthlyIncome * 12, 2) AS Annual_Salary_At_Risk,
    ROUND(MonthlyIncome * 12 * 0.5, 2) AS Min_Replacement_Cost
FROM employees
WHERE Attrition = 'No'
    AND OverTime = 'Yes'
    AND JobSatisfaction <= 2
    AND WorkLifeBalance <= 2
    AND YearsSinceLastPromotion >= 3
ORDER BY MonthlyIncome DESC
LIMIT 20;
-- Result: Top 20 high-value employees matching every attrition risk factor

-- Query 11: Highest attrition combination of department + role + overtime
-- Business Question: What is the deadliest employee profile combination?
SELECT 
    Department,
    JobRole,
    OverTime,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrited,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Rate_Pct,
    ROUND(AVG(MonthlyIncome), 2) AS Avg_Monthly_Income
FROM employees
GROUP BY Department, JobRole, OverTime
HAVING COUNT(*) > 20
ORDER BY Attrition_Rate_Pct DESC
LIMIT 10;
-- Result: Sales + Sales Representative + Overtime Yes = highest attrition combination

-- Query 12: Attrition rate by job role and overtime — pivot style
-- Business Question: Which roles are most sensitive to overtime pressure?
SELECT 
    JobRole,
    COUNT(*) AS Total_Employees,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' AND OverTime = 'Yes' THEN 1 ELSE 0 END) * 100.0 /
          NULLIF(SUM(CASE WHEN OverTime = 'Yes' THEN 1 ELSE 0 END), 0), 2) AS Attrition_With_OT,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' AND OverTime = 'No' THEN 1 ELSE 0 END) * 100.0 /
          NULLIF(SUM(CASE WHEN OverTime = 'No' THEN 1 ELSE 0 END), 0), 2) AS Attrition_Without_OT,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' AND OverTime = 'Yes' THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN OverTime = 'Yes' THEN 1 ELSE 0 END), 0) -
        SUM(CASE WHEN Attrition = 'Yes' AND OverTime = 'No' THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN OverTime = 'No' THEN 1 ELSE 0 END), 0)
    , 2) AS OT_Impact
FROM employees
GROUP BY JobRole
ORDER BY OT_Impact DESC;
-- Result: Shows which roles are most sensitive to overtime — actionable for workload management