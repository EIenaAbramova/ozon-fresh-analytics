-- SQLite. Одна строка orders = заказ, order_items = единица товара в заказе,
-- products_category = SKU и его категория. order_item_id не является количеством.
SELECT 'orders' AS table_name, COUNT(*) AS rows_count, COUNT(DISTINCT order_id) AS unique_keys FROM orders
UNION ALL SELECT 'order_items', COUNT(*), COUNT(DISTINCT order_id || ':' || order_item_id) FROM order_items
UNION ALL SELECT 'products_category', COUNT(*), COUNT(DISTINCT product_id) FROM products_category;
