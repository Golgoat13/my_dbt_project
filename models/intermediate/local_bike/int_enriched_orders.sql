WITH order_date AS (

    SELECT 
        order_id,
        DATE(order_date) AS order_date,
        DATE(required_date) AS required_date,
        SAFE_CAST(shipped_date AS DATE) AS shipped_date,

        DATE_DIFF(
            SAFE_CAST(shipped_date AS DATE),
            DATE(order_date),
            DAY
        ) AS leadtime,

        IF(
            DATE_DIFF(
                SAFE_CAST(shipped_date AS DATE),
                DATE(required_date),
                DAY
            ) > 0,
            0,
            1
        ) AS ontime_flag

    FROM {{ ref('raw_orders') }}
)

SELECT 
    o.order_id,
    o.customer_id AS customer_id,

    CONCAT(
        cu.first_name,
        " ",
        cu.last_name
    ) AS customer,

    CONCAT(
        staff.first_name,
        " ",
        staff.last_name
    ) AS selling_staff,

    o.store_id AS store_id,

    od.order_date AS order_date,
    od.required_date AS required_date,
    od.shipped_date AS shipped_date,
    od.leadtime AS leadtime,
    od.ontime_flag AS ontime_flag

FROM {{ ref('raw_orders') }} AS o

-- joins with staging models
LEFT JOIN {{ ref('raw_customers') }} AS cu
    ON o.customer_id = cu.customer_id

LEFT JOIN {{ ref('raw_staffs') }} AS staff
    ON o.staff_id = staff.staff_id

-- join with CTE
LEFT JOIN order_date AS od
    ON o.order_id = od.order_id

WHERE od.shipped_date IS NOT NULL