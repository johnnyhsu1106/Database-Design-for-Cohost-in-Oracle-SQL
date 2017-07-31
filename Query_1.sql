--01--Top destination cities for Co.Host overall

/*
--Parameter:  rownum <= 3  means taht choose the top 3 
--Output : City, Number of Reservation 
*/


Select *
  from 
  (
  Select addrs_city City,count(reserv_ID) Total_No_Reservation
  From ADDRESS, ROOM, RESERVATION
  
  Where ADDRESS.addrs_ID = ROOM.addrs_ID 
  And ROOM.room_ID = RESERVATION.room_ID
  AND reserv_ID not in(Select reserv_ID from CANCELLATION)
  
  Group by addrs_city
  Order by count(reserv_ID) desc 
  )
  where rownum <= 10;
  