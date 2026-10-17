-- customer_id трактуется как идентификатор клиента в предоставленной книге.
SELECT COUNT(DISTINCT customer_id) AS july_customers FROM orders
WHERE purchase_timestamp >= '2017-07-01' AND purchase_timestamp < '2017-08-01';
