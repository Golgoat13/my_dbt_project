SELECT
    oi.order_id,
    oi.product_id,
    o.store_id,
    o.customer_id,

    SAFE_CAST(o.order_date AS DATE) AS order_date,

    SUM(
        SAFE_CAST(oi.quantity AS INT64)
    ) AS quantity_sold,

    ROUND(
        SUM(
            SAFE_CAST(oi.quantity AS INT64)
            * SAFE_CAST(oi.list_price AS FLOAT64)
        ),
        2
    ) AS gross_business_volume,

    ROUND(
        AVG(
            SAFE_CAST(oi.discount AS FLOAT64)
        ),
        2
    ) AS avg_perc_discount,

    ROUND(
        SUM(
            SAFE_CAST(oi.quantity AS INT64)
            * SAFE_CAST(oi.list_price AS FLOAT64)
            * SAFE_CAST(oi.discount AS FLOAT64)
        ),
        2
    ) AS discount_value,

    ROUND(
        SUM(
            SAFE_CAST(oi.quantity AS INT64)
            * SAFE_CAST(oi.list_price AS FLOAT64)
            * (1 - SAFE_CAST(oi.discount AS FLOAT64))
        ),
        2
    ) AS net_business_volume

FROM {{ ref('raw_order_items') }} AS oi

LEFT JOIN {{ ref('raw_orders') }} AS o
    ON oi.order_id = o.order_id

GROUP BY
    oi.order_id,
    oi.product_id,
    o.store_id,
    o.customer_id,
    order_date
