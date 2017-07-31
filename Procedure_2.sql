--2--Co.Host revenues per city over given time periods

-----------------------------Create Table------------------------------- 
/*
DROP TABLE JABBERWOCKY.REVENUE_PER_CITY CASCADE CONSTRAINTS;
CREATE TABLE JABBERWOCKY.REVENUE_PER_CITY
  (
    REVPER_ID    VARCHAR(12) CONSTRAINT REVENUE_PER_CITY_REVPERID_PK PRIMARY KEY ,
    CITY         VARCHAR(200),
    STARTDATE    DATE,
    ENDDATE      DATE,
    TOTALREVENUE DECIMAL(24,6)
  );
*/
----------------------------Create Sequence for Revenue_ID
/*
CREATE OR REPLACE TRIGGER TRIG_REV_SEQ BEFORE
  INSERT ON JABBERWOCKY.REVENUE_PER_CITY FOR EACH ROW DECLARE TEMP_REV_NO JABBERWOCKY.REVENUE_PER_CITY.REVENUE_ID%TYPE ;
  BEGIN
    SELECT 'REV'
      || LPAD( TO_CHAR(REVENUE_PER_CITY_REVPER_ID_SEQ.NEXTVAL ),9,'0')
    INTO TEMP_REV_NO
    FROM DUAL;
    :NEW.REVENUE_ID := TEMP_REV_NO ;
  END ;

*/
-------------------------------Procedure ------------------------------- 

-- Input Parameter: city, start_date, end_date  
-- Output: Insert into Table REVENUE_PER_CITY
-- Procedure Format: Revenue_For_Period ('01-JAN-15', '31-JAN-15')

Create or Replace Procedure Revenue_For_Period
( 
start_date PAYMENT.pmnt_date%type,
end_date PAYMENT.pmnt_date%type
)

--Return PAYMENT.pmnt_price%type

IS

-- Declare the Variable

Cursor C1 is Select addrs_city, pmnt_date, pmnt_price 
From ADDRESS, ROOM, RESERVATION, PAYMENT 
Where ADDRESS.addrs_ID = ROOM.addrs_ID 
  And ROOM.room_ID = RESERVATION.room_ID
  And RESERVATION.pmnt_ID = PAYMENT.pmnt_ID   
  And reserv_ID not in (Select reserv_ID from CANCELLATION)
  And pmnt_date >= start_date and pmnt_date  <=  end_date
;

Cursor C2 is Select distinct addrs_city from ADDRESS; 

temp_city ADDRESS.addrs_city%type;  
temp_revenue PAYMENT.pmnt_price%type ;
total_revenue PAYMENT.pmnt_price%type;

Begin
    
    
    
    Delete From REVENUE_PER_CITY; 
    
    For C2_row in C2 Loop
        
        temp_revenue:= 0;
        total_revenue:=0;
        temp_city := C2_row.addrs_city;
      
      For C1_row in C1 Loop
          If (C1_row.addrs_city = temp_city) Then      
            temp_revenue := C1_row.pmnt_price ;
            total_revenue := temp_revenue + total_revenue ;
          End If;
          
      End Loop;
      
      Insert into REVENUE_PER_CITY (City,StartDate, EndDate,TotalRevenue) 
        values(temp_city, start_date, end_date, total_revenue);
        
    End Loop;
    
     
End;
/

commit;

-----------------------------Test The Procedure------------------------------- /*
/*

Execute  Revenue_For_Period('01-Jan-15','31-JAN-16') ;
Select * from REVENUE_PER_CITY order by city;

Execute  Revenue_For_Period( '01-Jan-15','31-DEC-16') ;
Select * from REVENUE_PER_CITY ;
Execute  Revenue_For_Period('21-May-15','30-SEP-15') ;
Select * from REVENUE_PER_CITY ;
*/
