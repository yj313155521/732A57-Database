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







