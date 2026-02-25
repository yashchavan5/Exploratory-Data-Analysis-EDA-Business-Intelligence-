-- =============================================================================
--  E-COMMERCE ANALYTICS — 7 BUSINESS SQL QUERIES
--  Portfolio Project | Senior Data Analyst
--  Database: ecommerce_db
--  Tables:   orders, customers, products, marketing_campaigns
-- =============================================================================
--
--  Schema Reference:
--  orders(order_id, customer_id, product_id, campaign_id, order_date,
--         units_sold, revenue, discount_pct, marketing_spend, returned,
--         region, payment_method)
--  customers(customer_id, signup_date, customer_segment, region, age_group)
--  products(product_id, product_name, category, unit_cost)
--  marketing_campaigns(campaign_id, channel, campaign_name, start_date,
--                       end_date, total_budget)
-- =============================================================================


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 1: Top 5 Products by Net Revenue — Last 6 Months
-- ─────────────────────────────────────────────────────────────────────────────
-- Business Question:
--   Which products are driving the most revenue right now?
--   Used by: Product & Merchandising team to decide restocking priorities
--
-- Concepts: Aggregation, Date filter, RANK window function, multi-table JOIN
-- Expected output: product_name, category, total_orders, gross_revenue,
--                  avg_discount, net_revenue, revenue_rank
-- ─────────────────────────────────────────────────────────────────────────────

SELECT
    p.product_name,
    p.category,
    COUNT(o.order_id)                                       AS total_orders,
    ROUND(SUM(o.revenue), 2)                                AS gross_revenue,
    ROUND(AVG(o.discount_pct), 1)                           AS avg_discount_pct,
    ROUND(SUM(o.revenue * (1 - o.discount_pct / 100)), 2)   AS net_revenue,
    RANK() OVER (ORDER BY SUM(o.revenue * (1 - o.discount_pct / 100)) DESC)
                                                            AS revenue_rank
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE
    o.order_date >= CURRENT_DATE - INTERVAL '6 months'
    AND o.returned = 0
GROUP BY p.product_id, p.product_name, p.category
ORDER BY net_revenue DESC
LIMIT 5;

-- INSIGHT: Compares gross vs net revenue to identify products where heavy
-- discounting is eroding value. A product can rank #1 on gross but #3 on net.


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 2: Monthly User Acquisition & Retention Trend
-- ─────────────────────────────────────────────────────────────────────────────
-- Business Question:
--   Are we growing our customer base? What's the split between new and
--   returning customers each month?
--   Used by: Growth & Marketing team for cohort reporting
--
-- Concepts: DATE_TRUNC, subquery, CASE WHEN, aggregation, CTEs
-- ─────────────────────────────────────────────────────────────────────────────

WITH first_orders AS (
    -- Identify each customer's very first order date
    SELECT
        customer_id,
        MIN(DATE_TRUNC('month', order_date)) AS first_order_month
    FROM orders
    GROUP BY customer_id
),
monthly_orders AS (
    SELECT
        DATE_TRUNC('month', o.order_date)   AS order_month,
        o.customer_id,
        fo.first_order_month
    FROM orders o
    JOIN first_orders fo ON o.customer_id = fo.customer_id
)
SELECT
    TO_CHAR(order_month, 'YYYY-MM')                                 AS month,
    COUNT(DISTINCT customer_id)                                      AS total_active_customers,
    COUNT(DISTINCT CASE
        WHEN order_month = first_order_month THEN customer_id
    END)                                                             AS new_customers,
    COUNT(DISTINCT CASE
        WHEN order_month > first_order_month THEN customer_id
    END)                                                             AS returning_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN order_month > first_order_month THEN customer_id END)
        * 100.0 /
        NULLIF(COUNT(DISTINCT customer_id), 0), 1
    )                                                                AS retention_rate_pct
FROM monthly_orders
GROUP BY order_month
ORDER BY order_month;

-- INSIGHT: retention_rate_pct dropping over time signals a growth-dependent
-- business that's not keeping customers. A healthy SaaS/e-comm target is 40%+.


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 3: Marketing Channel ROI — Revenue vs Spend Analysis
-- ─────────────────────────────────────────────────────────────────────────────
-- Business Question:
--   Which acquisition channels are delivering the best return on ad spend
--   (ROAS)? Where should we increase or cut marketing budget?
--   Used by: Digital Marketing & Finance teams for budget allocation
--
-- Concepts: Multi-table JOIN, ratio calculation, CASE classification
-- ─────────────────────────────────────────────────────────────────────────────

SELECT
    mc.channel,
    COUNT(o.order_id)                                               AS total_orders,
    COUNT(DISTINCT o.customer_id)                                   AS unique_customers,
    ROUND(SUM(o.marketing_spend), 2)                                AS total_marketing_spend,
    ROUND(SUM(o.revenue * (1 - o.discount_pct / 100)), 2)           AS total_net_revenue,
    ROUND(AVG(o.revenue * (1 - o.discount_pct / 100)), 2)           AS avg_order_value,
    ROUND(
        SUM(o.revenue * (1 - o.discount_pct / 100))
        / NULLIF(SUM(o.marketing_spend), 0), 2
    )                                                               AS roas,
    ROUND(SUM(o.marketing_spend) / NULLIF(COUNT(DISTINCT o.customer_id), 0), 2)
                                                                    AS cac,
    CASE
        WHEN SUM(o.revenue) / NULLIF(SUM(o.marketing_spend), 0) >= 8 THEN 'HIGH ROI — Scale Up'
        WHEN SUM(o.revenue) / NULLIF(SUM(o.marketing_spend), 0) >= 4 THEN 'MEDIUM ROI — Optimize'
        ELSE                                                             'LOW ROI — Review or Cut'
    END                                                             AS budget_recommendation
FROM orders o
JOIN marketing_campaigns mc ON o.campaign_id = mc.campaign_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY mc.channel
ORDER BY roas DESC;

-- INSIGHT: ROAS (return on ad spend) above 4x is typically profitable for
-- e-commerce. CAC (customer acquisition cost) should be < 12-month LTV/3.


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 4: Customer Segmentation — RFM-Based Value Tiers
-- ─────────────────────────────────────────────────────────────────────────────
-- Business Question:
--   Who are our most valuable customers? Who is at risk of churning?
--   Used by: CRM & Retention team for targeted campaign lists
--
-- Concepts: CTEs, NTILE window function, CASE WHEN, aggregation, JOIN
-- ─────────────────────────────────────────────────────────────────────────────

WITH customer_metrics AS (
    SELECT
        customer_id,
        COUNT(order_id)                                     AS order_frequency,
        SUM(revenue * (1 - discount_pct / 100))             AS lifetime_value,
        MAX(order_date)                                     AS last_order_date,
        CURRENT_DATE - MAX(order_date)::date                AS recency_days
    FROM orders
    WHERE returned = 0
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        order_frequency,
        lifetime_value,
        recency_days,
        NTILE(4) OVER (ORDER BY recency_days ASC)           AS r_score,  -- lower recency = better
        NTILE(4) OVER (ORDER BY order_frequency)            AS f_score,
        NTILE(4) OVER (ORDER BY lifetime_value)             AS m_score
    FROM customer_metrics
),
rfm_final AS (
    SELECT
        r.customer_id,
        c.customer_segment,
        r.recency_days,
        r.order_frequency,
        ROUND(r.lifetime_value, 2)                          AS lifetime_value,
        (r.r_score + r.f_score + r.m_score)                 AS rfm_total,
        CASE
            WHEN (r.r_score + r.f_score + r.m_score) >= 10 THEN 'Champions'
            WHEN (r.r_score + r.f_score + r.m_score) >= 8  THEN 'Loyal Customers'
            WHEN (r.r_score + r.f_score + r.m_score) >= 6  THEN 'Potential Loyalists'
            WHEN (r.r_score + r.f_score + r.m_score) >= 4  THEN 'At Risk'
            ELSE                                                 'Lost / Hibernating'
        END                                                 AS rfm_segment
    FROM rfm_scores r
    JOIN customers c ON r.customer_id = c.customer_id
)
SELECT
    rfm_segment,
    COUNT(customer_id)                                      AS customer_count,
    ROUND(AVG(lifetime_value), 2)                           AS avg_clv,
    ROUND(SUM(lifetime_value), 2)                           AS total_clv,
    ROUND(AVG(recency_days), 0)                             AS avg_recency_days,
    ROUND(AVG(order_frequency), 1)                          AS avg_order_frequency,
    ROUND(COUNT(customer_id) * 100.0 / SUM(COUNT(customer_id)) OVER (), 1)
                                                            AS segment_share_pct
FROM rfm_final
GROUP BY rfm_segment
ORDER BY avg_clv DESC;

-- INSIGHT: Focus retention spend on "At Risk" — they know your brand.
-- Re-engagement cost is 5x less than acquiring a new customer.


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 5: Category-Wise Return Rate & Revenue Impact
-- ─────────────────────────────────────────────────────────────────────────────
-- Business Question:
--   Which product categories have the highest return rates? What is the
--   true revenue impact of returns vs gross sales?
--   Used by: Operations, Supply Chain & Product Quality teams
--
-- Concepts: CASE WHEN aggregation, conditional SUM, percentage calculation
-- ─────────────────────────────────────────────────────────────────────────────

SELECT
    p.category,
    COUNT(o.order_id)                                               AS total_orders,
    SUM(CASE WHEN o.returned = 1 THEN 1 ELSE 0 END)                AS returned_orders,
    ROUND(
        SUM(CASE WHEN o.returned = 1 THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(o.order_id), 0), 2
    )                                                               AS return_rate_pct,
    ROUND(SUM(o.revenue * (1 - o.discount_pct / 100)), 2)           AS gross_net_revenue,
    ROUND(SUM(
        CASE WHEN o.returned = 1
             THEN o.revenue * (1 - o.discount_pct / 100)
             ELSE 0 END
    ), 2)                                                           AS revenue_lost_to_returns,
    ROUND(SUM(
        CASE WHEN o.returned = 0
             THEN o.revenue * (1 - o.discount_pct / 100)
             ELSE 0 END
    ), 2)                                                           AS realized_net_revenue,
    ROUND(
        SUM(CASE WHEN o.returned = 1 THEN o.revenue * (1 - o.discount_pct / 100) ELSE 0 END)
        * 100.0
        / NULLIF(SUM(o.revenue * (1 - o.discount_pct / 100)), 0), 2
    )                                                               AS revenue_leakage_pct
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue_leakage_pct DESC;

-- INSIGHT: A 1% reduction in Electronics return rate recovers more revenue
-- than a 5% reduction in Books returns, due to AOV difference.


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 6: Cohort Revenue Analysis — 12-Month LTV by Acquisition Month
-- ─────────────────────────────────────────────────────────────────────────────
-- Business Question:
--   Customers acquired in which months generate the most long-term value?
--   Do holiday-acquired customers stay engaged?
--   Used by: Finance & Growth teams for LTV modelling and CAC payback
--
-- Concepts: CTE chaining, DATE_TRUNC, self-referential joins, pivot logic
-- ─────────────────────────────────────────────────────────────────────────────

WITH cohorts AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date))    AS cohort_month
    FROM orders
    GROUP BY customer_id
),
cohort_orders AS (
    SELECT
        c.cohort_month,
        DATE_TRUNC('month', o.order_date)       AS order_month,
        o.customer_id,
        o.revenue * (1 - o.discount_pct / 100)  AS net_revenue,
        -- Months since acquisition (0 = first month)
        EXTRACT(YEAR FROM AGE(
            DATE_TRUNC('month', o.order_date),
            c.cohort_month
        )) * 12 +
        EXTRACT(MONTH FROM AGE(
            DATE_TRUNC('month', o.order_date),
            c.cohort_month
        ))                                      AS months_since_acquisition
    FROM orders o
    JOIN cohorts c ON o.customer_id = c.customer_id
)
SELECT
    TO_CHAR(cohort_month, 'YYYY-MM')            AS cohort,
    COUNT(DISTINCT customer_id)                 AS cohort_size,
    ROUND(SUM(net_revenue), 2)                  AS total_12m_revenue,
    ROUND(SUM(net_revenue) / NULLIF(COUNT(DISTINCT customer_id), 0), 2)
                                                AS avg_12m_ltv,
    ROUND(SUM(CASE WHEN months_since_acquisition <= 1 THEN net_revenue ELSE 0 END)
          / NULLIF(COUNT(DISTINCT customer_id), 0), 2)
                                                AS avg_m0_m1_revenue,
    ROUND(SUM(CASE WHEN months_since_acquisition BETWEEN 2 AND 5 THEN net_revenue ELSE 0 END)
          / NULLIF(COUNT(DISTINCT customer_id), 0), 2)
                                                AS avg_m2_m5_revenue,
    ROUND(SUM(CASE WHEN months_since_acquisition >= 6 THEN net_revenue ELSE 0 END)
          / NULLIF(COUNT(DISTINCT customer_id), 0), 2)
                                                AS avg_m6_plus_revenue
FROM cohort_orders
WHERE months_since_acquisition <= 11
GROUP BY cohort_month
ORDER BY cohort_month;

-- INSIGHT: High avg_m0_m1 but low avg_m6_plus suggests one-time buyers.
-- Q4 cohorts (Nov–Dec) typically show high initial spend but sharp drop-off.


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 7: Executive KPI Dashboard View — Current Month vs Prior Month
-- ─────────────────────────────────────────────────────────────────────────────
-- Business Question:
--   What is the business health this month vs last month across all
--   critical KPIs? (Used in Monday morning executive standups)
--   Used by: CEO, VP of Product, Head of Growth
--
-- Concepts: CASE WHEN for period bucketing, window functions, LAG alternative,
--           multiple KPIs in single pass, percentage change calculation
-- ─────────────────────────────────────────────────────────────────────────────

WITH period_data AS (
    SELECT
        CASE
            WHEN order_date >= DATE_TRUNC('month', CURRENT_DATE)
                 THEN 'Current Month'
            WHEN order_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
             AND order_date  < DATE_TRUNC('month', CURRENT_DATE)
                 THEN 'Prior Month'
        END                                             AS period,
        order_id, customer_id, revenue,
        discount_pct, marketing_spend, returned
    FROM orders
    WHERE order_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
),
kpi_summary AS (
    SELECT
        period,
        COUNT(order_id)                                 AS total_orders,
        COUNT(DISTINCT customer_id)                     AS active_customers,
        ROUND(SUM(revenue * (1 - discount_pct / 100)), 2)
                                                        AS net_revenue,
        ROUND(AVG(revenue * (1 - discount_pct / 100)), 2)
                                                        AS avg_order_value,
        ROUND(AVG(discount_pct), 2)                     AS avg_discount_pct,
        ROUND(SUM(returned) * 100.0 / NULLIF(COUNT(order_id), 0), 2)
                                                        AS return_rate_pct,
        ROUND(SUM(revenue * (1 - discount_pct / 100))
              / NULLIF(SUM(marketing_spend), 0), 2)     AS roas,
        ROUND(SUM(marketing_spend)
              / NULLIF(COUNT(DISTINCT customer_id), 0), 2)
                                                        AS cac
    FROM period_data
    WHERE period IS NOT NULL
    GROUP BY period
),
current_m  AS (SELECT * FROM kpi_summary WHERE period = 'Current Month'),
prior_m    AS (SELECT * FROM kpi_summary WHERE period = 'Prior Month')
SELECT
    'Net Revenue'                                       AS kpi,
    c.net_revenue                                       AS current_value,
    p.net_revenue                                       AS prior_value,
    ROUND((c.net_revenue - p.net_revenue) * 100.0
          / NULLIF(p.net_revenue, 0), 2)               AS mom_change_pct
FROM current_m c, prior_m p

UNION ALL SELECT 'Total Orders',    c.total_orders,    p.total_orders,
    ROUND((c.total_orders - p.total_orders) * 100.0 / NULLIF(p.total_orders, 0), 2)
FROM current_m c, prior_m p

UNION ALL SELECT 'Active Customers', c.active_customers, p.active_customers,
    ROUND((c.active_customers - p.active_customers) * 100.0 / NULLIF(p.active_customers, 0), 2)
FROM current_m c, prior_m p

UNION ALL SELECT 'Avg Order Value', c.avg_order_value, p.avg_order_value,
    ROUND((c.avg_order_value - p.avg_order_value) * 100.0 / NULLIF(p.avg_order_value, 0), 2)
FROM current_m c, prior_m p

UNION ALL SELECT 'Return Rate (%)', c.return_rate_pct, p.return_rate_pct,
    ROUND(c.return_rate_pct - p.return_rate_pct, 2)
FROM current_m c, prior_m p

UNION ALL SELECT 'ROAS',            c.roas,            p.roas,
    ROUND((c.roas - p.roas) * 100.0 / NULLIF(p.roas, 0), 2)
FROM current_m c, prior_m p

UNION ALL SELECT 'CAC (₹)',         c.cac,             p.cac,
    ROUND((c.cac - p.cac) * 100.0 / NULLIF(p.cac, 0), 2)
FROM current_m c, prior_m p;

-- INSIGHT: This single query powers the live executive dashboard.
-- A positive mom_change_pct is good for Revenue/Orders/ROAS/Customers.
-- A NEGATIVE mom_change_pct is GOOD for Return Rate and CAC.

-- =============================================================================
-- END OF SQL QUERIES
-- =============================================================================
