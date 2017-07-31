
-------------------------------Trigger ------------------------------- 
--14—- Automatically Update Totol_Department_Spend,Total_Company_Spend, 
--After Insert or Update of pmnt_price on PAYMENT

-- Event:  
-- Trigger: 

Create or Replace Trigger Trig_Dept_Company_Spend Before Insert or 
Update Of pmnt_price,dept_ID on PAYMENT 
For Each Row

Declare
  temp_tot_dept_spend DEPARTMENT.tot_dept_spend%type ;
  temp_tot_co_spend COMPANY.total_co_spend%type ;
  temp_pmnt_price PAYMENT.pmnt_price%type;
  temp_co_ID COMPANY.co_ID%type;
  
  temp_tot_old_dept_spend DEPARTMENT.tot_dept_spend%type ;
  temp_tot_new_dept_spend DEPARTMENT.tot_dept_spend%type ;
  
   
Begin
/*
    If Updating('pmnt_ID') Then
      If Updating ('dept_ID') Then
        
        Select tot_dept_spend into temp_tot_old_dept_spend
          From DEPARTMENT Where dept_ID = : old.dept_ID ;  
          
        Select tot_dept_spend into temp_tot_new_dept_spend
          From DEPARTMENT Where dept_ID = : new.dept_ID ;  
          
        Select co_ID into temp_co_ID
          From DEPARTMENT Where dept_ID = : old.dept_ID ;      
        
        Select total_co_spend into temp_tot_co_spend 
          From COMPANY Where co_ID = temp_co_ID ;  
        
        -- Update total departmental spend
        temp_tot_old_dept_spend := temp_tot_old_dept_spend + : old.pmnt_price;
        temp_tot_new_dept_spend := temp_tot_new_dept_spend - : new.pmnt_price;
          
       -- Update total company's spend
        temp_tot_co_spend := temp_tot_co_spend - : old.pmnt_price + : new.pmnt_price;
        
        
        Update DEPARTMENT Set tot_dept_spend = temp_tot_old_dept_spend 
          Where dept_ID = : old.dept_ID;
          
        Update DEPARTMENT Set tot_dept_spend = temp_tot_new_dept_spend 
          Where dept_ID = : new.dept_ID;
        
        Update COMPANY Set total_co_spend = temp_tot_co_spend 
          Where co_ID =  temp_co_ID;
      
      End If;
*/
    If (Inserting)Then
    
        Select tot_dept_spend,co_ID into temp_tot_dept_spend, temp_co_ID
          From DEPARTMENT Where dept_ID = : new.dept_ID ;      
              
        Select total_co_spend into temp_tot_co_spend 
          From COMPANY Where co_ID = temp_co_ID ;      
        
        temp_tot_dept_spend := temp_tot_dept_spend + : new.pmnt_price;
        temp_tot_co_spend := temp_tot_co_spend + : new.pmnt_price;
        
        Update DEPARTMENT Set tot_dept_spend = temp_tot_dept_spend 
          Where dept_ID = : new.dept_ID;
        
        Update COMPANY Set total_co_spend = temp_tot_co_spend 
          Where co_ID = temp_co_ID ;         
    
    End IF;   
    
    If (Updating ('pmnt_price')) Then
    
        Select tot_dept_spend, co_ID into temp_tot_dept_spend, temp_co_ID
          From DEPARTMENT Where dept_ID = : old.dept_ID ;      
        
        Select total_co_spend into temp_tot_co_spend 
          From COMPANY Where co_ID = temp_co_ID ;      
    
        -- Update total departmental spend
        temp_tot_dept_spend := temp_tot_dept_spend - : old.pmnt_price;
        temp_tot_dept_spend := temp_tot_dept_spend + : new.pmnt_price;
          
       -- Update total company's spend
        temp_tot_co_spend := temp_tot_co_spend - : old.pmnt_price;
        temp_tot_co_spend := temp_tot_co_spend + : new.pmnt_price;
        
        Update DEPARTMENT Set tot_dept_spend = temp_tot_dept_spend 
          Where dept_ID = : old.dept_ID;
        
        Update COMPANY Set total_co_spend = temp_tot_co_spend 
          Where co_ID =  temp_co_ID;
     
     End If;     
     
     If (Updating ('dept_ID')) Then
     
         
        Select tot_dept_spend into temp_tot_old_dept_spend
          From DEPARTMENT Where dept_ID = : old.dept_ID ;  
          
        Select tot_dept_spend into temp_tot_new_dept_spend
          From DEPARTMENT Where dept_ID = : new.dept_ID ;  
          
        
        -- Update total departmental spend
        temp_tot_old_dept_spend := temp_tot_old_dept_spend - : old.pmnt_price;
        temp_tot_new_dept_spend := temp_tot_new_dept_spend + : old.pmnt_price;
          
        
        Update DEPARTMENT Set tot_dept_spend = temp_tot_old_dept_spend 
          Where dept_ID = : old.dept_ID;
        
        Update DEPARTMENT Set tot_dept_spend = temp_tot_new_dept_spend 
          Where dept_ID = : new.dept_ID;
              
    End If;
  

End;
/
commit;

-----------------------------Test The Trigger------------------------------- 
/*
-- Test Isert --
Select * from PAYMENT Where DEPT_ID = 'DEP000007' ;
Select * from DEPARTMENT Where DEPT_ID = 'DEP000007';
Select * from COMPANY Where CO_ID = 'CO_00001'; 

Insert into PAYMENT(DEPT_ID,PMNT_DATE, PMNT_PRICE) Values ('DEP000007', '01-JAN-16', 1000);
Select * from PAYMENT Where DEPT_ID = 'DEP000007' ;
Select * from DEPARTMENT Where DEPT_ID = 'DEP000007';
Select * from COMPANY Where CO_ID = 'CO_00001'; 
--Update DEPARTMENT set tot_dept_spend = 10775 where dept_ID = 'DEP000009';
-- Test Update Payment Price --
Select * from PAYMENT Where DEPT_ID = 'DEP000007' ;
Update PAYMENT Set PMNT_PRICE = 2000 Where DEPT_ID = 'DEP000007' And PMNT_DATE ='01-JAN-16'; 
Select * from PAYMENT Where DEPT_ID = 'DEP000007' ;
Select * from DEPARTMENT Where DEPT_ID = 'DEP000007';
Select * from COMPANY Where CO_ID = 'CO_00001'; 
--Update COMPANY set total_co_spend = 15337.8 where co_ID = 'CO_00001';
--Update DEPARTMENT set tot_dept_spend = 8775 where dept_ID = 'DEP000009';

Rollback;
-- Test Update Department ID --
Select * from PAYMENT Where DEPT_ID = 'DEP000009' ;
Select * from DEPARTMENT Where DEPT_ID = 'DEP000009';
Select * from PAYMENT Where DEPT_ID = 'DEP000007' ;
Update PAYMENT Set DEPT_ID = 'DEP000009' Where PMNT_ID ='PMN000000059' ; 
Select * from PAYMENT Where DEPT_ID = 'DEP000009' order by pmnt_ID desc;
Select * from DEPARTMENT Where DEPT_ID = 'DEP000009';
Select * from DEPARTMENT Where DEPT_ID = 'DEP000007';
Select * from DEPARTMENT Where DEPT_ID = 'DEP000010';


Select * from COMPANY Where CO_ID = 'CO_00001'; 

Rollback;
-- Test Update Department ID & Payment Amount--
Select * from PAYMENT Where DEPT_ID = 'DEP000007'or DEPT_ID = 'DEP000009' or DEPT_ID= 'DEP000010' order by dept_ID ;

Update PAYMENT Set DEPT_ID = 'DEP000010', PMNT_PRICE = 3000 Where PMNT_ID ='PMN000000059' ; 
Select * from PAYMENT Where DEPT_ID = 'DEP000010' order by pmnt_ID desc;
Select * from DEPARTMENT Where DEPT_ID = 'DEP000010';
Select * from PAYMENT Where DEPT_ID = 'DEP000009' order by pmnt_ID desc;
Select * from DEPARTMENT Where DEPT_ID = 'DEP000009';

Select * from PAYMENT Where DEPT_ID = 'DEP000007' order by pmnt_ID desc;
Select * from DEPARTMENT Where DEPT_ID = 'DEP000007';

Select * from COMPANY Where CO_ID = 'CO_00001'; 
rollback;
*/