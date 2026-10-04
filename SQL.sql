Create database netflix_project;
use netflix_project;
show databases;
select database();
CREATE TABLE netflix (
    show_id VARCHAR(10),
    type VARCHAR(20),
    title VARCHAR(255),
    director TEXT,
    cast TEXT,
    country TEXT,
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(20),
    duration VARCHAR(30),
    listed_in TEXT,
    description TEXT
);
show tables from netflix_project;
select count(*) from netflix;
SELECT * FROM netflix LIMIT 5;


/*TRUNCATE TABLE netflix;
SELECT COUNT(*) FROM netflix;
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'C:/Users/Siddhi/Documents/Netflix Data Project/netflix_titles.csv'
INTO TABLE netflix
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
SHOW VARIABLES LIKE 'local_infile';
LOAD DATA LOCAL INFILE 'C:/Users/Siddhi/Documents/Netflix Data Project/netflix_titles.csv'
INTO TABLE netflix
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;*/


SELECT COUNT(*) AS total_records
FROM netflix;

select * from netflix limit 10;

select count(*) as total_count from netflix;

describe netflix;

select count(*) as director_missing from netflix where director is null or trim(director) = '';
select count(*) as cast_missing from netflix where cast is null or trim(cast) = '';
select count(*) as country_missing_values from netflix where country is null or trim(country) = '';
select count(*) as date_missing from netflix where date_added is null or trim(date_added) = '';

SET SQL_SAFE_UPDATES = 0;
update netflix set director = null where trim(director) = '';
update netflix set cast = null where trim(cast) = '';
update netflix set country = null where trim(country) = '';
update netflix set date_added = null where trim(date_added) = '';
update netflix set rating = null where trim(rating) = '';
select rating, count(*) as total from netflix group by rating order by total desc;
SELECT * FROM netflix WHERE rating IN ('74 min', '84 min', '66 min');
update netflix set duration = rating , rating = Null where rating in ('74 min', '84 min', '66 min');
select rating,duration from netflix where duration in ('74 min', '84 min', '66 min');
SELECT show_id, title, rating, duration FROM netflix WHERE show_id IN ('s5542', 's5795', 's5814');

select count(*) as missiing_duration from netflix where duration is null or trim(duration) = '';
select type, count(*) as total from netflix group by type order by total desc;
select count(*) as total from netflix where type is null or trim(type) = '';
select distinct type from netflix;
select distinct show_id from netflix;
select show_id, count(*) as total from netflix group by show_id having count(*) > 1 ;
SELECT COUNT(*) AS total_records FROM netflix;

SELECT 
    MIN(release_year) AS oldest_year,
    MAX(release_year) AS newest_year
FROM netflix;
SELECT release_year, COUNT(*) AS total
FROM netflix
GROUP BY release_year
ORDER BY release_year;
SELECT date_added
FROM netflix
WHERE date_added IS NOT NULL
LIMIT 10;
alter table netflix add column date_added_clean date;

SELECT STR_TO_DATE('September 25, 2021', '%M %d, %Y');
SELECT date_added FROM netflix WHERE date_added IS NOT NULL AND STR_TO_DATE(TRIM(date_added), '%M %d, %Y') IS NULL LIMIT 20;
UPDATE netflix SET date_added_clean = STR_TO_DATE(TRIM(date_added), '%M %d, %Y') WHERE date_added IS NOT NULL AND date_added_clean IS NULL;
SELECT date_added, date_added_clean
FROM netflix
WHERE date_added_clean IS NOT NULL
LIMIT 10; 

SELECT show_id, title, rating, duration
FROM netflix
WHERE duration IN ('74 min', '84 min', '66 min');
SELECT COUNT(*) AS missing_listed_in
FROM netflix
WHERE listed_in IS NULL
   OR TRIM(listed_in) = '';
   
###Exploratory Data Analysis###

select type , count(*) as total from netflix group by type order by total desc;
select release_year, count(*) as total from netflix group by release_year order by release_year; 
select listed_in, count(*) as total from netflix group by listed_in order by total desc;

SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', numbers.n), ',', -1)) AS genre, # substring_index() - (text, delimiter, count) #
    COUNT(*) AS total
FROM netflix
JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
    UNION ALL SELECT 7 UNION ALL SELECT 8
    UNION ALL SELECT 9 UNION ALL SELECT 10
    UNION ALL SELECT 11 UNION ALL SELECT 12
    UNION ALL SELECT 13
) numbers
ON numbers.n <= 1 + LENGTH(listed_in) - LENGTH(REPLACE(listed_in, ',', ''))
GROUP BY genre
ORDER BY total DESC;

select country from netflix limit 10;
SELECT 
    TRIM(
        SUBSTRING_INDEX(
            SUBSTRING_INDEX(country, ',', numbers.n),
            ',',
            -1
        )
    ) AS country_name,
    COUNT(*) AS total
FROM netflix
JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
    UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
    UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
    UNION ALL SELECT 13
) numbers
ON numbers.n <= 1 + LENGTH(country) - LENGTH(REPLACE(country, ',', ''))
WHERE country IS NOT NULL
GROUP BY country_name
ORDER BY total DESC;
SELECT 
    rating,
    COUNT(*) AS total
FROM netflix
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY total DESC;

SELECT 
    AVG(CAST(REPLACE(duration, ' min', '') AS UNSIGNED)) AS average_movie_duration
FROM netflix
WHERE type = 'Movie';
SELECT 
    AVG(
        CAST(
            REPLACE(
                REPLACE(duration, ' Seasons', ''),
                ' Season',
                ''
            ) AS UNSIGNED
        )
    ) AS average_tv_seasons
FROM netflix
WHERE type = 'TV Show';

select year(date_added_clean) as added_year, count(*) as total_added from netflix where date_added_clean is not null group by year(date_added_clean)order by added_year;
select release_year,type,count(*) as total from netflix group by type , release_year order by release_year;

SELECT
    type,
    TRIM(
        SUBSTRING_INDEX(
            SUBSTRING_INDEX(listed_in, ',', numbers.n),
            ',',
            -1
        )
    ) AS genre,
    COUNT(*) AS total
FROM netflix
JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
    UNION ALL SELECT 7 UNION ALL SELECT 8
    UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
    UNION ALL SELECT 12 UNION ALL SELECT 13
) numbers
ON numbers.n <= 1 + LENGTH(listed_in) - LENGTH(REPLACE(listed_in, ',', ''))
GROUP BY type, genre
ORDER BY type, total DESC;

SELECT
    type,
    TRIM(
        SUBSTRING_INDEX(
            SUBSTRING_INDEX(country, ',', numbers.n),
            ',',
            -1
        )
    ) AS country_name,
    COUNT(*) AS total
FROM netflix
JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
    UNION ALL SELECT 7 UNION ALL SELECT 8
    UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
    UNION ALL SELECT 12 UNION ALL SELECT 13
) numbers
ON numbers.n <= 1 + LENGTH(country) - LENGTH(REPLACE(country, ',', ''))
WHERE country IS NOT NULL
GROUP BY type, country_name
ORDER BY country_name, total DESC;

SELECT
    TRIM(
        SUBSTRING_INDEX(
            SUBSTRING_INDEX(country, ',', countries.n),
            ',',
            -1
        )
    ) AS country_name,

    TRIM(
        SUBSTRING_INDEX(
            SUBSTRING_INDEX(listed_in, ',', genres.n),
            ',',
            -1
        )
    ) AS genre,

    COUNT(*) AS total

FROM netflix

JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
    UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
    UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
    UNION ALL SELECT 13
) countries

JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
    UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
    UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
    UNION ALL SELECT 13
) genres

ON countries.n <= 1 + LENGTH(country)
                  - LENGTH(REPLACE(country, ',', ''))

AND genres.n <= 1 + LENGTH(listed_in)
               - LENGTH(REPLACE(listed_in, ',', ''))

WHERE country IS NOT NULL
  AND listed_in IS NOT NULL

GROUP BY country_name, genre
ORDER BY total DESC;

SELECT
    country_name,
    genre,
    total,
    ROUND(
        total * 100.0 /
        SUM(total) OVER (PARTITION BY country_name),
        2
    ) AS genre_percentage
FROM (
    SELECT
        TRIM(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(country, ',', countries.n),
                ',',
                -1
            )
        ) AS country_name,

        TRIM(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(listed_in, ',', genres.n),
                ',',
                -1
            )
        ) AS genre,

        COUNT(*) AS total

    FROM netflix

    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
        UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
        UNION ALL SELECT 13
    ) countries

    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
        UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
        UNION ALL SELECT 13
    ) genres

    ON countries.n <= 1 + LENGTH(country)
                      - LENGTH(REPLACE(country, ',', ''))

    AND genres.n <= 1 + LENGTH(listed_in)
                   - LENGTH(REPLACE(listed_in, ',', ''))

    WHERE country IS NOT NULL
      AND listed_in IS NOT NULL

    GROUP BY country_name, genre
) AS country_genre;
SELECT *
FROM (
    SELECT
        country_name,
        genre,
        total,
        ROUND(
            total * 100.0 /
            SUM(total) OVER (PARTITION BY country_name),
            2
        ) AS genre_percentage
    FROM (
        SELECT
            TRIM(
                SUBSTRING_INDEX(
                    SUBSTRING_INDEX(country, ',', countries.n),
                    ',',
                    -1
                )
            ) AS country_name,

            TRIM(
                SUBSTRING_INDEX(
                    SUBSTRING_INDEX(listed_in, ',', genres.n),
                    ',',
                    -1
                )
            ) AS genre,

            COUNT(*) AS total

        FROM netflix

        JOIN (
            SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
            UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
            UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
            UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
            UNION ALL SELECT 13
        ) countries

        JOIN (
            SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
            UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
            UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
            UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
            UNION ALL SELECT 13
        ) genres

        ON countries.n <= 1 + LENGTH(country)
                          - LENGTH(REPLACE(country, ',', ''))

        AND genres.n <= 1 + LENGTH(listed_in)
                       - LENGTH(REPLACE(listed_in, ',', ''))

        WHERE country IS NOT NULL
          AND listed_in IS NOT NULL

        GROUP BY country_name, genre
    ) AS country_genre
) AS analysis
WHERE total >= 20
ORDER BY total DESC;

SELECT
    genre,
    COUNT(*) AS total,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS overall_percentage
FROM (
    SELECT
        TRIM(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(listed_in, ',', numbers.n),
                ',',
                -1
            )
        ) AS genre
    FROM netflix
    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
        UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
        UNION ALL SELECT 13
    ) numbers
    ON numbers.n <= 1 + LENGTH(listed_in)
                       - LENGTH(REPLACE(listed_in, ',', ''))
    WHERE listed_in IS NOT NULL
) AS genre_data
GROUP BY genre
ORDER BY total DESC;

WITH genre_data AS (
    SELECT
        TRIM(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(listed_in, ',', numbers.n),
                ',',
                -1
            )
        ) AS genre
    FROM netflix
    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
        UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
        UNION ALL SELECT 13
    ) numbers
    ON numbers.n <= 1 + LENGTH(listed_in)
                       - LENGTH(REPLACE(listed_in, ',', ''))
    WHERE listed_in IS NOT NULL
),

overall_genre AS (
    SELECT
        genre,
        COUNT(*) AS overall_total,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS overall_percentage
    FROM genre_data
    GROUP BY genre
),

country_genre AS (
    SELECT
        TRIM(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(country, ',', countries.n),
                ',',
                -1
            )
        ) AS country_name,

        TRIM(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(listed_in, ',', genres.n),
                ',',
                -1
            )
        ) AS genre,

        COUNT(*) AS country_genre_total

    FROM netflix

    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
        UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
        UNION ALL SELECT 13
    ) countries

    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
        UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
        UNION ALL SELECT 13
    ) genres

    ON countries.n <= 1 + LENGTH(country)
                      - LENGTH(REPLACE(country, ',', ''))

    AND genres.n <= 1 + LENGTH(listed_in)
                   - LENGTH(REPLACE(listed_in, ',', ''))

    WHERE country IS NOT NULL
      AND listed_in IS NOT NULL

    GROUP BY country_name, genre
),

country_totals AS (
    SELECT
        country_name,
        SUM(country_genre_total) AS country_total
    FROM country_genre
    GROUP BY country_name
)

SELECT
    cg.country_name,
    cg.genre,
    cg.country_genre_total,
    ROUND(
        cg.country_genre_total * 100.0 / ct.country_total,
        2
    ) AS country_percentage,
    ROUND(og.overall_percentage, 2) AS overall_percentage,
    ROUND(
        (cg.country_genre_total * 100.0 / ct.country_total)
        / og.overall_percentage,
        2
    ) AS representation_index

FROM country_genre cg

JOIN country_totals ct
    ON cg.country_name = ct.country_name

JOIN overall_genre og
    ON cg.genre = og.genre

WHERE cg.country_genre_total >= 20

ORDER BY representation_index ASC;


WITH genre_data AS (
    SELECT
        TRIM(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(listed_in, ',', numbers.n),
                ',',
                -1
            )
        ) AS genre
    FROM netflix
    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
        UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
        UNION ALL SELECT 13
    ) numbers
    ON numbers.n <= 1 + LENGTH(listed_in)
                       - LENGTH(REPLACE(listed_in, ',', ''))
    WHERE listed_in IS NOT NULL
),

overall_genre AS (
    SELECT
        genre,
        COUNT(*) AS overall_total,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS overall_percentage
    FROM genre_data
    GROUP BY genre
),

country_genre AS (
    SELECT
        TRIM(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(country, ',', countries.n),
                ',',
                -1
            )
        ) AS country_name,

        TRIM(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(listed_in, ',', genres.n),
                ',',
                -1
            )
        ) AS genre,

        COUNT(*) AS country_genre_total

    FROM netflix

    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
        UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
        UNION ALL SELECT 13
    ) countries

    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
        UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
        UNION ALL SELECT 13
    ) genres

    ON countries.n <= 1 + LENGTH(country)
                      - LENGTH(REPLACE(country, ',', ''))

    AND genres.n <= 1 + LENGTH(listed_in)
                   - LENGTH(REPLACE(listed_in, ',', ''))

    WHERE country IS NOT NULL
      AND listed_in IS NOT NULL

    GROUP BY country_name, genre
),

country_totals AS (
    SELECT
        country_name,
        SUM(country_genre_total) AS country_total
    FROM country_genre
    GROUP BY country_name
),

representation AS (
    SELECT
        cg.country_name,
        cg.genre,
        cg.country_genre_total,
        ROUND(
            cg.country_genre_total * 100.0 / ct.country_total,
            2
        ) AS country_percentage,
        ROUND(og.overall_percentage, 2) AS overall_percentage,
        ROUND(
            (cg.country_genre_total * 100.0 / ct.country_total)
            / og.overall_percentage,
            2
        ) AS representation_index

    FROM country_genre cg

    JOIN country_totals ct
        ON cg.country_name = ct.country_name

    JOIN overall_genre og
        ON cg.genre = og.genre

    WHERE cg.country_genre_total >= 20
)

SELECT
    country_name,
    genre,
    country_genre_total,
    country_percentage,
    overall_percentage,
    representation_index,

    CASE
        WHEN representation_index < 1
        THEN ROUND((1 - representation_index) * 100, 2)
        ELSE 0
    END AS gap_score

FROM representation

ORDER BY gap_score DESC;