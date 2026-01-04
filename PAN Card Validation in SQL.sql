select * from pan_number

-- START DATA CLEANING AND PREPROCESSING.

-- 1. HANDLING THE MISSING DATA:

select * from pan_number

WHERE pan_number IS null;


--2. CHECK THE DUPLICATES.

select pan_num , count(*)
 
from pan_number

group by pan_num

having count(*)>1;

--3 Handle leading/trailing spaces

select * from pan_number
WHERE pan_num <> TRIM(pan_num)


-- Correct letter case

SELECT *
FROM pan_number
WHERE pan_num <> upper(pan_num);

-- CLEAN PAN NUMBERS

-- * FOR NULL VALUES

select * 

from pan_number

WHERE pan_number IS  NOT null;


-- * REMOVE THE DUPLICATES

Select distinct(pan_num)

from pan_number

WHERE pan_number IS  NOT null;

-- * Handle leading/trailing spaces

Select distinct TRIM(pan_num)

from pan_number

WHERE pan_number IS  NOT null

AND TRIM(pan_num) <> '';


-- * Correct letter case.

Select distinct UPPER(TRIM(pan_num)) AS pan_number

from pan_number

WHERE pan_number IS  NOT null

AND TRIM(pan_num) <> '';


-- PAN Format Validation(It is exactly 10 characters long)


SELECT * 

from pan_number

where length(pan_num) = 10;



-- The format is as follows: AAAAA1234A

--function to check the adjacent character are the same "VGLOD3180G"

CREATE OR REPLACE FUNCTION fn_check_adjacent_characaters(p_str TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    FOR i IN 1 .. (LENGTH(p_str) - 1)
    LOOP
        IF SUBSTRING(p_str, i, 1) = SUBSTRING(p_str, i + 1, 1) THEN
            RETURN TRUE;
        END IF;
    END LOOP;

    RETURN FALSE;
END;
$$;


select fn_check_adjacent_characaters('WUFAR0132H')


-- TO CHECK IF THE SEQUENCIAL CHARACTERS ARE USED

CREATE OR REPLACE FUNCTION fn_check_sequencial_characaters(p_str TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1 .. LENGTH(p_str) - 1 LOOP
        IF ASCII(SUBSTRING(p_str, i + 1, 1))
           - ASCII(SUBSTRING(p_str, i, 1)) <> 1 THEN
            RETURN FALSE;
        END IF;
    END LOOP;

    RETURN TRUE;
END;
$$;


select fn_check_sequencial_characaters('ABCDE')

--Regular expression to validate the pattern or strucuture of pan numbers.

select * from pan_number

where pan_num ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'

-- VALID AND INVALID CATEOGRIZATION

create or replace view vw_valid_invalid_pans
as
WITH cte_cleaned_pan as 
(Select distinct UPPER(TRIM(pan_num)) AS pan_number

from pan_number

WHERE pan_number IS  NOT null

AND TRIM(pan_num) <> ''),

cte_valid_pans as

(select * from cte_cleaned_pan

where fn_check_adjacent_characaters(pan_number) = false

and   fn_check_sequencial_characaters(substring(pan_number,1,5)) = false

and   fn_check_sequencial_characaters(substring(pan_number,6,4)) = false

and   pan_number ~ '^[A-Z]{5}[0-9]{4}[A-Z]$')


select cln.pan_number
, case when vld.pan_number is not null
         
		 then 'Valid pan' 
     
	 else 'Invalid pan' 
 
 end as Status


from cte_cleaned_pan cln

left join cte_valid_pans vld on vld.pan_number = cln.pan_number;


--CREATE A SUMMARY OR REPORT 

-- Valid or invalid pans
select count(*) filter(where status = 'Valid pan') as total_valid_pans
,      count(*) filter(where status = 'Invalid pan') as total_valid_pans


from  vw_valid_invalid_pans









