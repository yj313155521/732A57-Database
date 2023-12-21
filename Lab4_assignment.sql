#-----DROP TABLES------
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



#-----DROP FUNCTIONS-----
DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS calculatePrice;




#------CREATE TABLES------
SET FOREIGN_KEY_CHECKS=1;

# AIRPORT TABLE
 CREATE TABLE AIRPORT(
	CODE VARCHAR(3),
    NAME VARCHAR(30),
    COUNTRY VARCHAR(30),
    
    constraint pk_airport
		primary key(CODE)
);

# ROUTE TABLE
CREATE TABLE ROUTE(
	ID integer,
    ARRIVAL_CODE VARCHAR(3),
    DEPATURE_CODE VARCHAR(3),
    
    constraint pk_route
		primary key(ID),
        
	constraint fk_route_airport
		FOREIGN KEY(ARRIVAL_CODE) references AIRPORT(CODE),
        
        FOREIGN KEY(DEPATURE_CODE) references AIRPORT(CODE)
);
 
 # YEAR TABLE
    CREATE TABLE YEAR(
		YEAR integer,
        PROFITFACTOR DOUBLE,
        
        constraint pk_year
        primary key(YEAR)
	);

# DAY TABLE
CREATE TABLE DAY(
	YEAR integer,
	DAY VARCHAR(10),
    WEEKDAYFACOR DOUBLE,
    
    constraint pk_day
		primary key(DAY),
        
	constraint fk_day_year
		FOREIGN KEY(YEAR) references YEAR(YEAR)
	);

 # WEEKLY_SCHEDUAL TABLE
 CREATE TABLE WEEKLY_SCHEDULE(
	ID integer,
    YEAR  integer,
    DAY VARCHAR(10),
    ROUTE_ID integer,
    DEPARTRUE_TIME time,
    
    constraint pk_weekly_schedule
		primary key (ID),
	
    constraint fk_weekly_schedule_year
		FOREIGN KEY(YEAR) references YEAR(YEAR),
	
    constraint fk_weekly_schedule_day
		FOREIGN KEY(DAY) references DAY(DAY),
        FOREIGN KEY(YEAR) references DAY(YEAR)
        
	);
        	
# FLIGHT TABLE
	CREATE TABLE FLIGHT(
		FLIGHTNUMBER integer,
		WEEK integer,
		SCHEDULE_ID integer,
    
		constraint pk_flight
        primary key(FLIGHTNUMBER),
        
        constraint fk_flight_weekly_schedule
        FOREIGN KEY(SCHEDULE_ID) references WEEKLY_SCHEDULE(ID)
    );

# PASSENGER TABLE
CREATE TABLE PASSENGER(
	PASSPORTNUMBER integer,
    NAME VARCHAR(30),
    
    constraint pk_passenger
    primary key(PASSPORTNUMBER)
	
);
    
# CONTACT TABLE
CREATE TABLE CONTACT(
	PASSPORTNUMBER integer,
    EMAIL VARCHAR(30),
    PHONENUMBER BIGINT,
    
    constraint pk_contact
    primary key(PASSPORTNUMBER),
    
    constraint fk_contact_passenger
    FOREIGN KEY(PASSPORTNUMBER) references PASSENGER(PASSPORTNUMBER)

);



   
# RESERVATION TABLE
CREATE TABLE RESERVATION(
	RESERVATION_NUMBER  integer,
    NUM_OF_PASSENGER integer,
    CONTACT_ID integer,
    FLIGHT_ID integer,
    
    constraint pk_reservation
    primary key(RESERVATION_NUMBER),
    
    constraint fk_reservation_contract
    FOREIGN KEY(CONTACT_ID) references CONTACT(PASSPORTNUMBER),
    
    constraint fk_reservation_flight
    FOREIGN KEY(FLIGHT_ID) references FLIGHT(FLIGHTNUMBER)
    
    );
    

 # CREDIT_CARD TABLE
CREATE TABLE CREDIT_CARD(
	CREDITCARD_NUMBER BIGINT,
    CARD_HOLDER VARCHAR(30),
    
    constraint pk_credit_card
    primary key(CREDITCARD_NUMBER)

);   


# BOOKING TABLE
CREATE TABLE BOOKING(
	ID integer,
    CREDITCARD_NUMBER BIGINT,
    ACTUAL_PRICE DOUBLE,
    
    constraint pk_booking
    primary key(ID),
    
    constraint fk_booking_reservation
    FOREIGN KEY(ID) references RESERVATION(RESERVATION_NUMBER),
    
    constraint fk_booking_CREDIT_CARD
    FOREIGN KEY(CREDITCARD_NUMBER) references CREDIT_CARD(CREDITCARD_NUMBER)
);



# ROUTE PRICEC
CREATE TABLE ROUTE_PRICE(
	YEAR integer,
    ROUTE_ID integer,
    ROUTE_PRICE DOUBLE,
    
    constraint pk_route_price
    primary key(YEAR,ROUTE_ID),
    
    constraint fk_route_price_route
    FOREIGN KEY(ROUTE_ID) references ROUTE(ID),
    
    constraint fk_route_price_year
    FOREIGN KEY(YEAR) references YEAR(YEAR)
    
);


# RESERVE TABLE
CREATE TABLE RESERVE(
	PASSPORTNUMBER integer,
    RESERVATION_NUMBER integer,
    
    constraint pk_reserve
    primary key(PASSPORTNUMBER,RESERVATION_NUMBER),
    
    constraint fk_reserver_passenger
    FOREIGN KEY(PASSPORTNUMBER) references PASSENGER(PASSPORTNUMBER),
    
    constraint fk_reserve_reservation
    FOREIGN KEY(RESERVATION_NUMBER) references RESERVATION(RESERVATION_NUMBER)
    
);

# BOOKED TABLE
CREATE TABLE BOOKED(

	BOOKING_ID integer,
    PASSENGER_ID integer,
    TICKET_NUMBER integer,
    
    constraint pk_booked
    primary key(BOOKING_ID,PASSENGER_ID),
    
    constraint fk_booked_booking
    FOREIGN KEY(BOOKING_ID) references BOOKING(ID),
    
    constraint fk_booked_passenger
    FOREIGN KEY(PASSENGER_ID) references PASSENGER(PASSPORTNUMBER)
    
);


# -----------------------PROCEDURES--------------------------------
# Procedure call: addYear(year, factor);
delimiter //
CREATE PROCEDURE addYear(IN year INT, IN factor DOUBLE)
BEGIN
INSERT INTO YEAR VALUES(year,factor);
END;
//

# Procedure call: addDay(year, day, factor);
delimiter //
CREATE PROCEDURE addDay(IN year INT, IN day VARCHAR(10), IN factor DOUBLE)
BEGIN
INSERT INTO DAY VALUES(year, day,factor);
END
// 

#  Procedure call: addDestination(airport_code, name, country);
delimiter //
CREATE PROCEDURE addDestination(IN airport_code VARCHAR(3), IN name VARCHAR(30), IN country VARCHAR(30))
BEGIN
INSERT INTO AIRPORT VALUES(airport_code,name,country);
END
//

#  Procedure call: addRoute(departure_airport_code, arrival_airport_code, year, routeprice);    
delimiter //
CREATE PROCEDURE addRoute(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year INT, IN routeprice DOUBLE)
BEGIN
	SET @n := (SELECT COUNT(*) FROM ROUTE WHERE ARRIVAL_CODE=arrival_airport_code AND DEPATURE_CODE=departure_airport_code);
    IF @n = 0 THEN
		SET @v1 := (SELECT COUNT(*) FROM ROUTE);
		INSERT INTO ROUTE VALUES(@v1+1,arrival_airport_code,departure_airport_code);
		INSERT INTO ROUTE_PRICE VALUES(year,@v1+1,routeprice);
	ELSE 
        SET @v3 := (SELECT ID FROM ROUTE WHERE ARRIVAL_CODE=arrival_airport_code AND DEPATURE_CODE=departure_airport_code);
        INSERT INTO ROUTE_PRICE VALUES(year,@v3,routeprice);
	END IF;
END
//


#  Procedure call: addFlight(departure_airport_code, arrival_airport_code, year, day, departure_time)

delimiter //
CREATE PROCEDURE addFlight(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year INT, IN day VARCHAR(10), IN departure_time time)
BEGIN

	SET @route_id := (SELECT ID FROM ROUTE WHERE (ARRIVAL_CODE=arrival_airport_code) AND (DEPATURE_CODE=departure_airport_code));
	SET @schedule_id := (SELECT ID FROM WEEKLY_SCHEDULE WHERE (YEAR=year) AND (DAY=day) AND (ROUTE_ID=@route_id) AND (DEPARTRUE_TIME=departure_time));
	SET @week_pre := (SELECT COUNT(*) FROM FLIGHT WHERE SCHEDULE_ID = @schedule_id);
	SET @flightnumber_pre :=(SELECT COUNT(*) FROM FLIGHT);
	INSERT INTO FLIGHT VALUES(@flightnumber_pre+1,@week_pre+1,@schedule_id);
END
//


#--------FUNCTIONS------
#  Function call: calculateFreeSeats(flightnumber)
delimiter //
CREATE FUNCTION calculateFreeSeats(flightnumber INT)
	RETURNS INTEGER
BEGIN
DECLARE NUMBER INT;
SELECT SUM(NUM_OF_PASSENGER) INTO NUMBER
FROM RESERVATION
WHERE RESERVATION_NUMBER IN (SELECT ID FROM BOOKING) AND FLIGHT_ID=flightnumber;
RETURN NUMBER;
END; //
delimiter 


#  Function call: calculatePrice(flightnumber)
delimiter //
CREATE FUNCTION calculatePrice(flightnumber INT)
	RETURNS DOUBLE

BEGIN
SET @year :=(SELECT YEAR FROM WEEKLY_SCHEDULE WHERE ID =(SELECT SCHEDULE_ID FROM FLIGHT WHERE ID=flightnumber));
SET @route_id :=(SELECT ROUTE_ID FROM WEEKLY_SCHEDULE WHERE ID =(SELECT SCHEDULE_ID FROM FLIGHT WHERE ID=flightnumber));
SET @route_price :=(SELECT ROUTE_PRICE FROM ROUTE_PRICE WHERE YEAR = year AND ROUTE_ID = route_id);
SET @weekdayfactor :=(SELECT WEEKDAYFACTOR FROM DAY WHERE YEAR = year);
SET @profitfactor :=(SELECT PROFITFACTOR FROM YEAR WHERE YEAR = year);

RETURN(route_price *weekdayfactor*profitfactor*(40-calculateFreeSeats(flightnumber+1)/40));
END;
//

#------TRIGGER----------
CREATE TRIGGER issue_ticketnumbers
BEFORE INSERT ON BOOKED
FOR EACH ROW
SET NEW.TICKET_NUMBER =rand();



# --------------STORED_PROCEDURES------------

# Procedure call: addReservation(departure_airport_code, arrival_airport_code, year, week, day, time, number_of_passengers, output_reservation_nr);
delimiter //
CREATE PROCEDURE addReservation(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year INT, IN week INT, IN day VARCHAR(10), IN time time, IN number_of_passengers INT, OUT output_reservation_nr INT)
BEGIN
	SET @route_id := (SELECT ID FROM ROUTE WHERE (ARRIVAL_CODE=arrival_airport_code) AND (DEPATURE_CODE=departure_airport_code));
	SET @schedule_id := (SELECT ID FROM WEEKLY_SCHEDULE WHERE (YEAR=year) AND (DAY=day) AND (ROUTE_ID=@route_id) AND (DEPARTRUE_TIME=time));
    SET @flightnumber := (SELECT FLIGHTNUMBER FROM FLIGHT WHERE(WEEK=week)AND(SCHEDULE_ID=@schedule_id));
    SELECT COUNT(*)+1 INTO output_reservation_nr FROM RESERVATION;
    INSERT INTO RESERVATION VALUES(output_reservation_nr,number_of_passengers,NULL,@flightnumber);
END;
//



# Procedure call to handle: addPassenger(reservation_nr, passport_number, name);
delimiter //
CREATE PROCEDURE addPassenger(IN reservation_nr INT, IN passport_number INT, IN name VARCHAR(30))
BEGIN
    SET @n2 = (SELECT COUNT(*) FROM RESERVATION WHERE RESERVATION_NUMBER = reservation_nr);
    IF @n2>0 THEN
		SET @n = (SELECT COUNT(*) FROM PASSENGER WHERE PASSPORTNUMBER = passport_number);
		IF @n=0 THEN
			INSERT INTO PASSENGER VALUES(passport_number,name);
			INSERT INTO RESERVE VALUES(passport_number,reservation_nr);
		ELSE 
			INSERT INTO RESERVE VALUES(passport_number,reservation_nr);
		END IF;
	ELSE 
        SELECT  'The given reservation number does not exist' AS "MESSAGE";
        
    END IF;
END;	
//

# Procedure call to handle: addContact(reservation_nr,passport_number, email, phone);
delimiter //
CREATE PROCEDURE addContact(IN reservation_nr INT,IN passport_number INT, IN email VARCHAR(30), IN phone BIGINT)
BEGIN
	SET @n = (SELECT COUNT(*) FROM RESERVATION WHERE RESERVATION_NUMBER = reservation_nr);
    SET @n2 = (SELECT COUNT(*) FROM PASSENGER WHERE PASSPORTNUMBER = passport_number);
    IF @n>0 THEN
			IF @n2 >0 THEN
				INSERT INTO CONTACT VALUES(passport_number,email,phone);
				UPDATE RESERVATION SET CONTACT_ID = passport_number WHERE RESERVATION_NUMBER = reservation_nr;
			ELSE
				SELECT 'The person is not a passenger of the reservation' AS "MESSAGE";
			END IF;
	ELSE 
        SELECT  'The given reservation number does not exist' AS "MESSAGE";
	END IF;
END;
//

# Procedure call to handle: addPayment (reservation_nr, cardholder_name, credit_card_number);
delimiter //
CREATE PROCEDURE addPayment (IN reservation_nr INT, IN cardholder_name VARCHAR(30), IN credit_card_number BIGINT)
BEGIN
	SET @contact_id =(SELECT CONTACT_ID FROM RESERVATION WHERE RESERVATION_NUMBER = reservation_nr);
    SET @flightnumber =(SELECT FLIGHT_ID FROM RESERVATION WHERE RESERVATION_NUMBER = reservation_nr);
    SET @seats_left = calculateFreeSeats(@flightnumber);
    SET @seats_need = (SELECT NUM_OF_PASSENGER FROM RESERVATION WHERE RESERVATION_NUMBER = reservation_nr);
	IF (@contact_id IS NOT NULL) AND( @seats_left>@seats_need) THEN
    SET @booking_id = (SELECT COUNT(*)FROM BOOKING) +1;
    INSERT INTO BOOKING VALUES(@booking_id,credit_card_number,calculatePrice(@flightnumber)*@seats_need);
    INSERT INTO CREDIT_CARD VALUES(credit_card_number,cardholder_name);
    SET @PASS = (SELECT PASSPORT FROM RESERVE WHERE RESERVATION_NUMBER = reservation_nr);
    INSERT INTO BOOKED(BOOKING_ID, PASSENGER_ID) VALUES (reservation_nr, @PASS );
    END IF;
END;	
//


#--------VIEWS--------

# Create a view allFlights containing all flights in your database
CREATE VIEW allFlights AS 
SELECT A.NAME AS departure_city_name, B.NAME AS destination_city_name,  DEPARTRUE_TIME AS departure_time, 
DAY AS departure_day, WEEK AS departure_week,YEAR AS departure_year,calculateFreeSeats(FLIGHT.FLIGHTNUMBER) as nr_of_free_seats, 
calculatePrice(FLIGHT.FLIGHTNUMBER) as current_price_per_seat
FROM WEEKLY_SCHEDULE 
LEFT JOIN ROUTE ON WEEKLY_SCHEDULE.ROUTE_ID =  ROUTE.ID
LEFT JOIN FLIGHT ON WEEKLY_SCHEDULE.ID = FLIGHT.SCHEDULE_ID
LEFT JOIN AIRPORT A ON ROUTE.DEPATURE_CODE = A.CODE
LEFT JOIN AIRPORT B ON ROUTE.ARRIVAL_CODE = B.CODE;





