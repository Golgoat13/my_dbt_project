SELECT

    -- Date
    oi.order_date,

    -- Product dimensions
    ca.product_name,
    ca.brand_name,
    ca.product_category,

    -- Store dimensions
    l.store_name,
    l.city,
    l.state_name,
    l.store_persona,

    -- Sales metrics
    SUM(oi.quantity_sold) AS quantity_sold,

    ROUND(
        SUM(oi.gross_business_volume),
        2
    ) AS gross_business_volume,

    ROUND(
        SAFE_DIVIDE(
            SUM(oi.discount_value),
            SUM(oi.gross_business_volume)
        ),
        4
    ) AS avg_perc_discount,

    ROUND(
        SUM(oi.discount_value),
        2
    ) AS discount_value,

    ROUND(
        SUM(oi.net_business_volume),
        2
    ) AS net_business_volume

FROM {{ ref('int_enriched_order_items') }} AS oi

LEFT JOIN {{ ref('int_catalog') }} AS ca
    ON oi.product_id = ca.product_id

LEFT JOIN {{ ref('int_locations') }} AS l
    ON oi.store_id = l.store_id

GROUP BY
    oi.order_date,
    ca.product_name,
    ca.brand_name,
    ca.product_category,
    l.store_name,
    l.city,
    l.state_name,
    l.store_persona