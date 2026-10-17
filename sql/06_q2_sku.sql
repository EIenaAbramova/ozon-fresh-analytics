SELECT COUNT(DISTINCT i.product_id) AS q2_unique_sku
FROM order_items i JOIN orders o ON o.order_id=i.order_id
WHERE o.purchase_timestamp >= '2017-04-01' AND o.purchase_timestamp < '2017-07-01';
