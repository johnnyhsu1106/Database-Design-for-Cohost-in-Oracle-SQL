
--06--Co.Host incentives paid to each user over given time periods
--Query
/*
Parameter: Start_Date: 01-Jan-15; End_date: 01-DEC-15'
Output :Total Reward Amount , called Total Incentive Paid
*/

Select EMPLOYEE.emp_ID Employee_ID, emp_first First_Name , emp_last Last_Name, 
sum(reward_amt) Partial_Incentive_Paid
From REWARD_LOG, EMPLOYEE 

Where EMPLOYEE.emp_ID = REWARD_LOG.emp_ID
 And reward_Date Between '01-JAN-15' And '31-DEC-15'

Group By EMPLOYEE.emp_ID ,emp_first, emp_last
Order By EMPLOYEE.emp_ID
;