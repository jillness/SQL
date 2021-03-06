USE sakila;


-- 1a. Display the first and last names of all actors from the table actor. 
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. 
SELECT CONCAT(first_name, '  ' , last_name) AS ActorName FROM actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor WHERE last_name LIKE "%LI%" ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country WHERE country IN ("Afghanistan", "Bangladesh", "China");


-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(30) AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor
MODIFY COLUMN middle_name BLOB;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor
DROP COLUMN middle_name;

SELECT * FROM actor;


-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) 
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) 
FROM actor
GROUP BY last_name
HAVING COUNT(*) >=2;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
	SET first_name = 'HARPO'
	WHERE first_name = 'GROUCHO'  AND last_name = 'WILLIAMS';

-- 4d. Write a single SQL Query to change all entries in the column that match "HARPO" to "GROUCHO" and those matching "GROUCHO" (before running  the query) to "MUCHO GROUCHO"
SELECT * FROM actor WHERE first_name = "HARPO" OR first_name = "GROUCHO";


UPDATE actor SET 
	first_name = CASE 
						WHEN actor_id IN (SELECT actor_id FROM actor WHERE first_name = "HARPO") THEN 'GROUCHO'
						WHEN actor_id IN (SELECT actor_id FROM actor WHERE first_name = "GROUCHO") THEN 'GROUCHO MUCHO'
						ELSE first_name
						END;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it? 
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT a.address, s.first_name, s.last_name
FROM address a
JOIN staff s
ON a.address_id = s.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. 
SELECT s.first_name, s.last_name, s.staff_id, SUM(p.amount) as total_rung_up
FROM staff s
RIGHT JOIN payment p
ON s.staff_id = p.staff_id
WHERE p.payment_date LIKE '2005-08%'
GROUP BY staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT f.title, COUNT(a.actor_id)
FROM film f
INNER JOIN film_actor a
ON f.film_id = a.film_id
GROUP BY a.actor_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory_id) FROM inventory WHERE film_id IN (SELECT film_id FROM film WHERE title = 'HUNCHBACK IMPOSSIBLE');

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) as total_paid
FROM customer c
JOIN  payment p
ON c.customer_id = p.customer_id
GROUP BY last_name, first_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- 		Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. 
SELECT title FROM film WHERE title LIKE 'K%' OR 'Q%' AND language_id = 1;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor WHERE actor_id IN (SELECT actor_id FROM film_actor WHERE film_id = (SELECT film_id FROM film WHERE title = 'ALONE TRIP'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c.email, c.first_name, c.last_name
FROM customer c
JOIN address a
ON a.address_id = c.address_id
WHERE c.address_id IN (
SELECT address_id FROM address WHERE city_id IN (
SELECT city_id FROM city WHERE country_id = (
SELECT country_id FROM country WHERE country = 'Canada')));


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT title FROM film WHERE film_id IN (
SELECT film_id FROM film_category WHERE category_id = (SELECT category_id FROM category WHERE name = 'Family')
);

-- 7e. Display the most frequently rented movies in descending order.

-- Not entirely sure where to find this information, what is the difference between inventory_id and rental_id?

SELECT *, COUNT(inventory_id) FROM rental
GROUP BY inventory_id;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT p.staff_id, SUM(p.amount), s.first_name, s.last_name, s.store_id FROM payment p
LEFT JOIN staff s 
ON p.staff_id =  s.staff_id
GROUP BY staff_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT city FROM city WHERE city_id IN (
SELECT city_id FROM address WHERE address_id IN (
SELECT address_id FROM store));
-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
-- 8b. How would you display the view that you created in 8a?
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.