--09--Rooms and addresses that have never been booked

/*
Parameter: 
          start date = '01-JAN-15'
          end date = '01-JAN-16'
Output :, Output : room ID,room price, address
*/
Select  room_ID, 
        addrs_zip Zip_Code, addrs_street Street, 
        addrs_city City, addrs_state State, addrs_country Country
  from ROOM, ADDRESS
  where
    ROOM.addrs_ID = ADDRESS.addrs_ID
  AND
  room_ID Not in 
  (
  Select ROOM.room_ID 
  
  From ADDRESS, ROOM, RESERVATION
  
  Where ADDRESS.addrs_ID = ROOM.addrs_ID 
  And ROOM.room_ID = RESERVATION.room_ID
  And reserv_start >= '01-JAN-15' 
  And reserv_end  <=  '01-JAN-16' 
  AND reserv_ID not in (Select reserv_ID from CANCELLATION)
  )
  order by room_ID
  ;
  