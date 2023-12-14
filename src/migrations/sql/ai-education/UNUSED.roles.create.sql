-- Public reader group for roles that can only read the public schema
CREATE ROLE "g_ai_education_reader_public";

-- Public reader role for only reading public schema tables
CREATE ROLE "ai_education_reader_public" WITH LOGIN NOCREATEROLE NOCREATEDB
  ENCRYPTED PASSWORD 'ai_education_reader_public' IN
GROUP "g_ai_education_reader_public";

-- Group for reading restricted schemas that aren't allowed for public
-- groups and roles
CREATE ROLE "g_ai_education_reader_restricted";

CREATE ROLE "ai_education_reader_restricted" WITH LOGIN NOCREATEROLE NOCREATEDB
  ENCRYPTED PASSWORD 'ai_education_reader_restricted' IN
GROUP "g_ai_education_reader_restricted";
