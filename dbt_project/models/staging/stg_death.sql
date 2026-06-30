

WITH source_data AS (
    SELECT * FROM {{source('dss', 'death')}}
),

cleaned_data AS (
    SELECT
        uuid AS death_uuid,
        (ageatdeath::INT / 365) AS ageatdeath, -- âge en années entières
        CASE
            WHEN (ageatdeath::INT / 365) < 1 THEN '<1'
            WHEN (ageatdeath::INT / 365) BETWEEN 1 AND 4 THEN '1-4'
            WHEN (ageatdeath::INT / 365) BETWEEN 5 AND 14 THEN '5-14'
            WHEN (ageatdeath::INT / 365) BETWEEN 15 AND 49 THEN '15-49'
            WHEN (ageatdeath::INT / 365) BETWEEN 50 AND 64 THEN '50-64'
            ELSE '65+'
        END AS age_class,
        deathcause,
        CAST(deathdate AS DATE) AS deathdate,
        CASE
            WHEN deathplace = '1' THEN 'formation sanitaire'
            WHEN deathplace = '2' THEN 'en route vers fs'
            WHEN deathplace = '3' THEN 'domicile'
            ELSE 'autre'
        END AS deathplace,
        CAST(insertdate AS DATE) AS insertdate,
        individual_uuid AS individual_id,
        visitdeath_uuid AS visitdeath_id,
        NOW() AS dss_insertdate
    FROM source_data
)

SELECT * FROM cleaned_data