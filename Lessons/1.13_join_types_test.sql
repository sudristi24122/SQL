/* =====================================================================
   JOIN TYPES TEST  —  data_jobs database
   Topic: INNER vs LEFT vs RIGHT vs FULL OUTER vs CROSS JOIN.
   Write your answer under each question, run it, then paste to Claude.

   Tables:
     job_postings_fact (jpf) : job_id, job_title_short, salary_year_avg,
                               company_id, ...
     company_dim      (cd)   : company_id, name
     skills_job_dim   (sjd)  : job_id, skill_id        <- bridge table
     skills_dim       (sd)   : skill_id, skills, type

   Reminder: companies 'Orbit Systems' & 'Hollow Co' have ZERO jobs.
   ===================================================================== */


-- Q1 (INNER): List every company name that HAS at least one job posting,
--             with how many jobs it posted. Matches only. Highest first.


-- Q2 (LEFT): List ALL companies and their job count, INCLUDING the ones
--            with zero jobs. (Hint: company_dim on the left.)


-- Q3 (LEFT + IS NULL): Show ONLY the companies that have posted no jobs.
--            Return just the company name. (The "find what's missing" trick.)


-- Q4 (think, no new query): In Q2, why do Orbit Systems and Hollow Co show
--            a count of 0 and not 1? Write your answer as a comment.
--            (Hint: what are you counting, and what is it for those rows?)


-- Q5 (RIGHT): Rewrite Q2 using a RIGHT JOIN instead of LEFT, keeping
--             company_dim as the RIGHT table. Same result, flipped syntax.


-- Q6 (FULL OUTER): Imagine some skills in skills_dim are never used by any
--            job. Join skills_dim to skills_job_dim with a FULL OUTER JOIN
--            and return skill name + job_id. (This keeps unused skills AND
--            any orphan links.) Just write and run it.


-- Q7 (LEFT + IS NULL, skills): Find skills in skills_dim that are NOT
--            requested by ANY job. Return the skill name only.
--            (Same missing-rows trick, different tables.)


-- Q8 (CROSS JOIN): Produce every possible pairing of job_title_short
--            (distinct) with every skill name. No ON clause. How many rows
--            would you expect = (# distinct titles) x (# skills)?


-- Q9 (choose the right join): For EVERY job posting, show job_id and its
--            company name. Every job must appear even if (hypothetically)
--            its company_id had no match in company_dim. Which join do you
--            pick, and why? Write the query + a one-line reason.
