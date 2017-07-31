--08--Top 10 booked rooms and addresses

/*
Parameter:  
          rownum <= 3  means taht choose the top 3
          start date = '01-JAN-15'
          end date = '01-JAN-16'
Output : room ID,room price, address, number of reservation 
*/
Select *
  from 
  (
  Select ROOM.room_ID ROOM_ID,  
        addrs_zip Zip_Code, addrs_street Street, 
        addrs_city City, addrs_state State, addrs_country Country, 
        count(reserv_ID) Partial_No_Reservation
  
  From ADDRESS, ROOM, RESERVATION
  
  Where ADDRESS.addrs_ID = ROOM.addrs_ID 
  And ROOM.room_ID = RESERVATION.room_ID
  And reserv_start >= '01-JAN-15' 
  And reserv_end  <=  '01-JAN-16'
  AND reserv_ID not in(Select reserv_ID from CANCELLATION)
  
  Group by ROOM.room_ID,addrs_zip,addrs_street, addrs_city, addrs_state, addrs_country
  Order by count(reserv_ID) desc 
  )
  where rownum <= 10;