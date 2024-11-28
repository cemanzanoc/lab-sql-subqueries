-- Use this 'sakila' Database
USE sakila;
SELECT * FROM inventory;
-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT 
	f.title,
    f.film_id,
    COUNT(i.film_id) AS number_of_copies
FROM film AS f
JOIN inventory AS i ON i.film_id=f.film_id
WHERE f.title = "Hunchback Impossible"
GROUP BY f.title, f.film_id;
-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT 
    title,
    length
FROM film
GROUP BY title, length
HAVING length > (SELECT ROUND(AVG(length),2) FROM film)
ORDER BY length;
-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT
    CONCAT(a.first_name,' ',a.last_name) AS actor
FROM
	actor AS a
WHERE a.actor_id IN(
	SELECT fa.actor_id
    FROM film_actor AS fa
    JOIN film AS f ON fa.film_id=f.film_id
	WHERE f.title= "Alone Trip"
);
-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT DISTINCT
    f.title AS titles_for_family
FROM film AS f
WHERE f.film_id IN (
    SELECT fc.film_id
    FROM film_category AS fc
    JOIN category AS c ON fc.category_id = c.category_id
    WHERE c.name IN ('Family', 'Children')
);
-- 5.Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
-- Using joints
SELECT 
	CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    c.email,
    co.country
FROM customer AS c
JOIN address AS a ON c.address_id=a.address_id
JOIN city AS ci ON a.city_id=ci.city_id
JOIN country AS co ON ci.country_id=co.country_id
WHERE co.country='Canada';
-- Using subqueries
SELECT 
	CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    c.email
FROM customer AS c
WHERE address_id IN (
	SELECT a.address_id
    FROM address AS a
    JOIN city AS ci ON a.city_id=ci.city_id
    JOIN country AS co ON ci.country_id=co.country_id
    WHERE co.country='Canada'
);
-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
    f.title
FROM film AS f
JOIN film_actor AS fa ON f.film_id = fa.film_id
JOIN actor AS a ON fa.actor_id = a.actor_id
WHERE fa.actor_id IN (
    SELECT
        actor_id
    FROM (
        SELECT
            actor_id,
            COUNT(film_id) AS film_count
        FROM
            film_actor
        GROUP BY
            actor_id
    ) AS counts
    WHERE film_count = (
        SELECT MAX(film_count) 
        FROM ( 
            SELECT COUNT(film_id) AS film_count 
            FROM film_actor 
            GROUP BY actor_id 
        ) AS subquery 
    )
)
ORDER BY actor_name, f.title;
-- Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT
    f.title AS titles,
    SUM(p.amount) AS total_amount
FROM film AS f
JOIN inventory AS i ON f.film_id = i.film_id
JOIN rental AS r ON i.inventory_id = r.inventory_id
JOIN payment AS p ON p.rental_id = r.rental_id
WHERE r.customer_id = (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    HAVING SUM(amount) = (
        SELECT MAX(total_payment)
        FROM ( 
            SELECT SUM(amount) AS total_payment
            FROM payment
            GROUP BY customer_id
        ) AS subquery
    )
)
GROUP BY f.title
ORDER BY total_amount DESC;
-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
SELECT 
    customer_id,
    SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(amount) AS total_spent
        FROM payment
        GROUP BY customer_id
    ) AS subquery
);