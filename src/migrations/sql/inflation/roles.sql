
CREATE ROLE g_inflation_readonly;

CREATE ROLE inflation_reader WITH
  LOGIN
  NOCREATEROLE
  NOCREATEDB
  ENCRYPTED PASSWORD 'inflation_reader'
  IN GROUP g_inflation_readonly;
  
CREATE ROLE g_inflation_admin WITH
  NOCREATEDB;

CREATE ROLE inflation_admin WITH
  LOGIN
  CONNECTION LIMIT 1
  ENCRYPTED PASSWORD 'inflation_admin'
  IN GROUP g_inflation_admin;
