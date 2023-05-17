DROP VIEW IF EXISTS inflation.with_decades CASCADE;
CREATE OR REPLACE VIEW inflation.with_decades AS
  SELECT 
    country_name,
    country_code,
    observation_year,
    FLOOR(observation_year / 10) * 10 decade,
    inflation_value
  FROM
    inflation.view_all_countries_inflation_data();

DROP VIEW IF EXISTS inflation.decade_stats CASCADE;
CREATE OR REPLACE VIEW inflation.decade_stats AS
  SELECT
    country_name,
    country_code,
    decade,
    COUNT(inflation_value) AS count,
    AVG(inflation_value)::NUMERIC(7,2) AS average,
    MAX(inflation_value)::NUMERIC(7,2) AS max,
    MIN(inflation_value)::NUMERIC(7,2) AS min,
    (PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY inflation_value))::NUMERIC(10,2) AS median,
    (MAX(inflation_value) - MIN(inflation_value))::NUMERIC(10,2) AS range,
    STDDEV(inflation_value)::NUMERIC(10,2) AS stddev,
    VARIANCE(inflation_value)::NUMERIC(10,2) AS variance
  FROM
    (SELECT * FROM inflation.with_decades) with_decades
  GROUP BY
    decade,
    country_name,
    country_code
  ORDER BY 
    country_name,
    decade;

DROP VIEW IF EXISTS inflation.decades_regression CASCADE;
CREATE OR REPLACE VIEW inflation.decades_regression AS
  SELECT 
    country_name,
    country_code,
    decade,
    regr_intercept(inflation_value, observation_year)::NUMERIC(10,4) intercept,
    regr_slope(inflation_value, observation_year)::NUMERIC(10,4) slope
  FROM
    inflation.with_decades
  GROUP BY
    country_name,
    country_code,
    decade
  ORDER BY
    country_name,
    decade
;
  
DROP VIEW IF EXISTS inflation.country_average_inflation;
CREATE OR REPLACE VIEW inflation.country_average_inflation AS
  SELECT DISTINCT
    s1."country_name",
    s1."country_average"
  FROM (
    SELECT 
      "country_name",
      "year",
      "value",
      avg("value") OVER (PARTITION BY "country_name") AS "country_average"
    FROM inflation.country_list c
    JOIN  
      inflation.inflation_data d ON c.id = d.country_id
  ) AS s1
  ORDER BY s1."country_average" DESC
;

DROP VIEW IF EXISTS inflation.year_average_inflation;
CREATE OR REPLACE VIEW inflation.year_average_inflation AS
  SELECT DISTINCT
    "year", 
    avg("value") OVER(PARTITION BY "year") AS "average_inflation"
  FROM inflation.inflation_data
;
