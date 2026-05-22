-- ============================================================================
-- ADVANCED BUSINESS INTELLIGENCE & SQL ANALYTICS QUERIES (PostgreSQL Dialect)
-- ============================================================================
-- This file contains 21 production-grade SQL queries to query the star schema.
-- Techniques demonstrated: CTEs, Window Functions, Cohort Analysis,
-- Cumulative Run Rates, Moving Averages, and Pareto (80/20 Rule) Analysis.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- SECTION 1: EXECUTIVE PERFORMANCE & TREND ANALYSIS
-- ----------------------------------------------------------------------------

-- Query 1: Executive KPI Scorecard
-- Objective: Provide high-level dashboard metrics (Sales, Profit, Profit Margin, Orders, AOV).
SELECT 
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value_aov,
    SUM(quantity) AS total_units_sold
FROM fact_sales;


-- Query 2: Year-Over-Year (YoY) Sales and Profit Growth
-- Objective: Calculate annual performance changes to evaluate growth rate.
WITH annual_metrics AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS order_year,
        SUM(sales) AS annual_sales,
        SUM(profit) AS annual_profit
    FROM fact_sales
    GROUP BY EXTRACT(YEAR FROM order_date)
)
SELECT 
    order_year,
    ROUND(annual_sales, 2) AS current_year_sales,
    ROUND(LAG(annual_sales) OVER (ORDER BY order_year), 2) AS prior_year_sales,
    ROUND(((annual_sales - LAG(annual_sales) OVER (ORDER BY order_year)) / LAG(annual_sales) OVER (ORDER BY order_year)) * 100, 2) AS sales_yoy_growth_pct,
    ROUND(annual_profit, 2) AS current_year_profit,
    ROUND(LAG(annual_profit) OVER (ORDER BY order_year), 2) AS prior_year_profit,
    ROUND(((annual_profit - LAG(annual_profit) OVER (ORDER BY order_year)) / LAG(annual_profit) OVER (ORDER BY order_year)) * 100, 2) AS profit_yoy_growth_pct
FROM annual_metrics
ORDER BY order_year;


-- Query 3: Month-Over-Month (MoM) Growth Analysis
-- Objective: Analyze monthly revenue fluctuations using CTEs and LEAD/LAG.
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date)::DATE AS order_month,
        SUM(sales) AS sales_amount
    FROM fact_sales
    GROUP BY DATE_TRUNC('month', order_date)::DATE
)
SELECT 
    order_month,
    ROUND(sales_amount, 2) AS current_month_sales,
    ROUND(LAG(sales_amount) OVER (ORDER BY order_month), 2) AS prior_month_sales,
    ROUND(((sales_amount - LAG(sales_amount) OVER (ORDER BY order_month)) / LAG(sales_amount) OVER (ORDER BY order_month)) * 100, 2) AS mom_growth_pct
FROM monthly_sales
ORDER BY order_month;


-- Query 4: Monthly Seasonality Patterns (All Years Consolidated)
-- Objective: Group sales by calendar month to find seasonal buying patterns.
SELECT 
    EXTRACT(MONTH FROM order_date) AS calendar_month,
    TO_CHAR(order_date, 'FMMonth') AS month_name,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS avg_sales_per_row,
    COUNT(DISTINCT order_id) AS total_orders
FROM fact_sales
GROUP BY EXTRACT(MONTH FROM order_date), TO_CHAR(order_date, 'FMMonth')
ORDER BY calendar_month;


-- Query 5: Running YTD (Year-To-Date) Total Sales
-- Objective: Calculate YTD running cumulative sum partitioned by calendar year.
SELECT 
    order_date,
    EXTRACT(YEAR FROM order_date) AS order_year,
    ROUND(sales, 2) AS transaction_sales,
    ROUND(SUM(sales) OVER (
        PARTITION BY EXTRACT(YEAR FROM order_date) 
        ORDER BY order_date, row_id
    ), 2) AS ytd_running_sales
FROM fact_sales
ORDER BY order_date, row_id;


-- Query 6: 3-Month Rolling/Moving Average Sales
-- Objective: Calculate a 3-month moving average of sales to smooth out volatility.
WITH monthly_agg AS (
    SELECT 
        DATE_TRUNC('month', order_date)::DATE AS order_month,
        SUM(sales) AS monthly_sales
    FROM fact_sales
    GROUP BY DATE_TRUNC('month', order_date)::DATE
)
SELECT 
    order_month,
    ROUND(monthly_sales, 2) AS sales_current_month,
    ROUND(AVG(monthly_sales) OVER (
        ORDER BY order_month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_3_month_avg
FROM monthly_agg
ORDER BY order_month;


-- ----------------------------------------------------------------------------
-- SECTION 2: GEOGRAPHIC & REGIONAL INSIGHTS
-- ----------------------------------------------------------------------------

-- Query 7: Regional Revenue & Margin Contribution
-- Objective: Show sales contribution, total profit, and actual margins for each region.
SELECT 
    geo.region,
    ROUND(SUM(f.sales), 2) AS total_sales,
    ROUND((SUM(f.sales) / SUM(SUM(f.sales)) OVER ()) * 100, 2) AS revenue_contribution_pct,
    ROUND(SUM(f.profit), 2) AS total_profit,
    ROUND((SUM(f.profit) / SUM(f.sales)) * 100, 2) AS regional_profit_margin_pct
FROM fact_sales f
JOIN dim_geography geo ON f.geography_key = geo.geography_key
GROUP BY geo.region
ORDER BY total_sales DESC;


-- Query 8: State Profitability Ranking (Dense Rank)
-- Objective: Rank US States by cumulative net profit, handling ties properly.
SELECT 
    geo.state,
    geo.region,
    ROUND(SUM(f.profit), 2) AS total_profit,
    DENSE_RANK() OVER (ORDER BY SUM(f.profit) DESC) AS profit_rank,
    ROUND(SUM(f.sales), 2) AS total_sales,
    ROUND((SUM(f.profit) / SUM(f.sales)) * 100, 2) AS state_margin_pct
FROM fact_sales f
JOIN dim_geography geo ON f.geography_key = geo.geography_key
GROUP BY geo.state, geo.region
ORDER BY profit_rank;


-- Query 9: Top 3 Cities by Revenue in Each US Region
-- Objective: Identify regional retail hubs using PARTITION BY and ROW_NUMBER.
WITH ranked_cities AS (
    SELECT 
        geo.region,
        geo.city,
        geo.state,
        SUM(f.sales) AS city_sales,
        ROW_NUMBER() OVER (
            PARTITION BY geo.region 
            ORDER BY SUM(f.sales) DESC
        ) AS rank_in_region
    FROM fact_sales f
    JOIN dim_geography geo ON f.geography_key = geo.geography_key
    GROUP BY geo.region, geo.city, geo.state
)
SELECT 
    region,
    city,
    state,
    ROUND(city_sales, 2) AS total_sales,
    rank_in_region
FROM ranked_cities
WHERE rank_in_region <= 3
ORDER BY region, rank_in_region;


-- ----------------------------------------------------------------------------
-- SECTION 3: PRODUCT & CATEGORY PERFORMANCES
-- ----------------------------------------------------------------------------

-- Query 10: Category and Sub-Category Sales & Margin Breakdown
-- Objective: Breakdown hierarchically to discover profit margin dynamics.
SELECT 
    prod.category,
    prod.sub_category,
    ROUND(SUM(f.sales), 2) AS total_sales,
    ROUND(SUM(f.profit), 2) AS total_profit,
    ROUND((SUM(f.profit) / SUM(f.sales)) * 100, 2) AS profit_margin_pct,
    SUM(f.quantity) AS units_sold
FROM fact_sales f
JOIN dim_products prod ON f.product_key = prod.product_key
GROUP BY prod.category, prod.sub_category
ORDER BY prod.category, total_sales DESC;


-- Query 11: Top 5 Loss-Making Product Sub-Categories
-- Objective: Find structural profit drains in inventory.
SELECT 
    prod.sub_category,
    prod.category,
    ROUND(SUM(f.sales), 2) AS total_sales,
    ROUND(SUM(f.profit), 2) AS net_losses,
    ROUND((SUM(f.profit) / SUM(f.sales)) * 100, 2) AS profit_margin_pct
FROM fact_sales f
JOIN dim_products prod ON f.product_key = prod.product_key
GROUP BY prod.sub_category, prod.category
HAVING SUM(f.profit) < 0
ORDER BY net_losses ASC;


-- Query 12: Product Concentration Analysis (Pareto Principle / 80-20 Rule)
-- Objective: Identify what percentage of products generate the top 80% of revenue.
WITH product_sales AS (
    SELECT 
        prod.product_name,
        SUM(f.sales) AS sales_amt
    FROM fact_sales f
    JOIN dim_products prod ON f.product_key = prod.product_key
    GROUP BY prod.product_name
),
cumulative_sales AS (
    SELECT 
        product_name,
        sales_amt,
        SUM(sales_amt) OVER (ORDER BY sales_amt DESC, product_name) AS running_sales,
        SUM(sales_amt) OVER () AS total_sales
    FROM product_sales
)
SELECT 
    product_name,
    ROUND(sales_amt, 2) AS product_revenue,
    ROUND((sales_amt / total_sales) * 100, 4) AS revenue_pct,
    ROUND((running_sales / total_sales) * 100, 2) AS cumulative_revenue_pct,
    CASE 
        WHEN (running_sales / total_sales) <= 0.80 THEN 'Core Revenue Generator (Top 80%)'
        ELSE 'Long Tail Product (Bottom 20%)'
    END AS pareto_classification
FROM cumulative_sales
ORDER BY sales_amt DESC;


-- Query 13: Underperforming High-Volume Products
-- Objective: Find products generating over $5,000 in revenue that are unprofitable.
SELECT 
    prod.product_id,
    prod.product_name,
    prod.category,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    SUM(f.quantity) AS total_units_sold,
    ROUND(SUM(f.profit), 2) AS net_losses,
    ROUND((SUM(f.profit) / SUM(f.sales)) * 100, 2) AS margin_pct
FROM fact_sales f
JOIN dim_products prod ON f.product_key = prod.product_key
GROUP BY prod.product_id, prod.product_name, prod.category
HAVING SUM(f.sales) >= 5000 AND SUM(f.profit) < 0
ORDER BY net_losses ASC;


-- Query 14: Profitability impact of Discount Levels
-- Objective: Correlate discount ranges with profit margins to determine profitability thresholds.
SELECT 
    discount AS discount_rate,
    COUNT(*) AS item_count,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    ROUND(AVG(quantity), 1) AS avg_qty_per_item
FROM fact_sales
GROUP BY discount
ORDER BY discount;


-- ----------------------------------------------------------------------------
-- SECTION 4: CUSTOMER SEGMENTATION & RETENTION
-- ----------------------------------------------------------------------------

-- Query 15: Customer Segment Performance Profile
-- Objective: Segment customer groups and verify buying habits.
SELECT 
    cust.segment,
    COUNT(DISTINCT f.customer_key) AS unique_customers,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND(SUM(f.sales), 2) AS total_sales,
    ROUND(SUM(f.profit), 2) AS total_profit,
    ROUND((SUM(f.profit) / SUM(f.sales)) * 100, 2) AS profit_margin_pct,
    ROUND(SUM(f.sales) / COUNT(DISTINCT f.order_id), 2) AS average_order_value_aov
FROM fact_sales f
JOIN dim_customers cust ON f.customer_key = cust.customer_key
GROUP BY cust.segment
ORDER BY total_sales DESC;


-- Query 16: Top 10 High-Value Customers (LTV Preparation)
-- Objective: Rank customers by revenue, displaying order frequency and net profit.
SELECT 
    cust.customer_id,
    cust.customer_name,
    cust.segment,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND(SUM(f.sales), 2) AS customer_lifetime_value_clv,
    ROUND(SUM(f.profit), 2) AS net_profit_contribution,
    ROUND((SUM(f.profit) / SUM(f.sales)) * 100, 2) AS customer_profit_margin_pct
FROM fact_sales f
JOIN dim_customers cust ON f.customer_key = cust.customer_key
GROUP BY cust.customer_id, cust.customer_name, cust.segment
ORDER BY customer_lifetime_value_clv DESC
LIMIT 10;


-- Query 17: Customer Repeat Purchase Behavior & Rate
-- Objective: Calculate the percentage of customers who made repeat purchases.
WITH customer_orders AS (
    SELECT 
        customer_key,
        COUNT(DISTINCT order_id) AS order_count
    FROM fact_sales
    GROUP BY customer_key
),
buyer_segments AS (
    SELECT 
        customer_key,
        order_count,
        CASE WHEN order_count > 1 THEN 1 ELSE 0 END AS is_repeat_buyer
    FROM customer_orders
)
SELECT 
    COUNT(*) AS total_customers,
    SUM(is_repeat_buyer) AS repeat_customers_count,
    ROUND((SUM(is_repeat_buyer)::NUMERIC / COUNT(*)) * 100, 2) AS repeat_purchase_rate_pct
FROM buyer_segments;


-- Query 18: Customer Cohorts by First Purchase Year
-- Objective: Track revenue performance of cohorts grouped by the year they were acquired.
WITH cohort_acquisition AS (
    SELECT 
        customer_key,
        MIN(EXTRACT(YEAR FROM order_date)) AS cohort_year
    FROM fact_sales
    GROUP BY customer_key
)
SELECT 
    ca.cohort_year,
    COUNT(DISTINCT f.customer_key) AS cohort_size,
    ROUND(SUM(CASE WHEN EXTRACT(YEAR FROM f.order_date) = 2014 THEN f.sales ELSE 0 END), 2) AS sales_2014,
    ROUND(SUM(CASE WHEN EXTRACT(YEAR FROM f.order_date) = 2015 THEN f.sales ELSE 0 END), 2) AS sales_2015,
    ROUND(SUM(CASE WHEN EXTRACT(YEAR FROM f.order_date) = 2016 THEN f.sales ELSE 0 END), 2) AS sales_2016,
    ROUND(SUM(CASE WHEN EXTRACT(YEAR FROM f.order_date) = 2017 THEN f.sales ELSE 0 END), 2) AS sales_2017,
    ROUND(SUM(f.sales), 2) AS cohort_cumulative_sales
FROM fact_sales f
JOIN cohort_acquisition ca ON f.customer_key = ca.customer_key
GROUP BY ca.cohort_year
ORDER BY ca.cohort_year;


-- ----------------------------------------------------------------------------
-- SECTION 5: OPERATIONS & SHIPPING EFFICIENCY
-- ----------------------------------------------------------------------------

-- Query 19: Shipping Duration and Metrics by Shipping Mode
-- Objective: Analyze logistics speed and performance against SLAs.
SELECT 
    ship_mode,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(shipping_duration), 2) AS avg_shipping_days,
    MAX(shipping_duration) AS max_shipping_days,
    MIN(shipping_duration) AS min_shipping_days
FROM fact_sales
GROUP BY ship_mode
ORDER BY avg_shipping_days;


-- Query 20: Delayed Shipments Identification
-- Objective: Flag orders failing delivery window targets (First Class > 2 days, Standard > 5 days).
WITH delivery_audit AS (
    SELECT DISTINCT
        order_id,
        ship_mode,
        shipping_duration,
        CASE 
            WHEN ship_mode = 'Same Day' AND shipping_duration > 0 THEN 'Delayed'
            WHEN ship_mode = 'First Class' AND shipping_duration > 2 THEN 'Delayed'
            WHEN ship_mode = 'Second Class' AND shipping_duration > 4 THEN 'Delayed'
            WHEN ship_mode = 'Standard Class' AND shipping_duration > 5 THEN 'Delayed'
            ELSE 'On-Time'
        END AS shipping_status
    FROM fact_sales
)
SELECT 
    ship_mode,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN shipping_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND((SUM(CASE WHEN shipping_status = 'Delayed' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*)) * 100, 2) AS delay_rate_pct
FROM delivery_audit
GROUP BY ship_mode
ORDER BY delay_rate_pct DESC;


-- Query 21: Customer Ordering Frequency Distribution Buckets
-- Objective: Segment customers based on order frequency distribution to guide CRM marketing.
WITH customer_order_frequencies AS (
    SELECT 
        customer_key,
        COUNT(DISTINCT order_id) AS order_count
    FROM fact_sales
    GROUP BY customer_key
),
frequency_buckets AS (
    SELECT 
        customer_key,
        order_count,
        CASE 
            WHEN order_count = 1 THEN 'One-time Purchaser'
            WHEN order_count BETWEEN 2 AND 5 THEN 'Frequent Buyer (2-5 orders)'
            WHEN order_count BETWEEN 6 AND 10 THEN 'Loyal Customer (6-10 orders)'
            ELSE 'VVIP Executive Buyer (>10 orders)'
        END AS customer_bucket
    FROM customer_order_frequencies
)
SELECT 
    customer_bucket,
    COUNT(*) AS customer_count,
    ROUND((COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER ()) * 100, 2) AS customer_pct
FROM frequency_buckets
GROUP BY customer_bucket
ORDER BY customer_count DESC;
