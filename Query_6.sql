--07--Current awards levels of individual users

/*
--Parameter:   
--Output : employee ID,total reward amount 
*/

Select EMPLOYEE.emp_ID  EMPLOYEE_ID, emp_first First_Name ,emp_last Last_Name ,email, 
reward_type, reward_name, current_rew_lvl,
sum(reward_amt) TOTAL_REWARD_AMOUNT
From EMPLOYEE, REWARD_LOG , PAYMENT, REWARD_SYSTEM 
Where EMPLOYEE.emp_ID = REWARD_LOG.emp_ID 
  And PAYMENT.pmnt_ID = REWARD_LOG.pmnt_ID
  And REWARD_SYSTEM.reward_ID = EMPLOYEE.reward_ID
  
  Group by EMPLOYEE.emp_ID, emp_first, emp_last, email , reward_type, reward_name, current_rew_lvl
  Order by EMPLOYEE.emp_ID;
