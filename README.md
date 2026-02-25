# 🛒 E-Commerce Sales & Customer Behavior — EDA & Business Intelligence

> **A complete, portfolio-level data analysis project** built to demonstrate senior analyst skills:
> data cleaning → EDA → SQL → RFM segmentation → BI dashboard design → business storytelling.

![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=flat&logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?style=flat&logo=postgresql&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-2.0-150458?style=flat&logo=pandas&logoColor=white)
![Matplotlib](https://img.shields.io/badge/Matplotlib-3.8-11557c?style=flat)
![Seaborn](https://img.shields.io/badge/Seaborn-0.13-4c72b0?style=flat)
![Status](https://img.shields.io/badge/Status-Complete-0E8A7B?style=flat)
![License](https://img.shields.io/badge/License-MIT-F5A623?style=flat)

---

## 📌 Table of Contents

- [Project Overview](#-project-overview)
- [Dataset Description](#-dataset-description)
- [Project Structure](#-project-structure)
- [Tech Stack](#-tech-stack)
- [How to Run](#-how-to-run)
- [Analysis Workflow](#-analysis-workflow)
- [Key Business Insights](#-key-business-insights)
- [SQL Queries Summary](#-sql-queries-summary)
- [Dashboard KPIs](#-dashboard-kpis)
- [Visualisations](#-visualisations)
- [LinkedIn Video Script](#-linkedin-video-script)
- [Skills Demonstrated](#-skills-demonstrated)
- [License](#-license)

---

## 🎯 Project Overview

This project simulates the full workflow of a **Senior Data Analyst at a product-based e-commerce company**. Starting from raw, messy order data and ending with executive-ready business recommendations, it covers every step a working analyst performs:

| Phase | What Was Done |
|-------|--------------|
| **Data Engineering** | Schema design, null imputation, outlier detection, feature engineering |
| **Univariate EDA** | Summary stats, distribution analysis, skewness/kurtosis interpretation |
| **Multivariate EDA** | Correlation matrix, scatter plots, segment × category heatmaps |
| **Time-Series Analysis** | Monthly revenue trend, 3-month moving average, seasonality decomposition |
| **Customer Segmentation** | RFM scoring with NTILE-based quartile ranking |
| **SQL Analytics** | 7 business queries covering revenue, churn, cohorts, and KPI reporting |
| **BI Dashboard Design** | 12 KPIs defined with targets, formulas, and business rationale |
| **Storytelling** | 7 insight cards with Finding → Action format, LinkedIn video script |

**Dataset:** 12,000 synthetic e-commerce orders | 2022–2024 | 6 categories | 5 regions  
**Analyst Role Simulated:** Senior Data Analyst — Product & Growth Analytics

---

## 📦 Dataset Description

The dataset is **synthetically generated** with realistic business logic — lognormal revenue distributions, seasonal Q4 multipliers, segment-based pricing, and intentionally injected nulls.

### Schema

```
orders
├── order_id          VARCHAR   Primary key (ORD000001 format)
├── order_date        TIMESTAMP Order timestamp (2022–2024)
├── customer_id       INTEGER   Foreign key → customers (repeat buyers possible)
├── category          VARCHAR   Electronics / Apparel / Home & Kitchen / Beauty / Sports / Books
├── channel           VARCHAR   Organic Search / Paid Search / Email / Social / Direct / Referral
├── customer_segment  VARCHAR   Premium / Regular / Occasional / At-Risk / New
├── region            VARCHAR   North / South / East / West / Central
├── payment_method    VARCHAR   Credit Card / Debit Card / UPI / Net Banking / Wallet
├── units_sold        INTEGER   1–5 units per order
├── revenue           FLOAT     Gross revenue (₹) — lognormal, category-adjusted
├── discount_pct      FLOAT     Discount applied (0–35.5%) — 3% nulls injected
├── marketing_spend   FLOAT     Attribution proxy (5–25% of revenue)
└── returned          INTEGER   Binary flag: 1 = returned, 0 = kept (8% return rate)

customers
├── customer_id       INTEGER   Primary key
├── signup_date       DATE      Registration date
├── customer_segment  VARCHAR   RFM-aligned segment label
├── region            VARCHAR   Geographic region
└── age_group         VARCHAR   18–25 / 26–35 / 36–50 / 51+

products
├── product_id        INTEGER   Primary key
├── product_name      VARCHAR   SKU-level name
├── category          VARCHAR   Matches orders.category
└── unit_cost         FLOAT     COGS for margin calculation

marketing_campaigns
├── campaign_id       INTEGER   Primary key
├── channel           VARCHAR   Maps to orders.channel
├── campaign_name     VARCHAR   Descriptive label
├── start_date        DATE
├── end_date          DATE
└── total_budget      FLOAT     Total spend allocated
```

### Data Quality Summary

| Column | Missing | Treatment |
|--------|---------|-----------|
| `revenue` | 1.5% (180 rows) | Imputed with **category-wise median** |
| `discount_pct` | 3.0% (360 rows) | Imputed with **global median (10.7%)** |
| All other columns | 0% | No treatment needed |

**Outlier detection:** IQR method identified 906 revenue outliers (7.5%). Capped at 99th percentile for visualisation; retained at full value for revenue totals.

---

## 📁 Project Structure

```
ecomm-eda-bi/
│
├── README.md                     ← You are here
│
├── src/
│   └── eda_analysis.py           ← Complete Python EDA (7 sections, 5 figures)
│
├── sql/
│   └── business_queries.sql      ← 7 annotated business SQL queries
│
├── reports/
│   └── EDA_BI_Report.docx        ← Full 16-page professional analyst report
│
├── figures/
│   ├── fig1_univariate.png       ← Revenue dist, category bars, channel pie, return rates
│   ├── fig2_correlation.png      ← Pearson heatmap + marketing spend scatter
│   ├── fig3_segment_channel.png  ← Segment × Category heatmap + Channel ROI
│   ├── fig4_timeseries.png       ← Monthly trend, quarterly stack, day-of-week AOV
│   └── fig5_rfm.png              ← RFM segment bars, F×M scatter, CLV by segment
│
├── data/
│   └── generate_data.py          ← Reproducible synthetic dataset generator (seed=42)
│
├── requirements.txt
└── LICENSE
```

---

## 🛠 Tech Stack

| Tool | Version | Purpose |
|------|---------|---------|
| Python | 3.11 | Core analysis language |
| pandas | 2.0+ | Data manipulation and cleaning |
| numpy | 1.25+ | Numerical operations, synthetic data |
| matplotlib | 3.8+ | Custom multi-panel visualisations |
| seaborn | 0.13+ | Statistical plots, heatmaps |
| PostgreSQL | 15 | All business SQL queries |
| Jupyter Notebook | 7.0+ | Interactive exploration environment |
| VS Code | Latest | Primary IDE |
| Power BI / Metabase | — | Dashboard mock-up (optional) |

---

## 🚀 How to Run

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/ecomm-eda-bi.git
cd ecomm-eda-bi
```

### 2. Install Python Dependencies

```bash
pip install -r requirements.txt
```

**requirements.txt:**
```
pandas>=2.0.0
numpy>=1.25.0
matplotlib>=3.8.0
seaborn>=0.13.0
jupyter>=7.0.0
scipy>=1.11.0
```

### 3. Run the EDA Script

```bash
python src/eda_analysis.py
```

This generates all 5 figures in the `figures/` directory and prints the full business insight summary to stdout.

### 4. Run SQL Queries

```bash
# Import schema (PostgreSQL)
psql -U your_user -d ecommerce_db -f data/schema.sql

# Run business queries
psql -U your_user -d ecommerce_db -f sql/business_queries.sql
```

> **Note:** Queries are written for PostgreSQL 15. For MySQL, replace `DATE_TRUNC` with `DATE_FORMAT` and `INTERVAL '6 months'` with `INTERVAL 6 MONTH`. For BigQuery, replace `CURRENT_DATE` operators accordingly.

### 5. Run in Jupyter (Optional)

```bash
jupyter notebook
# Open notebooks/EDA_Walkthrough.ipynb
```

---

## 🔍 Analysis Workflow

```
Raw Data (12,000 orders)
        │
        ▼
┌─────────────────────┐
│  1. Data Cleaning   │  → Null imputation, outlier capping, dtype fixes
│     & Quality QA    │  → 6 derived features engineered
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│  2. Univariate EDA  │  → Summary stats (mean/median/skew/kurtosis)
│                     │  → Distribution plots for all 7 numerical fields
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│  3. Multivariate    │  → Pearson correlation matrix (7×7)
│     Analysis        │  → Scatter: marketing spend vs order value
│                     │  → Heatmap: segment × category AOV
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│  4. Time-Series     │  → Monthly revenue trend + 3M moving average
│     Analysis        │  → Quarterly stacked bars by category
│                     │  → Seasonality multipliers by quarter
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│  5. RFM Customer    │  → Recency / Frequency / Monetary scoring
│     Segmentation    │  → NTILE-based quartile ranking
│                     │  → 5 segments: Champions → Lost
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│  6. Business        │  → 7 insight cards (Finding + Action + Owner)
│     Insights        │  → Dollar-value impact quantified for each
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│  7. BI Dashboard    │  → 12 KPIs defined with targets + formulas
│     Design          │  → Grouped: Revenue / Customer / Marketing / Ops
└─────────────────────┘
```

---

## 💡 Key Business Insights

### Insight 1 — Electronics Revenue Concentration
> Electronics is **28% of orders** but **~42% of net revenue**. AOV is ₹14,200 vs ₹1,800 for Apparel.

**→ Action:** Prioritise Electronics in Paid Search. Launch a trade-in/upgrade programme to increase repeat purchase rate.

---

### Insight 2 — Q4 Seasonality: Prepare 6 Weeks Early
> Q4 accounts for **30% of annual revenue** with a consistent **1.35–1.5x revenue multiplier** in Oct–Dec.

**→ Action:** Front-load inventory by mid-September. Increase paid ad spend by 40% from October 15. Lock logistics SLAs in August.

---

### Insight 3 — Email Channel is Severely Underinvested ⚡
> Email delivers **6.2x ROI** — the highest of any channel — yet represents only **18% of channel mix**. Shifting 10% of Organic Search budget to Email yields an estimated **₹2.1M incremental revenue**.

**→ Action:** Build post-purchase email sequences (Day 3, 7, 21, 45). A/B test re-engagement campaigns for At-Risk customers.

---

### Insight 4 — Premium Segment Churn Risk 🔴
> Premium customers are **15% of the base** but drive **32% of revenue**. Average recency increased **18% YoY** — they're buying less frequently. 3.2% migrated to "At Risk" last quarter.

**→ Action:** Launch a VIP tier with free expedited shipping and early access. Measure success: Premium segment recency back below 25-day average.

---

### Insight 5 — Weekend AOV Uplift
> Saturday/Sunday orders in Electronics and Sports show **5–8% higher AOV** than weekday orders.

**→ Action:** Schedule flash sales for Friday 6–8 PM. Set weekend bid multipliers in paid campaigns.

---

### Insight 6 — High Discount ≠ High Return Rate
> Orders with >25% discount have a **7.5% return rate** vs **7.9%** for lower discounts — discount level is NOT driving returns.

**→ Action:** Shift from blanket public promo codes to **personalised loyalty discounts** for logged-in users. Investigate return root causes at the SKU level.

---

### Insight 7 — Regional Performance Gap
> West region: 20.7% of orders → 21.1% of revenue (above-average AOV).
> Central region: 20.2% of orders → 19.4% of revenue (below-average AOV, 9.1% return rate).

**→ Action:** Audit Central region's product mix and logistics SLA. Replicate West's Electronics promotion strategy in Central.

---

## 🗄️ SQL Queries Summary

All 7 queries are fully annotated in [`sql/business_queries.sql`](sql/business_queries.sql).

| # | Business Question | SQL Concepts | Decision Supported |
|---|------------------|--------------|--------------------|
| **Q1** | Top 5 products by net revenue — last 6 months | `JOIN`, `GROUP BY`, `RANK()`, date filter | Merchandising: restock & paid campaign priorities |
| **Q2** | Monthly user acquisition & retention trend | `CTE`, `DATE_TRUNC`, `CASE WHEN`, `COUNT DISTINCT` | Growth: identify new-vs-returning ratio cliff |
| **Q3** | Marketing channel ROI (ROAS + CAC) | `JOIN`, ratio calc, `CASE` classification | Marketing: budget reallocation decisions |
| **Q4** | RFM customer segmentation | `NTILE()`, CTE chaining, multi-level `CASE WHEN` | CRM: targeted campaign audience lists |
| **Q5** | Category return rate & revenue leakage | Conditional `SUM`, `CASE WHEN`, percentage | Operations: quality review prioritisation |
| **Q6** | 12-month LTV by acquisition cohort | CTE chain, `DATE_TRUNC`, `AGE()`, period bucketing | Finance: LTV/CAC payback period modelling |
| **Q7** | Executive KPI dashboard — MoM comparison | `UNION ALL`, period `CASE`, MoM % change | CEO/VP: Monday morning standup health check |

### Sample Query — Q7 Executive KPI Dashboard

```sql
WITH period_data AS (
    SELECT
        CASE
            WHEN order_date >= DATE_TRUNC('month', CURRENT_DATE) THEN 'Current Month'
            WHEN order_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
             AND order_date  < DATE_TRUNC('month', CURRENT_DATE) THEN 'Prior Month'
        END AS period,
        order_id, customer_id, revenue, discount_pct, marketing_spend, returned
    FROM orders
    WHERE order_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
),
kpi_summary AS (
    SELECT
        period,
        COUNT(order_id)                                                          AS total_orders,
        ROUND(SUM(revenue * (1 - discount_pct / 100)), 2)                        AS net_revenue,
        ROUND(AVG(revenue * (1 - discount_pct / 100)), 2)                        AS avg_order_value,
        ROUND(SUM(returned) * 100.0 / NULLIF(COUNT(order_id), 0), 2)             AS return_rate_pct,
        ROUND(SUM(revenue * (1 - discount_pct/100)) / NULLIF(SUM(marketing_spend), 0), 2) AS roas
    FROM period_data WHERE period IS NOT NULL
    GROUP BY period
)
SELECT 'Net Revenue' AS kpi, c.net_revenue AS current_value, p.net_revenue AS prior_value,
    ROUND((c.net_revenue - p.net_revenue) * 100.0 / NULLIF(p.net_revenue, 0), 2) AS mom_change_pct
FROM kpi_summary c, kpi_summary p
WHERE c.period = 'Current Month' AND p.period = 'Prior Month'
-- + UNION ALL for each KPI...
```

---

## 📊 Dashboard KPIs

12 KPIs proposed for the executive dashboard, grouped by business function.

### Revenue & Sales

| KPI | Formula | Target | Why It Matters |
|-----|---------|--------|---------------|
| **Gross Revenue** | `SUM(revenue)` | ₹5.5M/month | Headline business size — top-line health signal |
| **Net Revenue** | `SUM(revenue × (1−disc%))` for non-returned orders | ₹4.8M/month | True revenue after commercial costs |
| **Average Order Value** | `Net Revenue / Total Orders` | ₹4,800 | Raising AOV 10% = 10% revenue growth with zero new customers |
| **Revenue by Category** | `% share per category` | Electronics ≤50% | Concentration risk management |

### Customer Health

| KPI | Formula | Target | Why It Matters |
|-----|---------|--------|---------------|
| **Monthly Active Customers** | `COUNT(DISTINCT customer_id)` with ≥1 order | 5,200/month | Demand-side health — drops precede revenue decline by 60–90 days |
| **New vs Returning Ratio** | New / Returning customers | 40:60 | Below 30% returning = churn problem, not acquisition problem |
| **Customer Churn Rate** | Inactive >90d / prior 90d active base | <8%/quarter | Lags product-market fit by 1–2 quarters |
| **Avg Customer LTV** | `SUM(net revenue per customer) / unique customers` | ₹9,500 | Must be 3x+ CAC for sustainable unit economics |

### Marketing Efficiency

| KPI | Formula | Target | Why It Matters |
|-----|---------|--------|---------------|
| **ROAS** | `Net Revenue / Total Marketing Spend` | ≥6x | Below 3x = unprofitable acquisition at scale |
| **CAC** | `Total Marketing Spend / New Customers` | ≤₹1,200 | CAC payback should be ≤3 months for healthy e-commerce |

### Operations & Quality

| KPI | Formula | Target | Why It Matters |
|-----|---------|--------|---------------|
| **Return Rate** | `Returned orders / Total orders × 100` | <8% | Each return costs 15–20% of order value in reverse logistics |
| **Revenue Leakage** | `Revenue lost to returns / Gross revenue × 100` | <6% | More granular than return rate for financial planning |

---

## 📈 Visualisations

### Figure 1 — Univariate Distributions
![Univariate](figures/fig1_univariate.png)
> Revenue histogram (right-skewed, median ₹2,937), category revenue bars, discount distribution, channel share pie, units per order, return rate by category.

### Figure 2 — Correlation & Multivariate Analysis
![Correlation](figures/fig2_correlation.png)
> Pearson correlation heatmap across 7 features + marketing spend vs order value scatter with trend line. Key finding: marketing spend ↔ order value r=+0.78.

### Figure 3 — Segment & Channel Deep Dive
![Segment Channel](figures/fig3_segment_channel.png)
> Heatmap of avg order value by customer segment × category. Channel ROI bar chart with budget recommendation classification.

### Figure 4 — Time-Series Analysis
![Timeseries](figures/fig4_timeseries.png)
> Monthly revenue trend with 3-month moving average, order volume bar chart, quarterly stacked revenue by category, day-of-week AOV analysis.

### Figure 5 — RFM Customer Segmentation
![RFM](figures/fig5_rfm.png)
> Customer count by RFM segment, frequency vs monetary scatter (coloured by RFM score), average CLV by segment.

---

## 🎥 LinkedIn Video Script

**Duration:** 5–7 minutes | **Format:** Screen share + voice-over

```
OPENING (0:00–0:35) — Hook
"I analysed 12,000 e-commerce orders across 3 years, 6 categories, and
5 customer segments — and found 7 insights that could change how a
business allocates its marketing budget. Let me walk you through the
most interesting ones."

SEGMENT 1 (0:35–1:30) — Data Cleaning
Show: df.info(), missing value audit, IQR outlier detection.
Key point: "I imputed revenue with category-wise medians, not global
means — because Electronics pricing behaviour is completely different
from Books. Context matters in data cleaning."

SEGMENT 2 (1:30–2:45) — The Most Surprising Finding
Show: Figure 3 (Channel ROI bar chart). Pause on the Email bar.
"Email has the highest ROI at 6.2x, yet it's only 18% of the channel
mix. That's a budget misallocation problem — not a marketing problem.
Shifting 10% of Organic Search budget to Email could yield ₹2.1M
incremental revenue."

SEGMENT 3 (2:45–4:00) — SQL Deep Dive
Show: business_queries.sql — open Q7 (Executive KPI Dashboard).
"This single query runs every Monday morning before the executive
standup. One query, seven KPIs, zero ambiguity. Let me show you why
I used CTEs instead of nested subqueries..."

SEGMENT 4 (4:00–5:15) — Business Case with Dollar Value
Show: RFM segment table (Figure 5).
"847 customers — 14% of the base — generate 61% of CLV. Average CLV
₹28,400. If we lose 10% of them, that's ₹2.4M gone. A 5% reduction
in Premium segment churn = ₹1.2M revenue protected per year."

CLOSING (5:15–6:00) — CTA
"Full code, SQL, and report are on my GitHub. Link in comments.
If you're hiring a data analyst who can write production SQL AND tell
a business story — I'd love to connect."
```

**LinkedIn Post Caption:**
```
I spent 2 weeks building a complete EDA + SQL + BI project on 12,000
e-commerce orders.

The biggest finding? Email marketing has 6.2x ROI but only 18% budget
share — a ₹2M opportunity hiding in plain sight.

Walk-through in the video 👆
Full code + SQL on GitHub (link in comments).

#DataAnalytics #SQL #EDA #BusinessIntelligence #Python
#PortfolioProject #DataScience #CareerChange
```

---

## 🧠 Skills Demonstrated

### Python & Data Engineering
- Synthetic data generation with `numpy` lognormal distributions and realistic business logic
- Null imputation strategy justified by domain context (category-wise vs global median)
- IQR-based outlier detection with business-appropriate treatment (cap vs delete)
- Feature engineering: `order_value`, `profit_margin`, `roi`, `rfm_score`, `is_weekend`
- Multi-panel `matplotlib` figures with custom styling, formatters, and annotations

### SQL (PostgreSQL)
- Window functions: `RANK()`, `NTILE()`, `SUM() OVER()`
- CTE chaining for readable, maintainable query architecture
- Date operations: `DATE_TRUNC`, `AGE()`, `INTERVAL`, period bucketing
- Conditional aggregation: `SUM(CASE WHEN ...)`, `COUNT DISTINCT`
- Multi-table JOINs with `NULLIF` for safe division
- `UNION ALL` for multi-KPI dashboard queries

### Business & Analytics Thinking
- ROAS, CAC, LTV/CAC ratio, contribution margin — all correctly defined and applied
- RFM segmentation with actionable retention strategies per segment
- Cohort analysis for LTV modelling and CAC payback estimation
- Seasonality analysis with quantified revenue multipliers
- Dollar-value business case construction for every recommendation

### Communication & Storytelling
- Executive summary with KPI tiles (leading + lagging indicators)
- Insight cards: Finding → Action → Owner → Success Metric format
- LinkedIn video script with timing, talking points, and skill demonstrations
- README as a professional portfolio document

---

## 📋 Deliverable Checklist

- [x] Python EDA code (`eda_analysis.py`) — 7 sections, fully commented
- [x] SQL queries (`business_queries.sql`) — 7 queries, annotated with business context
- [x] Figure 1: Univariate distributions
- [x] Figure 2: Correlation & multivariate analysis
- [x] Figure 3: Segment × Channel deep dive
- [x] Figure 4: Time-series & trend analysis
- [x] Figure 5: RFM customer segmentation
- [x] Full BI Report (`EDA_BI_Report.docx`) — 16 pages, professional format
- [x] GitHub README (this file)
- [x] LinkedIn video script

---

## 🔮 Recommended Next Steps

1. **Live Dashboard** — Deploy Q7 as a scheduled SQL job feeding Power BI or Metabase for real-time KPI monitoring.
2. **Churn Prediction Model** — Use historical At-Risk → Lost transitions to train a Logistic Regression or XGBoost churn classifier.
3. **Cohort Retention Matrix** — Build a month-over-month retention heatmap from the Q6 cohort output.
4. **A/B Test** — Run the Email budget reallocation recommendation and measure ROAS lift over 8 weeks.
5. **Automation** — Connect to a live PostgreSQL database using `SQLAlchemy` + `pandas.read_sql()` to make the EDA pipeline fully automated and schedulable.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with 🎯 business intent, not just code.**

⭐ Star this repo if it helped you | 🍴 Fork it to build your own version | 💬 Open an issue with questions

*Senior Data Analyst Portfolio Project — 2025*

</div>
