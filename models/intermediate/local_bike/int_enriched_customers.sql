WITH customer_orders AS (

    SELECT
        o.customer_id,

        COUNT(DISTINCT o.order_id) AS nb_orders,

        CASE 
            WHEN COUNT(DISTINCT o.order_id) > 1 THEN "Regular"
            ELSE "New"
        END AS customer_fidelity,

        DATE_DIFF(
            CURRENT_DATE(),
            MAX(SAFE_CAST(o.order_date AS DATE)),
            DAY
        ) AS days_last_order

    FROM {{ ref('raw_order_items') }} AS oi

    LEFT JOIN {{ ref('raw_orders') }} AS o
        ON oi.order_id = o.order_id

    GROUP BY o.customer_id
),


customer_locality_table AS (

    SELECT
        o.customer_id,

        CASE 
            WHEN s.city = cu.city THEN "1"
            ELSE "0"
        END AS customer_locality,

        CASE 
            WHEN s.state = cu.state THEN "1"
            ELSE "0"
        END AS customer_regionality

    FROM {{ ref('raw_order_items') }} AS oi

    LEFT JOIN {{ ref('raw_orders') }} AS o
        ON oi.order_id = o.order_id

    LEFT JOIN {{ ref('raw_stores') }} AS s
        ON o.store_id = s.store_id

    LEFT JOIN {{ ref('raw_customers') }} AS cu
        ON o.customer_id = cu.customer_id
),


customer_local_status AS (

    SELECT
        customer_id,

        IF(
            MAX(SAFE_CAST(customer_locality AS INT64)) = 1,
            "local",
            IF(
                MAX(SAFE_CAST(customer_regionality AS INT64)) = 1,
                "regional",
                "Mexican"
            )
        ) AS customer_local_status

    FROM customer_locality_table

    GROUP BY customer_id
),


customer_local_store AS (

    SELECT
        o.customer_id,
        s.store_id

    FROM {{ ref('raw_order_items') }} AS oi

    LEFT JOIN {{ ref('raw_orders') }} AS o
        ON oi.order_id = o.order_id

    LEFT JOIN {{ ref('raw_stores') }} AS s
        ON o.store_id = s.store_id

    LEFT JOIN {{ ref('raw_customers') }} AS cu
        ON o.customer_id = cu.customer_id

    GROUP BY
        o.customer_id,
        s.store_id
)


SELECT 
    cu.customer_id AS customer_id,

    CONCAT(
        cu.first_name,
        " ",
        cu.last_name
    ) AS customer_firstname_name,

    cu.city AS city,
    cu.zip_code AS zipcode,
    cu.state AS state,

    cuo.nb_orders AS nb_orders,
    cuo.days_last_order AS days_last_order,
    cuo.customer_fidelity AS customer_fidelity,

    cul.customer_local_status AS locality_status,

    culs.store_id AS store_id

FROM {{ ref('raw_customers') }} AS cu

LEFT JOIN customer_orders AS cuo
    ON cu.customer_id = cuo.customer_id

LEFT JOIN customer_local_status AS cul
    ON cu.customer_id = cul.customer_id

LEFT JOIN customer_local_store AS culs
    ON cu.customer_id = culs.customer_id