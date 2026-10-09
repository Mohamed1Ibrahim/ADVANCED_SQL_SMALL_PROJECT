
-- get the columns that we will use 
WITH order_line_revenue  AS (
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price as line_revenue
from order_items oi 
LEFT JOIN products as p on p.product_id = oi.product_id
)

-- calculate the total salse for each product 
,
product_sales  AS (
    SELECT 
        product_id,
        product_name,
        category,
        sum(line_revenue) as product_revenue
    FROM order_line_revenue
    GROUP BY product_id, product_name, category

)
-- calculate the total sales for each category and the percentage for every product
SELECT
    *,
    sum(product_revenue) over (PARTITION BY category) AS category_total,
    round(product_revenue / sum(product_revenue) over (PARTITION BY category) * 100 , 2) AS pct_of_category
FROM product_sales
ORDER BY category ,product_revenue  DESC
-- =====================================================
-- KEY INSIGHTS
-- =====================================================
-- 1. Accessories is the top-revenue category ($9,459.97) 
--    despite having only 5 products — driven almost 
--    entirely by a single item (Rolex Submariner).
--
-- 2. Rolex Submariner accounts for 95.14% of the 
--    Accessories category revenue. This is a severe 
--    concentration risk — if this product stops selling, 
--    the entire category collapses.
--
-- 3. Furniture and Home & Kitchen show similar 
--    concentration patterns:
--    - Pottery Barn Sofa = 45.45% of Furniture revenue
--    - Dyson V15 Vacuum = 45.28% of Home & Kitchen revenue
--
-- 4. Dell XPS 13 has zero sales in the dataset, making 
--    it a dead SKU in the catalog — worth investigating 
--    (pricing, marketing, or stock issue).
-- =====================================================;
;
