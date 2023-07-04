-- Extracts the number of mutants for each omim entry where
-- there is a mapping to SwissProt and the numbering has been 
-- mapped successfully
-- ACRM 17.02.11
-- select   omim, count(record) from sws_mutant
-- where    valid = 't'
-- group by omim 
-- order by count(record);

select   omim, ac, count(record) from sws_mutant
where    valid = 't'
group by omim, ac 
order by count(record);
