
BEGIN;
INSERT INTO Orders (user_id, status) VALUES (1, 'Pending');
SAVEPOINT sp_order_created;
INSERT INTO Order_Items (order_id, product_id, quantity, unit_price)
VALUES (currval('orders_order_id_seq'), 1, 5, 50000);
UPDATE Products 
SET stock_quantity = stock_quantity - 5 
WHERE product_id = 1;

COMMIT;