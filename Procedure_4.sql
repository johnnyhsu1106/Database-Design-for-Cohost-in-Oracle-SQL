/*
------------------Procedure to find the daily rate------------------------------
Purpose: Create a list of rooms and dates with the daily price of each room 
         on each date based on the ROOM_ID that is prompted, the dates the 
         active traveler is interested in, and the active traveler_id at run 
         time.
         
         To create this list of rooms and dates we join the REGION_RATE, REGION,
         ADDRESS, and the ROOM table. 
         
         We initialize a variable that uses the date the traveler wants to start 
         their travel and use it as the loop index variable checking all dates
         from the date they want to start their stay up until one day before 
         the traveler wants to end their stay. Then we find rates by look for
         where the loop index variable (temp_date_start) to make sure it falls
         between RATE_BEGIN_DATE and one month after the RATE_BEGIN_DATE. We
         find the one month after date by using the ADD_MONTHS function and 
         adding one month. 
         
         On each loop we append one row to the ROOM_RATE and calculate the 
         daily rate as REGION_RATE * .9, CoHost policy is that room rates are 
         locked to 90% of the rate charged for the region the room is in.
         
         Once finished the result is the detail view of the table that the 
         procedure to find available rooms builds. This is used to see each 
         daily price that makes up the room_price in the reservation and 
         available_room table.
         
Parameters 

roomno:  This is the ROOM_ID that the active traveler would like to get more
         detail about. 

date_want_start:  This is the date that the active traveler is interested in 
                  starting their trip.

date_want_end:  This is the date that the active traveler is interested in 
                ending their trip.
                  
query_trav:   this is the active traveler id that is currently using the
              website. 
              
Exception Handling:
There are 2 exceptions handled by this procedure. 

1. If the user has entered a date before today's date they are prompted to 
   enter a valid date.
   
2. If any other exception happens the ORA-20002 exception is thrown and the user
   is given a brief message explaining that the traveler id or the room id does
   not exist.
   
Output:   This procedure appends data to the room price table.           
*/

CREATE OR REPLACE PROCEDURE ROOM_PRICE
(roomno room.room_id%type,
 date_want_start reservation.reserv_start%type,
 date_want_end   reservation.reserv_end%type,
 query_trav employee.emp_id%type)
 
as
temp_date_start reservation.reserv_start%type;
temp_rate region_rate.region_rate%type;
temp_room room.room_id%type;
temp_date_end reservation.reserv_end%type;
temp_trav employee.emp_id%type;


BEGIN

DELETE ROOM_RATE;

temp_date_start := date_want_start;
temp_date_end := date_want_end ;


IF TO_DATE(temp_date_end) < TO_DATE(SYSDATE)

THEN 

raise_application_error 
(-20009, 'Please enter a date greater than or equal to today''s date.'); 

ELSE

/*While loop to move through all days that a traveler would be staying with a host.*/


WHILE temp_date_end > temp_date_start

LOOP

SELECT roomno into temp_room from dual;
SELECT query_trav into temp_trav from dual;


/*Calculate each rate based on the date and price of that date*/

SELECT (RR.REGION_RATE * .9) AS RATE_CHARGED INTO temp_rate FROM
REGION_RATE RR
INNER JOIN REGION RE
ON RR.REG_ID = RE.REG_ID
INNER JOIN ADDRESS AA
ON TRIM(LOWER(AA.ADDRS_COUNTY)) = TRIM(LOWER(RE.COUNTY))
INNER JOIN
ROOM RO
ON AA.ADDRS_ID = RO.ADDRS_ID
WHERE room_id = temp_room
and temp_date_start >= RR.RATE_BEGIN_DATE
and temp_date_start <= (ADD_MONTHS(RR.RATE_BEGIN_DATE,1)-1);

/*Insert the new values into the ROOM_RATE table so that they can be displayed
  in the front end*/

INSERT INTO ROOM_RATE (ROOM_ID, TRAVELER_ID, ROOM_RATE, ROOM_DATE, RUN_DATE)
VALUES (TEMP_ROOM, TEMP_TRAV, TEMP_RATE,  temp_date_start, SYSDATE);
  
/*iterate the looping vairable*/

temp_date_start := temp_date_start + 1;

END LOOP;

END IF;

/*Handle the no data found exception*/

COMMIT;

Exception  
    When no_data_found Then
        raise_application_error 
        (-20002, TEMP_TRAV || ' or ' || TEMP_ROOM ||' does not exist.'); 
       

END;
/


/*Test Values used to verify procedure*/

/*
EXECUTE ROOM_PRICE ('ROO000000010','30-DEC-15','05-JAN-16','EMP000000004');
COMMIT;

SELECT * FROM ROOM_RATE AA
WHERE AA.TRAVELER_ID = *ACTIVE TRAVELER*
AND AA.RUN_DATE = (SELECT MAX(RUN_DATE) ROOM_RATE BB WHERE BB.TRAVELER_ID = AA.TRAVELER_ID GROUP BY TRAVELER_ID);

*/