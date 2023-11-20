USE databasetech;

# 9. List all cities that have suppliers located in them. Formulate this query 
# using a subquery in the WHERE clause.
SELECT c.name FROM jbcity c
WHERE c.id IN (SELECT DISTINCT(city) FROM jbsupplier);

# 10. What is the name and the color of the parts that are heavier than a card
# reader? Formulate this query using a subquery in the WHERE clause.
# (The query must not contain the weight of the card reader as a constant;
# instead, the weight has to be retrieved within the query.)
SELECT p.name , p.color FROM jbparts p
WHERE weight > (SELECT weight FROM jbparts j
	WHERE j.name = "card reader");

# 11. Formulate the same query as above, but without a subquery. Again, the
# query must not contain the weight of the card reader as a constant.
SELECT p1.name , p1.color FROM jbparts p1,jbparts p2
WHERE p2.name="card reader" AND p1.weight>p2.weight;# Use cross join here

# 12. What is the average weight of all black parts?
SELECT AVG(weight) FROM jbparts
WHERE color = "black";

# 13. For every supplier in Massachusetts (“Mass”), retrieve the name and the
# total weight of all parts that the supplier has delivered? Do not forget to
# take the quantity of delivered parts into account. Note that one row
# should be returned for each supplier.
SELECT q.name , SUM(p.weight*q.quan) AS totalWeight FROM 
(SELECT se.name, s.part,s.quan FROM jbsupplier se
JOIN jbsupply s ON se.id=s.supplier
WHERE se.city IN (SELECT id FROM jbcity WHERE state="Mass")) q
JOIN jbparts p ON q.part=p.id
GROUP BY q.name;

# 14. Create a new relation with the same attributes as the jbitems relation by
# using the CREATE TABLE command where you define every attribute
# explicitly (i.e., not as a copy of another table). Then, populate this new
# relation with all items that cost less than the average price for all items.
# Remember to define the primary key and foreign keys in your table!
CREATE TABLE IF NOT EXISTS jbiteminfo (
	id INT PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    debt INT,
    price LONG,
    qoh LONG,
    supplier INT NOT NULL,
    FOREIGN KEY(supplier) REFERENCES jbsupplier(id) ON DELETE CASCADE
    );
    
INSERT INTO jbiteminfo
SELECT * FROM jbitem it WHERE it.price < (SELECT AVG(price) FROM jbitem);

SELECT * FROM jbiteminfo;

# 15. Create a view that contains the items that cost less than the average
# price for items.
CREATE VIEW jbiteminfo_view AS
SELECT * FROM jbitem WHERE price < (SELECT AVG(price) FROM jbitem);

SELECT * FROM jbiteminfo_view;

# 16. What is the difference between a table and a view? One is static and the
# other is dynamic. Which is which and what do we mean by static
# respectively dynamic?

-- Table is static, it store the static data and must hold the persistancy. Unless update the table, every query on the table shows the same data.
-- View is dynamic and is more like a query compare to a table, it doesn't store the data but show the current state every time we query the view.

# 17. Create a view that calculates the total cost of each debit, by considering
# price and quantity of each bought item. (To be used for charging
# customer accounts). The view should contain the sale identifier (debit)
# and the total cost. In the query that defines the view, capture the join
# condition in the WHERE clause (i.e., do not capture the join in the
# FROM clause by using keywords inner join, right join or left join).
CREATE VIEW debit_total_cost AS
SELECT s.debit, SUM(i.price*s.quantity) AS totalCost
FROM jbsale s,jbitem i 
WHERE s.item=i.id
GROUP BY s.debit;

SELECT * FROM debit_total_cost;

DROP VIEW IF EXISTS debit_total_cost;

# 18. Do the same as in the previous point, but now capture the join conditions
# in the FROM clause by using only left, right or inner joins. Hence, the
# WHERE clause must not contain any join condition in this case. Motivate
# why you use type of join you do (left, right or inner), and why this is the
# correct one (in contrast to the other types of joins).
CREATE VIEW debit_total_cost AS
SELECT s.debit, SUM(i.price*s.quantity) AS totalCost
FROM jbsale s
JOIN jbitem i ON s.item=i.id
GROUP BY s.debit;

SELECT * FROM debit_total_cost;

# 19. Oh no! An earthquake!
# a) Remove all suppliers in Los Angeles from the jbsupplier table. This
#    will not work right away. Instead, you will receive an error with error
#    code 23000 which you will have to solve by deleting some other 
#    related tuples. However, do not delete more tuples from other tables
#    than necessary, and do not change the structure of the tables (i.e.,
#    do not remove foreign keys). Also, you are only allowed to use “Los
#    Angeles” as a constant in your queries, not “199” or “900”.
# b) Explain what you did and why.
DELETE FROM jbsale
WHERE item IN
(SELECT id FROM jbitem
WHERE supplier IN (SELECT id FROM jbsupplier
	WHERE city IN (
		SELECT c.id FROM jbcity c 
			WHERE c.name="Los Angeles")
	)
);

DELETE FROM jbitem
WHERE supplier IN (SELECT id FROM jbsupplier
	WHERE city IN (
		SELECT c.id FROM jbcity c 
			WHERE c.name="Los Angeles")
);
            
DELETE FROM jbsupplier
WHERE city IN (SELECT c.id FROM jbcity c WHERE c.name="Los Angeles");

SELECT * FROM jbsupplier;

-- In order to delete the supplier in LA in jbsupplier, you need to delete the row corresponding to the supplier in jbitem, because a foreign key dependency on the jbsupplier table is set in jbitem.
-- Similarly, in order to delete certain rows in jbitem, you need to delete some rows in the corresponding jbitem in jbsale, because foreign key dependencies on jbitem are also set in the jbsale table.
-- In the foreign key settings of the jbitem and jbsale tables, the corresponding behavior after an item in the dependent table is deleted is not specified, so it has to be deleted recursively manually.

# 20. An employee has tried to find out which suppliers have delivered items
# that have been sold. To this end, the employee has created a view and
# a query that lists the number of items sold from a supplier.
# Now, the employee also wants to include the suppliers that have
# delivered some items, although for whom no items have been sold so
# far. In other words, he wants to list all suppliers that have supplied any
# item, as well as the number of these items that have been sold. Help
# him! Drop and redefine the jbsale_supply view to also consider suppliers
# that have delivered items that have never been sold.

CREATE VIEW jbsale_supply(supplier, item, quantity) AS
SELECT s.name, i.name, sa.quantity 
FROM jbsupplier s
JOIN jbitem i ON s.id=i.supplier
LEFT JOIN jbsale sa ON i.id=sa.item;

SELECT supplier, sum(quantity) AS sum FROM jbsale_supply
GROUP BY supplier;


