SELECT :1, RTRIM((XMLAGG(XMLELEMENT(E,UPPER(:2 || '.' || column_name),', ')ORDER BY column_id).EXTRACT('//text()')).getclobval(),',') very_long_text--,
--       LISTAGG(UPPER(:2 || '.' || column_name), ', ') WITHIN GROUP (ORDER BY column_id) column_list
FROM all_tab_columns
WHERE table_name = :1
GROUP BY :1
ORDER BY :1;

--FIND KEYs in a record
SELECT RECNAME, FIELDNAME, (TRUNC((USEEDIT/1),0) - TRUNC((USEEDIT/2),0) * 2) KEY, (TRUNC((USEEDIT/2),0) - TRUNC((USEEDIT/4),0) * 2) DUPORDERKEY, 
       (TRUNC((USEEDIT/256),0) - TRUNC((USEEDIT/512),0) * 2) REQUIRED 
FROM PSRECFIELD 
WHERE RECNAME = 'DISTRIB_LINE'
ORDER BY 3 DESC;
