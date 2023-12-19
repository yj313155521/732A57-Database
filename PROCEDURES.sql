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