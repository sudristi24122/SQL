SELECT
 jpf.job_id,
  jpf.job_title_short,
cd.company_id,
cd.name as company_name,
jpf.job_location
FROM
job_postings_fact as jpf
 inner join company_dim as cd
on jpf.company_id=cd.company_id
;

select
* from company_dim;


select 
jpf.job_id,
jpf.job_title_short,
sjd.skill_id,
sd.skills,

from 
    job_postings_fact as jpf
left join
    skills_job_dim as sjd
on  jpf.job_id =sjd.job_id

left join
skills_dim as sd
on sjd.skill_id =sd.skill_id;

explain
select
cd.name as company_name,
count(jpf.job_id) as number_of_posting
from
    job_postings_fact as jpf
left join 
    company_dim as cd
on 
    jpf.company_id=cd.company_id
where
jpf.job_country='United States'
group by 
   cd.name
having 
number_of_posting>3000
order  by number_of_posting desc
limit 10;

select distinct job_title_short from job_postings_fact;