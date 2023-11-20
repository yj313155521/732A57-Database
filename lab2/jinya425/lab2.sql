/*Lab 2, Shipeng Liu (shili506) and Jin Yan (jinya425)*/
SOURCE company_schema.sql;
SOURCE company_data.sql;

/*Question 1: List all employees, i.e., all tuples in the jbemployee relation.*/
SELECT *
FROM jbemployee;

/*Question 2: List the name of all departments in alphabetical order. Note: by “name” 
we mean the name attribute in the jbdept relation.*/
SELECT name
FROM jbdept
ORDER BY name;

/*Question 3: What parts are not in store? Note that such parts have the value 0 (zero)
for the qoh attribute (qoh = quantity on hand).*/
SELECT id, name
FROM jbparts
WHERE  qoh = 0;

/*Question 4: List all employees who have a salary between 9000 (included) and 
10000 (included)?*/
SELECT id, name
FROM jbemployee
WHERE 9000 < salary <10000;

/*Question 5: List all employees together with the age they had when they started 
working? Hint: use the startyear attribute and calculate the age in the 
SELECT clause.*/
SELECT id, name, startyear - birthyear
FROM jbemployee;

/*Question 6: List all employees who have a last name ending with “son”.*/
SELECT *
FROM jbemployee
WHERE name LIKE '%son';

/*Question 7: Which items (note items, not parts) have been delivered by a supplier 
called Fisher-Price? Formulate this query by using a subquery in the 
WHERE clause.*/
SELECT id, name
FROM jbitem
WHERE supplier = (SELECT id
FROM jbsupplier
WHERE name = 'Fisher-Price' );

/*Question 8: Formulate the same query as above, but without a subquery.*/
SELECT items.id,items.name
FROM jbitem AS items, jbsupplier AS supplier
WHERE items.supplier = supplier.id AND supplier.name = 'Fisher-Price';

/*Question 9: List all cities that have suppliers located in them. Formulate this query 
using a subquery in the WHERE clause.*/
SELECT id, name
FROM jbcity
WHERE id IN (SELECT city FROM jbsupplier);

/*Question 10: What is the name and the color of the parts that are heavier than a card 
reader? Formulate this query using a subquery in the WHERE clause. 
(The query must not contain the weight of the card reader as a constant;
instead, the weight has to be retrieved within the query.)*/
SELECT name, color
FROM jbparts
WHERE weight > (SELECT weight FROM jbparts WHERE name = 'card reader');

/*Question 11: Formulate the same query as above, but without a subquery. Again, the 
query must not contain the weight of the card reader as a constant.*/
SELECT One.name, One.color
FROM jbparts One, jbparts Two
WHERE Two.name = 'card reader' AND One.weight > Two.weight;

/*Question 12: What is the average weight of all black parts?*/
SELECT AVG(weight)
FROM jbparts
WHERE color = 'black';

/*Question 13: For every supplier in Massachusetts (“Mass”), retrieve the name and the
total weight of all parts that the supplier has delivered? Do not forget to
take the quantity of delivered parts into account. Note that one row 
should be returned for each supplier.*/
SELECT supplier, SUM(quan * weight)
FROM (SELECT * 
		FROM jbsupply 
        WHERE supplier IN (
							SELECT id 
							FROM jbsupplier 
                            WHERE city IN (
											SELECT id 
											FROM jbcity 
											WHERE state ='Mass'))) AS One INNER JOIN jbparts AS Two ON One.part = Two.id

GROUP BY supplier;

/*Question 14: Create a new relation with the same attributes as the jbitems relation by 
using the CREATE TABLE command where you define every attribute 
explicitly (i.e., not as a copy of another table). Then, populate this new 
relation with all items that cost less than the average price for all items. 
Remember to define the primary key and foreign keys in your table!*/
CREATE TABLE NEW_TABLE(
			id integer,
            name VARCHAR(50),
            dept integer,
            price integer,
            qoh integer,
            supplier integer,
            
            constraint primary key (id),
            
            constraint FOREIGN KEY (id) references jbitem (id)
            );
            
INSERT INTO NEW_TABLE
SELECT *
FROM jbitem
WHERE price < (SELECT AVG(price) FROM jbitem);

/*Question 15: Create a view that contains the items that cost less than the average 
price for items.*/
CREATE VIEW view_new_table AS
SELECT *
FROM NEW_TABLE;

/* Question 16: What is the difference between a table and a view? One is static and the
other is dynamic. Which is which and what do we mean by static respectively dynamic?*/
/* Answer: Table is tatic and view is dynamic. Static means if we get an table with a SQL statement, it would be fixed and would not be changed.
By comparison, view is a visual table, which means it only represents the results of stored query on one or more tables used.*/

/* Question 17: Create a view that calculates the total cost of each debit, by considering 
price and quantity of each bought item. (To be used for charging 
customer accounts). The view should contain the sale identifier (debit) 
and the total cost. In the query that defines the view, capture the join 
condition in the WHERE clause (i.e., do not capture the join in the 
FROM clause by using keywords inner join, right join or left join). */
CREATE VIEW view_cost_of_debits AS
SELECT debit, SUM(quantity * price)
FROM jbsale, jbitem
WHERE item = id
GROUP BY debit;

/* Question 18: Do the same as in the previous point, but now capture the join conditions
in the FROM clause by using only left, right or inner joins. Hence, the 
WHERE clause must not contain any join condition in this case. Motivate
why you use type of join you do (left, right or inner), and why this is the 
correct one (in contrast to the other types of joins). */
CREATE VIEW view_cost_of_debits_2 AS
SELECT debit, SUM(quantity * price)
FROM jbsale INNER JOIN  jbitem ON item = id
GROUP BY debit;
/* Answer: “Left join” means we need to go throught the left table one row by one row and at the same time searching for the rows in the right table that can satisfy the contition. 
If there is no appropriate rows in the right table, the corresponding locations in the new combined table would be NULL. For "right join", basically
it is in the same case. By comparision, when we use  "inner join", the total number of the new combine table would be n*m and after filtering some rows by using the condition, the final
table is what I really need.*/

set SQL_SAFE_UPDATES=0;

/* Question 19 (a): Remove all suppliers in Los Angeles from the jbsupplier table. This will not work right away. Instead, you will receive an error with error code 23000 which you will have to solve by deleting some other related tuples. However, do not delete more tuples from other tables 
than necessary, and do not change the structure of the tables (i.e., do not remove foreign keys). Also, you are only allowed to use “Los Angeles” as a constant in your queries, not “199” or “900”. */
DELETE FROM NEW_TABLE
WHERE id in (SELECT id FROM jbitem
WHERE supplier in  (SELECT id FROM jbsupplier WHERE city in (SELECT id FROM jbcity WHERE name = "Los Angeles")));

DELETE FROM jbsale
WHERE item in (SELECT id FROM jbitem
WHERE supplier in  (SELECT id FROM jbsupplier WHERE city in (SELECT id FROM jbcity WHERE name = "Los Angeles")));

DELETE FROM jbitem
WHERE supplier = (SELECT id FROM jbsupplier WHERE city in (SELECT id FROM jbcity WHERE name = "Los Angeles"));

DELETE FROM jbsupplier
WHERE city in (SELECT id
				FROM jbcity
				WHERE name = "Los Angeles");

/* Question 19 (b): Explain what you did and why./*
/* Answer: When we want to delet certain rows in jbsupplier, it failed. This is because the rows are the references of certain rows of jbitems. In order to deletion, we have to remove 
the certain rows in jbitems. However, there are the same questions for jbitems. This way, we have to delete the certain rows in jbsale and NEW_TABLE to make sure
that when we delete certain rows in jbitem, there is no conflicts./*

/* Question 20: Now, the employee also wants to include the suppliers that have 
delivered some items, although for whom no items have been sold so 
far. In other words, he wants to list all suppliers that have supplied any 
item, as well as the number of these items that have been sold. Help 
him! Drop and redefine the jbsale_supply view to also consider suppliers
that have delivered items that have never been sold. */
# the following is to redefine the jbsale_supply view
CREATE VIEW jbsale_supply  AS
SELECT ID_S, Name_S, ID_I, Name_I, quantity "Quantity_sold"
FROM (SELECT jbsupplier.id "ID_S", jbsupplier.name "Name_S", jbitem.id "ID_I", jbitem.name "Name_I"
		FROM jbsupplier, jbitem
        WHERE jbsupplier.id = jbitem.supplier) AS One LEFT JOIN jbsale ON One.ID_I = jbsale.item;

