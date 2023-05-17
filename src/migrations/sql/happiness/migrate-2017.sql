CALL raw.create_audit_insert_function_for_year(2017);

CREATE TRIGGER audit_insert_year_2017 
  AFTER INSERT 
  ON raw.year_2017
  FOR EACH ROW
  EXECUTE PROCEDURE raw.tr_audit_insert_year_2017();

CREATE OR REPLACE PROCEDURE migrate_year_2017()
  LANGUAGE plpgsql
  AS $$
BEGIN
  COPY raw.year_2017 (
    "country",
    "happiness_rank",
    "happiness_score",
    "whisker_high", 
    "whisker_low", 
    "gdp_per_capita",
    "family",
    "life_expectancy",
    "freedom",
    "government_corruption",
    "generosity",
    "dystopia_residual"
  )
  FROM '/migrations/data/happiness/2017.csv'
  CSV HEADER;
END;
$$;
