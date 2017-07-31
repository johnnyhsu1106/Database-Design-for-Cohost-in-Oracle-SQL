
--5--Top destination cities for a given company over a given time period
/*
Parameter: company name = 'SAP'  
          start date = '01-JAN-15' , end_date = ''01-JAN-16
          rownum <= 3  means taht choose the top 3 
--Output : city, company name,  number of Reservation 

*/
Select *
  from 
  (
  Select co_name Company_Name, addrs_city City,  count(reserv_ID) Partial_No_Reservation

  From ADDRESS, ROOM, RESERVATION, TRAVELER, EMPLOYEE, DEPARTMENT, COMPANY
  
  Where ADDRESS.addrs_ID = ROOM.addrs_ID 
  And ROOM.room_ID = RESERVATION.room_ID
  And RESERVATION.traveler_ID = TRAVELER.traveler_ID
  And TRAVELER.traveler_ID = EMPLOYEE.emp_ID
  And EMPLOYEE.dept_ID = DEPARTMENT.dept_ID
  And DEPARTMENT.co_ID = COMPANY.CO_ID
  
  And co_name = 'SAP' 
  And reserv_start >= '01-JAN-15' 
  And reserv_end  <=  '01-JAN-16'
  AND reserv_ID not in(Select reserv_ID from CANCELLATION)
  
  
  Group By co_name , addrs_city 
  Order By count(reserv_ID) desc 
  )
  Where Rownum <= 5
 
  ;
  