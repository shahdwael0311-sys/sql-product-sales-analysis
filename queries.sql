-- ============================================
-- Task 5: SQL-Based Analysis of Product Sales
-- Database: Chinook (SQLite)
-- ============================================


-- ============================================
-- SECTION A: PRODUCT SALES
-- ============================================

-- Query 1: Top 10 best-selling tracks by revenue (uses JOINs)
SELECT t.Name AS Track,
       ar.Name AS Artist,
       SUM(il.Quantity) AS Units_Sold,
       ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS Revenue
FROM InvoiceLine il
JOIN Track t   ON il.TrackId = t.TrackId
JOIN Album al  ON t.AlbumId = al.AlbumId
JOIN Artist ar ON al.ArtistId = ar.ArtistId
GROUP BY t.TrackId
ORDER BY Revenue DESC, Units_Sold DESC
LIMIT 10;


-- ============================================
-- SECTION B: REVENUE PER REGION
-- ============================================

-- Query 2: Revenue per country
SELECT BillingCountry AS Country,
       COUNT(InvoiceId) AS Total_Orders,
       ROUND(SUM(Total), 2) AS Revenue
FROM Invoice
GROUP BY BillingCountry
ORDER BY Revenue DESC;

-- Query 3: Total revenue (validation check)
-- The sum of Query 2's Revenue column should equal this number
SELECT ROUND(SUM(Total), 2) AS Total_Revenue
FROM Invoice;


-- ============================================
-- SECTION C: MONTHLY PERFORMANCE
-- ============================================

-- Query 4: Monthly performance (orders and revenue)
SELECT strftime('%Y-%m', InvoiceDate) AS Month,
       COUNT(InvoiceId) AS Orders,
       ROUND(SUM(Total), 2) AS Revenue
FROM Invoice
GROUP BY Month
ORDER BY Month;

-- Query 5: Top 3 strongest months by revenue
SELECT strftime('%Y-%m', InvoiceDate) AS Month,
       ROUND(SUM(Total), 2) AS Revenue
FROM Invoice
GROUP BY Month
ORDER BY Revenue DESC
LIMIT 3;

-- Query 6: Top 3 weakest months by revenue
SELECT strftime('%Y-%m', InvoiceDate) AS Month,
       ROUND(SUM(Total), 2) AS Revenue
FROM Invoice
GROUP BY Month
ORDER BY Revenue ASC
LIMIT 3;


-- ============================================
-- SECTION D: REVENUE BY GENRE AND CUSTOMERS
-- ============================================

-- Query 7: Revenue by genre (uses JOINs)
SELECT g.Name AS Genre,
       ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS Revenue
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name
ORDER BY Revenue DESC;

-- Query 8: Top 5 customers overall
SELECT c.FirstName || ' ' || c.LastName AS Customer,
       c.Country,
       ROUND(SUM(i.Total), 2) AS Spent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY Spent DESC
LIMIT 5;


-- ============================================
-- SECTION E: BONUS - WINDOW FUNCTIONS
-- ============================================

-- Query 9 (Bonus): Top 3 customers in each country using RANK()
SELECT * FROM (
    SELECT c.Country,
           c.FirstName || ' ' || c.LastName AS Customer,
           ROUND(SUM(i.Total), 2) AS Spent,
           RANK() OVER (PARTITION BY c.Country ORDER BY SUM(i.Total) DESC) AS Rnk
    FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId
)
WHERE Rnk <= 3;

-- Query 10 (Bonus): Month-over-month revenue change using LAG()
WITH monthly AS (
    SELECT strftime('%Y-%m', InvoiceDate) AS Month,
           SUM(Total) AS Revenue
    FROM Invoice
    GROUP BY Month
)
SELECT Month,
       ROUND(Revenue, 2) AS Revenue,
       ROUND(Revenue - LAG(Revenue) OVER (ORDER BY Month), 2) AS Change_vs_Prev_Month
FROM monthly;