-- ADVANCE SQL PROJECT ---SPOTIFY DATASET

-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);



-- EDA
SELECT * FROM spotify;

SELECT COUNT(*) FROM spotify;

SELECT DISTINCT(artist) FROM spotify;

SELECT DISTINCT(album) FROM spotify;

SELECT COUNT(DISTINCT(album_type)) FROM spotify;
SELECT DISTINCT(album_type) FROM spotify;

SELECT CONCAT(max(duration_min),' MIN') FROM spotify;

SELECT CONCAT(MIN(duration_min),' MIN') FROM spotify;

-- we found that there r some songs with '0' duration_min. so, this type of songs r not consider..
SELECT * FROM spotify
WHERE duration_min=0

DELETE FROM spotify
WHERE duration_min=0

SELECT DISTINCT(channel) FROM spotify;

SELECT DISTINCT most_played_on FROM spotify;


-- Easy Level
-- 1. Retrieve the names of all tracks that have more than 1 billion streams.
-- 2. List all albums along with their respective artists.
-- 3. Get the total number of comments for tracks where licensed = TRUE.
-- 4. Find all tracks that belong to the album type single.
-- 5. Count the total number of tracks by each artist.

-- Q.1  Retrieve the names of all tracks that have more than 1 billion streams.
SELECT 
      track,
	  stream
FROM spotify
WHERE stream >1000000000;



-- Q.2  List all albums along with their respective artists.
SELECT 
      DISTINCT album,
	  artist
FROM spotify
order by 1;



-- Q.3. Get the total number of comments for tracks where licensed = TRUE.
SELECT 
	  SUM(comments) AS total_comments
FROM spotify
WHERE licensed=True;



-- Q.4. Find all tracks that belong to the album type single.
SELECT
     track,
	 album_type
FROM spotify
WHERE album_type='single';



-- Q.5. Count the total number of tracks by each artist.
SELECT
      artist,
	  count(track) AS total_tracks
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;



--Medium Level
-- 6.Calculate the average danceability of tracks in each album.
-- 7.Find the top 5 tracks with the highest energy values.
-- 8.List all tracks along with their views and likes where official_video = TRUE.
-- 9.For each album, calculate the total views of all associated tracks.
-- 10.Retrieve the track names that have been streamed on Spotify more than YouTube.

-- Q.6.Calculate the average danceability of tracks in each album.
SELECT 
      album,
	  AVG(danceability) as avg_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;


-- Q.7.Find the top 5 tracks with the highest energy values.
SELECT 
      DISTINCT track,
	  energy
FROM spotify
ORDER BY 2 DESC
LIMIT 5;


-- Q.8.List all tracks along with their views and likes where official_video = TRUE.
SELECT 
     track,
	 SUM(views) AS total_views,
	 SUM(likes) AS total_likes
FROM spotify
WHERE official_video=TRUE
GROUP BY 1;


-- Q.9.For each album, calculate the total views of all associated tracks.
SELECT 
      album,
	  track,
	  SUM(views) AS total_views
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC;


--Q.10. Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT *
FROM
(SELECT 
      track,
	  COALESCE(SUM(CASE WHEN most_played_on='Youtube' THEN stream END),0) AS streamed_on_youtube,
	   COALESCE(SUM(CASE WHEN most_played_on='Spotify' THEN stream END),0) AS streamed_on_spotify
FROM spotify
GROUP BY 1) AS T1
WHERE streamed_on_spotify>streamed_on_youtube
AND
streamed_on_youtube !=0;



-- Advanced Level
-- 11. Find the top 3 most-viewed tracks for each artist using window functions.
-- 12. Write a query to find tracks where the liveness score is above the average.
-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values 
--     for tracks in each album.
-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
-- 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window 
--     functions.



-- Q.11. Find the top 3 most-viewed tracks for each artist using window functions.
WITH ranking_artist
AS
(SELECT 
      artist,
	  track,
	  SUM(views) AS total_views ,
	  DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views)DESC) as d_rank
FROM spotify
GROUP BY 1,2
)
SELECT *
FROM ranking_artist
WHERE d_rank<=3




--Q.12. Write a query to find tracks where the liveness score is above the average.
SELECT 
     track,
	 artist,
	 liveness
FROM spotify
WHERE liveness>(SELECT AVG(liveness) FROM spotify)


-- Q.13. Use a WITH clause to calculate the difference between the highest and lowest energy values 
--       for tracks in each album.
WITH CTE AS 
(SELECT
      album,
	  MAX(energy) AS max_energy,
	  MIN(energy) AS min_energy
FROM spotify
GROUP BY 1)

SELECT album,
       max_energy-min_energy AS energy_diff
FROM CTE
ORDER BY 2 DESC;


--Q.14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
--energy-to-liveness ratio == energy / liveness
SELECT 
    track
FROM 
    spotify
WHERE 
    (energy / liveness) > 1.2;



-- Q.15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window 
--     functions.
SELECT 
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views DESC) AS cumulative_likes
FROM 
    spotify;











