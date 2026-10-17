-- Заказы за весь представленный период, в том числе без товарных позиций.
SELECT COUNT(*) AS orders_count, MIN(purchase_timestamp) AS first_purchase,
       MAX(purchase_timestamp) AS last_purchase FROM orders;
