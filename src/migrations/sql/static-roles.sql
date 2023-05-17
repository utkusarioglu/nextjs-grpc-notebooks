CREATE ROLE g_all_reader NOCREATEDB NOCREATEROLE IN
GROUP g_inflation_readonly,
g_happiness_readonly;

CREATE ROLE grafana_reader LOGIN CONNECTION LIMIT 10 ENCRYPTED PASSWORD
  'grafana_reader' IN
GROUP g_all_reader;

CREATE GROUP g_vault_manager NOCREATEDB NOLOGIN NOSUPERUSER;

CREATE ROLE vault_manager_inflation 
  GROUP g_vault_manager 
  ENCRYPTED PASSWORD 'a' 
  CONNECTION LIMIT 1;
GRANT ALL TO vault_manager_inflation ON DATABASE inflation;
