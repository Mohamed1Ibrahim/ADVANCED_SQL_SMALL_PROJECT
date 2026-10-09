
WITH customer_category_spending as (
    select
    o.customer_id,
    c.first_name || ' '|| c.last_name as customer_name,
    p.category,
    sum(oi.unit_price * oi.quantity) as  spent_in_category
    from order_items as oi
    inner join orders as o on o.order_id = oi.order_id
    inner join products as p on p.product_id = oi.product_id 
    inner join customers as c on c.customer_id = o.customer_id
    group by o.customer_id, p.category, c.first_name,c.last_name
) 
,
category_spending as (
    select
        category,
        customer_name,
        spent_in_category,
        row_number() over(partition by category order by spent_in_category desc) as rn
    from customer_category_spending
)

select 
    category,
    customer_name,
    spent_in_category,
    rn
from category_spending
where rn =1
order by category asc

-- =====================================================
-- KEY INSIGHTS — TOP CUSTOMER PER CATEGORY
-- =====================================================
-- 1. Five categories, five different top customers —
--    no single customer dominates multiple categories.
--
-- 2. Massive variation in category-level top spending:
--    - Accessories  → Ryan King    → $8,999.99
--    - Electronics  → Michael Brown → $2,099.98
--    - Furniture    → James Wilson  → $1,899.99
--    - Home & Kitchen → Emma Johnson → $799.99
--    - Clothing     → Sarah Davis   → $409.94
--
--    The gap between #1 and #5 is 22x — driven entirely 
--    by Ryan's single Rolex purchase.
--
-- 3. Ryan King's $8,999.99 in Accessories is 92% of the 
--    entire Accessories category revenue — he IS the 
--    Accessories category from a customer standpoint.
-- =====================================================
;
