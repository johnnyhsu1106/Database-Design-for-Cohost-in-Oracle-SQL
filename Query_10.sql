-- How many groups does a traveler stay with a host.



select count (*) as "Shared stay count", final."A" as "Employee 1", final."B" as "Employee 2" from
(select resr.traveler_ID as "A", A.host_ID as "B"  from reservation resr ,address A, room R, (select distinct AA.traveler_ID as "T1" ,AA.host_ID as "H1" from
(select resr.traveler_ID, A.host_ID  from reservation resr ,address A, room R
where R.addrs_ID=A.addrs_ID
and  R.room_ID= resr.room_ID ) AA,
(select resr.traveler_ID, A.host_ID  from reservation resr ,address A, room R
where R.addrs_ID=A.addrs_ID
and  R.room_ID= resr.room_ID ) BB
where AA.host_ID=BB.traveler_ID and BB.host_ID=AA.traveler_ID and
SUBSTR(AA.traveler_ID, 4, 12) > SUBSTR(AA.host_ID,4, 12)) grp2
where R.addrs_ID=A.addrs_ID
and  R.room_ID= resr.room_ID 
and grp2."T1"=resr.traveler_ID
and grp2."H1"=A.host_ID
Union All
select A.host_ID as "A", resr.traveler_ID as "B"  from reservation resr ,address A, room R, (select distinct AA.traveler_ID as "T1" ,AA.host_ID as "H1" from
(select resr.traveler_ID, A.host_ID  from reservation resr ,address A, room R
where R.addrs_ID=A.addrs_ID
and  R.room_ID= resr.room_ID ) AA,
(select resr.traveler_ID, A.host_ID  from reservation resr ,address A, room R
where R.addrs_ID=A.addrs_ID
and  R.room_ID= resr.room_ID ) BB
where AA.host_ID=BB.traveler_ID and BB.host_ID=AA.traveler_ID and
SUBSTR(AA.traveler_ID, 4, 12) < SUBSTR(AA.host_ID,4, 12)) grp1
where R.addrs_ID=A.addrs_ID
and  R.room_ID= resr.room_ID 
and grp1."T1"=resr.traveler_ID
and grp1."H1"=A.host_ID) final
GROUP by final."A", final."B"
