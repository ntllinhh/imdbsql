-- IMDB Movies Data Analysis Script
-- Project by Linh Nguyen

-- 1. Check for NULL values in key columns
SELECT 
    col.column_name, 
    COUNT(*) FILTER (WHERE col.column_value IS NULL) AS null_count
FROM imdb,
LATERAL (
    VALUES
        ('series_title', series_title::text),
        ('released_year', released_year::text),
        ('certificate', certificate::text),
        ('runtime', runtime::text),
        ('genre', genre::text),
        ('imdb_rating', imdb_rating::text),
        ('meta_score', meta_score::text),
        ('director', director::text),
        ('no_of_votes', no_of_votes::text),
        ('gross', gross::text),
        ('star1', star1::text),
        ('star2', star2::text),
        ('star3', star3::text),
        ('star4', star4::text)
) AS col(column_name, column_value)
WHERE col.column_value IS NULL
GROUP BY col.column_name
ORDER BY null_count DESC;

-- 2. Range of IMDb Ratings
SELECT DISTINCT imdb_rating
FROM imdb
GROUP BY imdb_rating
ORDER BY imdb_rating;

-- 3. IMDb Rating Distribution by Group
SELECT 
  CASE 
    WHEN imdb_rating >= 7.5 AND imdb_rating < 8 THEN '[7.5-7.9]'
    WHEN imdb_rating >= 8 AND imdb_rating < 9 THEN '[8-8.9]'
    WHEN imdb_rating >= 9 THEN '[9+]'
    ELSE 'N/A'
  END AS rating_group,
  COUNT(*) AS count
FROM imdb
GROUP BY rating_group
ORDER BY rating_group;

-- 4. Top 10 Most Common Genres
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(genre, ','))) AS single_genre,
    COUNT(*) AS no_of_movies
FROM imdb
GROUP BY single_genre
ORDER BY no_of_movies DESC
LIMIT 10;

-- 5. Number of Movies Produced per 25-Year Period
SELECT
    CASE 
        WHEN CAST(released_year AS INT) BETWEEN 1920 AND 1944 THEN '1920–1944'
        WHEN CAST(released_year AS INT) BETWEEN 1945 AND 1969 THEN '1945–1969'
        WHEN CAST(released_year AS INT) BETWEEN 1970 AND 1994 THEN '1970–1994'
        WHEN CAST(released_year AS INT) BETWEEN 1995 AND 2020 THEN '1995–2020'
    END AS year_bin,
    COUNT(*) AS no_of_movies
FROM imdb
WHERE released_year IS NOT NULL 
  AND released_year != 'PG'
GROUP BY year_bin
ORDER BY year_bin;

-- 6. Average IMDb Rating by Genre
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(genre, ','))) AS single_genre,
    ROUND(AVG(imdb_rating), 2) AS avg_rating
FROM imdb
GROUP BY single_genre
ORDER BY avg_rating DESC;

-- 7. Genres with Highest Average Gross Revenue
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(genre, ','))) AS single_genre,
    ROUND(AVG(gross), 0) AS avg_gross
FROM imdb
WHERE gross IS NOT NULL
GROUP BY single_genre
ORDER BY avg_gross DESC;

-- 8. Years with Most High-Grossing Movies (>200M)
SELECT 
  released_year,
  COUNT(*) AS high_grossing_movie_count
FROM imdb
WHERE 
  gross IS NOT NULL
  AND CAST(gross AS BIGINT) > 200000000
  AND released_year IS NOT NULL
GROUP BY released_year
ORDER BY high_grossing_movie_count DESC
LIMIT 10;

-- 9. Top 10 Movies by IMDb Rating
SELECT
  series_title,
  imdb_rating
FROM imdb
ORDER BY imdb_rating DESC
LIMIT 10;

-- 10. Top 10 Movies by Gross Revenue
SELECT
  series_title,
  gross
FROM imdb
WHERE gross IS NOT NULL
ORDER BY gross DESC
LIMIT 10;

-- 11. Correlation Analysis between Quality Metrics and Revenue
SELECT 'imdb_rating' AS variable_x, 'meta_score' AS variable_y, CORR(imdb_rating, meta_score) AS correlation
FROM imdb
WHERE imdb_rating IS NOT NULL AND meta_score IS NOT NULL

UNION ALL

SELECT 'imdb_rating', 'gross', CORR(imdb_rating, gross)
FROM imdb
WHERE imdb_rating IS NOT NULL AND gross IS NOT NULL

UNION ALL

SELECT 'imdb_rating', 'no_of_votes', CORR(imdb_rating, no_of_votes)
FROM imdb
WHERE imdb_rating IS NOT NULL AND no_of_votes IS NOT NULL

UNION ALL

SELECT 'meta_score', 'gross', CORR(meta_score, gross)
FROM imdb
WHERE meta_score IS NOT NULL AND gross IS NOT NULL

UNION ALL

SELECT 'meta_score', 'no_of_votes', CORR(meta_score, no_of_votes)
FROM imdb
WHERE meta_score IS NOT NULL AND no_of_votes IS NOT NULL

UNION ALL

SELECT 'gross', 'no_of_votes', CORR(gross, no_of_votes)
FROM imdb
WHERE gross IS NOT NULL AND no_of_votes IS NOT NULL;

-- 12. Recurring Directors in Top 10 Movies by IMDb Rating
WITH top_movies AS (
  SELECT 
    series_title,
    director,
    imdb_rating
  FROM imdb
  ORDER BY imdb_rating DESC
  LIMIT 10
)
SELECT
  director,
  COUNT(*) AS no_of_movies
FROM top_movies
GROUP BY director
HAVING COUNT(*) > 1;

-- 13. Most Genre-Diverse Actors
SELECT
  actor_name,
  COUNT(DISTINCT TRIM(single_genre)) AS number_of_genres
FROM (
  SELECT
    actor_name,
    UNNEST(STRING_TO_ARRAY(genre, ',')) AS single_genre
  FROM (
    SELECT genre, star1 AS actor_name FROM imdb
    UNION ALL
    SELECT genre, star2 FROM imdb
    UNION ALL
    SELECT genre, star3 FROM imdb
    UNION ALL
    SELECT genre, star4 FROM imdb
  ) AS actor_genre
  WHERE actor_name IS NOT NULL
) AS subquery
GROUP BY actor_name
ORDER BY number_of_genres DESC
LIMIT 20;
