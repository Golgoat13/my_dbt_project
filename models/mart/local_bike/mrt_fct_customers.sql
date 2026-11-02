SELECT
    cu.customer_firstname_name,
    cu.city,
    l.state_name,

    cu.nb_orders,
    cu.days_last_order,
    cu.customer_fidelity,
    cu.locality_status,

    l.store_persona

FROM {{ ref('int_enriched_customers') }} AS cu

LEFT JOIN {{ ref('int_locations') }} AS l
    ON cu.store_id = l.store_id