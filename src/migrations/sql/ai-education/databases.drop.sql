SELECT
  pg_terminate_backend(pid)
FROM
  pg_stat_activity
WHERE
  datname = 'ai_education'
  AND pid != pg_backend_pid();

DROP DATABASE IF EXISTS "ai_education";
