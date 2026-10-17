PRAGMA foreign_keys=ON;
CREATE TABLE orders(order_id TEXT PRIMARY KEY, customer_id TEXT NOT NULL, purchase_timestamp TEXT NOT NULL, delivered_customer_date TEXT);
CREATE TABLE products_category(product_id TEXT PRIMARY KEY, product_category_name TEXT);
CREATE TABLE order_items(order_id TEXT NOT NULL REFERENCES orders(order_id), order_item_id INTEGER NOT NULL, product_id TEXT NOT NULL REFERENCES products_category(product_id), seller_id TEXT NOT NULL, price REAL NOT NULL, freight_value REAL NOT NULL, PRIMARY KEY(order_id,order_item_id));
CREATE INDEX ix_items_product ON order_items(product_id);
CREATE INDEX ix_orders_purchase ON orders(purchase_timestamp);
