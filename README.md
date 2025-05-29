# IMDb Movies Data Analysis using SQL
PROJECT BY LINH NGUYEN

![](https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/IMDB_Logo_2016.svg/1200px-IMDB_Logo_2016.svg.png)

## Overview
This project presents a comprehensive exploratory data analysis (EDA) of the IMDb Top 1000 Movies and TV Shows dataset using SQL. The primary objective is to uncover meaningful patterns, trends, and relationships within the dataset by examining various aspects such as ratings, genres, revenue, and the people behind the films.

## Dataset
The data used in this project is from Kaggle:
- **Link**: [IMDB Movies Dataset] (https://www.kaggle.com/datasets/harshitshankhdhar/imdb-dataset-of-top-1000-movies-and-tv-shows)

## Schema

```sql
DROP TABLE IF EXISTS imdb;
CREATE TABLE imdb
(
  poster_link VARCHAR(200),
  series_title VARCHAR(100),
  released_year VARCHAR(4),
  certificate VARCHAR(10),
  runtime VARCHAR(10),
  genre VARCHAR(50),
  imdb_rating NUMERIC,
  overview VARCHAR(500),
  meta_score NUMERIC,
  director VARCHAR(50),
  star1 VARCHAR(50),
  star2 VARCHAR(50),
  star3 VARCHAR(50),
  star4 VARCHAR(50),
  no_of_votes INTEGER,
  gross INTEGER
);
```
## EDA on the dataset
### Data Quality & Structure
### 1. Are there any invalid or inconsistent values in the dataset?

```sql
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
```
**Objective:** Determine null values in the dataset.

### 2. What is the valid range and distribution of IMDb rating?

### 2.1. Query 1: Range of IMDb ratings

```sql
SELECT DISTINCT imdb_rating
FROM imdb
GROUP BY imdb_rating;
```
**Insights you can gain:** Understand the full scope of IMDb ratings in the dataset.

### 2.2. Query 2: IMDb rating distribution by group

```sql
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
```
**Insights you can gain:** See how movies are spread across different rating brackets.

### Descriptive Insights

### 3. What are the top 10 most common genres?

```sql
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(genre, ','))) AS single_genre,
    COUNT(*) AS no_of_movies
FROM imdb
GROUP BY single_genre
ORDER BY COUNT(*) DESC
LIMIT 10;
```
**Insights you can gain:** Reveal which genres dominate the movie industry in terms of production volume.

### 4. How many movies were produced per 25-year period?

```sql
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
```
**Insights you can gain:** Track the growth or decline of movie production over long historical periods.

### 5. How does IMDb rating vary by genre?

```sql
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(genre, ','))) AS single_genre,
    ROUND(AVG(imdb_rating), 2) AS avg_rating
FROM imdb
GROUP BY single_genre
ORDER BY ROUND(AVG(imdb_rating), 2) DESC;
```
**Insights you can gain:**
  - Identify genres with consistenly high or low IMDb ratings.
  - Compare audience reception across different types of films

### 6. Which genres have the highest average gross revenue?

```sql
SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(genre, ','))) AS single_genre,
        ROUND(AVG(gross), 0) AS avg_gross
FROM imdb
WHERE gross IS NOT NULL
GROUP BY single_genre
ORDER BY ROUND(AVG(gross), 0) DESC;
```
**Insights you can gain:** Pinpoint which genres tend to generate the most box office income on average.

### Trend & Performance Insights
### 7. Which years saw the highest number of high-grossing movies?

```sql
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
```
**Insights you can gain:**
  - Identify specific years where high-grossing movies were most concentrated.
  - Understand whether the number of blockbuster movies is increasing in recent years.

### 8. What are the top 10 movies by IMDb rating?

```sql
SELECT
  series_title,
  imdb_rating
FROM imdb
ORDER BY imdb_rating DESC
LIMIT 10;
```
**Insights you can gain:**
  - Identify which movies are most appreciated by IMDb users.
  - Use these top ratings as a reference for comparing other films in the dataset.

### 9. What are the top 10 movies by gross revenue?

```sql
SELECT
  series_title,
  gross
FROM imdb
WHERE gross IS NOT NULL
ORDER BY gross DESC
LIMIT 10;
```
**Insights you can gain:**
  - Understand which movies performed best at the box office.
  - Compare with IMDb ratings to identify films that were commercially successful but not critically acclaimed (or vice versa).

### Correlation & Relationships
### 10. Is there a correlation between movie quality indicators (IMDb rating, metascore, number of votes) and gross revenue?

```sql
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
```
**Insights you can gain:**
  - Determine whether higher critical or audience ratings are associated with better box office performance.
  - Assess whether a higher number of votes translates to higher revenue.

### People Insights
### 11. Do the top 10 movies by IMDb rating have recurring directors?

```sql
WITH top_movies AS (
SELECT 
        series_title,
        director,
        genre,
        imdb_rating
FROM imdb
ORDER BY imdb_rating DESC
LIMIT 10 )

SELECT
        director,
        COUNT(*) AS no_of_movies
FROM top_movies
GROUP BY director
HAVING COUNT(*) > 1;
```
**Insights you can gain:**
  - Highlight whether certain directors consistenly produce top-rated films.
  - Recurring directors among top-rated movies may indicate a strong link between direction style and critical acclaim.

### 12. Which actors appear in the most movies across all genres?

```sql
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
```
**Insights you can gain:** Identify the most genre-diverse actors.
  



