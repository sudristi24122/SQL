/* =====================================================================
   JOIN PRACTICE TEST  —  data_jobs database
   Write your answer under each question. Run it. Then paste your query
   back to Claude to be marked. Do NOT look up answers first — guess!

   Tables:
     job_postings_fact (jpf) : job_id, job_title_short, job_title,
                               salary_year_avg, company_id, job_location,
                               job_schedule_type, job_work_from_home,
                               job_posted_date
     company_dim      (cd)   : company_id, name
     skills_job_dim   (sjd)  : job_id, skill_id        <- bridge table
     skills_dim       (sd)   : skill_id, skills, type
   ===================================================================== */


/* ---------- WARM-UP: review before joins (SELECT / WHERE / GROUP BY / HAVING) ---------- */

-- Q1 (easy): Show job_id, job_title_short and salary_year_avg for the
--            first 10 rows of job_postings_fact.

select 
  job_id,
  job_title_short,
  salary_year_avg
from job_postings_fact
limit 10;


-- Q2 (easy): Show only 'Data Analyst' jobs (job_title_short), returning
--            job_id and salary_year_avg, where salary_year_avg is not null.

select 
  job_id,
  job_title_short,
  salary_year_avg
from
  job_postings_fact
where
  job_title_short='Data Analyst' and 
  salary_year_avg is not null;


-- Q3 (medium): For each job_title_short, show how many job postings there are.
--              Order from most postings to least.
select
job_title_short,
count( job_title_short) as job_postings
from
job_postings_fact
group by job_title_short
order by job_postings desc;


-- Q4 (medium): For each job_title_short, show the average salary_year_avg,
--              but only keep titles whose average salary is above 100000.
--              (Think: WHERE vs HAVING — which one filters a group aggregate?)

select 
  job_title_short,
 avg(salary_year_avg) as average_salary
from 
  job_postings_fact

group by 
  job_title_short
having
 avg(salary_year_avg) >100000;


/* ---------- JOINS: two tables ---------- */

-- Q5 (easy): INNER JOIN job_postings_fact to company_dim.
--            Return job_id, job_title_short, and the company name.



select
   jpf.job_id,
   jpf.job_title_short,
   cd.name as company_name
from
    job_postings_fact as jpf
inner join
  company_dim as cd
on
jpf.company_id= cd.company_id;



-- Q6 (medium): Return job_id, job_title_short and company name for
--              'Data Engineer' jobs only. Use a join.
select
jpf.job_id,
jpf.job_title_short,
cd.name as company_name
from Job_postings_fact as jpf
left join company_dim as cd
on 
  jpf.company_id=cd.company_id
where
job_title_short='Data Engineer';

-- Q7 (medium): Which company (name) posted the most jobs?
--              Return the company name and the number of postings,
--              highest first. Use a join + GROUP BY.

select 
 cd.name as company_name,
count ( jpf.job_title_short) as number_of_postings
from 
  job_postings_fact as jpf
left join 
  company_dim as cd
on
jpf.company_id=cd.company_id
group by company_name
order by number_of_postings desc;





-- Q8 (medium/hard): Use a LEFT JOIN from company_dim to job_postings_fact.
--              Think first: what does a LEFT JOIN give you here that an
--              INNER JOIN would NOT? Write the query, then write a one-line
--              comment explaining the difference.




/* ---------- JOINS: three tables (the new stuff) ---------- */

-- Q9 (medium): Join job_postings_fact -> skills_job_dim -> skills_dim.
--              Return job_id, job_title_short and the skill name (skills)
--              for the first 20 rows.




select
jpf.job_id,
jpf.job_title_short,
sd.skills

from
job_postings_fact as jpf
left  join skills_job_dim as sjd
on jpf.job_id=sjd.job_id

left  join skills_dim as sd
on sd.skill_ID=sjd.skill_id;





-- Q10 (hard): What are the 5 most-requested skills across ALL job postings?
--             Return the skill name and how many times it appears, highest first.


select 
sd.skills,
count(sd.skills) as most_requested_skills

from
job_postings_fact as jpf
left join skills_job_dim as sjd
on 
 jpf.job_id=sjd.job_id
left join skills_dim as sd
on 
sjd.skill_id=sd.skill_id

group by
sd.skills
order by
most_requested_skills desc
limit 5;




-- Q11 (hard): What are the top 5 skills specifically for 'Data Analyst' jobs?
--             Return skill name and count, highest first.


select 
sd.skills,
count(sd.skills) as number_of_request
from
  job_postings_fact as jpf
left join 
  skills_job_dim as sjd
on jpf.job_id=sjd.job_id
left join
  skills_dim as sd
on
  sjd.skill_id=sd.skill_id
where 
  jpf.job_title_short ='Data Analyst'

Group by 
  skills
order by 
  number_of_request desc
limit 5;
  

-- Q12 (hard, 4 tables): For 'Data Scientist' jobs, show the company name and
--             the skill name. Join all four tables. Limit to 20 rows.
--             (job_postings_fact + company_dim + skills_job_dim + skills_dim)

select 
cd.name as company_name,
sd.skills as skill_name
from job_postings_fact as jpf
left join skills_job_dim as sjd
on jpf.job_id=sjd.job_id

left join skills_dim as sd
on sjd.skill_id=sd.skill_id

left join company_dim as cd
on jpf.company_id=cd.company_id

where 
jpf.job_title_short='Data Scientist'

limit 20;

/* ---------- BONUS (stretch) ---------- */

-- Q13: For each skill (skills), show the average salary_year_avg of the
--      jobs that require it (ignore null salaries). Show the top 10 skills
--      by average salary, highest first.
--skills, job_title_short, average_salary, limit 10 desc,
select
sd.skills,
avg(salary_year_avg) as average_salary 

from 
job_postings_fact as jpf
left join skills_job_dim as sjd
on jpf.job_id=sjd.job_id

left join skills_dim as sd
on sjd.skill_id=sd.skill_id

where salary_year_avg is not null

group by sd.skills
order by  avg(salary_year_avg) desc
limit 10;