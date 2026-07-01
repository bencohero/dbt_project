

WITH source_data AS (
    SELECT * FROM {{source('dss', 'socialgroup')}}
),

cleaned_data AS (
    SELECT 
        uuid AS socialgroup_uuid,
        extId AS ID_groupe_social,
        groupname AS nom_groupe_social,
        grouptype AS type_groupe_social,
        grouphead_uuid AS chef_groupe_social_uuid,
        insertdate::date AS insertdate,
        now() AS dwh_insertdate
    FROM source_data
)
SELECT * FROM cleaned_data