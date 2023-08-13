-- Show the employee's first_name and last_name, a "num_orders" column with a count of the orders taken, and a column called "Shipped" that displays "On Time" if the order shipped on time and "Late" if the order shipped late.
-- Order by employee last_name, then by first_name, and then descending by number of orders.

SELECT 
	employees.first_name,
    employees.last_name,
    COUNT(*) AS num_orders,
    (CASE
      WHEN shipped_date < required_date THEN 'On Time'
      ELSE 'Late'
      END) AS shipped
FROM employees
INNER JOIN orders ON employees.employee_id = orders.employee_id
GROUP BY first_name,last_name,shipped
ORDER BY last_name,first_name,num_orders DESC;

-- Show the ProductName, CompanyName, CategoryName from the products, suppliers, and categories table

SELECT 
	product_name,
    company_name,
    category_name
FROM categories
INNER JOIN products ON products.category_id = categories.category_id
INNER JOIN suppliers ON suppliers.supplier_id = products.supplier_id;

-- Show the category_name and the average product unit price for each category rounded to 2 decimal places.

SELECT 
	category_name,
    ROUND(AVG(unit_price),2) as avg_unit_price
FROM products
INNER JOIN categories ON categories.category_id = products.category_id
GROUP BY category_name;

-- Show the city, company_name, contact_name from the customers and suppliers table merged together.
-- Create a column which contains 'customers' or 'suppliers' depending on the table it came from.

SELECT 
	city,
    company_name,
    contact_name,
    'customers'
FROM customers
UNION ALL
SELECT 
	city,
    company_name,
    contact_name,
    'suppliers'
FROM suppliers

-- Show the category_name and description from the categories table sorted by category_name.
 
SELECT 
	category_name,
    description
FROM categories
order by category_name;

-- Show all the contact_name, address, city of all customers which are not from 'Germany', 'Mexico', 'Spain'

SELECT 
	contact_name,
    address,
    city
FROM customers
WHERE country NOT IN ('Germany', 'Mexico', 'Spain');

-- Show order_date, shipped_date, customer_id, Freight of all orders placed on 2018 Feb 26

SELEct
	order_date,
    shipped_date,
    customer_id,
    freight
FROM orders
WHERE order_date = '2018-02-26' ;

-- Show the employee_id, order_id, customer_id, required_date, shipped_date from all orders shipped later than the required date

SELECT 
	employee_id,
    order_id,
    customer_id,
    required_date,
    shipped_date
FROM orders
WHERE required_date < shipped_date;

-- Show all the even numbered Order_id from the orders table

SELECT
	order_id
FROM orders
WHERE order_id % 2 = 0;

--Show the city, company_name, contact_name of all customers from cities which contains the letter 'L' in the city name, sorted by contact_name

SELECT 
	city,
    company_name,
    contact_name
FROM customers
WHERE city LIKE '%L%'
ORDER BY contact_name;

-- Show the company_name, contact_name, fax number of all customers that has a fax number. (not null)

SELECT 
	company_name,
    contact_name,
    fax
FROM customers
WHERE fax is not null;

-- Show the first_name, last_name. hire_date of the most recently hired employee.

SELECT
	first_name,
    last_name,
    hire_date
FROM employees
ORDER BY hire_date DEsc
LIMIT 1;

-- Show the average unit price rounded to 2 decimal places, the total units in stock, total discontinued products from the products table.

SELECT 
	ROUND(AVG(unit_price),2),
    SUM(units_in_stock),
    SUM(discontinued)
FROM products;
