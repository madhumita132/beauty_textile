-- ================================================================
-- Beauty Textile — Test / Dummy Data
-- Run AFTER schema_postgresql.sql (schema + seed must exist first)
--
--   psql -U postgres -d beauty_textile -f database/test_data.sql
-- ================================================================

-- ----------------------------------------------------------------
-- 1. Products (5 more, in addition to the 6 already seeded)
-- ----------------------------------------------------------------
INSERT INTO products (name, description, category, price, stock, image_url, barcode) VALUES
('Daily Wear Cotton Saree',  'Comfortable soft cotton saree for everyday use',      'Cotton Sarees',        599.00, 30, NULL, 'BT2001'),
('Party Wear Georgette Saree','Shimmering georgette saree with embroidery border',  'Party Wear Sarees',   1899.00, 10, NULL, 'BT2002'),
('Men Formal Pant',          'Slim-fit formal trouser in charcoal grey',            'Pants & Trousers',     999.00, 22, NULL, 'BT2003'),
('Gown Maxi Dress',          'Floor-length maxi gown for functions and parties',    'Gowns',               1599.00, 14, NULL, 'BT2004'),
('Ethnic Wear Kurta Set',    'Men kurta with matching pyjama, festive wear',        'Ethnic Wear',         1349.00, 17, NULL, 'BT2005')
ON CONFLICT (barcode) DO NOTHING;

-- ----------------------------------------------------------------
-- 2. Orders (5 customer online orders)
-- ----------------------------------------------------------------
INSERT INTO orders (id, customer_name, phone, address, total_amount, payment_status, razorpay_order_id, razorpay_payment_id, created_at) VALUES
(1, 'Priya Sharma',    '9876543210', '12, MG Road, Chennai - 600001',            2999.00, 'PAID',    'order_abc001', 'pay_abc001', NOW() - INTERVAL '5 days'),
(2, 'Ramesh Kumar',    '9123456789', '45, Anna Nagar, Chennai - 600040',         1199.00, 'PAID',    'order_abc002', 'pay_abc002', NOW() - INTERVAL '4 days'),
(3, 'Lakshmi Devi',    '9988776655', '7, T Nagar, Chennai - 600017',             3498.00, 'PAID',    'order_abc003', 'pay_abc003', NOW() - INTERVAL '3 days'),
(4, 'Arjun Patel',     '9871234567', '23, Velachery Main Rd, Chennai - 600042',  799.00, 'PENDING', NULL,           NULL,         NOW() - INTERVAL '1 day'),
(5, 'Meena Iyer',      '9765432100', '5, Adyar, Chennai - 600020',              2198.00, 'PAID',    'order_abc005', 'pay_abc005', NOW())
ON CONFLICT DO NOTHING;

-- ----------------------------------------------------------------
-- 3. Order Items (2 items per order)
-- ----------------------------------------------------------------
INSERT INTO order_items (order_id, product_id, product_name, quantity, price) VALUES
-- Order 1: Kanjivaram Silk Saree × 1
(1, 4, 'Kanjivaram Silk Saree', 1, 2999.00),
-- Order 2: Men Casual Shirt × 1
(2, 2, 'Men Casual Shirt',      1, 1199.00),
-- Order 3: Cotton Kurti + Girls Party Dress
(3, 1, 'Cotton Kurti Blue',     2,  899.00),
(3, 3, 'Girls Party Dress',     1, 1499.00),
-- Order 4: Boys Cargo Pants
(4, 5, 'Boys Cargo Pants',      1,  799.00),
-- Order 5: Kids Ethnic Set + Cotton Kurti
(5, 6, 'Kids Ethnic Set',       1, 1299.00),
(5, 1, 'Cotton Kurti Blue',     1,  899.00);

-- ----------------------------------------------------------------
-- 4. Billing (5 walk-in POS bills)
-- ----------------------------------------------------------------
INSERT INTO billing (id, customer_name, phone, total_amount, payment_mode, created_at) VALUES
(1, 'Sunita Bai',    '9900112233', 1798.00, 'CASH',   NOW() - INTERVAL '4 days'),
(2, 'Vijay Kumar',   '9811223344', 1199.00, 'UPI',    NOW() - INTERVAL '3 days'),
(3, 'Kavitha Reddy', '9933445566', 3598.00, 'CASH',   NOW() - INTERVAL '2 days'),
(4, 'Suresh Raj',    '9944556677',  599.00, 'CARD',   NOW() - INTERVAL '1 day'),
(5, 'Anita Singh',   '9955667788', 2399.00, 'UPI',    NOW())
ON CONFLICT DO NOTHING;

-- ----------------------------------------------------------------
-- 5. Billing Items (2 items per bill)
-- ----------------------------------------------------------------
INSERT INTO billing_items (bill_id, product_id, product_name, quantity, price) VALUES
-- Bill 1: Cotton Kurti × 2
(1, 1, 'Cotton Kurti Blue',        2,  899.00),
-- Bill 2: Men Casual Shirt
(2, 2, 'Men Casual Shirt',         1, 1199.00),
-- Bill 3: Party Wear Saree + Kanjivaram Saree
(3, 4, 'Kanjivaram Silk Saree',    1, 2999.00),
(3, 1, 'Cotton Kurti Blue',        1,  599.00),
-- Bill 4: Daily Wear Cotton Saree
(4, 7, 'Daily Wear Cotton Saree',  1,  599.00),
-- Bill 5: Gown + Kids Ethnic Set
(5, 9, 'Gown Maxi Dress',          1, 1599.00),
(5, 6, 'Kids Ethnic Set',          1, 1299.00);

-- ----------------------------------------------------------------
-- Sync sequences after manual ID inserts
-- ----------------------------------------------------------------
SELECT setval('orders_id_seq',  (SELECT MAX(id) FROM orders));
SELECT setval('billing_id_seq', (SELECT MAX(id) FROM billing));

-- ----------------------------------------------------------------
-- Quick verification
-- ----------------------------------------------------------------
SELECT 'products'     AS tbl, COUNT(*) FROM products
UNION ALL SELECT 'categories',   COUNT(*) FROM categories
UNION ALL SELECT 'orders',       COUNT(*) FROM orders
UNION ALL SELECT 'order_items',  COUNT(*) FROM order_items
UNION ALL SELECT 'billing',      COUNT(*) FROM billing
UNION ALL SELECT 'billing_items',COUNT(*) FROM billing_items
UNION ALL SELECT 'admin_users',  COUNT(*) FROM admin_users;
