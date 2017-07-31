--04- Departmental spends for a given company through the Co.Host platform over a given time period
/*
Parameter:  company name, start_date, end_date  
Output : company name, department name, departmental spend
*/

Select co_name COMPANY_NAME, dept_name DEPARTMENT_NAME, Sum (pmnt_price) Partial_Spend_Amount
From PAYMENT, DEPARTMENT, COMPANY

Where PAYMENT.dept_ID = DEPARTMENT.dept_ID 
  And DEPARTMENT.co_ID = COMPANY.co_ID
  
  And (pmnt_date >= '01-JAN-15' And pmnt_date  <=  '01-JAN-16')
  And Co_name = 'Intuit'
  --And dept_name = 'Marketing'
  
  Group by co_name, dept_name
  Order by dept_name
  ;
