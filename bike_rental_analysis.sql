/*  
===============================================================
    BIKE RENTAL DATA ANALYSIS – SQL CASE STUDY
    Author: Martinraj Nadar
    Description:
        This case study analyzes bike rental data to extract 
        business insights. The queries are categorized into 
        Basic, Intermediate, and Advanced analysis levels.
===============================================================
*/

/* ============================================================
   BASIC ANALYSIS
============================================================ */

-- 1. List of all bikes currently available for rent
SELECT *
FROM bikes
WHERE status = 'Available';

-- 2. Total number of rentals done by each customer
SELECT customer_id, COUNT(*) AS total_rentals
FROM rentals
GROUP BY customer_id;

-- 3. Total revenue earned from each bike
SELECT bike_id, SUM(amount_paid) AS total_revenue
FROM rentals
GROUP BY bike_id;

-- 4. Rentals lasting more than 240 minutes
SELECT *
FROM rentals
WHERE TIMESTAMPDIFF(MINUTE, start_time, end_time) > 240;

-- 5. Customers who rented a bike in October 2023
SELECT DISTINCT customer_id
FROM rentals
WHERE MONTH(start_time) = 10
  AND YEAR(start_time) = 2023;


/* ============================================================
   INTERMEDIATE INSIGHTS
============================================================ */

-- 6. Top 3 customers by total spend
SELECT customer_id, SUM(amount_paid) AS total_spend
FROM rentals
GROUP BY customer_id
ORDER BY total_spend DESC
LIMIT 3;

-- 7. Average rental duration per bike category
SELECT b.category, 
       AVG(TIMESTAMPDIFF(MINUTE, r.start_time, r.end_time)) AS avg_duration_minutes
FROM rentals r
JOIN bikes b ON r.bike_id = b.bike_id
GROUP BY b.category;

-- 8. Customers who rented bikes but never had a membership
SELECT DISTINCT r.customer_id
FROM rentals r
JOIN customers c ON r.customer_id = c.customer_id
WHERE c.membership_status = 'None';

-- 9. Monthly rental revenue trend for 2023
SELECT MONTH(start_time) AS month, SUM(amount_paid) AS monthly_revenue
FROM rentals
WHERE YEAR(start_time) = 2023
GROUP BY MONTH(start_time)
ORDER BY month;

-- 10. Rental count per bike with its current status
SELECT b.bike_id, b.status, COUNT(r.rental_id) AS rental_count
FROM bikes b
LEFT JOIN rentals r ON b.bike_id = r.bike_id
GROUP BY b.bike_id, b.status;


/* ============================================================
   ADVANCED ANALYSIS
============================================================ */

-- 11. Customers who rented all four categories (Mountain, Road, Hybrid, Electric)
SELECT customer_id
FROM rentals r
JOIN bikes b ON r.bike_id = b.bike_id
GROUP BY customer_id
HAVING COUNT(DISTINCT b.category) = 4;

-- 12. Most frequently rented bike model per customer
SELECT customer_id, model
FROM (
    SELECT r.customer_id, b.model,
           ROW_NUMBER() OVER (PARTITION BY r.customer_id ORDER BY COUNT(*) DESC) AS rn
    FROM rentals r
    JOIN bikes b ON r.bike_id = b.bike_id
    GROUP BY r.customer_id, b.model
) t
WHERE rn = 1;

-- 13. Customers whose rental payments exceeded membership payments
SELECT customer_id
FROM (
    SELECT p.customer_id,
           SUM(CASE WHEN p.payment_type = 'Rental' THEN p.amount ELSE 0 END) AS rental_total,
           SUM(CASE WHEN p.payment_type = 'Membership' THEN p.amount ELSE 0 END) AS membership_total
    FROM payments p
    GROUP BY p.customer_id
) totals
WHERE rental_total > membership_total;
