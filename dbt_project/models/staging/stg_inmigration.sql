
WITH source_data AS (
    SELECT * FROM {{source('dss', 'inmigration')}}
),
cleaned_data AS (
    SELECT
        uuid AS inmigration_uuid,
        CASE
            WHEN LOWER(origin) = 'null' THEN 'n/a'
            ELSE origin
        END AS origin,
        migtype AS migration_type,
        CASE
            WHEN LOWER(reason) IN ('1', '01', 'work') THEN 'travail'
            WHEN reason IN ('2', '02') THEN 'agriculture'
            WHEN reason IN ('3', '03') THEN 'mariage'
            WHEN reason IN ('4', '04') THEN 'demenagement'
            WHEN reason IN ('5', '05') THEN 'arriver avec parents'
            WHEN LOWER(reason) IN ('6', '06', 'other') THEN 'autre'
            WHEN reason IN ('7', '07') THEN 'retour en famille'
            WHEN reason IN ('8', '08') THEN 'en attente de mariage'
            WHEN reason IN ('9', '09') THEN 'sante'
            WHEN reason IN ('10', '10') THEN 'etude'
            WHEN POSITION('_' in reason) > 0 THEN LOWER(REPLACE(reason, '_', ''))
            ELSE LOWER(reason)
        END AS reason,
        insertdate,
        recordeddate,
        individual_uuid,
        residency_uuid,
        CURRENT_TIMESTAMP AS inserted_at
    FROM source_data
)
SELECT * FROM cleaned_data