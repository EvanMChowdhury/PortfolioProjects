USE PortfolioProject;

 DROP TABLE airlines;
 CREATE TABLE IF NOT EXISTS airlines (
	IATA_CODE VARCHAR(10) PRIMARY KEY,
    Airline VARCHAR(30)
    );
    
DROP TABLE flights;
CREATE TABLE IF NOT EXISTS flights(
	Flight_Year YEAR,
    Flight_Month INT,
    Flight_Day INT,
    Day_of_Week INT,
    Airline VARCHAR(10),
    Flight_Number INT,
    Tail_Number VARCHAR(20),
    Origin VARCHAR(10),
    Destination VARCHAR(10),
    Scheduled_Departure INT,
    Departure_Time INT,
    Departure_Delay INT,
    Taxi_Out INT,
    Wheels_Off INT,
    Scheduled_Time INT, 
    Elapsed_Time INT,
    Air_Time INT,
    Distance INT,
    Wheels_ON INT,
    Taxi_In INT,
    Scheduled_Arrival INT,
    Arrival_Time TIME,
    Arrival_Delay INT,
    Diverted INT,
    Cancelled INT,
    Cancellation_Reason VARCHAR(20),
    Air_System_Delay INT,
    Security_Delay INT,
    Airline_Delay INT,
    Late_Aircraft_Delay INT,
    Weather_Delay INT,
	FOREIGN KEY(Airline) REFERENCES airlines(IATA_Code)
    );
    
DESC flights;
    
DESC airlines;


SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = true;
 
LOAD DATA LOCAL INFILE 'Users/evanchowdhury/Downloads/archive/flights.csv'
INTO TABLE flights
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;    

LOAD DATA LOCAL INFILE 'Users/evanchowdhury/Downloads/archive/airlines.csv'
INTO TABLE airlines
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; 


-- Which flights were the most delayed in 2015? (Top 50)
SELECT CONCAT(flights.Airline, Flight_Number) AS Flight,
airlines.Airline,
CONCAT(Flight_Year, '/', Flight_Month, '/', Flight_Day) AS Flight_date,
Scheduled_Departure,
Departure_Time,
Departure_Delay
FROM flights
JOIN airlines ON flights.Airline = airlines.IATA_code
WHERE Cancellation_Reason = '' AND Elapsed_Time != 0
ORDER BY Departure_Delay DESC LIMIT 50;

-- What is the average delay for each airline?
SELECT airlines.Airline, 
AVG(Departure_Delay) AS avg_delay,
COUNT(*) AS total_flights
FROM flights 
JOIN airlines ON flights.Airline = airlines.IATA_code
WHERE Cancellation_Reason = ''
GROUP BY airlines.Airline
ORDER BY avg_delay DESC;

-- How many of each airline's flights were delayed over 30 minutes?
SELECT airlines.Airline, 
COUNT(*) AS total_flights,
COUNT(IF(Departure_Delay > 30, 1, null)) AS delay_count,
COUNT(IF(Departure_Delay > 30, 1, null)) / 
COUNT(*) AS delay_fraction
FROM flights
JOIN airlines ON flights.Airline = airlines.IATA_code
GROUP BY airlines.Airline
ORDER BY delay_fraction DESC;

-- What is the average runway time per airline?
SELECT airlines.Airline,
AVG(Elapsed_Time - Air_Time) AS avg_runway_time
FROM flights
JOIN airlines ON flights.Airline = airlines.IATA_code
GROUP BY airlines.Airline
ORDER BY avg_runway_time DESC;

-- How many flights per airline are on the runway for > 45 minutes?
SELECT airlines.Airline,
COUNT(*) AS total_flights,
COUNT(IF(Elapsed_Time - Air_Time > 45, 1, null)) AS delay_count,
COUNT(IF(Elapsed_Time - Air_Time > 45, 1, null)) / 
COUNT(*) AS delay_fraction
FROM flights
JOIN airlines ON flights.Airline = airlines.IATA_code
GROUP BY airlines.Airline
ORDER BY delay_fraction DESC;

-- How many fewer flights took place on Thanksgiving in 2015? Compared to total flights in Nov 2015
SELECT CONCAT(Flight_Year, '/', Flight_Month, '/', Flight_Day) AS Flight_date,
COUNT(*) AS flights_per_day, 
AVG(COUNT(*)) OVER() AS avg_nov_flights,
COUNT(*) - AVG(COUNT(*)) OVER() as diff_from_avg
FROM flights
WHERE Flight_Month = 11 AND Flight_Year = 2015 AND Flight_Day BETWEEN 20 AND 30
GROUP BY Flight_Day;

-- What is the most popular day of the week for flights in September 2015?
SELECT DAYNAME(CONCAT(Flight_Year, '/', Flight_Month, '/', Flight_Day)) AS day_of_the_week, 
COUNT(*) AS num_flights
FROM flights
WHERE Flight_Month = 9 AND Flight_Year = 2015
GROUP BY day_of_the_week
ORDER BY num_flights DESC;

-- Which month contains the most number of flights?
SELECT MONTHNAME(CONCAT(Flight_Year, '/', Flight_Month, '/', Flight_Day)) AS month_name, 
COUNT(*) AS num_flights_per_month
FROM flights
GROUP BY month_name
ORDER BY num_flights_per_month DESC;