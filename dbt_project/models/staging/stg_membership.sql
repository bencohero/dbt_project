WITH source_data AS (
    SELECT * FROM {{source('dss', 'membership')}}
),

cleaned_data AS (
    SELECT 
        uuid AS membership_uuid,
        bistoa,
        CASE 
            WHEN LOWER(starttype) = 'bir' THEN 'birth'
            WHEN LOWER(starttype) = 'img' THEN 'inmigration'
            ELSE 'enu'
        END AS starttype,
        startDate::date AS startdate,
        
        -- On garde la date de fin brute typée en date (sera NULL si absent)
        CASE WHEN endDate IS NOT NULL AND endDate != '' THEN endDate::date ELSE NULL END AS enddate,

        CASE 
            WHEN endDate IS NULL OR endDate = '' THEN 'actif'
            ELSE 'quitté'
        END AS statut_membre,

        -- On utilise une variable locale compilée ou on applique le COALESCE de manière sécurisée
        (COALESCE(CASE WHEN endDate IS NOT NULL AND endDate != '' THEN endDate::date ELSE NULL END, CURRENT_DATE) - startDate::date) AS duree_jours,

        -- Les calculs suivants se basent sur la même logique sécurisée
        ROUND((COALESCE(CASE WHEN endDate IS NOT NULL AND endDate != '' THEN endDate::date ELSE NULL END, CURRENT_DATE) - startDate::date) / 30.0, 2) AS duree_mois,
        ROUND((COALESCE(CASE WHEN endDate IS NOT NULL AND endDate != '' THEN endDate::date ELSE NULL END, CURRENT_DATE) - startDate::date) / 365.25, 2) AS duree_annees,

        -- Durée formatée
        FLOOR(DATE_PART('year', age(COALESCE(CASE WHEN endDate IS NOT NULL AND endDate != '' THEN endDate::date ELSE NULL END, CURRENT_DATE), startDate::date))) || ' ans ' ||
        FLOOR(DATE_PART('month', age(COALESCE(CASE WHEN endDate IS NOT NULL AND endDate != '' THEN endDate::date ELSE NULL END, CURRENT_DATE), startDate::date))) || ' mois' 
        AS duree_formatee,

        -- Classe de durée
        CASE 
            WHEN (COALESCE(CASE WHEN endDate IS NOT NULL AND endDate != '' THEN endDate::date ELSE NULL END, CURRENT_DATE) - startDate::date) < 182 THEN 'Moins de 6 mois'
            WHEN (COALESCE(CASE WHEN endDate IS NOT NULL AND endDate != '' THEN endDate::date ELSE NULL END, CURRENT_DATE) - startDate::date) < 365 THEN '6-12 mois'
            WHEN (COALESCE(CASE WHEN endDate IS NOT NULL AND endDate != '' THEN endDate::date ELSE NULL END, CURRENT_DATE) - startDate::date) < 1095 THEN '1-3 ans'
            WHEN (COALESCE(CASE WHEN endDate IS NOT NULL AND endDate != '' THEN endDate::date ELSE NULL END, CURRENT_DATE) - startDate::date) < 1825 THEN '3-5 ans'
            WHEN (COALESCE(CASE WHEN endDate IS NOT NULL AND endDate != '' THEN endDate::date ELSE NULL END, CURRENT_DATE) - startDate::date) >= 1825 THEN '5 ans et plus'
            ELSE 'Inconnue'
        END AS classe_duree,
        individual_uuid,
        socialgroup_uuid,
        insertdate::date AS insertdate

    FROM source_data
)
SELECT * FROM cleaned_data