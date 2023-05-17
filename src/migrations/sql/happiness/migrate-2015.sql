CALL raw.create_audit_insert_function_for_year(2015);

CREATE TRIGGER audit_insert_year_2015 
  AFTER INSERT 
  ON raw.year_2015
  FOR EACH ROW
  EXECUTE PROCEDURE raw.tr_audit_insert_year_2015();

CREATE OR REPLACE PROCEDURE migrate_year_2015()
  LANGUAGE plpgsql
  AS $$
BEGIN
  COPY raw.year_2015 (
    "country",
    "region",
    "happiness_rank",
    "happiness_score",
    "standard_error",
    "gdp_per_capita",
    "family",
    "life_expectancy",
    "freedom",
    "government_corruption",
    "generosity",
    "dystopia_residual"
  )
  FROM '/migrations/data/happiness/2015.csv'
  CSV HEADER;
END;
$$;
