create database answers

use answers


CREATE TABLE artists
(
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks
(
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales
(
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists
    (artist_id, name, country, birth_year)
VALUES
    (1, 'Vincent van Gogh', 'Netherlands', 1853),
    (2, 'Pablo Picasso', 'Spain', 1881),
    (3, 'Leonardo da Vinci', 'Italy', 1452),
    (4, 'Claude Monet', 'France', 1840),
    (5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks
    (artwork_id, title, artist_id, genre, price)
VALUES
    (1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
    (2, 'Guernica', 2, 'Cubism', 2000000.00),
    (3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
    (4, 'Water Lilies', 4, 'Impressionism', 500000.00),
    (5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales
    (sale_id, artwork_id, sale_date, quantity, total_amount)
VALUES
    (1, 1, '2024-01-15', 1, 1000000.00),
    (2, 2, '2024-02-10', 1, 2000000.00),
    (3, 3, '2024-03-05', 1, 3000000.00),
    (4, 4, '2024-04-20', 2, 1000000.00);


select *
from artists
select *
from artworks
select *
from sales


-- Section 1
-- Que 1
-- 1. Write a query to display the artist names in uppercase.

SELECT UPPER(name) AS artist_name
FROM artists;

-- 2. Write a query to find the top 2 highest-priced 
-- artworks and the total quantity sold for each.

SELECT top 2
    a.title, a.price, SUM(s.quantity) AS total_quantity_sold
FROM artworks a
    JOIN sales s ON a.artwork_id = s.artwork_id
GROUP BY a.title, a.price
ORDER BY a.price DESC

-- 3. Write a query to find the total amount of
--  sales for the artwork 'Mona Lisa'.
SELECT SUM(s.total_amount) AS total_sales_amount
FROM sales s
    JOIN artworks a ON s.artwork_id = a.artwork_id
WHERE a.title = 'Mona Lisa';

-- 4. Write a query to extract the 
-- year from the sale date of 'Guernica'.

select DATEPART(YEAR,sale_date) as sale_year
from sales s
    join artworks a on s.artwork_id = a.artwork_id
WHERE a.title = 'Guernica'

-- Section 2
-- 5. Write a query to find the artworks that have 
-- the highest sale total for each genre.

SELECT genre, SUM(total_amount) as totalAMount
from artworks a
    join sales s on s.artwork_id = a.artwork_id
GROUP by genre;

-- 6. Write a query to rank artists by their total sales 
-- amount and display the top 3 artists.

WITH
    artistsales
    AS
    (
        SELECT a.artist_id, a.name, SUM(s.total_amount) AS total_sales
        FROM artists a
            JOIN artworks ar ON a.artist_id = ar.artist_id
            JOIN sales s ON ar.artwork_id = s.artwork_id
        GROUP BY a.artist_id, a.name
    )
SELECT name, total_sales,
    RANK() OVER (ORDER BY total_sales DESC) AS artist_rank
FROM artistsales;

-- 7. Write a query to display artists who have
--  artworks in multiple genres.

SELECT a.name, aw.genre
from artists a
    join artworks aw on a.artist_id = aw.artist_id
GROUP by aw.genre,a.name
HAVING COUNT(distinct aw.genre) > 1;


-- 8. Write a query to find the 
-- average price of artworks for each artist.
select name, aw.artwork_id , AVG(aw.price) as AvgArtworkPrice
from artists a
    join artworks aw on aw.artist_id = a.artist_id
group by name,aw.artwork_id;

-- 9. Write a query to create a non-clustered index on the 
-- `sales` table to improve query performance for queries filtering by `artwork_id`

CREATE NONCLUSTERED INDEX idx_sales_artwork_id ON sales (artwork_id);

-- 10. Write a query to find the artists who have sold more 
-- artworks than the average number of artworks sold per artist.


WITH
    artist_sales
    AS
    (
        SELECT a.artist_id, a.name, COUNT(s.sale_id) AS artworks_sold
        FROM artists a
            JOIN artworks ar ON a.artist_id = ar.artist_id
            JOIN sales s ON ar.artwork_id = s.artwork_id
        GROUP BY a.artist_id, a.name
    )
,
    avg_artworks_sold
    AS
    (
        SELECT AVG(artworks_sold) AS avg_artworks_sold
        FROM artist_sales
    )
SELECT name
FROM artist_sales
WHERE artworks_sold > (SELECT avg_artworks_sold
FROM avg_artworks_sold);


-- 11. Write a query to find the artists who have 
-- created artworks in both 'Cubism' and 'Surrealism' genres.

SELECT a.name
from artists a
    join artworks aw on aw.artist_id = a.artist_id
where genre in ('Cubism','Surrealism')
GROUP by name
having COUNT(distinct genre) > 1


-- 12. Write a query to display artists whose birth year is earlier 
-- than the average birth year of artists from their country.

WITH
    countryAvgbirth_year
    AS
    (
        SELECT country, AVG(birth_year) AS avg_birth_year
        FROM artists
        GROUP BY country
    )
SELECT a.name, a.birth_year
FROM artists a
    JOIN countryAvgbirth_year c ON a.country = c.country
WHERE a.birth_year < c.avg_birth_year;


-- 13. Write a query to find the artworks that have
--  been sold in both January and February 2024.

SELECT aw.artwork_id
from artworks aw
    join sales s on aw.artwork_id = s.artwork_id
WHERE sale_date BETWEEN '2024-01-15' AND '2024-02-10'


-- 14. Write a query to calculate the price of
--  'Starry Night' plus 10% tax.

select title, price, price * 1.1 as AfterTax
from artworks
WHERE title = 'Starry Night'


-- 15. Write a query to display the artists whose average artwork price is
--  higher than every artwork price in the 'Renaissance' genre.

WITH
    artistAvgPrice
    AS
    (
        SELECT a.name, AVG(aw.price) AS avgArtworkPrice
        FROM artists a
            JOIN artworks aw ON a.artist_id = aw.artist_id
        GROUP BY a.name
    )
,
    renaissance_prices
    AS
    (
        SELECT price
        FROM artworks
        WHERE genre = 'Renaissance'
    )
SELECT avp.name
FROM artistAvgPrice avp
WHERE avp.avgArtworkPrice > (SELECT MAX(price)
FROM renaissance_prices);


-- Section 3

-- 16. Write a query to find artworks that have a higher price
-- than the average price of artworks by the same artist.

WITH
    artistAvgPrice
    AS
    (
        SELECT a.artist_id, AVG(aw.price) AS avgArtPrice
        FROM artists a
            JOIN artworks aw ON a.artist_id = aw.artist_id
        GROUP BY a.artist_id
    )
SELECT aw.title, aw.price
FROM artworks aw
    JOIN artistAvgPrice ap ON aw.artist_id = ap.artist_id
WHERE aw.price > ap.avgArtPrice;

-- 17. Write a query to find the average price of artworks for each artist and only
--  include artists whose average artwork price is higher than the overall average artwork price.

WITH
    artisAvgPrice
    AS
    (
        SELECT a.name, AVG(ar.price) AS avgArtPrice
        FROM artists a
            JOIN artworks ar ON a.artist_id = ar.artist_id
        GROUP BY a.name
    )
,
    overall_avg_price
    AS
    (
        SELECT AVG(price) AS allAvgPrice
        FROM artworks
    )
SELECT name, avgArtPrice
FROM artisAvgPrice
WHERE avgArtPrice > (SELECT allAvgPrice
FROM overall_avg_price);


-- 18. Write a query to
-- create a view that shows artists who have 
-- created artworks in multiple genres.

GO
create view artistWithMultipleGenre
AS
    (
    SELECT a.artist_id, a.name
    FROM artists a
        JOIN artworks aw ON a.artist_id = aw.artist_id
    GROUP BY a.artist_id, a.name
    having COUNT(distinct aw.genre) >  1
)
GO

select *
from artistWithMultipleGenre

-- Section 4

-- 19. Write a query to convert the artists and
--  their artworks into JSON format.


select *
from artists
select *
from artworks

select
    a.artist_id
    name ,
    country,
    birth_year
from artists a
for JSON PATH

    -- 20. Write a query to export the artists
    --  and their artworks into XML format.

    SELECT
        a.artist_id AS "@artist_id",
        a.name AS "name",
        a.country AS "country",
        a.birth_year AS "birth_year",
        (
        SELECT
            aw.artwork_id AS "@artwork_id",
            aw.title AS "title",
            aw.genre AS "genre",
            aw.price AS "price"
        FROM artworks aw
        WHERE aw.artist_id = a.artist_id
        FOR XML PATH('artwork'), TYPE
      )
    FROM artists a
    FOR XML PATH('artist'), ROOT('artists');

        -- Section 5
        -- 21.
        -- Create a trigger to log changes to the `artworks` table into an `artworks_log` 
        -- table, capturing the `artwork_id`, `title`, and a change description.




        -- 22.  Create a scalar function to calculate the average
        --  sales amount for artworks in a given genre and write a query to use this
        -- function for 'Impressionism'.

        GO
        CREATE FUNCTION avgSalesGenre(@genre VARCHAR(50))
        RETURNS DECIMAL
        (10, 2)
        AS
        BEGIN
            RETURN (
            SELECT AVG(total_amount) as AvgTotalAmount
            FROM sales s
                JOIN artworks a ON s.artwork_id = a.artwork_id
            WHERE a.genre = @genre
            );
        END;
        GO
        SELECT avgSalesGenre ('Impressionism')

        -- 23.
        -- Create a stored procedure to
        -- add a new sale and
        -- update the total sales for the artwork
        -- . Ensure the quantity is positive, and
        -- use transactions
        -- to maintain data integrity.
        GO
        CREATE PROCEDURE addSale(
  p_artwork_id INT,
  p_sale_date DATE,
  p_quantity INT,
  p_total_amount DECIMAL
        (10, 2)
)
AS
        BEGIN
    START TRANSACTION;

        INSERT INTO sales
            (artwork_id, sale_date, quantity, total_amount)
        VALUES
            (p_artwork_id, p_sale_date, p_quantity, p_total_amount);

        COMMIT;
        END;
GO

        exec addSale
        (1, '2024-05-01', 1, 1200000.00);

        -- 24. Create a multi-statement table-valued function
        --         (MTVF) to
        --         return the
        --         total quantity sold for each genre and
        --         use it
        --         in a query to display the results.

GO
        CREATE FUNCTION totalQuantityGenre()
RETURNS TABLE (
            genre VARCHAR(50),
            total_quantity INT
)
AS
        BEGIN
            RETURN (
            SELECT a.genre, SUM(s.quantity) AS total_quantity
            FROM artworks a
                JOIN sales s ON a.artwork_id = s.artwork_id
            GROUP BY a.genre
            )
        END;
        GO

        SELECT *
        FROM totalQuantityGenre();

        -- 25. Write a query to
        -- create an NTILE distribution of artists based on 
        -- their total sales, divided into 4 tiles.
        WITH
            artistSales
            AS
            (
                SELECT a.name, SUM(s.total_amount) AS totalSales
                FROM artists a
                    JOIN artworks aw ON a.artist_id = aw.artist_id
                    JOIN sales s ON aw.artwork_id = s.artwork_id
                GROUP BY a.name
            )
        SELECT name, totalSales,
            NTILE(4) OVER (ORDER BY totalSales DESC) AS salesTiles
        FROM artistSales;



-- 26





