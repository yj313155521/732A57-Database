SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS ROUTE;
DROP TABLE IF EXISTS AIRPORT;

DROP TABLE IF EXISTS WEEKLY_SCHEDULE;

DROP TABLE IF EXISTS YEAR;
DROP TABLE IF EXISTS DAY;
DROP TABLE IF EXISTS FLIGHT;
DROP TABLE IF EXISTS RESERVATION;
DROP TABLE IF EXISTS CONTACT;
DROP TABLE IF EXISTS PASSENGER;
DROP TABLE IF EXISTS BOOKING;
DROP TABLE IF EXISTS CREDIT_CARD;
DROP TABLE IF EXISTS ROUTE_PRICE;
DROP TABLE IF EXISTS RESERVE;
DROP TABLE IF EXISTS BOOKED;

#-----DROP PROCEDURE-----
DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;
DROP PROCEDURE IF EXISTS addReservation;
DROP PROCEDURE IF EXISTS addPassenger;
DROP PROCEDURE IF EXISTS addContact;
DROP PROCEDURE IF EXISTS addPayment;

DROP TRIGGER IF EXISTS issue_ticketnumbers;

#-----DROP FUNCTIONS-----
DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS calculatePrice;

# 2.
SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE AIRPORT(
		CODE VARCHAR(3),
        NAME VARCHAR(30),
        COUNTRY VARCHAR(30),
        
        CONSTRAINT pk_airport PRIMARY KEY(CODE)
        );
        
CREATE TABLE ROUTE(
		ID integer,
        ARRIVAL_CODE VARCHAR(3),
        DEPARTURE_CODE VARCHAR(3),
        
        CONSTRAINT pk_route PRIMARY KEY(ID),
        CONSTRAINT fk_route_airport
				foreign key(ARRIVAL_CODE) REFERENCES AIRPORT(CODE),
                foreign key(DEPARTURE_CODE) REFERENCES AIRPORT(CODE)
		);
        
CREATE TABLE YEAR(
		YEAR INTEGER,
        PROFITFACTOR DOUBLE,
        
        CONSTRAINT pk_year PRIMARY KEY(YEAR)
        );
        
CREATE TABLE DAY(
		YEAR INTEGER,
        DAY VARCHAR(10),
        WEEKDAYFACTOR DOUBLE,
        
        CONSTRAINT pk_day PRIMARY KEY(YEAR,DAY),
        CONSTRAINT fk_day_YEAR 
				FOREIGN KEY(YEAR) REFERENCES YEAR(YEAR)
		);
        
CREATE TABLE WEEKLY_SCHEDULE(
		ID INTEGER,
        YEAR INTEGER,
        DAY VARCHAR(10),
        ROUTE_ID INTEGER,
        DEPARTURE_TIME TIME,
        
        CONSTRAINT pk_weekly_schedule PRIMARY KEY(ID),
		CONSTRAINT fk_weekly_schdule_day
				FOREIGN KEY(YEAR,DAY) REFERENCES DAY(YEAR,DAY),
		CONSTRAINT fk_weekly_schdule_route
				FOREIGN KEY(ROUTE_ID) REFERENCES ROUTE(ID)
		);
        
CREATE TABLE FLIGHT(
		FLIGHTNUMBER INTEGER,
        WEEK INTEGER,
        SCHEDULE_ID INTEGER,
        
        CONSTRAINT pk_flight PRIMARY KEY(FLIGHTNUMBER),
        CONSTRAINT fk_flight_weekly_schedule FOREIGN KEY(SCHEDULE_ID) REFERENCES WEEKLY_SCHEDULE(ID)
        );
        
CREATE TABLE PASSENGER(
		PASSPORTNUMBER INTEGER,
        NAME VARCHAR(30),
        
        CONSTRAINT pk_passenger PRIMARY KEY(PASSPORTNUMBER)
        );
        
CREATE TABLE CONTACT(
		PASSPORTNUMBER INTEGER,
        EMAIL VARCHAR(30),
        PHONENUMBER BIGINT,
        
        CONSTRAINT pk_contact PRIMARY KEY(PASSPORTNUMBER),
        CONSTRAINT fk_contact_passenger
				FOREIGN KEY(PASSPORTNUMBER) REFERENCES PASSENGER(PASSPORTNUMBER)
		);
        
CREATE TABLE RESERVATION(
		RESERVATION_NUMBER INTEGER,
        NUM_OF_PASSENGER INTEGER,
        CONTACT_ID INTEGER,
        FLIGHT_ID INTEGER,
        
        CONSTRAINT pk_reservation PRIMARY KEY(RESERVATION_NUMBER),
        CONSTRAINT fk_reservation_contact 
				FOREIGN KEY(CONTACT_ID) REFERENCES CONTACT(PASSPORTNUMBER),
		CONSTRAINT fk_reservation_FLIGHT
				FOREIGN KEY(FLIGHT_ID) REFERENCES FLIGHT(FLIGHTNUMBER)
		);
		
CREATE TABLE CREDIT_CARD(
		CREDITCARD_NUMBER BIGINT,
		CARD_HOLDER VARCHAR(30),
        
        CONSTRAINT pk_credit_card PRIMARY KEY(CREDITCARD_NUMBER)
        );
        
CREATE TABLE BOOKING(
		ID INTEGER,
        CREDITCARD_NUMBER BIGINT,
        ACTUAL_PRICE DOUBLE,
        
        CONSTRAINT pk_booking PRIMARY KEY(ID),
        CONSTRAINT fk_booking_reservation
				FOREIGN KEY(ID) REFERENCES RESERVATION(RESERVATION_NUMBER),
		CONSTRAINT fk_booking_credit_card 
				FOREIGN KEY(CREDITCARD_NUMBER) REFERENCES CREDIT_CARD(CREDITCARD_NUMBER)
		);
        
CREATE TABLE ROUTE_PRICE(
		YEAR INTEGER,
        ROUTE_ID INTEGER,
        ROUTE_PRICE DOUBLE,
        
        CONSTRAINT pk_route_price_route PRIMARY KEY(YEAR,ROUTE_ID),
		CONSTRAINT fk_route_price_route
				FOREIGN KEY(ROUTE_ID) REFERENCES ROUTE(ID)
		);
        
CREATE TABLE RESERVE(
		PASSPORTNUMBER INTEGER,
        RESERVATION_NUMBER INTEGER,
        
        CONSTRAINT pk_reserve
				PRIMARY KEY(PASSPORTNUMBER,RESERVATION_NUMBER),
		CONSTRAINT fk_reserve_passenger
				FOREIGN KEY(PASSPORTNUMBER) REFERENCES PASSENGER(PASSPORTNUMBER) ON DELETE CASCADE,
		CONSTRAINT fk_reserve_reservation
				FOREIGN KEY(RESERVATION_NUMBER) REFERENCES RESERVATION(RESERVATION_NUMBER) ON DELETE CASCADE
		);
        
CREATE TABLE BOOKED(
		BOOKING_ID INTEGER,
        PASSENGER_ID INTEGER,
        TICKET_NUMBER INTEGER,
        
        CONSTRAINT pk_booked PRIMARY KEY(BOOKING_ID,PASSENGER_ID),
        CONSTRAINT fk_booked_booking
				FOREIGN KEY(BOOKING_ID) REFERENCES BOOKING(ID),
		CONSTRAINT fk_booked_passenger
				FOREIGN KEY(PASSENGER_ID) REFERENCES PASSENGER(PASSPORTNUMBER)
		);
        


# 3.

delimiter //
CREATE PROCEDURE addYear(IN year INT,IN factor DOUBLE)
BEGIN
INSERT INTO YEAR
VALUES(year,factor);
END;
//

CREATE PROCEDURE addDay(IN year INT,IN day VARCHAR(10),IN factor DOUBLE)
BEGIN
INSERT INTO DAY
VALUES(year,day,factor);
END;
//

CREATE PROCEDURE addDestination(IN airport_code VARCHAR(3),IN name VARCHAR(30),IN country VARCHAR(30))
BEGIN
INSERT INTO AIRPORT
VALUES(airport_code,name,country);
END;
//

CREATE PROCEDURE addRoute(IN departure_airport_code VARCHAR(3),IN arrival_airport_code VARCHAR(3),IN year INT,IN routeprice DOUBLE)
BEGIN
SET @n = (SELECT COUNT(*) FROM ROUTE WHERE ARRIVAL_CODE=arrival_airport_code AND DEPARTURE_CODE=departure_airport_code);
IF @n = 0 THEN
	SET @v1 = (SELECT COUNT(*) FROM ROUTE);
    INSERT INTO ROUTE VALUES (@V1+1,arrival_airport_code,departure_airport_code);
    INSERT INTO ROUTE_PRICE VALUES (year,@V1+1,routeprice);
ELSE
	SET @v3 = (SELECT ID FROM ROUTE WHERE ARRIVAL_CODE=arrival_airport_code AND DEPARTURE_CODE=departure_airport_code);
    INSERT INTO ROUTE_PRICE VALUES (year,@V3,routeprice);
END IF;
END;
//

CREATE PROCEDURE addFlight(IN departure_airport_code VARCHAR(3),IN arrival_airport_code VARCHAR(3),IN year1 INT,IN day1 VARCHAR(10),IN _departure_time TIME)
BEGIN
	SET @route_id = (SELECT ID FROM ROUTE 
						WHERE ARRIVAL_CODE=arrival_airport_code AND
                        DEPARTURE_CODE=departure_airport_code);
	
    SET @schedule_id = (SELECT ID FROM WEEKLY_SCHEDULE			
						WHERE `YEAR`=year1 AND
						`DAY`=day1 AND 
						ROUTE_ID=@route_id AND
                        `DEPARTURE_TIME`=_departure_time);  
	IF @schedule_id IS NULL THEN
    
		SET @schedule_n = (SELECT COUNT(*) FROM WEEKLY_SCHEDULE);
		INSERT INTO WEEKLY_SCHEDULE VALUES (@schedule_n+1,year1,day1,@route_id,_departure_time);
        SET @flight_n = (SELECT COUNT(*) FROM FLIGHT);
		INSERT INTO FLIGHT SELECT @flight_n+n,n,@schedule_n+1 
							FROM (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
								  UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11
								  UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16
								  UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21
								  UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION SELECT 26
								  UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 UNION SELECT 31
								  UNION SELECT 32 UNION SELECT 33 UNION SELECT 34 UNION SELECT 35 UNION SELECT 36
								  UNION SELECT 37 UNION SELECT 38 UNION SELECT 39 UNION SELECT 40 UNION SELECT 41
								  UNION SELECT 42 UNION SELECT 43 UNION SELECT 44 UNION SELECT 45 UNION SELECT 46
								  UNION SELECT 47 UNION SELECT 48 UNION SELECT 49 UNION SELECT 50 UNION SELECT 51
								  UNION SELECT 52) numbers;
                                  
    ELSE
		SET @flight_n = (SELECT COUNT(*) FROM FLIGHT);
		INSERT INTO FLIGHT SELECT @flight_n+n,n,@schedule_id 
							FROM (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
								  UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11
								  UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16
								  UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21
								  UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION SELECT 26
								  UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 UNION SELECT 31
								  UNION SELECT 32 UNION SELECT 33 UNION SELECT 34 UNION SELECT 35 UNION SELECT 36
								  UNION SELECT 37 UNION SELECT 38 UNION SELECT 39 UNION SELECT 40 UNION SELECT 41
								  UNION SELECT 42 UNION SELECT 43 UNION SELECT 44 UNION SELECT 45 UNION SELECT 46
								  UNION SELECT 47 UNION SELECT 48 UNION SELECT 49 UNION SELECT 50 UNION SELECT 51
								  UNION SELECT 52) numbers;
	END IF;
    
END;
//


# 4.

# SET GLOBAL log_bin_trust_function_creators = 1;
//
CREATE FUNCTION calculateFreeSeats(_flightnumber INT)
	RETURNS INTEGER
BEGIN
DECLARE NUMBER1 INT;

SELECT SUM(NUM_OF_PASSENGER) INTO NUMBER1 FROM RESERVATION 
WHERE `FLIGHT_ID`=_flightnumber AND
	`RESERVATION_NUMBER` IN (SELECT `ID` FROM BOOKING);
IF NUMBER1 IS NULL THEN
	RETURN 40;
ELSE
	RETURN (40-NUMBER1);
END IF;
END;
//

CREATE FUNCTION calculatePrice(_flightnumber INT)
#	RETURNS DECIMAL(8)
	RETURNS DOUBLE
BEGIN
#DECLARE PRICE DECIMAL(8);
DECLARE PRICE DOUBLE;

SET @schedule_id = (SELECT `SCHEDULE_ID` FROM `FLIGHT`
 					WHERE `FLIGHTNUMBER` = _flightnumber);
SET @year1 :=(SELECT `YEAR` FROM `WEEKLY_SCHEDULE` 
				WHERE `ID` =@schedule_id);
SET @route_id = (SELECT `ROUTE_ID` FROM `WEEKLY_SCHEDULE`
				 WHERE `ID` = @schedule_id);
SET @route_price = (SELECT t.ROUTE_PRICE FROM `ROUTE_PRICE` t 
 					WHERE `YEAR` = @year1 AND `ROUTE_ID` = @route_id);
SET @profitfactor = (SELECT `PROFITFACTOR` FROM `YEAR`
						WHERE `YEAR` = @year1);
SET @weekdayfactor = (SELECT `WEEKDAYFACTOR` FROM `DAY`
 						WHERE `YEAR` = @year1 AND
 						`DAY` = (SELECT `DAY` FROM WEEKLY_SCHEDULE 
 								WHERE `ID` = @schedule_id));

SET @free_seats = calculateFreeSeats(_flightnumber);
SET PRICE = @route_price * @weekdayfactor * (40-@free_seats+1)/40 * @profitfactor;

RETURN ROUND(PRICE,3);
END;
//

# 5.

CREATE TRIGGER issue_ticketnumbers
BEFORE INSERT ON BOOKED
FOR EACH ROW
SET NEW.TICKET_NUMBER = rand();
//

# 6. 

CREATE PROCEDURE addReservation(IN departure_airport_code VARCHAR(3),IN arrival_airport_code VARCHAR(3),IN year1 INT,IN week1 INT,IN day1 VARCHAR(10),IN time1 TIME,IN number_of_passengers INT, OUT output_reservation_nr INT)
BEGIN

SET @route_id = (SELECT ID FROM ROUTE WHERE ARRIVAL_CODE = arrival_airport_code AND DEPARTURE_CODE = departure_airport_code);
IF @route_id IS NULL THEN
	SELECT 'There exist no flight for the given route, date and time' AS "MESSAGE";
ELSE

	SET @schedule_id=(SELECT ID FROM WEEKLY_SCHEDULE
						WHERE ROUTE_ID=@route_id AND
						YEAR=year1 AND
						DAY=day1 AND
						DEPARTURE_TIME=time1);
						
	IF @schedule_id IS NULL THEN
		SELECT 'There exist no flight for the given route, date and time' AS "MESSAGE";
	ELSE
		SET @flight_id=(SELECT FLIGHTNUMBER FROM FLIGHT
						WHERE WEEK=week1 AND
						SCHEDULE_ID=@schedule_id);
		IF @flight_id IS NULL THEN
			SELECT 'There exist no flight for the given route, date and time' AS "MESSAGE";
		ELSE

			SET @free_seats := calculateFreeSeats(@flight_id);

            IF @free_seats < number_of_passengers THEN
				SELECT 'There are not enough seats available on the chosen flight' AS "MESSAGE";
			ELSE
				SELECT COUNT(*)+1 INTO output_reservation_nr FROM RESERVATION;
				INSERT INTO RESERVATION VALUES (output_reservation_nr,number_of_passengers,NULL,@flight_id);
			END IF;
		END IF;
	END IF;
END IF;

END;
//

CREATE PROCEDURE addPassenger(IN reservation_nr INT,IN passport_number INT,IN name1 VARCHAR(30))
BEGIN

SET @n2 = (SELECT COUNT(*) FROM RESERVATION WHERE RESERVATION_NUMBER = reservation_nr);
IF @n2>0 THEN
	IF (SELECT COUNT(*) FROM `BOOKING` WHERE `ID` = reservation_nr) > 0 THEN
		SELECT  'The booking has already been payed and no futher passengers can be added' AS "MESSAGE";
	ELSE
		SET @n = (SELECT COUNT(*) FROM PASSENGER WHERE PASSPORTNUMBER = passport_number);
		IF @n=0 THEN
			INSERT INTO PASSENGER VALUES(passport_number,name1);
			INSERT INTO RESERVE VALUES (passport_number,reservation_nr);
            SET @reserve_people_num=(SELECT COUNT(*) FROM RESERVE WHERE RESERVATION_NUMBER=reservation_nr);
            IF @reserve_people_num > (SELECT NUM_OF_PASSENGER FROM RESERVATION WHERE RESERVATION_NUMBER = reservation_nr) THEN
				UPDATE RESERVATION SET NUM_OF_PASSENGER=@reserve_people_num WHERE RESERVATION_NUMBER = reservation_nr;
			END IF;
		ELSE
			INSERT INTO RESERVE VALUES (passport_number,reservation_nr);
            SET @reserve_people_num=(SELECT COUNT(*) FROM RESERVE WHERE RESERVATION_NUMBER=reservation_nr);
            IF @reserve_people_num > (SELECT NUM_OF_PASSENGER FROM RESERVATION WHERE RESERVATION_NUMBER = reservation_nr) THEN
				UPDATE RESERVATION SET NUM_OF_PASSENGER=@reserve_people_num WHERE RESERVATION_NUMBER = reservation_nr;
			END IF;
		END IF;
	END IF;
ELSE
	SELECT 'The given reservation number does not exist' AS "MESSAGE";
END IF;

END;
//

CREATE PROCEDURE addContact(IN reservation_nr INT,IN passport_number INT, IN email VARCHAR(30), IN phone BIGINT)
BEGIN
	SET @n = (SELECT COUNT(*) FROM RESERVATION WHERE RESERVATION_NUMBER = reservation_nr);
    SET @n2 = (SELECT COUNT(*) FROM PASSENGER WHERE PASSPORTNUMBER = passport_number);
    IF @n>0 THEN
			IF @n2 >0 THEN
				SET @n3= (SELECT COUNT(*) FROM RESERVE WHERE PASSPORTNUMBER=passport_number AND RESERVATION_NUMBER = reservation_nr);
                IF @n3>0 THEN
					IF (SELECT COUNT(*) FROM CONTACT WHERE `PASSPORTNUMBER`=passport_number) > 0 THEN
						UPDATE RESERVATION SET CONTACT_ID = passport_number WHERE RESERVATION_NUMBER = reservation_nr;
					ELSE
						INSERT INTO CONTACT VALUES(passport_number,email,phone);
						UPDATE RESERVATION SET CONTACT_ID = passport_number WHERE RESERVATION_NUMBER = reservation_nr;
					END IF;
				ELSE
					SELECT 'The person is not a passenger of the reservation' AS "MESSAGE";
				END IF;
			ELSE
				SELECT 'The person is not a passenger of the reservation' AS "MESSAGE";
			END IF;
	ELSE 
        SELECT  'The given reservation number does not exist' AS "MESSAGE";
	END IF;
END;
//

CREATE PROCEDURE addPayment(IN reservation_nr INT,IN cardholder_name VARCHAR(30),IN credit_card_number BIGINT)
BEGIN
	SET @n = (SELECT COUNT(*) FROM RESERVATION WHERE RESERVATION_NUMBER = reservation_nr);
    
    IF @n>0 THEN
		IF(SELECT CONTACT_ID FROM RESERVATION WHERE RESERVATION_NUMBER = reservation_nr) IS NULL THEN
			SELECT  'The reservation has no contact yet' AS "MESSAGE";
		ELSE
			IF (SELECT COUNT(*) FROM `BOOKING` WHERE `ID` = reservation_nr) > 0 THEN
				SELECT  'The booking has already been payed and no futher passengers can be added' AS "MESSAGE";
			ELSE
				SET @flight_id=(SELECT `FLIGHT_ID` FROM `RESERVATION` WHERE `RESERVATION_NUMBER` = reservation_nr);
				SET @free_seats := calculateFreeSeats(@flight_id);
                SET @number_of_passenger=(SELECT `NUM_OF_PASSENGER` FROM `RESERVATION` WHERE `RESERVATION_NUMBER` = reservation_nr);
                IF @free_seats < @number_of_passenger THEN
					DELETE FROM `RESERVATION` WHERE `RESERVATION_NUMBER` = reservation_nr;
					SELECT  'There are not enough seats available on the flight anymore, deleting reservation' AS "MESSAGE";

				ELSE
					SET @price=(calculatePrice(@flight_id)*@number_of_passenger);
                    IF (SELECT COUNT(*) FROM CREDIT_CARD WHERE CREDITCARD_NUMBER=credit_card_number) = 0 THEN
						INSERT INTO CREDIT_CARD VALUES (credit_card_number,cardholder_name);
					END IF;
					INSERT INTO BOOKING VALUES (reservation_nr,credit_card_number,@price);
                    INSERT INTO BOOKED
						SELECT reservation_nr,PASSPORTNUMBER,NULL 
                        FROM RESERVE 
                        WHERE RESERVATION_NUMBER= reservation_nr;
                    
				END IF;
			END IF;
		END IF;
	ELSE 
        SELECT  'The given reservation number does not exist' AS "MESSAGE";
	END IF;
END;
//



# 7.
DROP VIEW IF EXISTS allFlights;
//
-- CREATE VIEW allFlights AS 
-- SELECT a.NAME AS departure_city_name,b.NAME AS destination_city_name,m.departure_time AS departure_time,m.departure_day AS departure_day,m.departure_week AS departure_week,
-- 		m.departure_year AS departure_year,calculateFreeSeats(m.FLIGHTNUMBER) AS nr_of_free_seats,calculatePrice(m.FLIGHTNUMBER) AS current_price_per_seat
-- FROM(SELECT FLIGHTNUMBER, w.ROUTE_ID AS ROUTE_ID, DEPARTURE_TIME AS departure_time, `YEAR` AS departure_year, `DAY` AS departure_day,
-- 		`WEEK` AS departure_week
-- 		FROM FLIGHT f INNER JOIN WEEKLY_SCHEDULE w ON f.SCHEDULE_ID=w.ID) m
-- INNER JOIN ROUTE r ON m.ROUTE_ID=r.`ID`
-- INNER JOIN AIRPORT a ON r.DEPARTURE_CODE=a.`CODE`
-- INNER JOIN AIRPORT b ON r.ARRIVAL_CODE=b.`CODE`;

CREATE VIEW allFlights AS 
SELECT A.NAME AS departure_city_name, B.NAME AS destination_city_name,  DEPARTURE_TIME AS departure_time, 
DAY AS departure_day, WEEK AS departure_week,YEAR AS departure_year,calculateFreeSeats(FLIGHT.FLIGHTNUMBER) as nr_of_free_seats, 
calculatePrice(FLIGHT.FLIGHTNUMBER) as current_price_per_seat
FROM WEEKLY_SCHEDULE 
INNER JOIN ROUTE ON WEEKLY_SCHEDULE.ROUTE_ID =  ROUTE.ID
INNER JOIN FLIGHT ON WEEKLY_SCHEDULE.ID = FLIGHT.SCHEDULE_ID
INNER JOIN AIRPORT A ON ROUTE.DEPARTURE_CODE = A.CODE
INNER JOIN AIRPORT B ON ROUTE.ARRIVAL_CODE = B.CODE;

//

# 8.

## a)
-- 1. Set permission groups for users. Non-staff members cannot access the database.
-- 2. Encrypt credit card numbers stored in the database. 
-- 	Due to the characteristics of the encryption algorithm, hackers cannot deduct credit card information from the encrypted card number. 
--     However, doing so will cause users to still have to enter credit card information every time they make a payment.
-- 3. Use stored procedures or ORM frameworks. They prevent SQL injection attacks. 
-- 	ORM can convert input into entity objects, and then use entity objects to perform CRUD operations on the database; 
--     while stored procedures use fixed parameters and do not include any dynamic SQL generation.
    
## b)
-- 1. The stored procedure is compiled and stored directly in the database, 
-- 	and is executed directly when called, while the SQL statement needs to be compiled first and then executed. 
--     Therefore, stored procedures execute more efficiently.
-- 2. High reusability. When repeated tasks need to be completed, only the same stored procedure needs to be called.
-- 3. High safety. Stored procedures require execution permissions in some DBMS and have identity restrictions.
-- 4. Reduce data transfer and communication cost (Don't need to transfer long SQL queries)


# 9.

## a)

### Session A
-- START TRANSACTION;
-- CALL addReservation("MIT","HOB",2010,1,"Monday","09:00:00",3,@f);
-- SELECT * FROM RESERVATION;
-- COMMIT;

### Session B
-- START TRANSACTION;
-- SELECT * FROM RESERVATION;
-- UPDATE RESERVATION SET NUM_OF_PASSENGER=1 WHERE RESERVATION_NUMBER=4;
-- COMMIT;allflights

## b)
-- This reservation is not visible in session B. The isolation level used by the innoDB engine defaults to REPEATABLE READ.
-- It ensures that the transaction can read data that has been committed during execution, 
-- but will not read data that is being modified by other concurrent transactions but has not yet been committed.
-- This ensures transaction isolation.

## c)
-- The reservation from session A will not be modified by session B until session A has been commited.
-- The isolation level used by the innoDB engine defaults to REPEATABLE READ.
-- When We add a reservation in A, A got a write lock; When we modify the reservation from A in B,
-- B can not get the write lock, hence it must wait for A to release the resources that the modify operation from B needed.
-- After A has been commited, B can finally get the write lock and modify the reservation.


# 10.

## a)
-- Overbooking did not occur when the scripts were executed. 
-- When the user in the Session B wants to pay for the reservation,there are not enough seats,
-- because the payment of user in A runs before that in B.

## b)
-- Yes, it can theoretically occured.
-- In the block of the store procedure 'addPayment':

-- 				...
--                 IF @free_seats < @number_of_passenger THEN
-- 					DELETE FROM `RESERVATION` WHERE `RESERVATION_NUMBER` = reservation_nr;
-- 					SELECT  'There are not enough seats available on the flight anymore, deleting reservation' AS "MESSAGE";

-- 				ELSE
-- 					SET @price=(calculatePrice(@flight_id)*@number_of_passenger);
--                  IF (SELECT COUNT(*) FROM CREDIT_CARD WHERE CREDITCARD_NUMBER=credit_card_number) = 0 THEN
-- 						INSERT INTO CREDIT_CARD VALUES (credit_card_number,cardholder_name);
-- 					END IF;
-- 					INSERT INTO BOOKING VALUES (reservation_nr,credit_card_number,@price);
--                     INSERT INTO BOOKED
-- 				...

-- When two sessions execute the stored procedure at the same time, one of the situations that may cause overbooking is:
-- When session A will execute the line 'INSERT INTO BOOKING VALUES (reservation_nr, credit_card_number,@price);',
-- Session B is starting to execute the code after 'ELSE', and then waits at 'INSERT INTO BOOKING VALUES (reservation_nr, credit_card_number,@price);' because it cannot obtain the write lock.
-- Until session A finishes executing the stored procedure.

## c)

//
DROP PROCEDURE IF EXISTS  addPaymentModify;
//
CREATE PROCEDURE addPaymentModify(IN reservation_nr INT,IN cardholder_name VARCHAR(30),IN credit_card_number BIGINT)
BEGIN
	
	DECLARE n INT;
    DECLARE is_booked INT;
	SELECT COUNT(*) INTO n FROM RESERVATION WHERE RESERVATION_NUMBER = reservation_nr;
    
    IF n>0 THEN
		IF(SELECT CONTACT_ID FROM RESERVATION WHERE RESERVATION_NUMBER = reservation_nr) IS NULL THEN
			SELECT  'The reservation has no contact yet' AS "MESSAGE";
		ELSE
			SELECT COUNT(*) INTO is_booked FROM `BOOKING` WHERE `ID` = reservation_nr;
			IF is_booked > 0 THEN
				SELECT  'The booking has already been payed and no futher passengers can be added' AS "MESSAGE";
			ELSE
				SET @flight_id=(SELECT `FLIGHT_ID` FROM `RESERVATION` WHERE `RESERVATION_NUMBER` = reservation_nr);
				SET @free_seats := calculateFreeSeats(@flight_id);
                SET @number_of_passenger=(SELECT `NUM_OF_PASSENGER` FROM `RESERVATION` WHERE `RESERVATION_NUMBER` = reservation_nr);
                IF @free_seats < @number_of_passenger THEN
					DELETE FROM `RESERVATION` WHERE `RESERVATION_NUMBER` = reservation_nr;
					SELECT  'There are not enough seats available on the flight anymore, deleting reservation' AS "MESSAGE";

				ELSE
					SELECT SLEEP(5);
					SET @price=(calculatePrice(@flight_id)*@number_of_passenger);
                    IF (SELECT COUNT(*) FROM CREDIT_CARD WHERE CREDITCARD_NUMBER=credit_card_number) = 0 THEN
						INSERT INTO CREDIT_CARD VALUES (credit_card_number,cardholder_name);
					END IF;
					INSERT INTO BOOKING VALUES (reservation_nr,credit_card_number,@price);
                    INSERT INTO BOOKED
						SELECT reservation_nr,PASSPORTNUMBER,NULL 
                        FROM RESERVE 
                        WHERE RESERVATION_NUMBER= reservation_nr;
                    
				END IF;
			END IF;
		END IF;
	ELSE 
        SELECT  'The given reservation number does not exist' AS "MESSAGE";
	END IF;
END;
//

-- The overbooking occured. 

# d) Modify the testscripts

-- SELECT "Testing script for Question 10, Adds a booking, should be run in both terminals" as "Message";
-- SELECT "Adding a reservations and passengers" as "Message";
-- CALL addReservation("MIT","HOB",2010,1,"Monday","09:00:00",21,@a); 
-- CALL addPassenger(@a,00000001,"Saruman");
-- CALL addPassenger(@a,00000002,"Orch1");
-- CALL addPassenger(@a,00000003,"Orch2");
-- CALL addPassenger(@a,00000004,"Orch3");
-- CALL addPassenger(@a,00000005,"Orch4");
-- CALL addPassenger(@a,00000006,"Orch5");
-- CALL addPassenger(@a,00000007,"Orch6");
-- CALL addPassenger(@a,00000008,"Orch7");
-- CALL addPassenger(@a,00000009,"Orch8");
-- CALL addPassenger(@a,00000010,"Orch9");
-- CALL addPassenger(@a,00000011,"Orch10");
-- CALL addPassenger(@a,00000012,"Orch11");
-- CALL addPassenger(@a,00000013,"Orch12");
-- CALL addPassenger(@a,00000014,"Orch13");
-- CALL addPassenger(@a,00000015,"Orch14");
-- CALL addPassenger(@a,00000016,"Orch15");
-- CALL addPassenger(@a,00000017,"Orch16");
-- CALL addPassenger(@a,00000018,"Orch17");
-- CALL addPassenger(@a,00000019,"Orch18");
-- CALL addPassenger(@a,00000020,"Orch19");
-- CALL addPassenger(@a,00000021,"Orch20");
-- CALL addContact(@a,00000001,"saruman@magic.mail",080667989); 
-- SELECT SLEEP(5);
-- SELECT "Making payment, supposed to work for one session and be denied for the other" as "Message";
-- LOCK TABLES `RESERVATION` WRITE;			<- I don't know why but it works
-- START TRANSACTION;
-- CALL addPaymentModify (@a, "Sauron",7878787878);
-- COMMIT;
-- UNLOCK TABLES;
-- SELECT "Nr of free seats on the flight (should be 19 if no overbooking occured, otherwise -2): " as "Message", (SELECT nr_of_free_seats from allFlights where departure_week = 1) as "nr_of_free_seats";


-- Using LOCK TABLES and UNLOCK TABLES.
-- The former can add a lock to the table, causing it to enter a waiting state when being read/written by one transaction A, while transaction B attempts to read/write the same table. The latter will release the table lock. 
-- We only need to add a lock to the table, so that when transaction A performs read/write operations on certain tables, transaction B enters a waiting state.


-- The question about secondary index
-- We first find the most intensive database operations that users may perform (for example, users may use the allFlights view every time they search for flights, so it is important to optimize the search efficiency of the view). 
-- We noticed that in the join operation "INNER JOIN FLIGHT ON WEEKLY_SCHEDULE.ID = FLIGHT.SCHEDULE_ID", the DBMS will search and match FLIGHT.SCHEDULE_ID according to WEEKLY_SCHEDULE.ID. Considering the Nested loop algorithm, when entering the second level of for nesting (that is, looking for matching tuples in FLIGHT.SCHEDULE_ID), since FLIGHT.SCHEDULE_ID is not the primary key of the FLIGHT table and is not sorted, the time complexity of each search is n (n is the number of data in the FLIGHT table). 
-- We create a secondary index on the SCHEDULE_ID column of the FLIGHT table, which can speed up the JOIN operation of this view.





