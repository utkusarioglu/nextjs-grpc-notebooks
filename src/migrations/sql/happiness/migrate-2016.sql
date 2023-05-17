CALL raw.create_audit_insert_function_for_year(2016);

CREATE TRIGGER audit_insert_year_2016 
  AFTER INSERT 
  ON raw.year_2016
  FOR EACH ROW
  EXECUTE PROCEDURE raw.tr_audit_insert_year_2016();

CREATE OR REPLACE PROCEDURE migrate_year_2016()
  LANGUAGE plpgsql
  AS $$
BEGIN
  COPY raw.year_2016 (
    "country",
    "region",
    "happiness_rank",
    "happiness_score",

    "lower_confidence_interval", -- different
    "upper_confidence_interval", -- different
    -- "standard_error",

    "gdp_per_capita",
    "family",
    "life_expectancy",
    "freedom",
    "government_corruption",
    "generosity",
    "dystopia_residual"
  )
  FROM '/migrations/data/happiness/2016.csv'
  CSV HEADER;
END;
$$;
