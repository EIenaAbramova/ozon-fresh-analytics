-- Популярность = число уникальных заказов, содержащих категорию.
-- DENSE_RANK сохраняет все категории при равенстве популярности.
WITH counts AS (
 SELECT p.product_category_name,COUNT(DISTINCT i.order_id) AS category_orders
 FROM order_items i JOIN products_category p ON p.product_id=i.product_id
 WHERE p.product_category_name IS NOT NULL GROUP BY p.product_category_name
), ranked AS (
 SELECT *,DENSE_RANK() OVER(ORDER BY category_orders DESC) AS popularity_rank FROM counts
)
SELECT *,1.0*category_orders/(SELECT COUNT(*) FROM orders) AS share_all_orders
FROM ranked WHERE popularity_rank=7 ORDER BY product_category_name;
