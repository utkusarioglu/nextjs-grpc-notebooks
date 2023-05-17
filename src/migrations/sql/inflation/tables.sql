-- Creates the temp inflation file that corresponds in structure to the 
-- Source csv file
CREATE OR REPLACE PROCEDURE create_temp_inflation_table()
  LANGUAGE plpgsql
  AS
$$
BEGIN
  DROP TABLE IF EXISTS inflation.inflation_temp;
  CREATE TABLE inflation.inflation_temp (
    id INT NOT NULL GENERATED ALWAYS AS IDENTITY,
    country_name TEXT UNIQUE NOT NULL,
    country_code TEXT UNIQUE NOT NULL ,
    indicator_name TEXT NOT NULL,
    indicator_code TEXT NOT NULL,
    year_1960 REAL,
    year_1961 REAL,
    year_1962 REAL,
    year_1963 REAL,
    year_1964 REAL,
    year_1965 REAL,
    year_1966 REAL,
    year_1967 REAL,
    year_1968 REAL,
    year_1969 REAL,
    year_1970 REAL,
    year_1971 REAL,
    year_1972 REAL,
    year_1973 REAL,
    year_1974 REAL,
    year_1975 REAL,
    year_1976 REAL,
    year_1977 REAL,
    year_1978 REAL,
    year_1979 REAL,
    year_1980 REAL,
    year_1981 REAL,
    year_1982 REAL,
    year_1983 REAL,
    year_1984 REAL,
    year_1985 REAL,
    year_1986 REAL,
    year_1987 REAL,
    year_1988 REAL,
    year_1989 REAL,
    year_1990 REAL,
    year_1991 REAL,
    year_1992 REAL,
    year_1993 REAL,
    year_1994 REAL,
    year_1995 REAL,
    year_1996 REAL,
    year_1997 REAL,
    year_1998 REAL,
    year_1999 REAL,
    year_2000 REAL,
    year_2001 REAL,
    year_2002 REAL,
    year_2003 REAL,
    year_2004 REAL,
    year_2005 REAL,
    year_2006 REAL,
    year_2007 REAL,
    year_2008 REAL,
    year_2009 REAL,
    year_2010 REAL,
    year_2011 REAL,
    year_2012 REAL,
    year_2013 REAL,
    year_2014 REAL,
    year_2015 REAL,
    year_2016 REAL,
    year_2017 REAL,
    year_2018 REAL,
    year_2019 REAL,
    year_2020 REAL,
    year_2021 REAL
  );
END;
$$;

CALL create_temp_inflation_table();

-- Creates processed tables for inflation
CREATE OR REPLACE PROCEDURE inflation.create_real_inflation_table()
  LANGUAGE plpgsql
  AS $$
BEGIN
  DROP TABLE IF EXISTS inflation.indicator_list CASCADE;
  CREATE TABLE inflation.indicator_list (
    "id" INT GENERATED ALWAYS AS IDENTITY,
    "indicator_name" VARCHAR(50) NOT NULL,
    "indicator_code" VARCHAR(20) NOT NULL,
    CONSTRAINT indicator_name_length CHECK (LENGTH("indicator_name") > 20),
    CONSTRAINT indicator_code_length CHECK (LENGTH("indicator_code") > 10),
    PRIMARY KEY ("id")
  );

  CREATE UNIQUE INDEX IF NOT EXISTS indicator_code 
    ON ONLY inflation.indicator_list (
      "indicator_code"
    )
    NULLS NOT DISTINCT
    TABLESPACE ts_inflation;

  DROP TABLE IF EXISTS inflation.country_list CASCADE;
  CREATE TABLE inflation.country_list (
    "id" INT GENERATED ALWAYS AS IDENTITY,
    "country_name" TEXT UNIQUE NOT NULL,
    "country_code" TEXT UNIQUE NOT NULL,
    "indicator_id" INT,
    PRIMARY KEY ("id"),
    CONSTRAINT indicator_foreign_key
      FOREIGN KEY("indicator_id")
      REFERENCES inflation.indicator_list(id)
      ON DELETE RESTRICT
      ON UPDATE CASCADE
  );

  DROP TABLE IF EXISTS inflation.inflation_data CASCADE;
  CREATE TABLE inflation.inflation_data(
    id INT GENERATED ALWAYS AS IDENTITY,
    country_id INT,
    year INT NOT NULL,
    value REAL NOT NULL,
    PRIMARY KEY(id),

    CONSTRAINT fk_country_list
      FOREIGN KEY(country_id)
      REFERENCES inflation.country_list(id)
      ON DELETE RESTRICT,
    CONSTRAINT observation_year_limits
      CHECK (year BETWEEN 1960 AND date_part('year', NOW()))
  );
END;
$$;

CALL inflation.create_real_inflation_table();

CREATE OR REPLACE PROCEDURE inflation.populate_real_inflation_table()
  LANGUAGE plpgsql
  AS $$
DECLARE
  raw_query TEXT := '
    INSERT INTO inflation.inflation_data (
      country_id,
      year,
      value
    ) VALUES (
      $1,
      %YEAR_NAME%,
      $2.year_%YEAR_NAME%
    );
  ';
  prepared_query TEXT;
  err_context TEXT;
  rec inflation.inflation_temp%ROWTYPE;
  country_id INT;
  current_indicator_id INT;
  years_list TEXT[]; -- int as text
  target_year TEXT; -- int as text
BEGIN
  INSERT INTO inflation.indicator_list (
    "indicator_name", 
    "indicator_code"
  )
    SELECT DISTINCT 
      "indicator_name",
      "indicator_code"
    FROM inflation.inflation_temp;
    
  SELECT ARRAY(
    SELECT 
      replace(column_name, 'year_', '') AS "year"
    FROM information_schema.columns 
    WHERE 
      table_name = 'inflation_temp' 
      AND 
      column_name LIKE 'year_%'
  )
  INTO years_list;

  FOR rec IN SELECT * FROM inflation.inflation_temp LOOP
    SELECT 
      l."id" 
    FROM inflation.indicator_list l
    WHERE
      l."indicator_code" = rec.indicator_code
    INTO current_indicator_id;
    
    INSERT INTO inflation.country_list (
      "country_name",
      "country_code",
      "indicator_id"
    ) VALUES (
      rec.country_name,
      rec.country_code,
      current_indicator_id
    ) 
    RETURNING "id"
    INTO country_id;

    FOREACH target_year IN ARRAY years_list LOOP
      prepared_query := REPLACE(
        raw_query, 
        '%YEAR_NAME%', 
        target_year
      );
      BEGIN
        EXECUTE prepared_query USING country_id, rec;
        EXCEPTION
          WHEN others THEN
            GET STACKED DIAGNOSTICS err_context = PG_EXCEPTION_CONTEXT;
            IF SQLSTATE = '23514' THEN
              RAISE INFO 'Error Name:%',SQLERRM;
              RAISE INFO 'Error State:%', SQLSTATE;
              RAISE INFO 'Error Context:%', err_context;
            END IF;
            -- return -1;
      END;
    END LOOP;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION inflation.trigger_insert_inflation_structured()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $$
BEGIN
  INSERT INTO inflation.audit_insert_inflation_structured (
    operation,
    entry_id,
    table_type,
    new_value
  ) VALUES (
    'insert',
    NEW.id,
    'structured',
    row_to_json(NEW.*)
  );
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION inflation.trigger_insert_inflation_temp()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $$
BEGIN
  INSERT INTO inflation.audit_insert_inflation_structured (
    operation,
    entry_id,
    table_type,
    new_value
  ) VALUES (
    'insert',
    NEW.id,
    'structured',
    row_to_json(NEW.*)
  );
  RETURN NEW;
END;
$$;

CREATE OR REPLACE PROCEDURE inflation.create_audit_tables()
  LANGUAGE plpgsql
  AS $$
BEGIN
  DROP TYPE IF EXISTS inflation.audit_operations CASCADE;
  CREATE TYPE inflation.audit_operations AS ENUM ('insert', 'update');
  
  DROP TYPE IF EXISTS inflation.audit_table_type CASCADE;
  CREATE TYPE inflation.audit_table_type AS ENUM ('temp', 'structured');

  DROP TABLE IF EXISTS inflation.audit CASCADE;
  CREATE TABLE inflation.audit (
    table_type inflation.audit_table_type,
    entry_id INT,
    operation inflation.audit_operations,
    tstz TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE (table_type, entry_id, operation)
  );

  DROP TABLE IF EXISTS inflation.audit_insert CASCADE;
  CREATE TABLE inflation.audit_insert (
    new_value TEXT NOT NULL,
    CHECK (operation = 'insert')
  ) 
  INHERITS (inflation.audit);

  DROP TABLE IF EXISTS inflation.audit_insert_inflation_temp;
  CREATE TABLE inflation.audit_insert_inflation_temp (
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    PRIMARY KEY (id),
    CHECK (table_type = 'temp')
  ) INHERITS (inflation.audit_insert);
  
  DROP TABLE IF EXISTS inflation.audit_insert_inflation_structured;
  CREATE TABLE inflation.audit_insert_inflation_structured (
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    PRIMARY KEY (id),
    CHECK (table_type = 'structured')
  ) INHERITS (inflation.audit_insert);
END;
$$;

CALL inflation.create_audit_tables();

CREATE OR REPLACE TRIGGER audit_insert_inflation_temp
  AFTER INSERT
  ON inflation.inflation_temp
  FOR EACH ROW
  EXECUTE PROCEDURE inflation.trigger_insert_inflation_temp();

COPY inflation.inflation_temp(
  country_name,
  country_code,
  indicator_name,
  indicator_code,
  year_1960,
  year_1961,
  year_1962,
  year_1963,
  year_1964,
  year_1965,
  year_1966,
  year_1967,
  year_1968,
  year_1969,
  year_1970,
  year_1971,
  year_1972,
  year_1973,
  year_1974,
  year_1975,
  year_1976,
  year_1977,
  year_1978,
  year_1979,
  year_1980,
  year_1981,
  year_1982,
  year_1983,
  year_1984,
  year_1985,
  year_1986,
  year_1987,
  year_1988,
  year_1989,
  year_1990,
  year_1991,
  year_1992,
  year_1993,
  year_1994,
  year_1995,
  year_1996,
  year_1997,
  year_1998,
  year_1999,
  year_2000,
  year_2001,
  year_2002,
  year_2003,
  year_2004,
  year_2005,
  year_2006,
  year_2007,
  year_2008,
  year_2009,
  year_2010,
  year_2011,
  year_2012,
  year_2013,
  year_2014,
  year_2015,
  year_2016,
  year_2017,
  year_2018,
  year_2019,
  year_2020,
  year_2021
) 
FROM '/migrations/data/inflation/inflation.csv' 
CSV HEADER;

CREATE OR REPLACE TRIGGER audit_insert_inflation_structured
  AFTER INSERT
  ON inflation.inflation_data
  FOR EACH ROW
  EXECUTE PROCEDURE inflation.trigger_insert_inflation_structured();

CALL inflation.populate_real_inflation_table();
