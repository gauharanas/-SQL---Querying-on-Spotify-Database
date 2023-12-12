use Music_database;


--Q1. Who is the senior most employee based on job title?

select top 1 CONCAT(first_name,' ',last_name) as employee_name , title, levels 
from employee 
order by levels desc ;

--Ans-: Mohan Madan (Senior General Manager) is the senior most employee
------------------------------------------------------------------------------------------------------------------------------
 
 --Q2. Which countries have the most Invoices?

select count(*)as c,billing_country
from invoice group by billing_country 
order by c desc;

  --Ans-: USA has the most invoices with total count of 131 invoices
-------------------------------------------------------------------------------------------------------------------------------

--Q3. What are top 3 values of total invoice?

select top 3 invoice_id, invoice_date, total
from invoice 
order by total desc;

  --Ans-: The 3 top values of total invoice  with thier invoice IDs are 
  --      1. Invoice_id = 183 and Total of 23.7600002288818
	    --2. Invoice_id = 31 and Total of 19.7999992370605
	 --   3. Invoice_id = 92 and Total of 19.7999992370605
-------------------------------------------------------------------------------------------------------------------------------------------

--Q4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
  --  Write a query that returns one city that has the highest sum of invoice totals. 
--    Return both the city name & sum of all invoice totals

select top 1 sum(total) as Total_invoice, count(billing_city) as total_invoices_from_city , billing_city 
from invoice 
group by billing_city 
order by Total_invoice desc;

 --Ans-: The one city that has the highest sum of invoice totals is PRAGUE with a total invoice of 273.240000247955
-------------------------------------------------------------------------------------------------------------------------------------------

 --Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer.
  --   Write a query that returns the person who has spent the most money.

  select top 3  customer.customer_id, CONCAT(first_name,' ',last_name) as Name  ,sum(total) as total_spendind 
  from customer
  inner join invoice
  on customer.customer_id = invoice.customer_id
  group by  customer.customer_id, CONCAT(first_name,' ',last_name) 
  order by total_spendind desc;

 --Ans-: The customer who has spent the most money is František Wichterlová with customer Id 5 , has a total spending of 144.539998054504

------------------------------------------------------------------------------------------------------------------------------------------------

  --Q6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
   --   Return your list ordered alphabetically by email starting with A

  Select distinct email, first_name,last_name,genre.name as Genre
  from customer
  join invoice on customer.customer_id = invoice.customer_id
  join invoice_line on invoice.invoice_id = invoice_line.invoice_line_id
  join track on invoice_line.track_id = track.track_id
  join genre on track.genre_id = genre.genre_id
  where genre.name like 'Rock'
  order by email;

  ----------------------------------------------------------------------------------------------------------------------------------------

  --Q7. Let's invite the artists who have written the most rock music in our dataset. 
  --    Write a query that returns the Artist name and total track count of the top 10 rock bands

   Select top 10 artist.artist_id, artist.name, COUNT(artist.artist_id) as number_of_songs
   from artist
   join album on  artist.artist_id = album.artist_id
   join track on album.album_id = track.album_id
   join genre on track.genre_id = genre.genre_id
   where genre.name like 'Rock'
   group by artist.artist_id, artist.name
   order by number_of_songs desc;

-----------------------------------------------------------------------------------------------------------------------------------------

  --Q8. Return all the track names that have a song length longer than the average song length. 
  --    Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

   select track.name, track.milliseconds 
   from track 
   where track.milliseconds >=  (select avg (milliseconds) from track) 
   order by milliseconds desc;

  ----------------------------------------------------------------------------------------------------------------------------------------

  --Q9.  Find how much amount spent by each customer on artists? 
  --     Write a query to return customer name, artist name and total spent
    
	WITH   best_selling_artist AS 
	( SELECT  top 1 artist.artist_id AS artist_id, artist.name AS artist_name,
	SUM (invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist.artist_id , artist.name
	ORDER BY total_sales DESC)  
	
	
	
	
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

-------------------------------------------------------------------------------------------------------------------------------------------

--Q10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases.
--     Write a query that returns each country along with the top Genre.
--	   For countries where the maximum number of purchases is shared return all Genres


WITH popular_genre AS 
(
    SELECT  top 1000 COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY  customer.country, genre.name, genre.genre_id  
	ORDER BY country ASC,  purchases  DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

---------------------------------------------------------------------------------------------------------------------------------------------

 --Q11. Write a query that determines the customer that has spent the most on music for each country.
 --     Write a query that returns the country along with the top customer and how much they spent. 
 --     For countries where the top amount spent is shared, provide all customers who spent this amount

	WITH Customter_with_country AS (
		SELECT top 1000 customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,first_name,last_name,billing_country
		ORDER BY billing_country ASC,total_spending DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1

