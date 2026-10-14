/* =====================================================================
   SETUP: builds a sample "data_jobs" database (4 normalized tables)
   matching Luke Barousse's schema, so the join practice test can run.

   This is SAMPLE data (not Luke's real 786k-row dataset) so you can
   practise joins offline. Re-run anytime to rebuild from scratch.

   Run with:  duckdb data_jobs.duckdb < setup_sample_db.sql
   ===================================================================== */

-- Deterministic data so the DB is the same every rebuild
SELECT setseed(0.42);

DROP TABLE IF EXISTS skills_job_dim;
DROP TABLE IF EXISTS skills_dim;
DROP TABLE IF EXISTS job_postings_fact;
DROP TABLE IF EXISTS company_dim;

/* ---------- company_dim (note: companies 11 & 12 will have NO jobs,
              which makes LEFT JOIN differ from INNER JOIN) ---------- */
CREATE TABLE company_dim (company_id INTEGER PRIMARY KEY, name VARCHAR);
INSERT INTO company_dim VALUES
 (1,'Acme Analytics'),(2,'DataCorp'),(3,'Insight Inc'),(4,'CloudNine'),
 (5,'Quant Labs'),(6,'ByteWorks'),(7,'Nimbus AI'),(8,'Streamline'),
 (9,'PixelPlex'),(10,'Zenith Data'),(11,'Orbit Systems'),(12,'Hollow Co');

/* ---------- skills_dim ---------- */
CREATE TABLE skills_dim (skill_id INTEGER PRIMARY KEY, skills VARCHAR, type VARCHAR);
INSERT INTO skills_dim VALUES
 (1,'sql','programming'),(2,'python','programming'),(3,'r','programming'),
 (4,'excel','analyst_tools'),(5,'tableau','analyst_tools'),(6,'power bi','analyst_tools'),
 (7,'aws','cloud'),(8,'azure','cloud'),(9,'gcp','cloud'),
 (10,'spark','libraries'),(11,'hadoop','libraries'),(12,'pandas','libraries'),
 (13,'sas','analyst_tools'),(14,'go','programming'),(15,'java','programming'),
 (16,'scala','programming'),(17,'snowflake','cloud'),(18,'looker','analyst_tools');

/* ---------- job_postings_fact (150 postings) ----------
   - company_id is 1..10 only  -> companies 11,12 get zero jobs
   - ~20% of salaries are NULL  -> practise IS NOT NULL / HAVING          */
CREATE TABLE job_postings_fact AS
SELECT
  g AS job_id,
  (ARRAY['Data Analyst','Data Engineer','Data Scientist',
         'Business Analyst','Machine Learning Engineer','Cloud Engineer']
   )[1 + (floor(random()*6))::INT] AS job_title_short,
  1 + (floor(random()*10))::INT AS company_id,
  (ARRAY['New York, NY','Austin, TX','Remote','London, UK',
         'Bangalore, India','Berlin, Germany']
   )[1 + (floor(random()*6))::INT] AS job_location,
  (ARRAY['Full-time','Contract','Part-time'])[1 + (floor(random()*3))::INT] AS job_schedule_type,
  (random() < 0.3) AS job_work_from_home,
  CASE WHEN random() < 0.2 THEN NULL
       ELSE round((70000 + random()*120000) / 1000) * 1000
  END AS salary_year_avg,
  DATE '2023-01-01' + (floor(random()*365))::INT AS job_posted_date
FROM generate_series(1, 150) AS t(g);

-- readable long title too (optional column Luke has)
ALTER TABLE job_postings_fact ADD COLUMN job_title VARCHAR;
UPDATE job_postings_fact SET job_title = job_title_short || ' (' || job_schedule_type || ')';

/* ---------- skills_job_dim (bridge): each job gets 1-5 distinct skills ---------- */
CREATE TABLE skills_job_dim AS
SELECT DISTINCT
  jpf.job_id,
  1 + (floor(random()*18))::INT AS skill_id
FROM job_postings_fact AS jpf, generate_series(1,5) AS s(n);

/* ---------- quick sanity report ---------- */
SELECT 'company_dim'       AS table_name, count(*) AS rows FROM company_dim
UNION ALL SELECT 'skills_dim',        count(*) FROM skills_dim
UNION ALL SELECT 'job_postings_fact', count(*) FROM job_postings_fact
UNION ALL SELECT 'skills_job_dim',    count(*) FROM skills_job_dim;
