# IMDB Movies Data Analysis using SQL
PROJECT BY LINH NGUYEN

![](https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/IMDB_Logo_2016.svg/1200px-IMDB_Logo_2016.svg.png)

## Overview
This project involves a detailed exploratory analysis of IMDb's movie dataset using SQL. The aim is to explore the data, identify patterns, detect anomalies, and generate useful insights about movies. This README provides an overview of the project's objectives, analytical approach, key findings, and overall conclusions.

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
### Concerns from the IMDB Movies dataset answered using SQL Queries.
### 1. Any invalid or inconsistent values in the dataset

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

## 2. Find the number of movies released each year (25-year bins)

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
**Objective:** Analyse the distribution of movie released across different historical periods.

## 3. Determine the valid range and distribution of IMDb rating

### 3.1. Query 1: Range of IMDb ratings

```sql
SELECT DISTINCT imdb_rating
FROM imdb
GROUP BY imdb_rating;
```
**Objective:** Find a quick overview of the spread and granularity of rating values.

### 3.2. Query 2: IMDb rating distribution by group

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
**Objective:** Categorise movies into rating groups and counts how many fall into each group.

## 4. Find the top 10 movie genres

```sql
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(genre, ','))) AS single_genre,
    COUNT(*) AS no_of_movies
FROM imdb
GROUP BY single_genre
ORDER BY COUNT(*) DESC
LIMIT 10;
```
**Objective:** Determine the most frequently occurring movie genres in the IMDb dataset.

## 5. Find average IMDb ratings by genre

```sql
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(genre, ','))) AS single_genre,
    ROUND(AVG(imdb_rating), 2) AS avg_rating
FROM imdb
GROUP BY single_genre
ORDER BY ROUND(AVG(imdb_rating), 2) DESC;
```
**Objective:** Examine how average IMDB ratings differe across individual genres.



