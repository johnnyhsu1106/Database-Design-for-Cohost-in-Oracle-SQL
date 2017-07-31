create or replace TRIGGER TRIG_CAN_SEQ BEFORE
  INSERT ON CANCELLATION
  FOR EACH ROW
  DECLARE
  TEMP_CAN_NO CANCELLATION.CANC_ID%TYPE ;
  TEMP_CANC_LIMIT CANCELLATION.CANC_LIMIT%TYPE;
  TEMP_REF_AMT CANCELLATION.REF_AMT%TYPE;
  TEMP_RES_START RESERVATION.RESERV_START%TYPE;
  TEMP_IS_CANC RESERVATION.ISCANC%TYPE;
  TEMP_CANC_DATE CANCELLATION.CANC_DATE%TYPE;
  temp_tot_dept_spend DEPARTMENT.tot_dept_spend%type ;
  temp_tot_co_spend COMPANY.total_co_spend%type ;
  TEMP_DEPT_ID DEPARTMENT.DEPT_ID%TYPE;
  TEMP_CO_ID COMPANY.CO_ID%TYPE;
  
BEGIN
  --Insert the cancellation number
  SELECT 'CAN'
    || LPAD( TO_CHAR(CANCELLATION_CANC_ID_SEQ.NEXTVAL ),9,'0')
  INTO TEMP_CAN_NO
  FROM DUAL;
  :new.CANC_ID := TEMP_CAN_NO ;
  
  --Handle duplicate cancellation errors
  SELECT ISCANC INTO TEMP_IS_CANC FROM RESERVATION 
  WHERE RESERV_ID = :new.reserv_ID;
  IF (TEMP_IS_CANC = 'Y') THEN
  raise_application_error(-20404, 'This reservation has already been cancelled.');
  
  ELSE
  TEMP_CANC_DATE := SYSDATE;  --assign the canc_date
  TEMP_IS_CANC := 'Y';  --mark the reservation as cancelled
  SELECT RESERV_START INTO TEMP_RES_START
  FROM RESERVATION WHERE RESERV_ID = :new.RESERV_ID;
  TEMP_CANC_LIMIT := TEMP_RES_START - 1;  --determine the last refundable canc_date
  
  IF (SYSDATE <= TEMP_CANC_LIMIT) THEN
    SELECT PMNT_PRICE INTO TEMP_REF_AMT
    FROM RESERVATION r JOIN PAYMENT p ON r.PMNT_ID = p.PMNT_ID
    WHERE RESERV_ID = :new.RESERV_ID;  --determine ref amt for timely canc
  ELSE
    TEMP_REF_AMT := 0;  --no refund for late cancellation
  END IF;
  
  --insert values for canc_limit, ref_amt, and canc_date in the CANCELLATION table
  :new.CANC_LIMIT := TEMP_CANC_LIMIT;
  :new.REF_AMT := TEMP_REF_AMT;
  :new.CANC_DATE := TEMP_CANC_DATE;
  UPDATE RESERVATION SET isCanc = TEMP_IS_CANC  --update cancellation state
  WHERE RESERV_ID = :new.RESERV_ID;             --in RESERVATION table
  
  --update the total department spend to subtract refund
  SELECT tot_dept_spend,r.DEPT_ID INTO temp_tot_dept_spend, TEMP_DEPT_ID
  FROM RESERVATION r JOIN DEPARTMENT d ON r.DEPT_ID = d.DEPT_ID
  WHERE r.RESERV_ID = :new.reserv_ID;
  temp_tot_dept_spend := temp_tot_dept_spend - TEMP_REF_AMT;
  
  Update DEPARTMENT Set tot_dept_spend = temp_tot_dept_spend 
  Where dept_ID = TEMP_DEPT_ID;
      
  --update total company spend to subtract refund
  SELECT total_co_spend, c.CO_ID INTO temp_tot_co_spend, TEMP_CO_ID
  FROM RESERVATION r JOIN DEPARTMENT d ON r.DEPT_ID = d.DEPT_ID
  JOIN COMPANY c ON d.CO_ID = c.CO_ID
  WHERE r.RESERV_ID = :new.reserv_ID;
  temp_tot_co_spend := temp_tot_co_spend - TEMP_REF_AMT;
  
  Update COMPANY Set total_co_spend = temp_tot_co_spend 
  Where co_ID = temp_co_ID ; 

  END IF;
END ;
/
