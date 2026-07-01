WITH RECURSIVE location_hierarchy AS (
    -- Point de départ : chaque localisation liée à son niveau direct
    SELECT 
        l.uuid AS location_uuid,
        l.extid AS location_id,
        l.locationname AS location_name,
        l.insertdate,
        lh.uuid AS level_uuid,
        lh.name AS level_name,
        lh.parent_uuid,
        l.accuracy,
        l.altitude,
        l.latitude,
        l.longitude,
        1 AS level_depth
    FROM {{ source('dss', 'location') }} l
    JOIN {{ source('dss', 'locationhierarchy') }} lh 
        ON l.locationlevel_uuid = lh.uuid

    UNION ALL

    -- Remontée récursive vers les niveaux parents
    SELECT
        lh.location_uuid,
        lh.location_id,
        lh.location_name,
        lh.insertdate,
        parent.uuid AS level_uuid,
        parent.name AS level_name,
        parent.parent_uuid,
        lh.accuracy,
        lh.altitude,
        lh.latitude,
        lh.longitude,
        lh.level_depth + 1
    FROM location_hierarchy lh
    JOIN {{ source('dss', 'locationhierarchy') }} parent
        ON parent.uuid = lh.parent_uuid
),

cleaned_data AS (
    -- Agrégation et pivotage de la hiérarchie + nettoyage géospatial
    SELECT 
        location_uuid,
        location_id,
        location_name,
        MAX(CASE WHEN level_depth = 1 THEN level_name END) AS zd,
        MAX(CASE WHEN level_depth = 2 THEN level_name END) AS village,
        MAX(CASE WHEN level_depth = 3 THEN level_name END) AS departement,
        MAX(CASE WHEN level_depth = 4 THEN level_name END) AS district,
        CASE 
            WHEN trim(lower(accuracy)) = 'null' OR accuracy = '' THEN NULL
            ELSE CAST(accuracy AS NUMERIC)
        END AS accuracy,
        CASE 
            WHEN trim(lower(altitude)) = 'null' OR altitude = '' THEN NULL
            ELSE CAST(altitude AS NUMERIC)
        END AS altitude,
        CASE 
            WHEN trim(lower(latitude)) = 'null' OR latitude = '' THEN NULL
            ELSE CAST(latitude AS NUMERIC)
        END AS latitude,
        CASE 
            WHEN trim(lower(longitude)) = 'null' OR longitude = '' THEN NULL
            ELSE CAST(longitude AS NUMERIC)
        END AS longitude,
        CAST(insertdate AS DATE) AS insertdate
    FROM location_hierarchy
    GROUP BY 
        location_uuid,
        location_name,
        location_id,
        accuracy,
        altitude,
        latitude,
        longitude,
        insertdate
)

SELECT * FROM cleaned_data
ORDER BY insertdate DESC