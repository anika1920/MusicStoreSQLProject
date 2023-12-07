--Who is the senior most employee based on job title

SELECT * FROM PUBLIC.EMPLOYEE
ORDER BY LEVELS DESC
LIMIT 1

--Which countries have the most invoices?

SELECT BILLING_COUNTRY ,COUNT(INVOICE_ID) FROM INVOICE 
GROUP BY BILLING_COUNTRY
ORDER BY COUNT DESC
LIMIT 1

--What are top 3 values of total invoice?

SELECT INVOICE_ID ,ROUND(CAST(TOTAL AS NUMERIC),2) FROM INVOICE
ORDER BY TOTAL DESC
LIMIT 3


--Which city has the best customers?return both city name and sum of all invoice totals

SELECT BILLING_CITY ,ROUND(SUM(CAST(TOTAL AS NUMERIC)),2) FROM INVOICE 
GROUP BY BILLING_CITY
ORDER BY ROUND DESC
LIMIT 1

--Who is the best customer?

SELECT C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,ROUND(SUM(CAST(I.TOTAL AS NUMERIC)),2)
FROM CUSTOMER AS C
JOIN INVOICE AS I ON C.CUSTOMER_ID=I.CUSTOMER_ID
GROUP BY C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME
ORDER BY ROUND DESC
LIMIT 1

--Write query to return the email,first name,last name and genre of rock

SELECT DISTINCT C.EMAIL,C.FIRST_NAME,C.LAST_NAME
FROM CUSTOMER AS C
INNER JOIN INVOICE AS I ON C.CUSTOMER_ID=I.CUSTOMER_ID
INNER JOIN INVOICE_LINE AS IL ON I.INVOICE_ID=IL.INVOICE_ID
INNER JOIN TRACK AS T ON IL.TRACK_ID=T.TRACK_ID
INNER JOIN GENRE AS G ON T.GENRE_ID=G.GENRE_ID
WHERE G.NAME = 'Rock'

--let's invite the artists who have written the most rock music.
--Write a query that returns the artist name and total track count of the top 10 rock bands.

SELECT A.NAME,COUNT(A.ARTIST_ID)
FROM ARTIST AS A
INNER JOIN ALBUM ON A.ARTIST_ID=ALBUM.ARTIST_ID
INNER JOIN TRACK AS T ON ALBUM.ALBUM_ID=T.ALBUM_ID
INNER JOIN GENRE AS G ON T.GENRE_ID=G.GENRE_ID
WHERE G.NAME = 'Rock'
GROUP BY A.NAME
ORDER BY COUNT(A.ARTIST_ID) DESC
limit 10;

--Return all the track names that have a song length longer than the average song length
--Return the name and milliseconds for each track.
--Order by the song length with the longest songs listed first

select name,milliseconds from track
where milliseconds> (
	select avg(milliseconds) 
	from track)
order by milliseconds desc;

--Find how much amount spent by each customer on artists?
--Write a query to return customer name, artist name and total spent.

SELECT 
	CONCAT (C.FIRST_NAME,C.LAST_NAME) AS FULL_NAME ,
	ARTIST.name,
	sum(IL.UNIT_PRICE * IL.QUANTITY)
	FROM CUSTOMER AS C
INNER JOIN INVOICE AS I ON C.CUSTOMER_ID=I.CUSTOMER_ID
INNER JOIN INVOICE_LINE AS IL ON I.INVOICE_ID=IL.INVOICE_ID
INNER JOIN TRACK AS T ON IL.TRACK_ID=T.TRACK_ID
INNER JOIN ALBUM AS A ON T.ALBUM_ID=A.ALBUM_ID
INNER JOIN ARTIST ON ARTIST.ARTIST_ID=A.ARTIST_ID
group by 1,2;

select * from invoice_line

--Find how much amount spent by each customer on best selling artists?

with best_artist as(
	select ar.artist_id,ar.name,sum(IL.UNIT_PRICE * IL.QUANTITY)
	from artist as ar
	join album as a ON AR.ARTIST_ID=A.ARTIST_ID
	INNER JOIN TRACK AS T ON T.ALBUM_ID=A.ALBUM_ID
	INNER JOIN INVOICE_LINE AS IL ON t.track_ID=IL.track_ID
	group by 1
	order by 3 desc
	limit 1)
SELECT 
	CONCAT (C.FIRST_NAME,C.LAST_NAME) AS FULL_NAME ,
	ba.name,
	sum(IL.UNIT_PRICE * IL.QUANTITY)
	FROM CUSTOMER AS C
INNER JOIN INVOICE AS I ON C.CUSTOMER_ID=I.CUSTOMER_ID
INNER JOIN INVOICE_LINE AS IL ON I.INVOICE_ID=IL.INVOICE_ID
INNER JOIN TRACK AS T ON IL.TRACK_ID=T.TRACK_ID
INNER JOIN ALBUM AS A ON T.ALBUM_ID=A.ALBUM_ID
INNER JOIN best_ARTIST as ba ON ba.ARTIST_ID=A.ARTIST_ID
group by 1,2;


--Find the most popular music genre for each country. 
--we determine the most popular genre as the genre with the highest amount of purchase
--write a query that returns each country along with the top genre.
--for countries where thr maximum number of purchases is shared return all genres.

WITH popular_genre AS (
    SELECT
        c.country,
        g.name,
        SUM(il.quantity) AS quantity,
	row_number() over(partition by c.country order by SUM(il.quantity) desc)
		FROM CUSTOMER AS C
INNER JOIN INVOICE AS I ON C.CUSTOMER_ID=I.CUSTOMER_ID
INNER JOIN INVOICE_LINE AS IL ON I.INVOICE_ID=IL.INVOICE_ID
INNER JOIN TRACK AS T ON IL.TRACK_ID=T.TRACK_ID
INNER JOIN GENRE AS G ON T.GENRE_ID=G.GENRE_ID
    GROUP BY 1,2
	order by 1,3 desc
)

SELECT * from popular_genre
    where row_number=1

--Write a query that determines the customer that has spent the most on music for each country
--Returns the country along with the top customer and how much they spent

WITH top_customer AS (
    SELECT
        c.country,c.first_name,c.last_name,
        SUM(i.total) AS quantity,
		row_number() over(partition by c.country order by SUM(i.total) desc)
		FROM CUSTOMER AS C
	INNER JOIN INVOICE AS I ON C.CUSTOMER_ID=I.CUSTOMER_ID
    GROUP BY 1,2,3
	order by 1 asc,4 desc
)

SELECT * from top_customer
    where row_number=1
	