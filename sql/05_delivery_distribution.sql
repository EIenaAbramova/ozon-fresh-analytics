-- Перцентили: линейная интерполяция между соседними порядковыми статистиками.
WITH delivery AS (
 SELECT julianday(delivered_customer_date)-julianday(purchase_timestamp) AS days
 FROM orders WHERE delivered_customer_date IS NOT NULL
), ranked AS (
 SELECT days, ROW_NUMBER() OVER(ORDER BY days) AS rn, COUNT(*) OVER() AS n FROM delivery
), targets AS (
 SELECT 'P25' AS metric,0.25 AS p UNION ALL SELECT 'median',0.5
 UNION ALL SELECT 'P75',0.75 UNION ALL SELECT 'P90',0.9 UNION ALL SELECT 'P95',0.95
), positions AS (
 SELECT metric,1+p*(MAX(n)-1) AS pos FROM targets CROSS JOIN ranked GROUP BY metric,p
)
SELECT metric,
 MAX(CASE WHEN rn=CAST(pos AS INTEGER) THEN days END)
 + (pos-CAST(pos AS INTEGER)) * (
 COALESCE(MAX(CASE WHEN rn=CAST(pos AS INTEGER)+1 THEN days END),MAX(days))
 -MAX(CASE WHEN rn=CAST(pos AS INTEGER) THEN days END)) AS days
FROM positions CROSS JOIN ranked GROUP BY metric,pos
UNION ALL SELECT 'mean',AVG(days) FROM delivery
UNION ALL SELECT 'max',MAX(days) FROM delivery
UNION ALL SELECT 'min',MIN(days) FROM delivery;
