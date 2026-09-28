-- 10.1
-- (i)
-- Similar Examples
-- Normal dimensions (examples)
CREATE TABLE student_dim (
  student_id   SERIAL PRIMARY KEY,
  student_code VARCHAR(50) UNIQUE,
  student_name VARCHAR(200),
  dob          DATE
);

CREATE TABLE course_dim (
  course_id   SERIAL PRIMARY KEY,
  course_code VARCHAR(50),
  course_name VARCHAR(200)
);

CREATE TABLE department_dim (
  dept_id   SERIAL PRIMARY KEY,
  dept_name VARCHAR(200)
);

-- Fact table with Year and Country as dimension-less attributes
CREATE TABLE fact_enrolment (
  enrolment_id      SERIAL PRIMARY KEY,
  student_id        INT NOT NULL REFERENCES student_dim(student_id),
  course_id         INT NOT NULL REFERENCES course_dim(course_id),
  dept_id           INT NOT NULL REFERENCES department_dim(dept_id),
  year              VARCHAR(20) NOT NULL,     -- dimension-less key (e.g. '2024' or 'AY2023')
  country           VARCHAR(100) NOT NULL,    -- dimension-less key (e.g. 'Malaysia')
  enrolled_count    INTEGER DEFAULT 0,
  total_credits     NUMERIC(10,2),
  load_datetime     TIMESTAMP DEFAULT now()
);

-- Optional: index to speed queries filtering by year/country
CREATE INDEX idx_fact_enrolment_year_country ON fact_enrolment(year, country);








-- (ii)
-- Normal dimensions (same as above)
CREATE TABLE student_dim (
  student_id   SERIAL PRIMARY KEY,
  student_code VARCHAR(50) UNIQUE,
  student_name VARCHAR(200),
  dob          DATE
);

CREATE TABLE course_dim (
  course_id   SERIAL PRIMARY KEY,
  course_code VARCHAR(50),
  course_name VARCHAR(200)
);

CREATE TABLE department_dim (
  dept_id   SERIAL PRIMARY KEY,
  dept_name VARCHAR(200)
);

-- Junk dimension that stores Year + Country combinations
CREATE TABLE junk_year_country_dim (
  junk_id SERIAL PRIMARY KEY,
  year    VARCHAR(20) NOT NULL,
  country VARCHAR(100) NOT NULL,
  CONSTRAINT uq_year_country UNIQUE (year, country)
);

-- Populate junk table with only valid pairs (example)
-- INSERT INTO junk_year_country_dim (year, country) VALUES ('2023', 'Malaysia'), ('2024', 'Malaysia'), ...;

-- Fact table referencing the junk dimension
CREATE TABLE fact_enrolment_junk (
  enrolment_id      SERIAL PRIMARY KEY,
  student_id        INT NOT NULL REFERENCES student_dim(student_id),
  course_id         INT NOT NULL REFERENCES course_dim(course_id),
  dept_id           INT NOT NULL REFERENCES department_dim(dept_id),
  junk_id           INT NOT NULL REFERENCES junk_year_country_dim(junk_id),
  enrolled_count    INTEGER DEFAULT 0,
  total_credits     NUMERIC(10,2),
  load_datetime     TIMESTAMP DEFAULT now()
);

-- Index for analytics filtering
CREATE INDEX idx_fact_enrolment_junk_junkid ON fact_enrolment_junk(junk_id);





-- 10.2 Dimension-less keys in FACT
-- Fact table for ITS Projects (all three dimensions are stored as attributes)
CREATE TABLE fact_its_projects (
  project_fact_id      SERIAL PRIMARY KEY,
  project_duration     VARCHAR(20) NOT NULL,    -- e.g. 'short', 'medium', 'long'
  project_type         VARCHAR(100) NOT NULL,   -- e.g. 'Research', 'Maintenance'
  department           VARCHAR(200) NOT NULL,   -- department name
  total_budget         NUMERIC(14,2) DEFAULT 0, -- total budget (currency)
  total_budget_per_hour NUMERIC(14,4) DEFAULT 0,-- total budget per hour (currency/hour)
  total_projects       INTEGER DEFAULT 0     -- number of projects (count)
);

-- Example indexes to speed common queries
CREATE INDEX idx_itsproj_duration_type_dept ON fact_its_projects(project_duration, project_type, department);