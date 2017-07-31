--15—- Insert the Payment based on the Reservation (after execute the procedure)
-- Procedure
-- Input Parameter: reservation ID, reservation start date, reservatin end date
-- Output Parameter: Table: REVENUE_PER_CITY

Create or Replace Procedure Make_Payment(
    reservation_ID RESERVATION.reserv_ID%type )
AS
  --/*
  temp_start_date       RESERVATION.reserv_start%type;
  temp_end_date         RESERVATION.reserv_end%type;
  temp_current_date     RESERVATION.reserv_start%type;
  temp_dept_ID          DEPARTMENT.dept_ID%type ;
  temp_off_ID           OFFICE.off_ID%type;
  temp_reg_ID           REGION.reg_ID%type;
  temp_room_ID         ROOM.room_ID%type;
  
  
  temp_pmnt_date        PAYMENT.pmnt_date%type ;
  temp_pmnt_ID          PAYMENT.pmnt_ID%type ;
  temp_pmnt_price       PAYMENT.pmnt_price%type ;
  
  temp_rate_begin_date  REGION_RATE.rate_begin_date%type;
  temp_region_rate      REGION_RATE.region_rate%type;
  
  temp_room_price       RESERVATION.room_price%type;
  total_room_price      RESERVATION.room_price%type;

Begin
    -- Delete old pmnt_ID, if pmnt_ID is not null
    
    Select pmnt_ID Into temp_pmnt_ID From RESERVATION Where reserv_ID = reservation_ID;
    If (temp_pmnt_ID is not null) Then
        Update RESERVATION Set pmnt_ID = null Where  reserv_ID = reservation_ID;
        Delete  From PAYMENT Where pmnt_ID = temp_pmnt_ID;
        
    End If;  
    
    -- Set up Initial Values
    Select  reserv_start, reserv_end ,
            dept_ID, off_ID,room_ID
      
      Into  temp_start_date,  temp_end_date ,
            temp_dept_ID, temp_off_ID, temp_room_ID
      
      From RESERVATION
  
      Where reserv_ID = reservation_ID;
  
  -- Query the region ID based onthe off_ID so room rate can be calculated.
      Select reg_ID into temp_reg_ID From OFFICE Where off_ID = temp_off_ID;
  
  -- Payment date is the system when execute this procedure
     Select sysdate Into temp_pmnt_date From DUAL;
     
     
     temp_current_date := temp_start_date;
     total_room_price := 0;
     
  -- Calcute the payment price based on reservation
      WHILE (temp_current_date < temp_end_date) Loop
      SELECT RR.REGION_RATE AS RATE_CHARGED INTO temp_region_rate FROM
      REGION_RATE RR
      INNER JOIN REGION RE
      ON RR.REG_ID = RE.REG_ID
        INNER JOIN ADDRESS AA
        ON TRIM(LOWER(AA.ADDRS_COUNTY)) = TRIM(LOWER(RE.COUNTY))
        INNER JOIN ROOM RO
        ON AA.ADDRS_ID = RO.ADDRS_ID
        WHERE room_ID = temp_room_ID
         
            And temp_current_date >= rate_begin_date 
            and temp_current_date <= (ADD_MONTHS(rate_begin_date ,1)-1);
       
          temp_room_price := temp_region_rate * 0.9;
      
          total_room_price := temp_room_price + total_room_price;
      
          temp_current_date := temp_current_date +1;
      
        End Loop;
      
      temp_pmnt_price := total_room_price;
    
        --Insert date into Table PAYMENT
      INSERT INTO PAYMENT(dept_ID,pmnt_date, pmnt_price)
        VALUES (temp_dept_ID, temp_pmnt_date,temp_pmnt_price);
    
      -- Update total room price into room price based on reservation.  
      Update RESERVATION Set room_price = total_room_price Where reserv_ID = reservation_ID;
      
      
      
    --Update foreign key value, current payment ID  into Table RESERVATION
    
    SELECT 'PMN'
      || LPAD( TO_CHAR(PAYMENT_PMNT_ID_SEQ.currval ),9,'0') into temp_pmnt_ID From Dual;
    
    UPDATE RESERVATION SET pmnt_ID = temp_pmnt_ID WHERE reserv_ID = reservation_ID;
  
  COMMIT;
  
  EXCEPTION
  
  WHEN no_data_found THEN
        raise_application_error (-20001, reservation_ID||'does not exist  ');
  END;
  /
  
  
  -----------------------------Test The Procedure-------------------------------
  --/*
 
  --Test 1 , Insert a new date into Table RAESERVATION and check the Table PAYMENT and RESERVATION
  Select * from RESERVATION where traveler_ID = 'EMP000000004';
  
  Insert Into RESERVATION (traveler_ID,room_ID,off_ID,dept_ID,reserv_start,reserv_end, iscanc)
  Values ('EMP000000004','ROO000000001','OFF00002','DEP000009','10-DEC-15', '14-JAN-16', 'N');

  Select * From RESERVATION Where traveler_ID ='EMP000000004';
  
  
  
  Execute Make_Payment('RES000000041');
  
  
  Select * From PAYMENT order by PMNT_ID desc;
  
  Select * From RESERVATION Where traveler_ID ='EMP000000004';
  Rollback;
  
   
  -- Test 2 , Insert a new date into Table RESERVATION and check the Table PAYMENT and RESERVATION
  Select * from RESERVATION;
  
 Insert Into RESERVATION (traveler_ID,room_ID,off_ID,dept_ID,reserv_start,reserv_end, iscanc)
  Values ('EMP000000004','ROO000000013','OFF00003','DEP000009','17-OCT-15', '14-DEC-15', 'N');
  
  Select * From RESERVATION Where traveler_ID ='EMP000000004';
  Execute Make_Payment('RES000000041');
  Select * From PAYMENT Order by PMNT_ID desc;
  Select * From RESERVATION Where traveler_ID ='EMP000000004' Order By reserv_ID Desc;
    