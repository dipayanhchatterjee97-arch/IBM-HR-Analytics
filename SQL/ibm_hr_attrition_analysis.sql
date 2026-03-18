-- ============================================================
-- IBM HR ANALYTICS - EMPLOYEE ATTRITION ANALYSIS
-- Dataset : IBM HR Employee Attrition (Fictional, 1470 rows)
-- Tool    : DB Browser for SQLite
-- Author  : Dipayan Chatterjee
-- Purpose : Identify key drivers of employee attrition using SQL
--           to support HR decision-making and people analytics
-- ============================================================


-- ============================================================
-- SECTION 1: DATA EXPLORATION
-- Quick look at the raw data to verify the import and
-- understand the structure before running analysis
-- ============================================================

-- Query 1: Preview the first 5 rows to confirm the data loaded
--          correctly and review available columns
SELECT * FROM hr_employees LIMIT 5;


-- Query 2: Count employees by attrition status (Yes / No)
--          to get a quick feel for the class distribution
SELECT 
    Attrition, 
    COUNT(*) AS total
FROM hr_employees
GROUP BY Attrition;


-- ============================================================
-- SECTION 2: OVERALL ATTRITION SUMMARY
-- Baseline metrics — total headcount, number of leavers,
-- and the overall attrition rate across the organisation
-- ============================================================

-- Query 3: Company-wide attrition summary
--          Uses conditional aggregation (CASE WHEN) to split
--          leavers from stayers in a single pass
SELECT
    COUNT(*)                                                          AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)               AS total_leavers,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                              AS attrition_rate
FROM hr_employees;


-- ============================================================
-- SECTION 3: ATTRITION BY DEPARTMENT & JOB ROLE
-- Breaks down attrition to identify which teams and roles
-- are experiencing the highest employee turnover
-- ============================================================

-- Query 4: Attrition rate by Department
--          Ordered highest to lowest to surface the most
--          at-risk departments at the top
SELECT
    Department,
    COUNT(*)                                                          AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)               AS total_leavers,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                              AS attrition_rate
FROM hr_employees
GROUP BY Department
ORDER BY attrition_rate DESC;


-- Query 5: Attrition rate by Job Role
--          Granular view below department level to pinpoint
--          specific roles driving overall attrition numbers
SELECT
    JobRole,
    COUNT(*)                                                          AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)               AS total_leavers,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                              AS attrition_rate
FROM hr_employees
GROUP BY JobRole
ORDER BY attrition_rate DESC;


-- ============================================================
-- SECTION 4: COMPENSATION ANALYSIS
-- Compares average monthly income between employees who
-- stayed vs left — segmented by Department and Education
-- to test whether pay gaps are driving attrition
-- ============================================================

-- Query 6: Average monthly income by Department — Stayed vs Left
--          Pivot-style output using conditional AVG to compare
--          compensation side by side in a single result set
SELECT 
    Department,
    ROUND(AVG(CASE WHEN Attrition = 'No'  THEN MonthlyIncome END), 2) AS avg_income_stayed,
    ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN MonthlyIncome END), 2) AS avg_income_left
FROM hr_employees
GROUP BY Department
ORDER BY Department;


-- Query 7: Average monthly income by Education Level — Stayed vs Left
--          Education codes are decoded to readable labels using CASE WHEN
--          (1=Below College, 2=College, 3=Bachelor, 4=Master, 5=Doctor)
SELECT
    CASE
        WHEN Education = 1 THEN 'Below College'
        WHEN Education = 2 THEN 'College'
        WHEN Education = 3 THEN 'Bachelor'
        WHEN Education = 4 THEN 'Master'
        WHEN Education = 5 THEN 'Doctor'
    END                                                               AS education_level,
    ROUND(AVG(CASE WHEN Attrition = 'No'  THEN MonthlyIncome END), 2) AS avg_income_stayed,
    ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN MonthlyIncome END), 2) AS avg_income_left
FROM hr_employees
GROUP BY Education
ORDER BY Education;


-- ============================================================
-- SECTION 5: KEY ATTRITION DRIVERS
-- Examines two of the strongest behavioural and environmental
-- factors linked to attrition: overtime and work-life balance
-- ============================================================

-- Query 8: Attrition rate by Overtime status (Yes / No)
--          Tests whether employees required to work overtime
--          are significantly more likely to leave
SELECT 
    OverTime,
    COUNT(*)                                                          AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)               AS employees_left,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                              AS attrition_rate
FROM hr_employees
GROUP BY OverTime;


-- Query 9: Attrition rate by Work-Life Balance rating
--          Numeric codes decoded to readable labels:
--          1=Bad, 2=Good, 3=Better, 4=Best
--          Ordered ascending to show trend across rating scale
SELECT
    CASE
        WHEN WorkLifeBalance = 1 THEN 'Bad'
        WHEN WorkLifeBalance = 2 THEN 'Good'
        WHEN WorkLifeBalance = 3 THEN 'Better'
        WHEN WorkLifeBalance = 4 THEN 'Best'
    END                                                               AS work_life_balance,
    COUNT(*)                                                          AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)               AS employees_left,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                              AS attrition_rate
FROM hr_employees
GROUP BY WorkLifeBalance
ORDER BY WorkLifeBalance ASC;


-- ============================================================
-- SECTION 6: ADVANCED ANALYSIS
-- Age-band segmentation and CTE-based ranking to demonstrate
-- more advanced SQL techniques for portfolio purposes
-- ============================================================

-- Query 10: Attrition rate by Age Group
--           Ages bucketed into bands using CASE WHEN ranges
--           to reveal which life/career stage has highest turnover
SELECT
    CASE
        WHEN Age < 20            THEN 'Below 20s'
        WHEN Age >= 20 AND Age < 30 THEN 'Below 30s'
        WHEN Age >= 30 AND Age < 40 THEN 'Below 40s'
        WHEN Age >= 40 AND Age < 50 THEN 'Below 50s'
        WHEN Age >= 50 AND Age < 60 THEN 'Below 60s'
        ELSE                         'Above 60s'
    END                                                               AS age_group,
    COUNT(*)                                                          AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)               AS employees_left,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                              AS attrition_rate
FROM hr_employees
GROUP BY age_group
ORDER BY attrition_rate DESC;


-- Query 11: Top 3 Job Roles by Attrition Rate using a CTE
--           CTE (Common Table Expression) first calculates attrition
--           per role, then the outer query filters to the top 3.
--           Demonstrates multi-step query logic and CTE syntax.
WITH cte_attrition AS (
    SELECT
        JobRole,
        COUNT(*)                                                      AS total_employees,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)           AS total_leavers,
        ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
              / COUNT(*), 2)                                          AS attrition_rate
    FROM hr_employees
    GROUP BY JobRole
)
SELECT * 
FROM cte_attrition
ORDER BY attrition_rate DESC
LIMIT 3;

-- ============================================================
-- END OF ANALYSIS
-- Skills demonstrated: SELECT, GROUP BY, ORDER BY, CASE WHEN,
-- Conditional Aggregation, ROUND, AVG, COUNT, SUM, CTE (WITH)
-- ============================================================
