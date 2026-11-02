SELECT 
    p.product_id,
    stock.store_id,

    SAFE_CAST(EXTRACT(YEAR FROM CURRENT_DATE()) AS INT64)
        - SAFE_CAST(p.model_year AS INT64) AS product_age,

    SUM(
        SAFE_CAST(stock.quantity AS INT64)
    ) AS stock_qty,

    ROUND(
        SUM(
            SAFE_CAST(stock.quantity AS INT64)
            * SAFE_CAST(p.list_price AS FLOAT64)
        ),
        2
    ) AS stock_value

FROM {{ ref('raw_products') }} AS p

LEFT JOIN {{ ref('raw_stocks') }} AS stock
    ON p.product_id = stock.product_id

WHERE SAFE_CAST(stock.quantity AS INT64) > 0

GROUP BY
    p.product_id,
    stock.store_id,
    product_age

ORDER BY
    stock_value DESC