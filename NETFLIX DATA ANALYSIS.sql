CREATE TABLE netflix
(
	show_id varchar(6),
	type varchar(10),
	title varchar(150),
	director varchar(225),	
	casts varchar(1000),
	country	varchar(200),
	date_added varchar(50),	
	release_year int,	
	rating varchar(10),	
	duration varchar(15),
	listed_in varchar(100),
	description varchar(250)
)

SELECT * FROM netflix



--BUSINESS PROBLEMS—

--1.Count the number of Movies vs TV Shows.

SELECT 
	type,
	COUNT(*) as total
from netflix
GROUP BY type 
 

--2.Identify underrepresented genres on Netflix.

WITH GenreCounts AS (
    SELECT
        TRIM(genre) AS genre 
    FROM
        netflix,
        UNNEST(string_to_array(listed_in, ',')) AS genre 
)
SELECT
    genre,
    COUNT(*) AS genre_count
FROM
    GenreCounts
GROUP BY
    genre
ORDER BY
    genre_count ASC; 

  


--3.Count the number of content items in each genre.

WITH GenreCounts AS (
    SELECT
        TRIM(genre) AS genre 
    FROM
        netflix,
        UNNEST(string_to_array(listed_in, ',')) AS genre 
)
SELECT
    genre,
    COUNT(*) AS genre_count
FROM
    GenreCounts
GROUP BY
    genre
ORDER BY
    genre_count DESC;

  

--4.List all TV shows with more than 5 seasons

SELECT 
    title
FROM 
    netflix
WHERE 
    type = 'TV Show'
    AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5
ORDER BY 
    title;


      





--5.Evaluate the lifespan of TV shows (average number of seasons).

SELECT 
    AVG(CAST(SUBSTRING(duration FROM 1 FOR POSITION(' ' IN duration)-1) AS INTEGER)) AS average_seasons
FROM netflix
WHERE type = 'TV Show';

 

--6.Find the most common rating for movies and TV shows.

SELECT 
	rating,
	COUNT(*) as total
FROM netflix
GROUP BY rating
ORDER BY total DESC

 
--7.Analyze the distribution of family-friendly content vs mature content.

SELECT
    CASE 
        WHEN rating IN ('G', 'PG', 'TV-Y', 'TV-Y7', 'TV-G', 'TV-PG') THEN 'Family-Friendly'
        WHEN rating IN ('PG-13', 'R', 'NC-17', 'TV-14', 'TV-MA') THEN 'Mature'
        ELSE 'Other'
    END AS content_type,
    COUNT(*) AS count
FROM netflix
WHERE rating IS NOT NULL
GROUP BY content_type
ORDER BY count DESC;

--8.Categorize content based on the presence of keywords ('kill' and 'violence') in the description field. Label such content as 'Bad' and the rest as 'Good.' Count how many items fall into each category.

SELECT
    CASE
        WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS content_category,
    COUNT(*) AS count
FROM netflix
WHERE description IS NOT NULL
GROUP BY content_category
ORDER BY count DESC;

--9.List all movies released in a specific year (e.g., 2020).

SELECT title FROM netflix
WHERE release_year='2020'

--10.Find content added in the last 5 years.

SELECT title,release_year FROM netflix 
WHERE release_year BETWEEN 2020 AND 2024
ORDER BY release_year ASC;

--11. Analyse the days of release of movies.

SELECT
     TO_CHAR(TO_DATE(date_added, 'Month DD,YYYY'), 'Day') AS day_of_week,
    COUNT(*) AS release_count  
FROM
    netflix
GROUP BY
    day_of_week
ORDER BY
    release_count DESC;

--12.Find the top 5 countries with the most content on Netflix.

SELECT
	country,
	COUNT(*) as Number_of_releases
FROM 
    (
        SELECT unnest(string_to_array(country, ', ')) AS country  
        FROM netflix
        WHERE country IS NOT NULL
    ) AS country_list
GROUP BY country
ORDER BY Number_of_releases DESC
LIMIT 5;

--13.Analyze country-wise contributions to Netflix’s library.

SELECT
	country,
	COUNT(*) as Number_of_releases
FROM 
    (
        SELECT unnest(string_to_array(country, ', ')) AS country  
        FROM netflix
        WHERE country IS NOT NULL
    ) AS country_list
GROUP BY country
ORDER BY Number_of_releases DESC

--14.	Find the average release year for content produced in a specific country.

SELECT
	country,
	ROUND(AVG(CAST(release_year AS INTEGER)),0) AS average_release_year
FROM 
    (
        SELECT unnest(string_to_array(country, ', ')) AS country, release_year  
        FROM netflix
        WHERE country IS NOT NULL AND release_year IS NOT NULL
    ) AS country_list
GROUP BY country
ORDER BY average_release_year DESC

--15.List all movies/TV shows by director 'Rajiv Chilaka.'

SELECT 
	title
FROM netflix
WHERE director = 'Rajiv Chilaka'

--16.Find how many movies actor 'Salman Khan' appeared in the last 10 years.

SELECT 
	title 
FROM 
    (
        SELECT unnest(string_to_array(casts, ', ')) AS casts,title 
        FROM netflix
        WHERE country IS NOT NULL AND title IS NOT NULL
    ) AS cast_list
WHERE casts = 'Salman Khan'



--17.Find the top 10 actors who have appeared in the highest number of movies in their career.

SELECT 
	casts,
	COUNT(*) as Total_no_of_movies
FROM 
    (
        SELECT unnest(string_to_array(casts, ', ')) AS casts,title 
        FROM netflix
        WHERE country IS NOT NULL AND title IS NOT NULL
    ) AS cast_list
GROUP BY casts
ORDER BY Total_no_of_movies DESC;

--18.Identify the most frequent directors.

SELECT 
	director,
	COUNT(*) as Total_no_of_movies
FROM 
    (
        SELECT unnest(string_to_array(director, ', ')) AS director,title 
        FROM netflix
        WHERE director IS NOT NULL AND title IS NOT NULL
    ) AS director_list
GROUP BY director
ORDER BY Total_no_of_movies DESC;

--19.Analyze recurring actor collaborations.

WITH actor_pairs AS (
    SELECT
        unnest(string_to_array(casts, ', ')) AS actor,
        title
    FROM
        netflix
    WHERE
        casts IS NOT NULL AND title IS NOT NULL 
),
collaborations AS (
    SELECT
        a1.actor AS actor_1,
        a2.actor AS actor_2,
        a1.title
    FROM
        actor_pairs a1
    JOIN
        actor_pairs a2
    ON
        a1.title = a2.title  
    WHERE
        a1.actor < a2.actor  
)
SELECT
    actor_1,
    actor_2,
    COUNT(*) AS collaboration_count
FROM
    collaborations
GROUP BY
    actor_1,
    actor_2
ORDER BY
    collaboration_count DESC
LIMIT 10; 

--20.Identify the longest movie or TV show duration

SELECT
    title,
    duration,
    CAST(SUBSTRING(duration FROM '\d+') AS INTEGER) AS movie_duration
FROM
    netflix
WHERE
    type = 'Movie' AND
	duration IS NOT NULL
ORDER BY
    movie_duration DESC
LIMIT 1; 
SELECT 
    title,
	CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) as seasons
FROM 
    netflix
WHERE 
    type = 'TV Show'
    AND duration IS NOT NULL
ORDER BY 
    seasons DESC
	LIMIT 1;

--21.Highlight long-running TV shows with exceptional durations.

SELECT 
    title,
	CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) as seasons
FROM 
    netflix
WHERE 
    type = 'TV Show'
    AND duration IS NOT NULL
ORDER BY 
    seasons DESC;
 

--22.Find all content without a director.

SELECT 
	title
FROM 
    netflix
WHERE director IS NULL

--23.List all movies that are documentaries

SELECT
    title
FROM
    netflix
WHERE
    type = 'Movie'
    AND listed_in LIKE '%Documentaries%'

