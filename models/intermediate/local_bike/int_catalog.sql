SELECT
    p.product_id AS product_id,
    p.product_name AS product_name,
    b.brand_name AS brand_name,
    ca.category_name AS product_category

FROM {{ ref('raw_products') }} AS p

LEFT JOIN {{ ref('raw_categories') }} AS ca
    ON p.category_id = ca.category_id

LEFT JOIN {{ ref('raw_brands') }} AS b
    ON p.brand_id = b.brand_id