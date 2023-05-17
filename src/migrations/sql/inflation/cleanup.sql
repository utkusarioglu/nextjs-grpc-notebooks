-- REVOKE ALL ON SCHEMA inflation FROM g_inflation_readonly;
-- REVOKE ALL ON DATABASE inflation FROM g_inflation_readonly;
DROP DATABASE IF EXISTS inflation;

DROP TABLESPACE IF EXISTS ts_inflation;

-- DROP ROLE IF EXISTS inflation_reader;
-- DROP ROLE IF EXISTS g_inflation_readonly;
