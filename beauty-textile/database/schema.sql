CREATE DATABASE IF NOT EXISTS beauty_textile;
USE beauty_textile;

CREATE TABLE IF NOT EXISTS categories (
    id        BIGINT PRIMARY KEY AUTO_INCREMENT,
    name      VARCHAR(80) NOT NULL UNIQUE,
    parent_id BIGINT NULL,
    image_path VARCHAR(255),
    CONSTRAINT fk_category_parent FOREIGN KEY (parent_id) REFERENCES categories(id)
);

CREATE TABLE IF NOT EXISTS products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    description VARCHAR(1000),
    category VARCHAR(60) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    image_url VARCHAR(500),
    barcode VARCHAR(50) NOT NULL UNIQUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address VARCHAR(500),
    total_amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    razorpay_order_id VARCHAR(100),
    razorpay_payment_id VARCHAR(100),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_name VARCHAR(150),
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_order_item_product FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE IF NOT EXISTS billing (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(150),
    phone VARCHAR(20),
    total_amount DECIMAL(10,2) NOT NULL,
    payment_mode VARCHAR(20),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS billing_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    bill_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_name VARCHAR(150),
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_billing_item_bill FOREIGN KEY (bill_id) REFERENCES billing(id) ON DELETE CASCADE,
    CONSTRAINT fk_billing_item_product FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE IF NOT EXISTS admin_users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(60) NOT NULL UNIQUE,
    password VARCHAR(200) NOT NULL,
    role VARCHAR(30)
);

-- Seed categories (hierarchical with image paths)
-- Top-level
INSERT IGNORE INTO categories (id, name, parent_id, image_path) VALUES
(1,  'Women',             NULL, '/images/categories/women.svg'),
(2,  'Men',               NULL, '/images/categories/mens/mens.svg'),
(3,  'Kids',              NULL, '/images/categories/kids/kids.svg'),
(4,  'Boys',              NULL, '/images/categories/kids/boys.svg'),
(5,  'Girls',             NULL, '/images/categories/kids/girls.svg');
-- Women sub-categories
INSERT IGNORE INTO categories (id, name, parent_id, image_path) VALUES
(6,  'Sarees',            1, '/images/categories/saree/saree.svg'),
(7,  'Girls Collection',  1, '/images/categories/kids/girls.svg'),
(8,  'Kurtis & Gowns',   1, '/images/categories/kurthi/kurthi.svg');
-- Sarees sub-categories
INSERT IGNORE INTO categories (id, name, parent_id, image_path) VALUES
(9,  'Daily Wear Sarees',   6, '/images/categories/saree/daily-wear.svg'),
(10, 'Cotton Sarees',        6, '/images/categories/saree/cotton.svg'),
(11, 'Party Wear Sarees',    6, '/images/categories/saree/party-wear.svg'),
(12, 'Kanjivaram Sarees',    6, '/images/categories/saree/kanjivaram.svg'),
(13, 'Pattu (Silk) Sarees',  6, '/images/categories/saree/pattu-silk.svg');
-- Kurtis & Gowns sub-categories
INSERT IGNORE INTO categories (id, name, parent_id, image_path) VALUES
(14, 'Kurti Tops',   8, '/images/categories/kurthi/tops.svg'),
(15, 'Kurti Sets',   8, '/images/categories/kurthi/set.svg'),
(16, 'Gowns',        8, '/images/categories/kurthi/gown.svg');
-- Men sub-categories
INSERT IGNORE INTO categories (id, name, parent_id, image_path) VALUES
(17, 'Shirts',           2, '/images/categories/mens/shirt.svg'),
(18, 'Pants & Trousers', 2, '/images/categories/mens/pant.svg'),
(19, 'Ethnic Wear',      2, '/images/categories/mens/ethnic-wear.svg');

-- Default admin: admin / admin123 (BCrypt)
INSERT IGNORE INTO admin_users (id, username, password, role)
VALUES (1, 'admin', '$2a$10$W4Dc4d2Qbhx6fJ0hIJ8v2uW1CkG4rPj7grxJvXQk5JrCFzNwCS6jK', 'ADMIN');

-- Sample products
INSERT IGNORE INTO products (id, name, description, category, price, stock, image_url, barcode) VALUES
(1, 'Cotton Kurti Blue',      'Soft cotton kurti for daily wear',        'Kurti Sets',         899.00,  25, NULL, 'BT1001'),
(2, 'Men Casual Shirt',       'Comfort fit check shirt',                 'Shirts',             1199.00, 18, NULL, 'BT1002'),
(3, 'Girls Party Dress',      'Elegant party dress',                     'Girls Collection',   1499.00, 12, NULL, 'BT1003'),
(4, 'Kanjivaram Silk Saree',  'Premium Kanjivaram saree with border',    'Kanjivaram Sarees',  2999.00,  8, NULL, 'BT1004'),
(5, 'Boys Cargo Pants',       'Durable cargo pants for active boys',     'Boys',                799.00, 20, NULL, 'BT1005'),
(6, 'Kids Ethnic Set',        'Festive ethnic wear set for kids',        'Kids',               1299.00, 15, NULL, 'BT1006');
