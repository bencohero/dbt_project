WITH source_data AS (
    SELECT * FROM {{source('dss', 'residency')}}
),

cleaned_data AS (
    SELECT 
        uuid AS residency_uuid,
        CASE
            WHEN LOWER(starttype) = 'bir' THEN 'birth'
            WHEN LOWER(starttype) = 'img' THEN 'inmigration'
            WHEN LOWER(starttype) = 'enu' THEN 'enu'
            ELSE LOWER(starttype)
        END AS starttype,
        startdate,
        CASE
            WHEN LOWER(endtype) = 'omg' THEN 'outmigration'
            WHEN LOWER(endtype) = 'dth' THEN 'death'
            WHEN LOWER(endtype) = 'na' THEN 'n/a'
            ELSE LOWER(endtype)
        END AS endtype,
        enddate,
        insertdate,
        CASE
            WHEN enddate IS NULL THEN AGE(CURRENT_DATE, startdate)
            ELSE AGE(enddate, startdate)
        END AS duree,
        -- Conversion en nombre de mois
        (EXTRACT(YEAR FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate)) * 12
        + EXTRACT(MONTH FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate)))::int AS duree_months,
        -- Classification des durées en tranches de 6 mois
        CASE
            WHEN (EXTRACT(YEAR FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate)) * 12
                + EXTRACT(MONTH FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate))) < 6
                THEN '0-5 mois'
            WHEN (EXTRACT(YEAR FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate)) * 12
                + EXTRACT(MONTH FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate))) BETWEEN 6 AND 11
                THEN '6-11 mois'
            WHEN (EXTRACT(YEAR FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate)) * 12
                + EXTRACT(MONTH FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate))) BETWEEN 12 AND 17
                THEN '12-17 mois'
            WHEN (EXTRACT(YEAR FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate)) * 12
                + EXTRACT(MONTH FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate))) BETWEEN 18 AND 23
                THEN '18-23 mois'
            WHEN (EXTRACT(YEAR FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate)) * 12
                + EXTRACT(MONTH FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate))) BETWEEN 24 AND 29
                THEN '24-29 mois'
            WHEN (EXTRACT(YEAR FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate)) * 12
                + EXTRACT(MONTH FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate))) BETWEEN 30 AND 35
                THEN '30-35 mois'
            WHEN (EXTRACT(YEAR FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate)) * 12
                + EXTRACT(MONTH FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate))) BETWEEN 36 AND 41
                THEN '36-41 mois'
            WHEN (EXTRACT(YEAR FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate)) * 12
                + EXTRACT(MONTH FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate))) BETWEEN 42 AND 47
                THEN '42-47 mois'
            WHEN (EXTRACT(YEAR FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate)) * 12
                + EXTRACT(MONTH FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate))) BETWEEN 48 AND 53
                THEN '48-53 mois'
            WHEN (EXTRACT(YEAR FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate)) * 12
                + EXTRACT(MONTH FROM AGE(COALESCE(enddate, CURRENT_DATE), startdate))) BETWEEN 54 AND 59
                THEN '54-59 mois'
            ELSE '60 mois et plus'
        END AS classe_duree_mois,
        individual_uuid,
        location_uuid
    FROM source_data
)

SELECT * FROM cleaned_data