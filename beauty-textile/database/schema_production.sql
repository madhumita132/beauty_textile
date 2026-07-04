-- ================================================================
-- Beauty Textile — Production MySQL Schema
-- Railway MySQL compatible — UTF8MB4
-- ================================================================

CREATE DATABASE IF NOT EXISTS beauty_textile CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE beauty_textile;

CREATE TABLE IF NOT EXISTS categories (
    id        BIGINT PRIMARY KEY AUTO_INCREMENT,
    name      VARCHAR(80) NOT NULL UNIQUE,
    parent_id BIGINT NULL,
    image_path VARCHAR(255),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_category_parent FOREIGN KEY (parent_id) REFERENCES categories(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS products (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(150) NOT NULL,
    description VARCHAR(1000),
    category    VARCHAR(60) NOT NULL,
    price       DECIMAL(10,2) NOT NULL,
    stock       INT NOT NULL DEFAULT 0,
    image_url   VARCHAR(500),
    barcode     VARCHAR(50) NOT NULL UNIQUE,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_products_category (category),
    INDEX idx_products_barcode (barcode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS orders (
    id                   BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_name        VARCHAR(150) NOT NULL,
    phone                VARCHAR(20) NOT NULL,
    address              VARCHAR(500),
    total_amount         DECIMAL(10,2) NOT NULL,
    payment_status       VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    razorpay_order_id    VARCHAR(100),
    razorpay_payment_id  VARCHAR(100),
    created_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_orders_created (created_at),
    INDEX idx_orders_status  (payment_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS order_items (
    id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id     BIGINT NOT NULL,
    product_id   BIGINT NOT NULL,
    product_name VARCHAR(150),
    quantity     INT NOT NULL,
    price        DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_oi_order   FOREIGN KEY (order_id)   REFERENCES orders(id)   ON DELETE CASCADE,
    CONSTRAINT fk_oi_product FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS billing (
    id            BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(150),
    phone         VARCHAR(20),
    total_amount  DECIMAL(10,2) NOT NULL,
    payment_mode  VARCHAR(20),
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_billing_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS billing_items (
    id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    bill_id      BIGINT NOT NULL,
    product_id   BIGINT NOT NULL,
    product_name VARCHAR(150),
    quantity     INT NOT NULL,
    price        DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_bi_bill    FOREIGN KEY (bill_id)    REFERENCES billing(id)  ON DELETE CASCADE,
    CONSTRAINT fk_bi_product FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS admin_users (
    id       BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(60) NOT NULL UNIQUE,
    password VARCHAR(200) NOT NULL,
    role     VARCHAR(30)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- Seed data ----

-- Top-level categories
INSERT IGNORE INTO categories (id, name, parent_id) VALUES
(1, 'Women', NULL),(2, 'Men', NULL),(3, 'Kids', NULL),(4, 'Boys', NULL),(5, 'Girls', NULL);
-- Women sub-categories
INSERT IGNORE INTO categories (id, name, parent_id) VALUES
(6,'Sarees',1),(7,'Girls Collection',1),(8,'Kurtis & Gowns',1);
-- Sarees
INSERT IGNORE INTO categories (id, name, parent_id) VALUES
(9,'Daily Wear Sarees',6),(10,'Cotton Sarees',6),(11,'Party Wear Sarees',6),(12,'Kanjivaram Sarees',6),(13,'Pattu (Silk) Sarees',6);
-- Kurtis & Gowns
INSERT IGNORE INTO categories (id, name, parent_id) VALUES
(14,'Kurti Tops',8),(15,'Kurti Sets',8),(16,'Gowns',8);
-- Men
INSERT IGNORE INTO categories (id, name, parent_id) VALUES
(17,'Shirts',2),(18,'Pants & Trousers',2),(19,'Ethnic Wear',2);

-- Default admin: password = admin123  (BCrypt $2a$10$...)
INSERT IGNORE INTO admin_users (id, username, password, role) VALUES
(1, 'admin', '$2a$10$W4Dc4d2Qbhx6fJ0hIJ8v2uW1CkG4rPj7grxJvXQk5JrCFzNwCS6jK', 'ADMIN');

-- Sample products
INSERT IGNORE INTO products (id, name, description, category, price, stock, image_url, barcode) VALUES
(1, 'Cotton Kurthi Blue',  'Soft cotton kurthi for daily wear',       'Kurthi', 899.00,  25, NULL, 'BT1001'),
(2, 'Men Casual Shirt',    'Comfort fit check shirt',                  'Men',    1199.00, 18, NULL, 'BT1002'),
(3, 'Girls Party Dress',   'Elegant party dress for special occasions','Girls',  1499.00, 12, NULL, 'BT1003'),
(4, 'Women Silk Saree',    'Premium silk saree with border',           'Women',  2999.00,  8, NULL, 'BT1004'),
(5, 'Boys Cargo Pants',    'Durable cargo pants for active boys',      'Boys',    799.00, 20, NULL, 'BT1005'),
(6, 'Kids Ethnic Set',     'Festive ethnic wear set for kids',         'Kids',   1299.00, 15, NULL, 'BT1006');
