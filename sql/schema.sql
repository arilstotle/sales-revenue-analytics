-- ============================================================================
-- SQL SCHEMA FOR SUPERSTORE SALES & REVENUE ANALYTICS (PostgreSQL Dialect)
-- ============================================================================

-- 1. STAGING TABLE (For initial flat-file CSV ingestion)
DROP TABLE IF EXISTS staging_superstore CASCADE;
CREATE TABLE staging_superstore (
    row_id INT,
    order_id VARCHAR(25),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(20),
    customer_id VARCHAR(15),
    customer_name VARCHAR(100),
    segment VARCHAR(20),
    country VARCHAR(30),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(15),
    region VARCHAR(15),
    product_id VARCHAR(25),
    category VARCHAR(25),
    sub_category VARCHAR(25),
    product_name VARCHAR(200),
    sales NUMERIC(12, 2),
    quantity INT,
    discount NUMERIC(5, 2),
    profit NUMERIC(12, 2)
);

-- 2. DIMENSION TABLES (Normalized tables)

-- Customer Dimension
DROP TABLE IF EXISTS dim_customers CASCADE;
CREATE TABLE dim_customers (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(15) UNIQUE NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    segment VARCHAR(20) NOT NULL
);

-- Product Dimension
DROP TABLE IF EXISTS dim_products CASCADE;
CREATE TABLE dim_products (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(25) UNIQUE NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(25) NOT NULL,
    sub_category VARCHAR(25) NOT NULL
);

-- Geography Dimension
DROP TABLE IF EXISTS dim_geography CASCADE;
CREATE TABLE dim_geography (
    geography_key SERIAL PRIMARY KEY,
    postal_code VARCHAR(15) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    country VARCHAR(30) NOT NULL,
    region VARCHAR(15) NOT NULL,
    CONSTRAINT uniq_geo UNIQUE (postal_code, city, state)
);


-- 3. FACT TABLE (Transactional metrics joined with keys)
DROP TABLE IF EXISTS fact_sales CASCADE;
CREATE TABLE fact_sales (
    fact_sales_key SERIAL PRIMARY KEY,
    row_id INT UNIQUE NOT NULL,
    order_id VARCHAR(25) NOT NULL,
    order_date DATE NOT NULL,
    ship_date DATE NOT NULL,
    ship_mode VARCHAR(20) NOT NULL,
    customer_key INT REFERENCES dim_customers(customer_key),
    geography_key INT REFERENCES dim_geography(geography_key),
    product_key INT REFERENCES dim_products(product_key),
    sales NUMERIC(12, 2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    discount NUMERIC(5, 2) DEFAULT 0.00,
    profit NUMERIC(12, 2) NOT NULL,
    profit_margin NUMERIC(12, 6) GENERATED ALWAYS AS (
        CASE WHEN sales = 0 THEN 0 ELSE (profit / sales) END
    ) STORED,
    shipping_duration INT GENERATED ALWAYS AS (
        (ship_date - order_date)
    ) STORED
);


-- 4. PERFORMANCE OPTIMIZATION INDEXES
CREATE INDEX idx_fact_sales_order_date ON fact_sales(order_date);
CREATE INDEX idx_fact_sales_customer_key ON fact_sales(customer_key);
CREATE INDEX idx_fact_sales_product_key ON fact_sales(product_key);
CREATE INDEX idx_fact_sales_geography_key ON fact_sales(geography_key);
CREATE INDEX idx_dim_products_cat_sub ON dim_products(category, sub_category);
CREATE INDEX idx_dim_geography_region ON dim_geography(region);


-- 5. ETL PIPELINE PROCEDURES

-- Populate Customers
INSERT INTO dim_customers (customer_id, customer_name, segment)
SELECT DISTINCT ON (customer_id) customer_id, customer_name, segment
FROM staging_superstore
ON CONFLICT (customer_id) DO UPDATE 
SET customer_name = EXCLUDED.customer_name, segment = EXCLUDED.segment;

-- Populate Products
INSERT INTO dim_products (product_id, product_name, category, sub_category)
SELECT DISTINCT ON (product_id) product_id, product_name, category, sub_category
FROM staging_superstore
ON CONFLICT (product_id) DO UPDATE 
SET product_name = EXCLUDED.product_name, category = EXCLUDED.category, sub_category = EXCLUDED.sub_category;

-- Populate Geography
INSERT INTO dim_geography (postal_code, city, state, country, region)
SELECT DISTINCT ON (postal_code, city, state) postal_code, city, state, country, region
FROM staging_superstore
ON CONFLICT (postal_code, city, state) DO NOTHING;

-- Populate Fact Table
INSERT INTO fact_sales (
    row_id, order_id, order_date, ship_date, ship_mode,
    customer_key, geography_key, product_key, sales, quantity, discount, profit
)
SELECT 
    stg.row_id,
    stg.order_id,
    stg.order_date,
    stg.ship_date,
    stg.ship_mode,
    c.customer_key,
    g.geography_key,
    p.product_key,
    stg.sales,
    stg.quantity,
    stg.discount,
    stg.profit
FROM staging_superstore stg
JOIN dim_customers c ON stg.customer_id = c.customer_id
JOIN dim_products p ON stg.product_id = p.product_id
JOIN dim_geography g ON stg.postal_code = g.postal_code AND stg.city = g.city AND stg.state = g.state
ON CONFLICT (row_id) DO NOTHING;
