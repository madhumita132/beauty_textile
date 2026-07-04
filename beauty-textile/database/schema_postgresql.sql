-- ================================================================
-- Beauty Textile — PostgreSQL Schema
-- Run once on a fresh database:
--   psql -U postgres -d beauty_textile -f schema_postgresql.sql
-- ================================================================

-- Categories (self-referencing tree)
CREATE TABLE IF NOT EXISTS categories (
    id         BIGSERIAL PRIMARY KEY,
    name       VARCHAR(80) NOT NULL UNIQUE,
    parent_id  BIGINT REFERENCES categories(id),
    image_path VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS products (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(150) NOT NULL,
    description VARCHAR(1000),
    category    VARCHAR(80) NOT NULL,
    price       NUMERIC(10,2) NOT NULL,
    stock       INTEGER NOT NULL DEFAULT 0,
    image_url   VARCHAR(500),
    barcode     VARCHAR(50) NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_barcode  ON products(barcode);

CREATE TABLE IF NOT EXISTS orders (
    id                   BIGSERIAL PRIMARY KEY,
    customer_name        VARCHAR(150) NOT NULL,
    phone                VARCHAR(20)  NOT NULL,
    address              VARCHAR(500),
    total_amount         NUMERIC(10,2) NOT NULL,
    payment_status       VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
    razorpay_order_id    VARCHAR(100),
    razorpay_payment_id  VARCHAR(100),
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_orders_created ON orders(created_at);

CREATE TABLE IF NOT EXISTS order_items (
    id           BIGSERIAL PRIMARY KEY,
    order_id     BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id   BIGINT NOT NULL REFERENCES products(id),
    product_name VARCHAR(150),
    quantity     INTEGER NOT NULL,
    price        NUMERIC(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS billing (
    id            BIGSERIAL PRIMARY KEY,
    customer_name VARCHAR(150),
    phone         VARCHAR(20),
    total_amount  NUMERIC(10,2) NOT NULL,
    payment_mode  VARCHAR(20),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_billing_created ON billing(created_at);

CREATE TABLE IF NOT EXISTS billing_items (
    id           BIGSERIAL PRIMARY KEY,
    bill_id      BIGINT NOT NULL REFERENCES billing(id) ON DELETE CASCADE,
    product_id   BIGINT NOT NULL REFERENCES products(id),
    product_name VARCHAR(150),
    quantity     INTEGER NOT NULL,
    price        NUMERIC(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS admin_users (
    id       BIGSERIAL PRIMARY KEY,
    username VARCHAR(60) NOT NULL UNIQUE,
    password VARCHAR(200) NOT NULL,
    role     VARCHAR(30)
);

-- Product colour variants (one product → many colours)
CREATE TABLE IF NOT EXISTS product_variants (
    id         BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    color_name VARCHAR(60) NOT NULL,
    color_hex  VARCHAR(10),
    image_url  VARCHAR(500)
);
CREATE INDEX IF NOT EXISTS idx_variants_product ON product_variants(product_id);

-- Sizes within a colour variant (M / L / XL / XXL …)
CREATE TABLE IF NOT EXISTS product_variant_sizes (
    id         BIGSERIAL PRIMARY KEY,
    variant_id BIGINT NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
    size       VARCHAR(10) NOT NULL,
    stock      INTEGER NOT NULL DEFAULT 0,
    UNIQUE (variant_id, size)
);

-- ---- Seed data ----

-- Top-level categories
INSERT INTO categories (id, name, parent_id, image_path) VALUES
(1, 'Sarees', NULL, '/images/categories/saree/saree.svg'),
(2, 'Women',  NULL, '/images/categories/women.svg'),
(3, 'Men',    NULL, '/images/categories/mens/mens.svg'),
(4, 'Kids',   NULL, '/images/categories/kids/kids.svg')
ON CONFLICT (name) DO UPDATE SET parent_id = EXCLUDED.parent_id, image_path = EXCLUDED.image_path;

-- Sarees sub-categories
INSERT INTO categories (id, name, parent_id, image_path) VALUES
(5,  'Daily Wear',       1, '/images/categories/saree/daily-wear.svg'),
(6,  'Party Wear Saree', 1, '/images/categories/saree/party-wear.svg'),
(7,  'Cotton Saree',     1, '/images/categories/saree/cotton.svg'),
(8,  'KanjiPattu Saree', 1, '/images/categories/saree/kanji-pattu.svg'),
(9,  'Pattu Saree',      1, '/images/categories/saree/pattu-silk.svg')
ON CONFLICT (name) DO UPDATE SET parent_id = EXCLUDED.parent_id, image_path = EXCLUDED.image_path;

-- Women sub-categories
INSERT INTO categories (id, name, parent_id, image_path) VALUES
(10, 'Kurthi', 2, '/images/categories/kurthi/kurthi.svg'),
(11, 'Tops',   2, '/images/categories/kurthi/tops.svg'),
(12, 'Chudi',  2, '/images/categories/kurthi/chudi.svg'),
(13, 'Gown',   2, '/images/categories/kurthi/gown.svg'),
(14, 'Legin',  2, '/images/categories/kurthi/legin.svg'),
(15, 'Shawl',  2, '/images/categories/kurthi/shawl.svg')
ON CONFLICT (name) DO UPDATE SET parent_id = EXCLUDED.parent_id, image_path = EXCLUDED.image_path;

-- Men sub-categories
INSERT INTO categories (id, name, parent_id, image_path) VALUES
(16, 'Shirt',       3, '/images/categories/mens/shirt.svg'),
(17, 'Pant',        3, '/images/categories/mens/pant.svg'),
(18, 'Ethnic Wear', 3, '/images/categories/mens/ethnic-wear.svg')
ON CONFLICT (name) DO UPDATE SET parent_id = EXCLUDED.parent_id, image_path = EXCLUDED.image_path;

-- Kids sub-categories
INSERT INTO categories (id, name, parent_id, image_path) VALUES
(19, 'Boys Collection',  4, '/images/categories/kids/boys.svg'),
(20, 'Girls Collection', 4, '/images/categories/kids/girls.svg')
ON CONFLICT (name) DO UPDATE SET parent_id = EXCLUDED.parent_id, image_path = EXCLUDED.image_path;

SELECT setval('categories_id_seq', (SELECT MAX(id) FROM categories));

-- Default admin: password = admin123
INSERT INTO admin_users (username, password, role)
VALUES ('admin', '$2a$10$W4Dc4d2Qbhx6fJ0hIJ8v2uW1CkG4rPj7grxJvXQk5JrCFzNwCS6jK', 'ADMIN')
ON CONFLICT (username) DO NOTHING;

-- Sample products
INSERT INTO products (id, name, description, category, price, stock, image_url, barcode) VALUES
(1, 'Cotton Kurthi Blue',    'Soft cotton kurthi for daily wear',        'Kurthi',        899.00, 0,  NULL, 'BT1001'),
(2, 'Men Casual Shirt',      'Comfort fit check shirt',                  'Shirt',        1199.00, 0,  NULL, 'BT1002'),
(3, 'Girls Party Gown',      'Elegant party gown for special events',    'Gown',         1499.00, 12, NULL, 'BT1003'),
(4, 'KanjiPattu Silk Saree', 'Premium silk saree with zari border',      'KanjiPattu Saree', 2999.00, 8, NULL, 'BT1004'),
(5, 'Boys Cargo Pant',       'Durable cargo pant for active boys',       'Pant',          799.00, 0,  NULL, 'BT1005'),
(6, 'Kids Ethnic Set',       'Festive ethnic wear set for kids',         'Kids',         1299.00, 15, NULL, 'BT1006')
ON CONFLICT (barcode) DO NOTHING;

SELECT setval('products_id_seq', (SELECT MAX(id) FROM products));

-- Sample colour variants for Men Casual Shirt (product id=2)
INSERT INTO product_variants (id, product_id, color_name, color_hex, image_url) VALUES
(1, 2, 'White',    '#FFFFFF', NULL),
(2, 2, 'Navy Blue','#1B3A6B', NULL),
(3, 2, 'Olive',    '#6B7C45', NULL)
ON CONFLICT DO NOTHING;

-- Sizes for each shirt colour (M/L/XL/XXL)
INSERT INTO product_variant_sizes (variant_id, size, stock) VALUES
(1,'M',8),(1,'L',12),(1,'XL',6),(1,'XXL',3),
(2,'M',5),(2,'L',10),(2,'XL',8),(2,'XXL',4),
(3,'M',7),(3,'L',9), (3,'XL',5),(3,'XXL',2)
ON CONFLICT (variant_id, size) DO NOTHING;

-- Sample colour variants for Boys Cargo Pant (product id=5)
INSERT INTO product_variants (id, product_id, color_name, color_hex, image_url) VALUES
(4, 5, 'Khaki',  '#C8A96E', NULL),
(5, 5, 'Black',  '#1A1A1A', NULL)
ON CONFLICT DO NOTHING;

INSERT INTO product_variant_sizes (variant_id, size, stock) VALUES
(4,'M',10),(4,'L',8),(4,'XL',5),(4,'XXL',3),
(5,'M',6), (5,'L',7),(5,'XL',4),(5,'XXL',2)
ON CONFLICT (variant_id, size) DO NOTHING;

SELECT setval('product_variants_id_seq', (SELECT MAX(id) FROM product_variants));
