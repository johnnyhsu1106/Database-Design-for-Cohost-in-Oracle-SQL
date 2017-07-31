--03--Companies' respective spends through the Co.Host platform over given time periods
-- Query

/*
Parameter: Start_Date: 01-Jan-15; End_date: 31-DEC-15'
Output :Companies' respective spends
*/

Select COMPANY.co_ID Company_ID, co_name Company_Name, sum(pmnt_price) Partial_Spend_Amount
From RESERVATION,PAYMENT, DEPARTMENT, COMPANY
  Where PAYMENT.dept_ID = DEPARTMENT.dept_ID
  And   DEPARTMENT.co_ID = COMPANY.co_ID
  And   PAYMENT.pmnt_ID = RESERVATION.pmnt_ID
  
  And  pmnt_date Between '01-JAN-15' and '31-DEC-15'
  And  iscanc = 'N'
  
  Group By COMPANY.co_ID, co_name
  Order by co_name
  ;