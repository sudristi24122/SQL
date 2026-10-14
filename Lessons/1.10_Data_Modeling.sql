SELECT
job_id,
job_title_short, 
salary_year_avg,
company_id
FROM
job_postings_fact
limit 10;

SELECT
company_id,
name 
FROM
company_dim
limit 10;
select * from information_schema.columns
where table_catalog='data_jobs';

PRAGMA show_tables_expanded;

