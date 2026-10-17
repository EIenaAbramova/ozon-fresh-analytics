-- Когорта покупок 2017; доставки в 2018 сохраняются. NULL не равен нулю дней.
SELECT COUNT(*) AS all_orders, COUNT(delivered_customer_date) AS observed_deliveries,
       SUM(delivered_customer_date IS NULL) AS missing_deliveries,
       AVG(julianday(delivered_customer_date)-julianday(purchase_timestamp)) AS mean_days
FROM orders;
