WITH order_dates AS (

    SELECT
        DATE_DIFF(
            MAX(order_date),
            MIN(order_date),
            DAY
        ) AS nb_sale_days

    FROM {{ ref('int_enriched_orders') }}
),

enriched_order_items AS (

    SELECT
        CONCAT(
            CAST(store_id AS STRING),
            "_",
            CAST(product_id AS STRING)
        ) AS item_store_id,

        ROUND(SUM(quantity_sold), 2) AS qty_bv,
        ROUND(SUM(gross_business_volume), 2) AS gross_bv,
        ROUND(AVG(avg_perc_discount), 2) AS avg_discount,
        ROUND(SUM(discount_value), 2) AS discount_value,
        ROUND(SUM(net_business_volume), 2) AS net_bv,

        od.nb_sale_days,

        ROUND(
            SAFE_DIVIDE(
                SUM(net_business_volume),
                od.nb_sale_days
            ),
            2
        ) AS daily_net_bv,

        ROUND(
            SAFE_DIVIDE(
                SUM(net_business_volume),
                SUM(gross_business_volume)
            ),
            2
        ) AS organic_sale_ratio

    FROM {{ ref('int_enriched_order_items') }}

    CROSS JOIN order_dates AS od

    GROUP BY
        item_store_id,
        od.nb_sale_days
)

SELECT
    CONCAT(
        CAST(i.store_id AS STRING),
        "_",
        CAST(i.product_id AS STRING)
    ) AS item_store_id,

    l.store_name,
    l.city,
    l.state_name,
    l.store_persona,

    ca.brand_name,
    ca.product_category,
    ca.product_name,

    i.product_age,
    i.stock_qty,
    i.stock_value,

    oi.organic_sale_ratio,

    ROUND(
        SAFE_DIVIDE(
            i.stock_value,
            oi.daily_net_bv
        ),
        2
    ) AS inventory_turn,

    CASE
        WHEN SAFE_DIVIDE(
            i.stock_value,
            oi.daily_net_bv
        ) IS NULL
            THEN "Dead Stock"

        WHEN SAFE_DIVIDE(
            i.stock_value,
            oi.daily_net_bv
        ) < 180
            THEN "[<6 mths]"

        WHEN SAFE_DIVIDE(
            i.stock_value,
            oi.daily_net_bv
        ) BETWEEN 180 AND 365
            THEN "[6mths-->1 yr]"

        WHEN SAFE_DIVIDE(
            i.stock_value,
            oi.daily_net_bv
        ) BETWEEN 365 AND 1095
            THEN "[1 yr-->3yrs]"

        WHEN SAFE_DIVIDE(
            i.stock_value,
            oi.daily_net_bv
        ) > 1095
            THEN "[>3yrs]"

        ELSE ""
    END AS stock_coverage_category

FROM {{ ref('int_enriched_inventory') }} AS i

LEFT JOIN {{ ref('int_catalog') }} AS ca
    ON i.product_id = ca.product_id

LEFT JOIN {{ ref('int_locations') }} AS l
    ON i.store_id = l.store_id

LEFT JOIN enriched_order_items AS oi
    ON CONCAT(
        CAST(i.store_id AS STRING),
        "_",
        CAST(i.product_id AS STRING)
    ) = oi.item_store_id