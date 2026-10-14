select 
sd.skills as skills,
count(jpf.job_id) as demand_count
from 
job_postings_fact as jpf
inner join skills_job_dim as sjd
on 
    jpf.job_id=sjd.job_id
inner join skills_dim as sd
on sjd.skill_id=sd.skill_id
where jpf.job_title_short='Data Engineer'
and jpf.job_work_from_home= True
group by skills
order by demand_count desc
limit 10;
/*
┌───────────────────────────┐
│      job_title_short      │
│          varchar          │
├───────────────────────────┤
│ Machine Learning Engineer │
│ Cloud Engineer            │
│ Senior Data Analyst       │
│ Senior Data Engineer      │
│ Software Engineer         │
│ Data Analyst              │
│ Business Analyst          │
│ Data Scientist            │
│ Senior Data Scientist     │
│ Data Engineer             │
└───────────────────────────┘
           10 rows         
*/

/*
Question: What are the highest-paying skills for data engineers?
- Calculate the median salary for each skill required in data engineer positions
- Focus on remote positions with specified salaries
- Include skill frequency to identify both salary and demand
- Why? Helps identify which skills command the highest compensation while also showing 
    how common those skills are, providing a more complete picture for skill development priorities
*/
select
sd.skills as skills,
 round(
median(jpf.salary_year_avg),0)  as median_salary,
count(sd.skills) as skills_frequency
from
    job_postings_fact as jpf
inner join
    skills_job_dim as sjd
on 
    jpf.job_id=sjd.job_id
inner join
    skills_dim as sd
on
    sjd.skill_id=sd.skill_id
where
    jpf.job_title_short='Data Engineer' and jpf.job_work_from_home=true
group by
    sd.skills
order by
median_salary desc 
limit 25;
/*
Question: What are the most optimal skills for data engineers—balancing both demand and salary?
- Create a ranking column that combines demand count and median salary to identify the most valuable skills.
- Focus only on remote Data Engineer positions with specified annual salaries.
- Why?
    - This approach highlights skills that balance market demand and financial reward. It weights core skills appropriately instead of letting rare, outlier skills distort the results.
    - The natural log transformation ensures that both high-salary and widely in-demand skills surface as the most practical and valuable to learn for data engineering careers.
*/
select
sd.skills as skills,
 round(median(jpf.salary_year_avg),0)  as median_salary,
 ln(count(jpf.*))as demand_count,
median(jpf.salary_year_avg)*ln(count(jpf.*))as optimal_score
from
    job_postings_fact as jpf
inner join
    skills_job_dim as sjd
on 
    jpf.job_id=sjd.job_id
inner join
    skills_dim as sd
on
    sjd.skill_id=sd.skill_id
where
    jpf.job_title_short='Data Engineer'
     and
      jpf.job_work_from_home=true
    and  jpf.salary_year_avg is not null
group by
    sd.skills
order by
optimal_score desc
limit 25;



SELECT 
    sd.skills,
    ROUND(MEDIAN(jpf.salary_year_avg), 1) AS median_salary,
    COUNT(jpf.*) AS demand_count,
    ROUND(LN(COUNT(jpf.*)), 1) AS ln_demand_count,
    ROUND((LN(COUNT(jpf.*)) * MEDIAN(jpf.salary_year_avg))/1_000_000, 2) AS optimal_score
FROM job_postings_fact jpf
INNER JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
WHERE
    jpf.job_title_short = 'Data Engineer'
    AND jpf.salary_year_avg IS NOT NULL
    AND jpf.job_work_from_home = True 
GROUP BY
    sd.skills
HAVING 
    COUNT(sjd.job_id) >= 100
ORDER BY
    optimal_score DESC
LIMIT 25;

select distinct 
job_country
from job_postings_facts;
