DECLARE


CURSOR CR_1 IS 
select * 
from tgc_exp_btr_lines s
where 1=1 
and s.btr_id =1 
and total_amount =0
order by element_name asc;


BEGIN 

For x in cr_1 loop 
  
dbms_output.put_line(x.element_name);

end loop;


END;
