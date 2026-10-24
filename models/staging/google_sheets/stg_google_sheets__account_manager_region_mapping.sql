select
    account_manager,
    state
from {{ source('google_sheets', 'territory_managers') }}
