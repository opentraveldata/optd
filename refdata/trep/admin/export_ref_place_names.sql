--
-- Export data from the ref_place_names table
--
select concat_ws(',', language_code, code, classical_name, extended_name, 
	   alternate_name1, alternate_name2, alternate_name3, alternate_name4, 
	   alternate_name5, alternate_name6, alternate_name7, alternate_name8, 
	   alternate_name9, alternate_name10)
from ref_place_names;

