-- EXISTS исключает двойной счёт нескольких позиций и пересечение категорий.
WITH flags AS (
 SELECT o.order_id,
 EXISTS(SELECT 1 FROM order_items i JOIN products_category p ON p.product_id=i.product_id
 WHERE i.order_id=o.order_id AND p.product_category_name='bed_bath_table') AS bed,
 EXISTS(SELECT 1 FROM order_items i JOIN products_category p ON p.product_id=i.product_id
 WHERE i.order_id=o.order_id AND p.product_category_name='computers_accessories') AS computers
 FROM orders o
)
SELECT COUNT(*) AS all_orders,SUM(bed) AS bed_orders,SUM(computers) AS computer_orders,
 SUM(bed AND computers) AS both_orders,SUM(bed OR computers) AS either_orders,
 1.0*SUM(bed OR computers)/COUNT(*) AS share_either,
 1.0*SUM(bed AND computers)/COUNT(*) AS share_both FROM flags;
