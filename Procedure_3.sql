/*------------------------------------------------------------------------------
---------------------Procedure to find avaliable rooms--------------------------
Purpose: This procedure is designed to find all available rooms within 
         our database where the active Traveler's company matches the 
         available Hosts' company, the room is in the same region as the 
         destination region, and where the Traveler is not also the Host.
         
         To accomplish this we take ROOM and use MINUS to remove all rooms
         where PREFFERED_START date and the PREFFERED_END date  overlap the 
         dates that have been reserved for this room in the RESERVATION table. 
         
         Then we get the host information for each available room by joining
         the ADDRESS, HOST, EMPLOYEE, and DEPARTMENTS tables and further limit 
         the results to only those where the TRAVELER is not also the HOST. 
         
         Then we validate that the results are in the preffered county and 
         preffered state. This is to be sure that we do not join to duplicate 
         counties across many states.
         
         Finally we join the traveler, employee, and department tables where 
         the TRAVLER_ID in the TRAVELER table is the same as the active travler
         and limit the results to only those where the traveler and host 
         are in the same company.
         
         We take these results and load them into a cursor and user the cursor.
         
         The procedure then users the cursor to append the results to the
         table AVAILABLE_ROOM. The results are effective dated and 
         include the active TRAVELER_ID to allow the front end to quickly 
         identify pertinent results by choosing all records where the 
         TRAVELER_ID in AVAILABLE_ROOM matches the active TRAVELER_ID
         and where the AVAIL_CHECK_DATE is the maximum from that group. 
         
         The AVAILABLE_ROOM table is intended to hold a history of user 
         queries until such time as it is truncated so that CoHost can 
         analyze user preferences in their searches. 
         
         There is a toggle written in to the procedure that will allow the 
         user to activate a delete of the AVAILABLE_ROOM table each time 
         the procedure is run but this does not actively support more than 
         one user at a time.
              
Parameters:
TRAV_CHECKING       The traveler Id of the person looking for a room.

OFFICE_COUNTY       The county that the traveler is trying to travel to.

OFFICE_STATE        The state that the traveler is trying to travel to. 
                    Necessary to differentiate duplicate county names.
                    
PREFERRED_START     The prefferred start date the traveler desires.

PREFFERED_END       The prefferred end date that the traveler desires.

Exception Handling:
There are 2 exceptions handled by this procedure. 

1. If the user has entered a date before today's date they are prompted to 
   enter a valid date.
   
2. If any other exception happens the ORA-20005 exception is thrown and the user
   is given a brief message explaining that no rooms were found for these dates.
   
Output:   This procedure appends a ROOM_ID and many interesting attributes 
          related to that room including all tracked amenities. The output also
          includes the TRAVELER_ID of the active traveler, the dates queried, 
          the date the procedure was run, and the room rate for each room 
          returned over the dates queried.

   
Future improvements:
Exception reporting could be improved to identify further errors and exceptions
that occur at runtime.
------------------------------------------------------------------------------*/


CREATE OR REPLACE PROCEDURE AVAILABLE_ROOMS(
    TRAV_CHECKING TRAVELER.TRAVELER_ID%TYPE,
    OFFICE_COUNTY ADDRESS.ADDRS_COUNTY%TYPE,
    OFFICE_STATE ADDRESS.ADDRS_STATE%TYPE,
    PREFFERED_START RESERVATION.RESERV_START%TYPE,
    PREFFERED_END RESERVATION.RESERV_END%TYPE)
AS
/*Variable Declaration*/

  TEMP_TRAV TRAVELER.TRAVELER_ID%TYPE;
  TEMP_ROOM_ID ROOM.ROOM_ID%TYPE;
  TEMP_STREET  ADDRESS.ADDRS_STREET%TYPE;
  TEMP_CITY    ADDRESS.ADDRS_CITY%TYPE;
  TEMP_STATE   ADDRESS.ADDRS_STATE%TYPE;
  TEMP_NBHD_NAME NEIGHBORHOOD.NBHD_NAME%TYPE;
  TEMP_NBHD_TYPE NEIGHBORHOOD.NBHD_TYPE%TYPE;
  TEMP_NBHD_FEAT NEIGHBORHOOD.NBHD_FEAT%TYPE;
  TEMP_WIFI ADDRESS.WIFI%TYPE;
  TEMP_PETS ADDRESS.PETS%TYPE;
  TEMP_CHILDREN ADDRESS.CHILDREN%TYPE;
  TEMP_KITCHEN ADDRESS.KITCHEN%TYPE;
  TEMP_COMMON_AREA ADDRESS.COMMON_AREA%TYPE;
  TEMP_OWNER_OCC ADDRESS.OWNER_OCC%TYPE;
  TEMP_TELEVISION ADDRESS.TELEVISION%TYPE;
  TEMP_BLDG_TYPE ADDRESS.BLDG_TYPE%TYPE;
  TEMP_SMOKING ADDRESS.SMOKING%TYPE;
  TEMP_WASHER_DRYER ADDRESS.WASHER_DRYER%TYPE;
  TEMP_POOL ADDRESS.POOL%TYPE;
  TEMP_OTHER ADDRESS.OTHER%TYPE;
  TEMP_COUNTY ADDRESS.ADDRS_COUNTY%TYPE;
  TEMP_START RESERVATION.RESERV_START%TYPE;
  TEMP_END RESERVATION.RESERV_END%TYPE;
  TEMP_LAT ADDRESS.ADDRS_LATITUDE%TYPE;
  TEMP_LONG ADDRESS.ADDRS_LONGITUDE%TYPE;
  TEMP_RATE_DATE RESERVATION.RESERV_START%TYPE;
  TEMP_RATE RESERVATION.ROOM_PRICE%TYPE;
  TEMP_INCREMENT RESERVATION.ROOM_PRICE%TYPE;
  
  /*Cursor to hold the resulst to insert into the AVAILABLE_ROOM table*/
  
  CURSOR C1
  IS
    SELECT RO.ROOM_ID,
      AA.ADDRS_STREET,
      AA.ADDRS_CITY,
      NBH.NBHD_NAME,
      NBH.NBHD_TYPE,
      NBH.NBHD_FEAT,
      AA.WIFI,
      AA.PETS,
      AA.CHILDREN,
      AA.KITCHEN,
      AA.COMMON_AREA,
      AA.OWNER_OCC,
      AA.TELEVISION,
      AA.BLDG_TYPE,
      AA.SMOKING,
      AA.WASHER_DRYER,
      AA.POOL,
      AA.OTHER,
      AA.ADDRS_LATITUDE,
      AA.ADDRS_LONGITUDE
    FROM ROOM RO
    INNER JOIN
      (SELECT RO.ROOM_ID FROM ROOM RO
    MINUS
      (SELECT RE.ROOM_ID
      FROM ROOM RO
      INNER JOIN reservation RE
      ON RO.ROOM_ID = RE.ROOM_ID
      INNER JOIN ADDRESS AA
      ON RO.ADDRS_ID           = AA.ADDRS_ID
      
      /*Find all dates that are not already booked*/
      
      WHERE ((PREFFERED_START <= RE.RESERV_START
              AND RE.RESERV_START <= PREFFERED_END)
            OR(PREFFERED_START < RE.RESERV_END
              AND RE.RESERV_END <= PREFFERED_END))
      AND AA.ADDRS_COUNTY      = OFFICE_COUNTY
      AND RE.ISCANC = 'N'
      GROUP BY RE.ROOM_ID
      )
      ) ROOMS ON RO.ROOM_ID = ROOMS.ROOM_ID
    INNER JOIN ADDRESS AA
    ON RO.ADDRS_ID = AA.ADDRS_ID
    INNER JOIN NEIGHBORHOOD NBH
    ON AA.NBHD_ID         = NBH.NBHD_ID
    INNER JOIN (SELECT AA.ADDRS_ID,DE.CO_ID,HO.HOST_ID FROM ADDRESS AA 
                                 INNER JOIN HOST HO 
                                 ON AA.HOST_ID = HO.HOST_ID
                                 INNER JOIN EMPLOYEE EE 
                                 ON EE.EMP_ID = HO.HOST_ID
                                 INNER JOIN DEPARTMENT DE
                                 ON DE.DEPT_ID = EE.DEPT_ID
                                 WHERE HO.HOST_ID <> TEMP_TRAV) HO
    ON AA.ADDRS_ID = HO.ADDRS_ID  
    
    /*Limit the results to just those within the proper region*/
    
    WHERE AA.ADDRS_COUNTY = OFFICE_COUNTY
    AND AA.ADDRS_STATE = OFFICE_STATE
    AND HO.CO_ID =
      (SELECT DE.CO_ID FROM TRAVELER TR
                                 INNER JOIN EMPLOYEE EE 
                                 ON EE.EMP_ID = TR.TRAVELER_ID
                                 INNER JOIN DEPARTMENT DE
                                 ON DE.DEPT_ID = EE.DEPT_ID
                                 WHERE TR.TRAVELER_ID = TEMP_TRAV
                                 GROUP BY DE.CO_ID) 
    ;
    
    
  BEGIN
   
  /*Toggle this command depending on how the AVAIABLE_ROOM table will be used
    if it is used to hold all room availability queries ever toggle it off
    if it is used to hold only the current session toggle it on. By default
    it is set to off*/
    
   --delete AVAILABLE_ROOM;
   
  
  /*Assign values to those variables that are not held in the cursor*/
    
    TEMP_TRAV       := TRAV_CHECKING;
    TEMP_COUNTY     := OFFICE_COUNTY;
    TEMP_STATE      := OFFICE_STATE;
    TEMP_START      := PREFFERED_START;
    TEMP_END        := PREFFERED_END;
    TEMP_RATE_DATE  := PREFFERED_START;
    TEMP_RATE       := 0;
    TEMP_INCREMENT  := 0;
    
    
   /*For loop to assign values to all variables inside the cursor*/
   
   IF TO_DATE(TEMP_START) < TO_DATE(SYSDATE)
      THEN
      raise_application_error 
      (-20009, 'Please enter a valid date equal to or after today''s date.');
      
   ELSE   
   
    FOR C1_REC IN C1
    
    
    LOOP
      TEMP_ROOM_ID      := C1_REC.ROOM_ID;
      TEMP_STREET       := C1_REC.ADDRS_STREET;
      TEMP_CITY         := C1_REC.ADDRS_CITY;
      TEMP_NBHD_NAME    := C1_REC.NBHD_NAME;
      TEMP_NBHD_TYPE    := C1_REC.NBHD_TYPE;
      TEMP_NBHD_FEAT    := C1_REC.NBHD_FEAT;
      TEMP_WIFI         := C1_REC.WIFI;
      TEMP_PETS         := C1_REC.PETS;
      TEMP_CHILDREN     := C1_REC.CHILDREN;
      TEMP_KITCHEN      := C1_REC.KITCHEN;
      TEMP_COMMON_AREA  := C1_REC.COMMON_AREA;
      TEMP_OWNER_OCC    := C1_REC.OWNER_OCC;
      TEMP_TELEVISION   := C1_REC.TELEVISION;
      TEMP_BLDG_TYPE    := C1_REC.BLDG_TYPE;
      TEMP_SMOKING      := C1_REC.SMOKING;
      TEMP_WASHER_DRYER := C1_REC.WASHER_DRYER;
      TEMP_POOL         := C1_REC.POOL;
      TEMP_OTHER        := C1_REC.OTHER;
      TEMP_LAT          := C1_REC.ADDRS_LATITUDE;
      TEMP_LONG         := C1_REC.ADDRS_LONGITUDE;
      
      /* If statement checks to see if date is valid. If date is before todays
         date we raise an application error to warn the customer to choose a
         date that is actually possible*/
      
      /*Assign default values to TEMP_RATE_DATE and TEMP_RATE before the loop
        to calculate the total amount of the stay*/
        
      TEMP_RATE_DATE := TEMP_START;
      
      TEMP_RATE := 0;  
      
      /*Loop to calculate the total amount that will be charged for each
        potential stay.*/
        
            
      WHILE TEMP_RATE_DATE < TEMP_END
      LOOP
      
      SELECT (RR.REGION_RATE * .9) INTO TEMP_INCREMENT
      FROM ROOM RO
      INNER JOIN ADDRESS AA
      ON RO.ADDRS_ID = AA.ADDRS_ID 
      INNER JOIN REGION RE
      ON TRIM(LOWER(AA.ADDRS_COUNTY)) = TRIM(LOWER(RE.COUNTY))
      INNER JOIN REGION_RATE RR
      ON RE.REG_ID = RR.REG_ID
      WHERE RR.RATE_BEGIN_DATE <= TEMP_RATE_DATE AND TEMP_RATE_DATE <= (ADD_MONTHS(RATE_BEGIN_DATE,1)-1)
      AND RO.ROOM_ID = TEMP_ROOM_ID;
      
      /*Assignment for each value during each loop*/
      
      TEMP_RATE := TEMP_RATE + NVL(TEMP_INCREMENT,0);
      
      TEMP_RATE_DATE := TEMP_RATE_DATE + 1;
      

      END LOOP;
      
      /*Insert each row into a table to capture each value.*/
           
      INSERT
      INTO AVAILABLE_ROOM
        (
          TRAVELER_ID,
          ROOM_ID,
          RESERV_START,
          RESERV_END,
          ROOM_PRICE,
          ADDRS_STREET,
          ADDRS_CITY,
          ADDRS_STATE,
          NBHD_NAME,
          NBHD_TYPE,
          NBHD_FEAT,
          WIFI,
          PETS,
          CHILDREN,
          KITCHEN,
          COMMON_AREA,
          OWNER_OCC,
          TELEVISION,
          BLDG_TYPE,
          SMOKING,
          WASHER_DRYER,
          POOL,
          OTHER,
          ADDRS_LATITUDE,
          ADDRS_LONGITUDE,
          AVAIL_CHECK_DATE
        )
        VALUES
        (
          TEMP_TRAV,
          TEMP_ROOM_ID,
          TEMP_START,
          TEMP_END,
          TEMP_RATE,
          TEMP_STREET,
          TEMP_CITY,
          TEMP_STATE,
          TEMP_NBHD_NAME,
          TEMP_NBHD_TYPE,
          TEMP_NBHD_FEAT,
          TEMP_WIFI,
          TEMP_PETS,
          TEMP_CHILDREN,
          TEMP_KITCHEN,
          TEMP_COMMON_AREA,
          TEMP_OWNER_OCC,
          TEMP_TELEVISION,
          TEMP_BLDG_TYPE,
          TEMP_SMOKING,
          TEMP_WASHER_DRYER,
          TEMP_POOL,
          TEMP_OTHER,
          TEMP_LAT,
          TEMP_LONG,
          SYSDATE
        );
        
    
        
    END LOOP;
    
    END IF;
    
    /*Commit all changes after the loop has finished*/
    COMMIT;
    
    
  /* Exception handling for the case when there are no rooms available*/  
  EXCEPTION
  WHEN no_data_found THEN
    raise_application_error (-20005, 'No rooms found for these dates');
    
  END;
  /

/*
  EXECUTE AVAILABLE_ROOMS ('EMP000000037','Santa Clara','CA','10-DEC-15','20-DEC-15'); 
 
   SELECT * FROM AVAILABLE_ROOM;
   
   ---query for usefull information from available_room
  SELECT ADDRS_STREET AS "Address Street",
  ADDRS_CITY        AS "Address City",
  BLDG_TYPE         AS "Building Type",
  RESERV_START      AS "Reservation Start Date",
  RESERV_END        AS "Reservation End Date",
  ROOM_PRICE        AS "Reservation Amount",
  NBHD_NAME         AS "Neighborhood",
  NBHD_TYPE         AS "Neighborhood Type",
  NBHD_FEAT         AS "Neighborhood Features",
  WIFI              AS "Wifi included",
  PETS              AS "Pets",
  CHILDREN          AS "Children",
  KITCHEN           AS "Kitchen Available",
  COMMON_AREA       AS "Shared Common Area",
  OWNER_OCC         AS "Owner Occupied",
  TELEVISION        AS "Television in Room",
  SMOKING           AS "Smoking allowed",
  WASHER_DRYER      AS "Washer/Dryer Available",
  POOL              AS "Pool Available",
  OTHER             AS "Other Features"
FROM AVAILABLE_ROOM AA
WHERE AA.TRAVELER_ID = *ACTIVE_TRAVELER*
AND AA.AVAIL_CHECK_DATE = (SELECT MAX(AVAIL_CHECK_DATE) AS MAX_CHECK FROM AVAILABLE_ROOM BB WHERE BB.TRAVELER_ID = AA.TRAVELER_ID GROUP BY BB.TRAVELER_ID);
   
   
   
  */