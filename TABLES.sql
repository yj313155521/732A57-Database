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