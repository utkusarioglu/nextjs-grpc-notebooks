REVOKE ALL IF EXISTS ON TABLE raw.year_2015 FROM g_readonly;

REVOKE ALL IF EXISTS ON TABLE raw.year_2016 FROM g_readonly;

REVOKE ALL IF EXISTS ON TABLE raw.year_2017 FROM g_readonly;

REVOKE ALL IF EXISTS ON TABLE raw.year_2018 FROM g_readonly;

REVOKE ALL IF EXISTS ON TABLE raw.year_2019 FROM g_readonly;

REVOKE ALL IF EXISTS ON SCHEMA raw FROM g_happiness_readonly;

REVOKE ALL IF EXISTS ON DATABASE happiness FROM g_happiness_readonly;

DROP DATABASE IF EXISTS happiness;

DROP TABLESPACE IF EXISTS ts_happiness;

DROP ROLE IF EXISTS happiness_reader;

DROP ROLE IF EXISTS g_happiness_readonly;

CREATE TABLESPACE ts_happiness LOCATION '/tablespaces/happiness';

CREATE DATABASE happiness TABLESPACE ts_happiness;

\c happiness;
CREATE SCHEMA raw;

CREATE ROLE g_happiness_readonly;

GRANT CONNECT ON DATABASE happiness TO g_happiness_readonly;

CREATE ROLE happiness_reader WITH LOGIN NOCREATEROLE NOCREATEDB ENCRYPTED
  PASSWORD 'happiness_reader' IN
GROUP g_happiness_readonly;

CREATE ROLE g_happiness_admin WITH NOLOGIN NOCREATEDB;

GRANT ALL ON DATABASE happiness TO g_happiness_admin;

GRANT ALL ON SCHEMA raw TO g_happiness_admin;

GRANT ALL ON TABLE raw.audit TO g_happiness_admin;

GRANT ALL ON TABLE raw.audit_insert TO g_happiness_admin;

GRANT ALL ON TABLE raw.audit_insert_year_2015 TO g_happiness_admin;

GRANT ALL ON TABLE raw.audit_insert_year_2016 TO g_happiness_admin;

GRANT ALL ON TABLE raw.audit_insert_year_2017 TO g_happiness_admin;

GRANT ALL ON TABLE raw.audit_insert_year_2018 TO g_happiness_admin;

GRANT ALL ON TABLE raw.audit_insert_year_2019 TO g_happiness_admin;

GRANT ALL ON TABLE raw.year_2015 TO g_happiness_admin;

GRANT ALL ON TABLE raw.year_2016 TO g_happiness_admin;

GRANT ALL ON TABLE raw.year_2017 TO g_happiness_admin;

GRANT ALL ON TABLE raw.year_2018 TO g_happiness_admin;

GRANT ALL ON TABLE raw.year_2019 TO g_happiness_admin;

CREATE ROLE happiness_admin WITH LOGIN ENCRYPTED PASSWORD 'happiness_admin'
  CONNECTION LIMIT 1 IN
GROUP g_happiness_admin;
