WITH ontime AS (

    SELECT
        order_id,

        SAFE_CAST(
            ROUND(
                SAFE_DIVIDE(
                    COUNTIF(ontime_flag = 1),
                    COUNT(DISTINCT order_id)
                ),
                2
            ) AS FLOAT64
        ) AS ontime_percentage

    FROM {{ ref('int_enriched_orders') }}

    GROUP BY order_id
)

SELECT
    l.store_name,
    l.city,
    l.state_name,
    l.store_persona,

    ROUND(
        AVG(o.leadtime),
        2
    ) AS avg_leadtime,

    ROUND(
        AVG(ot.ontime_percentage),
        2
    ) AS ontime_percentage

FROM {{ ref('int_enriched_orders') }} AS o

LEFT JOIN {{ ref('int_locations') }} AS l
    ON o.store_id = l.store_id

LEFT JOIN ontime AS ot
    ON o.order_id = ot.order_id

GROUP BY
    l.store_name,
    l.city,
    l.state_name,
    l.store_persona