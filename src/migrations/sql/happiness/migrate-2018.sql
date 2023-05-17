CALL raw.create_audit_insert_function_for_year(2018);

CREATE TRIGGER audit_insert_year_2018 
  AFTER INSERT 
  ON raw.year_2018
  FOR EACH ROW
  EXECUTE PROCEDURE raw.tr_audit_insert_year_2018();

CREATE OR REPLACE PROCEDURE migrate_year_2018()
  LANGUAGE plpgsql
  AS $$
BEGIN
  COPY raw.year_2018 (
    "happiness_rank",
    "country_or_region",
    "happiness_score",
    "gdp_per_capita",
    "social_support",
    "life_expectancy",
    "freedom",
    "generosity",
    "corruption"
  )
  FROM '/migrations/data/happiness/2018.csv'
  WITH (
    NULL 'N/A',
    FORMAT CSV,
    HEADER
  );
END;
$$;
