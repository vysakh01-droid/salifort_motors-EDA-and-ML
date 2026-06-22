--SQL ANALYSIS --

SELECT * FROM "Salifort Sales" LIMIT 10;

--1. HOW MANY - Attrition count & rate?--
SELECT 
  COUNT(*) as total_employees,
  SUM(CASE WHEN "left" = 1 THEN 1 ELSE 0 END) as employees_left,
  ROUND(100.0 * SUM(CASE WHEN "left" = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) as attrition_rate_pct
FROM "Salifort Sales";

--2. Department attrition?--
SELECT 
  department,
  COUNT(*) as total,
  SUM(CASE WHEN "left" = 1 THEN 1 ELSE 0 END) as left_count,
  ROUND(100.0 * SUM(CASE WHEN "left" = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) as attrition_rate_pct
FROM "Salifort Sales"
GROUP BY department
ORDER BY attrition_rate_pct DESC;

--3. How much it cost?--
SELECT 
  salary as salary_level,
  SUM(CASE WHEN "left" = 1 THEN 1 ELSE 0 END) as people_left,
  SUM(CASE WHEN "left" = 1 AND salary = 'low' THEN 40000*1.5 
           WHEN "left" = 1 AND salary = 'medium' THEN 80000*1.5
           WHEN "left" = 1 AND salary = 'high' THEN 120000*1.5 END) as est_replacement_cost_usd
FROM "Salifort Sales"
GROUP BY salary
ORDER BY 
  CASE salary 
    WHEN 'low' THEN 1 
    WHEN 'medium' THEN 2 
    WHEN 'high' THEN 3 
  END;

--4. Risk profile by tenure + satisfaction?--
SELECT 
  CASE 
    WHEN tenure <= 2 THEN '0-2 years'
    WHEN tenure <= 4 THEN '3-4 years' 
    ELSE '5+ years'
  END as tenure_bucket,
  CASE 
    WHEN satisfaction_level < 0.4 THEN 'Low Sat'
    WHEN satisfaction_level < 0.7 THEN 'Med Sat'
    ELSE 'High Sat'
  END as satisfaction_bucket,
  COUNT(*) as total,
  SUM(CASE WHEN "left" = 1 THEN 1 ELSE 0 END) as left_count,
  ROUND(100.0 * SUM(CASE WHEN "left" = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) as attrition_rate_pct
FROM "Salifort Sales"
GROUP BY tenure_bucket, satisfaction_bucket
ORDER BY attrition_rate_pct DESC;

--5. Promotion + Workload impact?--
SELECT 
  promotion_last_5years,
  CASE WHEN average_monthly_hours > 200 THEN 'High Hours >200' ELSE 'Normal Hours <=200' END as workload,
  COUNT(*) as total,
  SUM(CASE WHEN "left" = 1 THEN 1 ELSE 0 END) as left_count,
  ROUND(100.0 * AVG("left"::numeric), 2) as attrition_rate_pct,
  ROUND(AVG(satisfaction_level::numeric), 3) as avg_satisfaction
FROM "Salifort Sales"
GROUP BY promotion_last_5years, workload
ORDER BY attrition_rate_pct DESC;