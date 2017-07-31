--10--Number of bookings in a given city over a given period of time

/*
Parameter:
          city = 'San Diego'
          start date = '01-JAN-15'
          end date = '01-JAN-16'
Output :, Output : room ID,room price, address
*/

Select addrs_city CITY, count(reserv_ID) Partial_No_Reservation
From ADDRESS, ROOM , RESERVATION 
Where ADDRESS.addrs_ID = ROOM.addrs_ID And ROOM.room_ID = RESERVATION.room_ID
And reserv_start  >= '01-JAN-15'
And reserv_end  <=  '01-JAN-16'
AND reserv_ID not in(Select reserv_ID from CANCELLATION)
Group By addrs_city
Order By addrs_city
;