
-- first calculate the total for every day
WITH day_sales as(
    select
        order_date,
        sum(total_amount) as daily_sales
    from orders 
    group by order_date
)
--second calculate the total revenue day by day
select
    order_date,
    daily_sales,
    sum(daily_sales) over(order by order_date) as running_total
from day_sales 
order by order_date asc

-- =====================================================
-- KEY INSIGHTS — DAILY SALES RUNNING TOTAL
-- =====================================================
-- 1. Total revenue over the period: $26,399.67 across 
--    30 distinct order dates (Jan–Mar 2024).
--
-- 2. The highest single day (Mar 2, $8,999.99) is driven 
--    by ONE order — the Rolex Submariner. This day is an 
--    outlier and does NOT reflect day-to-day sales strength.
--
-- 3. Daily sales fluctuate significantly ($79.99 to 
--    $1,899.99 excluding the outlier day), indicating 
--    inconsistent demand without a clear trend.
--
-- 4. The running total curve jumps sharply on Mar 2 
--    (+$8,999.99 in one day) — but the underlying 
--    momentum stays relatively flat.
-- =====================================================
;