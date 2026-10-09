
--first calculate total spending for each customer
WITH customer_spending  AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' ||  c.last_name AS customer_name,
        sum(o.total_amount)  AS total_spent
    FROM customers as c
    LEFT JOIN orders as o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name,c.last_name
)
--second divide them in the quartiles that you need 
,
segmentation AS (
    SELECT 
        customer_id,
        customer_name,
        total_spent,
        ntile(4) over(order by total_spent desc) as quartile 
    FROM customer_spending  
)
--third determine every customer to the quartiles
select 
    customer_id,
    customer_name,
    total_spent,
    quartile,
    case 
        when quartile = 1 then 'Platinum'
        when quartile = 2 then 'Gold'
        when quartile = 3 then 'Silver'
        else 'Bronze'
    end as segment
from segmentation
order by total_spent desc

-- =====================================================
-- KEY INSIGHTS — CUSTOMER SEGMENTATION
-- =====================================================
-- 1. The customer base is heavily concentrated at the top:
--    - Ryan King (Platinum) alone spent $8,999.99 — nearly 
--      3x the second-highest customer.
--    - The top 25% of customers (Platinum) account for 
--      ~52% of total revenue.
--
-- 2. Extreme spending gap between segments:
--    - Top customer: $8,999.99
--    - Bottom customer: $89.99
--    - Ratio: 100x
--
-- 3. Marketing implication:
--    - Platinum tier (5 customers) deserves white-glove 
--      retention treatment — losing one is costly.
--    - Bronze tier (5 customers) has potential for 
--      re-engagement campaigns.
-- =====================================================
;

