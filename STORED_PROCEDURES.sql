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
        SET MESSAGE_TEXT = 'The given reservation number does not exist';
    END IF;
END;	
//

# Procedure call to handle: addContact(reservation_nr,passport_number, email, phone);
delimiter //
CREATE PROCEDURE addContact(IN reservation_nr INT,IN passport_number INT, IN email VARCHAR(30), IN phone BIGINT)
BEGIN
	INSERT INTO CONTACT VALUES(passport_number,email,phone);
    UPDATE RESERVATION SET CONTACT_ID = passport_number WHERE RESERVATION_NUMBER = reservation_nr;
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




