-- Средняя цена заказанной единицы товара, без freight_value.
-- Каждая строка позиции получает одинаковый вес; это не средний чек заказа.
SELECT COUNT(*) AS ordered_units, AVG(i.price) AS mean_unit_price,
       SUM(i.price) AS merchandise_value
FROM order_items i JOIN orders o ON o.order_id=i.order_id
WHERE o.purchase_timestamp >= '2017-04-01' AND o.purchase_timestamp < '2017-07-01';
