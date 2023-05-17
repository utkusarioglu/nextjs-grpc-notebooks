CREATE OR REPLACE PROCEDURE create_audit_parent_tables()
  LANGUAGE plpgsql
  AS $$
BEGIN
  DROP TABLE IF EXISTS raw.audit_insert CASCADE;
  DROP TABLE IF EXISTS raw.audit CASCADE;

  CREATE TABLE raw.audit (
    "entry_id" INT,
    "ts" TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );
  CREATE TABLE raw.audit_insert (
    "type" TEXT GENERATED ALWAYS AS ('insert') STORED
  ) INHERITS (raw.audit);
END;
$$;

CREATE OR REPLACE PROCEDURE raw.create_audit_insert_function_for_year(
  "year" INT
)
  LANGUAGE plpgsql
  AS $outer$
DECLARE
  raw_query TEXT := '
    CREATE OR REPLACE FUNCTION raw.tr_audit_insert_year_%%YEAR%%()
      RETURNS TRIGGER
      LANGUAGE plpgsql
      AS $inner$
    BEGIN
      INSERT INTO raw.audit_insert_year_%%YEAR%% (
        "entry_id",
        "new_value",
        "ts"
      ) VALUES (
        NEW.id,
        row_to_json(NEW.*),
        NOW()
      );
      RETURN NEW;
    END;
    $inner$;
  ';
  processed_query TEXT;
BEGIN
  processed_query := replace(raw_query, '%%YEAR%%', "year"::TEXT);
  EXECUTE processed_query;
END;
$outer$;

CREATE OR REPLACE PROCEDURE create_year_insert_table(
  "year" INT
)
  LANGUAGE plpgsql
  AS $$
DECLARE
  raw_query TEXT := '
    CREATE TABLE raw.audit_insert_year_%%YEAR%% (
      "id" INT UNIQUE GENERATED ALWAYS AS IDENTITY,
      "target_table" TEXT GENERATED ALWAYS AS (''year_%%YEAR%%'') STORED,
      "new_value" JSONB,
      CONSTRAINT fk_year_%%YEAR%%
        FOREIGN KEY ("entry_id") 
        REFERENCES RAW.year_%%YEAR%%("id")
        ON DELETE CASCADE,
      UNIQUE ("id", "target_table", "entry_id", "type")
    ) 
      INHERITS (raw.audit_insert);
  ';
  processed_query TEXT;
BEGIN
  processed_query = replace(raw_query, '%%YEAR%%', "year"::TEXT);
  EXECUTE processed_query;
END;
$$;


CREATE OR REPLACE PROCEDURE create_2015_tables()
  LANGUAGE plpgsql
  AS $$
BEGIN
  DROP TABLE IF EXISTS raw.audit_insert_year_2015 CASCADE;
  DROP TABLE IF EXISTS raw.year_2015 CASCADE;
  CREATE TABLE raw.year_2015 (
    "id" INT UNIQUE GENERATED ALWAYS AS IDENTITY,
    "country" TEXT, -- Country
    "region" TEXT, -- Region
    "happiness_rank" INT, -- Happiness Rank
    "happiness_score" NUMERIC(6,2), -- Happiness Score
    "standard_error" NUMERIC(6,2), -- Standard Error
    "gdp_per_capita" NUMERIC(10,2), -- Economy (GDP per Capita)
    "family" NUMERIC(10,2), -- Family
    "life_expectancy" NUMERIC(10,2), -- Health (Life Expectancy)
    "freedom" NUMERIC(10,2), -- Freedom
    "government_corruption" NUMERIC(10,2), -- Trust (Government Corruption)
    "generosity" NUMERIC(10,2), -- Generosity
    "dystopia_residual" NUMERIC(10,2) -- Dystopia Residual
  );
  CALL create_year_insert_table(2015);
END;
$$;

CREATE OR REPLACE PROCEDURE create_2016_tables()
  LANGUAGE plpgsql
  AS $$
BEGIN
  DROP TABLE IF EXISTS raw.audit_insert_year_2016 CASCADE;
  DROP TABLE IF EXISTS raw.year_2016 CASCADE;
  CREATE TABLE raw.year_2016 (
    "id" INT UNIQUE GENERATED ALWAYS AS IDENTITY,
    "country" TEXT, -- Country
    "region" TEXT, -- Region
    "happiness_rank" INT, -- Happiness Rank
    "happiness_score" NUMERIC(6,2), -- Happiness Score

    "lower_confidence_interval" NUMERIC(6,2), -- Lower Confidence Interval (DIFFERENT)
    "upper_confidence_interval" NUMERIC(6,2), -- Upper Confidence Interval (DIFFERENT)
    -- (NO STANDARD ERROR)

    "gdp_per_capita" NUMERIC(10,2), -- Economy (GDP per Capita)
    "family" NUMERIC(10,2), -- Family
    "life_expectancy" NUMERIC(10,2), -- Health (Life Expectancy)
    "freedom" NUMERIC(10,2), -- Freedom
    "government_corruption" NUMERIC(10,2), -- Trust (Government Corruption)
    "generosity" NUMERIC(10,2), -- Generosity
    "dystopia_residual" NUMERIC(10,2) -- Dystopia Residual
  );

  CALL create_year_insert_table(2016);
END;
$$;

CREATE OR REPLACE PROCEDURE create_2017_tables()
  LANGUAGE plpgsql
  AS $$
BEGIN
  DROP TABLE IF EXISTS raw.audit_insert_year_2017 CASCADE;
  DROP TABLE IF EXISTS raw.year_2017 CASCADE;
  CREATE TABLE raw.year_2017 (
    "id" INT UNIQUE GENERATED ALWAYS AS IDENTITY,
    "country" TEXT, -- Country
    -- (NO REGION)
    "happiness_rank" INT, -- Happiness.Rank
    "happiness_score" NUMERIC(6, 2),-- Happiness.Score

    "whisker_high" NUMERIC(6, 2), -- Whisker.high (DIFFERENT)
    "whisker_low" NUMERIC(6, 2), -- Whisker.low (DIFFERENT)

    "gdp_per_capita" NUMERIC(10, 2), -- Economy..GDP.per.Capita.
    "family" NUMERIC(10, 2), -- Family
    "life_expectancy" NUMERIC(10, 2), -- Health..Life.Expectancy.
    "freedom" NUMERIC(10, 2),  -- Freedom
    "generosity" NUMERIC(10, 2), -- Generosity
    "government_corruption" NUMERIC(10, 2), -- Trust..Government.Corruption.
    "dystopia_residual" NUMERIC(10, 2) -- Dystopia.Residual
  );

  CALL create_year_insert_table(2017);
END;
$$;

-- TODO this table needs to be able to convert N/A to null in "corruption"
CREATE OR REPLACE PROCEDURE create_2018_tables()
  LANGUAGE plpgsql
  AS $$
BEGIN
  DROP TABLE IF EXISTS raw.audit_insert_year_2018 CASCADE;
  DROP TABLE IF EXISTS raw.year_2018 CASCADE;
  CREATE TABLE raw.year_2018 (
    "id" INT UNIQUE GENERATED ALWAYS AS IDENTITY,
    "happiness_rank" INT, -- Overall rank
    "country_or_region" TEXT, -- Country or region (DIFFERENT)
    "happiness_score" NUMERIC(6, 2), -- Score
    "gdp_per_capita" NUMERIC(10, 2), -- GDP per capita 
    "social_support" NUMERIC(10, 2), -- Social support (DIFFERENT)
    "life_expectancy" NUMERIC(10, 2),-- Healthy life expectancy)
    "freedom" NUMERIC(10, 2), -- Freedom to make life choices
    "generosity" NUMERIC(10, 2), -- Generosity
    "corruption" NUMERIC(10, 2) -- Perceptions of corruption
    -- (NO dystopia_residual)
  );


  CALL create_year_insert_table(2018);
END;
$$;

CREATE OR REPLACE PROCEDURE create_2019_tables()
  LANGUAGE plpgsql
  AS $$
BEGIN
  DROP TABLE IF EXISTS raw.audit_insert_year_2019 CASCADE;
  DROP TABLE IF EXISTS raw.year_2019 CASCADE;
  CREATE TABLE raw.year_2019 (
    "id" INT UNIQUE GENERATED ALWAYS AS IDENTITY,
    "happiness_rank" INT, -- Overall rank
    "country_or_region" TEXT, -- Country or region
    "happiness_score" NUMERIC(10, 2), -- Score
    "gdp_per_capita" NUMERIC(6, 2), -- GDP per capita
    "social_support" NUMERIC(10, 2), -- Social support
    "life_expectancy" NUMERIC(10, 2), -- Healthy life expectancy
    "freedom" NUMERIC(10, 2), -- Freedom to make life choices
    "generosity" NUMERIC(10, 2), -- Generosity
    "corruption" NUMERIC(10, 2) -- Perceptions of corruption
    -- (NO dystopia_residual)
  );
  CALL create_year_insert_table(2019);
END;
$$;

CALL create_audit_parent_tables();

CALL create_2015_tables();
\i '/migrations/sql/happiness/migrate-2015.sql';
CALL migrate_year_2015();

CALL create_2016_tables();
\i '/migrations/sql/happiness/migrate-2016.sql';
CALL migrate_year_2016();

CALL create_2017_tables();
\i '/migrations/sql/happiness/migrate-2017.sql';
CALL migrate_year_2017();

CALL create_2018_tables();
\i '/migrations/sql/happiness/migrate-2018.sql';
CALL migrate_year_2018();

CALL create_2019_tables();
\i '/migrations/sql/happiness/migrate-2019.sql';
CALL migrate_year_2019();
