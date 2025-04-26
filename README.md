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
