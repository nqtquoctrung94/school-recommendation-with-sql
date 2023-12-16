---------------------------------------------------------------
---------------------------- crime ----------------------------
WITH crime_total AS (
    SELECT city
        , SUM( ViolentCrime
            + Murder
            + Rape
            + Robbery
            + AggravatedAssault
            + PropertyCrime
            + Burglary
            + Theft
            + MotorVehicleTheft ) AS total_crime
    FROM crime
    GROUP BY city
    HAVING SUM(ViolentCrime + Murder + Rape + Robbery + AggravatedAssault + PropertyCrime + Burglary + Theft + MotorVehicleTheft) IS NOT NULL
        AND city IS NOT NULL
)

, crime_percentile AS (
    SELECT *
    , PERCENTILE_CONT(0.50) WITHIN GROUP(ORDER BY total_crime ASC) OVER() AS percentile_50
    FROM crime_total
)

, crime_cleaned AS (
    SELECT 
        city
        , total_crime
    FROM crime_percentile
    WHERE total_crime <= percentile_50
)

---------------------------------------------------------------
-------------------- metro startup Ranking --------------------
, cleaned_metro AS (
    SELECT metro_area_name AS metro
        , metro_area_main_city_splitted AS city
        , metro_area_states AS state
        , startup_rank
    FROM metro_startup_ranking_cleaned
    WHERE (startup_rank * 100 / (SELECT COUNT(*) FROM metro_startup_ranking)) <= 25  -- Get top 25% in ranking
)

---------------------------------------------------------------
------------------------- university -------------------------
, uni_computer_total AS (
    SELECT unitid AS university_id 
        , instnm AS university_name
        , city AS city
        , stabbr AS state
        , ( cip11cert1
            + cip11cert2
            + cip11cert4
            + cip11assoc
            + cip11bachl) AS total_certicates
        , pcip11 AS percent_award
    FROM university_info_cleaned
    WHERE locale IN (11, 12, 13, 21, 22, 23)
        AND (cip11cert1 + cip11cert2 + cip11cert4 + cip11assoc + cip11bachl) > 0
)
, uni_cleaned AS (
    SELECT *
        , DENSE_RANK() OVER (ORDER BY percent_award DESC) AS award_rank
        , DENSE_RANK() OVER (ORDER BY total_certicates DESC) AS certificate_rank
    FROM uni_computer_total
)

---------------------------------------------------------------
---------------------------- query ----------------------------
, joined_table AS (
    SELECT 
        -- Information
        metro.metro
        , metro.city
        , metro.state 
        , uni.university_name
        , uni.total_certicates
        , uni.percent_award
        , crime.total_crime 

        -- Ranking
        , DENSE_RANK() OVER (ORDER BY metro.startup_rank ASC) AS startup_rank
        , DENSE_RANK() OVER (ORDER BY crime.total_crime ASC) AS crime_rank
        , DENSE_RANK() OVER (ORDER BY uni.total_certicates DESC) AS certificate_rank
        , DENSE_RANK() OVER (ORDER BY uni.percent_award DESC) AS award_rank

    FROM cleaned_metro metro
    INNER JOIN crime_cleaned crime ON metro.city = crime.city
    INNER JOIN uni_cleaned uni ON metro.city = uni.city
)

---------------------------------------------------------------
---------------------------- result ----------------------------
SELECT
    metro
    , city
    , state
    , university_name
    , total_certicates
    , percent_award
    , total_crime
    , (startup_rank + crime_rank + certificate_rank + award_rank) AS rank
FROM joined_table
ORDER BY (startup_rank + crime_rank + certificate_rank + award_rank) ASC