
WITH quartiles as (
select 
    percentile_cont(0.25) within group (order by total_amount) as q1,
    percentile_cont(0.75) within group (order by total_amount) as q3
from orders
)
,
bounds as(
    select 
        q3 - q1 as iqr,
        q1 - 1.5*(q3 - q1) as lower_bound,
        q3 + 1.5* (q3 - q1) as upper_bound
    from quartiles
)
,
is_outlier as (
    select
        o.order_id,
        o.total_amount,
        b.upper_bound,
        b.lower_bound,
        case 
            when total_amount > upper_bound then TRUE
            when total_amount < lower_bound then TRUE 
            else FALSE
        end check_outliers
    from orders as o
    cross join bounds as b 
)

select 
*
from is_outlier
ORDER BY  total_amount desc

-- =====================================================
-- OUTLIER DETECTION — SUMMARY (IMPACT)
-- =====================================================


WITH quartiles as (
select 
    percentile_cont(0.25) within group (order by total_amount) as q1,
    percentile_cont(0.75) within group (order by total_amount) as q3
from orders
),
bounds as(
    select 
        q3 - q1 as iqr,
        q1 - 1.5*(q3 - q1) as lower_bound,
        q3 + 1.5* (q3 - q1) as upper_bound
    from quartiles
)
,
is_outlier as (
    select
        o.order_id,
        o.total_amount,
        b.upper_bound,
        b.lower_bound,
        case 
            when total_amount > upper_bound then TRUE
            when total_amount < lower_bound then TRUE 
            else FALSE
        end check_outliers
    from orders as o
    cross join bounds as b )
select 
    sum(total_amount) as total_revenue,
    sum(case when check_outliers = FALSE THEN total_amount end) as total_revenue_excl_outliers,
    avg(total_amount) as avg_order,
    avg(case when check_outliers = FALSE then total_amount end )as avg_order_excl_outliers
from is_outlier;

-- =====================================================
-- KEY INSIGHTS — OUTLIER DETECTION (IQR METHOD)
-- =====================================================
-- 1. Only 1 order flagged as outlier (order #23 — Rolex 
--    Submariner at $8,999.99), but its impact is enormous.
--
-- 2. Revenue distortion:
--    - With outlier:    $26,399.67
--    - Without outlier: $17,399.68
--    - Impact:          -34.1% (the single order drove 
--                        over a third of total revenue)
--
-- 3. Average order distortion:
--    - With outlier:    $879.99
--    - Without outlier: $599.99
--    - Impact:          -31.8%
--
-- 4. Business implication:
--    - True baseline AOV is ~$600, NOT ~$880.
--    - Rolex purchase was a one-time luxury sale, not a 
--      repeatable business pattern.
--    - Marketing & pricing decisions should be based on 
--      the $600 baseline.
-- =====================================================
