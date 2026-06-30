
with staging_data as (
    select * from {{ ref('stg_individual') }}
)

select
    ID_individu,
    fullName,
    dob,
    
    -- Utilisation par défaut (simple)
    {{ get_age_bucket('dob') }} as classe_age_simple,
    
    -- Utilisation du format OMS
    {{ get_age_bucket('dob', mode='oms') }} as classe_age_oms,
    
    -- Utilisation du format ONU (génère automatiquement les tranches dynamiques de 5 ans)
    {{ get_age_bucket('dob', mode='onu') }} as classe_age_onu

from staging_data