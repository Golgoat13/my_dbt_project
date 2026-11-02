SELECT
    store_id,
    store_name,
    city,
    zip_code,
    state AS state_code,

    CASE
        WHEN state = 'TX' THEN 'Texas'
        WHEN state = 'NY' THEN 'New York'
        WHEN state = 'CA' THEN 'California'
        ELSE state
    END AS state_name,

    CASE
        WHEN state = 'CA' THEN 'Outdoor Performance'
        WHEN state = 'NY' THEN 'Family & Commuter'
        WHEN state = 'TX' THEN 'Emerging Cycling Market'
        ELSE 'Other'
    END AS store_persona

FROM {{ ref('raw_stores') }}