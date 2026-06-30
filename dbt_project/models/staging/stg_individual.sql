
-- {{ config(materialized='view') }} -- Les modèles de staging sont souvent des vues légères

with source_data as (

    select * from {{ source('dss', 'individual') }}

),

cleaned_data as (

    select
        uuid as individual_uuid,
        extId as ID_individu,
        concat(trim(firstName), ' ', trim(middlename), ' ', trim(lastName)) as fullName,
        dob,
        {{ date_to_age('dob') }} as age,
        {{get_age_bucket('dob', 'oms')}} as age_class,
        CASE
            WHEN lower(gender) = 'm' THEN 'male'
            WHEN lower(gender) = 'f' THEN 'female'
            ELSE lower(gender)
        END as gender,
        CASE 
                WHEN religion = '1' OR religion = 'MUSULMAN'   THEN 'musulman'
                WHEN religion = '2' OR religion = 'CATHOLIQUE' THEN 'catholique'
                WHEN religion = '3' OR religion = 'PROTESTANT' THEN 'protestant'
                WHEN religion = '4' OR religion = 'ANIMISTE'   THEN 'animiste'
                WHEN religion = '5'                              THEN 'autre'
                WHEN religion = '6'                              THEN 'sans religion'
                ELSE 'unk'
            END AS religion,
        father_uuid,
        mother_uuid,
        insertdate as inserted_at,
        NOW() as dwh_insertdate
    from source_data

)

select * from cleaned_data

