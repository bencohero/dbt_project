WITH source_data AS (
    SELECT * FROM {{ source('dss', 'outmigration') }}
),

cleaned_data AS (
    SELECT
        uuid AS outmigration_uuid,
        
        CASE
            WHEN LOWER(trim(destination)) = 'null' OR destination IS NULL THEN 'n/a'
            ELSE LOWER(trim(destination))
        END AS destination,
        
        CASE
            WHEN LOWER(trim(reason)) IN ('1', '01', 'chercher du travail', 'travail', 'travailler') THEN 'travail'
            WHEN LOWER(trim(reason)) IN ('2', '02', 'agriculture') THEN 'agriculture'
            WHEN LOWER(trim(reason)) IN ('3', '03', 'mariage') THEN 'mariage'
            WHEN LOWER(trim(reason)) IN ('4', '04', 'demenager', 'demenagement') THEN 'demenagement'
            WHEN LOWER(trim(reason)) IN ('5', '05', 'partie avec parent', 'parti avec parent') THEN 'partie avec parents'
            WHEN LOWER(trim(reason)) IN ('6', '06', 'null', 'autre', '18-08-2017') OR reason IS NULL THEN 'autre'
            WHEN LOWER(trim(reason)) IN ('7', '07', 'rejoindre la famille') THEN 'rejoindre la famille'
            WHEN LOWER(trim(reason)) IN ('8', '08', 'divorce') THEN 'divorce'
            WHEN LOWER(trim(reason)) IN ('9', '09', 'sante') THEN 'sante'
            WHEN LOWER(trim(reason)) IN ('10', 'etude') THEN 'etude'
            WHEN LOWER(trim(reason)) IN ('rejoindre epo', 'rejoindre epoux') THEN 'rejoindre epoux'
            ELSE LOWER(trim(reason))
        END AS reason,
        
        CAST(insertdate AS DATE) AS insertdate,
        CAST(recordeddate AS DATE) AS recordeddate,
        individual_uuid,
        residency_uuid,
        NOW() AS dwh_inserted_at
    FROM source_data
)

SELECT * FROM cleaned_data