-- TODO The assumption made in this view for the whiskers and confidence 
-- intervals is a faulty one, and should be corrected.
CREATE OR REPLACE VIEW raw.years_all AS
  SELECT 
    "id",
    2015 "year",
    "country" AS "country_or_region",
    "region",
    "happiness_rank",
    "happiness_score",
    "standard_error",
    NULL AS "lower_confidence_interval",
    NULL AS "upper_confidence_interval",
    "gdp_per_capita",
    "family",
    "life_expectancy",
    "freedom",
    "government_corruption",
    "generosity",
    "dystopia_residual"
  FROM raw.year_2015
  UNION
  SELECT 
    "id",
    2016 "year",
    "country" AS "country_or_region",
    "region",
    "happiness_rank",
    "happiness_score",
    NULL AS "standard_error",
    "lower_confidence_interval",
    "upper_confidence_interval",
    "gdp_per_capita",
    "family",
    "life_expectancy",
    "freedom",
    "government_corruption",
    "generosity",
    "dystopia_residual"
  FROM raw.year_2016
  UNION
  SELECT
    "id",
    2017 "year",
    "country" AS "country_or_region",
    NULL AS "region",
    "happiness_rank",
    "happiness_score",
    NULL AS "standard_error",
    "whisker_low" AS "lower_confidence_interval",
    "whisker_high" AS "upper_confidence_interval",
    "gdp_per_capita",
    "family",
    "life_expectancy",
    "freedom",
    "generosity",
    "government_corruption",
    "dystopia_residual"
  FROM raw.year_2017
  UNION
  SELECT
    "id",
    2018 "year",
    "country_or_region",
    NULL AS "region",
    "happiness_rank",
    "happiness_score",
    NULL AS "standard_error",
    NULL AS "lower_confidence_interval",
    NULL AS "upper_confidence_interval",
    "gdp_per_capita",
    "social_support" AS "family",
    "life_expectancy",
    "freedom",
    "generosity",
    "corruption" AS "government_corruption",
    NULL "dystopia_residual"
  FROM raw.year_2018
  UNION
  SELECT 
    "id",
    2019 AS "year",
    "country_or_region",
    NULL AS "region",
    "happiness_rank",
    "happiness_score",
    NULL AS "standard_error",
    NULL AS "lower_confidence_interval",
    NULL AS "upper_confidence_interval",
    "gdp_per_capita",
    "social_support" AS "family",
    "life_expectancy",
    "freedom",
    "generosity",
    "corruption" AS "government_corruption",
    NULL AS "dystopia_residual"
  FROM raw.year_2019;

-- this one
DROP VIEW raw.lowest_scores CASCADE;
CREATE OR REPLACE VIEW raw.lowest_scores AS
  SELECT 
    "country_or_region",
    "year",
    "min_score" AS "score",
    ROW_NUMBER() OVER (
      PARTITION BY "country_or_region"
    ) AS "order",
    COUNT("country_or_region") OVER (
      PARTITION BY "country_or_region"
    ) AS "duplicity"
  FROM (
    SELECT * 
    FROM (
      SELECT 
        "country_or_region",
        "year",
        "happiness_score",
        MIN("happiness_score") OVER (
          PARTITION BY "country_or_region"
        ) AS "min_score"
      FROM raw.years_all
    ) as s1
    WHERE
      s1."min_score" = s1."happiness_score"
    ORDER BY 
      s1."year"
  ) AS s2
;


DROP VIEW raw.highest_scores CASCADE;
CREATE OR REPLACE VIEW raw.highest_scores AS
  SELECT 
    "country_or_region",
    "year",
    "max_score" AS "score",
    ROW_NUMBER() OVER (
      PARTITION BY "country_or_region"
    ) AS "order",
    COUNT("country_or_region") OVER (
      PARTITION BY "country_or_region"
    ) AS "duplicity"
  FROM (
    SELECT * 
    FROM (
      SELECT 
        "country_or_region",
        "year",
        "happiness_score",
        MAX("happiness_score") OVER (
          PARTITION BY "country_or_region"
        ) AS "max_score"
      FROM raw.years_all
    ) as s1
    WHERE
      s1."max_score" = s1."happiness_score"
    ORDER BY 
      s1."year"
  ) AS s2
;

DROP VIEW raw.highest_and_lowest_scores CASCADE;
CREATE OR REPLACE VIEW raw.highest_and_lowest_scores AS
  SELECT 
    h."country_or_region",
    h."year" AS "highest_year",
    h."score" AS "highest_score",
    h."duplicity" AS "high_duplicity",
    l."year" AS "lowest_year",
    l."score" AS "lowest_score",
    l."duplicity" AS "low_duplicity",
    (CASE 
      WHEN l."year" > h."year" 
      THEN 'decrease' 
      ELSE 'increase' END
    ) AS "change_direction",
    h."score" - l."score" AS "change"
  FROM raw.highest_scores h
  JOIN
    raw.lowest_scores l ON l."country_or_region" = h."country_or_region"
  WHERE
    l."order" = 1
    AND
    h."order" = 1
;

DROP VIEW raw.audit_insert_years_all;
CREATE OR REPLACE VIEW raw.audit_insert_years_all AS
  SELECT
    "entry_id",
    "ts",
    "type",
    "id",
    "target_table",
    "new_value",
    "new_value"->'country' as "json_country",
    "new_value" @> '{"region": "Western Europe"}'::JSONB AS "in_western_europe"
  FROM raw.audit_insert_years_all_compose()
;

DROP VIEW raw.countries_yearly_rankings;
CREATE OR REPLACE VIEW raw.countries_yearly_rankings AS
  SELECT
    *
  FROM (
    SELECT
      "year",
      "country_or_region",
      "gdp_per_capita",
      row_number() OVER (
        PARTITION BY "year" 
        ORDER BY "gdp_per_capita" DESC
      ) AS "gdp_per_capita_rank",

      "family",
      row_number() OVER (
        PARTITION BY "year" 
        ORDER BY "family" DESC
      ) AS "family_rank"
    FROM raw.years_all
  ) AS s1
