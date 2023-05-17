DROP FUNCTION raw.audit_insert_years_all_compose;
CREATE OR REPLACE FUNCTION raw.audit_insert_years_all_compose() 
  RETURNS TABLE (
    "entry_id" INT,
    "ts" TIMESTAMPTZ,
    "type" TEXT,
    "id" INT,
    "target_table" TEXT,
    "new_value" JSONB
  )
  LANGUAGE plpgsql
  AS $$
DECLARE
  raw_query TEXT := '
    SELECT 
      "entry_id",
      "ts",
      "type",
      "id",
      "target_table",
      "new_value"
    FROM raw.audit_insert_year_%%YEAR%%
  ';
  prepared_queries TEXT[];
  prepared_composed_query TEXT;
BEGIN
  FOR current_year IN 2015..2019 LOOP
    prepared_queries := prepared_queries || ARRAY[
      replace(raw_query, '%%YEAR%%', current_year::TEXT)
    ];
  END LOOP;
  prepared_composed_query := array_to_string(prepared_queries, ' UNION ');
  RETURN QUERY EXECUTE prepared_composed_query;
END;
$$;

DROP FUNCTION raw.countries_yearly_rankings CASCADE;
CREATE OR REPLACE FUNCTION raw.countries_yearly_rankings() 
  RETURNS TABLE (
    "year" INT,
    "country_or_region" TEXT,
    "gdp_per_capita" BIGINT,
    "family" BIGINT,
    "life_expectancy" BIGINT,
    "freedom" BIGINT,
    "generosity" BIGINT,
    "government_corruption" BIGINT,
    "dystopia_residual" BIGINT
    -- "gdp_per_capita_rank" BIGINT,
    -- "family_rank" BIGINT,
    -- "life_expectancy_rank" BIGINT,
    -- "freedom_rank" BIGINT,
    -- "generosity_rank" BIGINT,
    -- "government_corruption_rank" BIGINT,
    -- "dystopia_residual_rank" BIGINT
  )
  LANGUAGE plpgsql
  AS $$
DECLARE
  ranked_columns TEXT[] := ARRAY[
    'gdp_per_capita',
    'family',
    'life_expectancy',
    'freedom',
    'generosity',
    'government_corruption',
    'dystopia_residual'
  ];
  query_prefix TEXT := '
    SELECT
      *
    FROM (
      SELECT
        "year",
        "country_or_region",
  ';
  section_raw TEXT := '
    row_number() OVER (
      PARTITION BY "year" 
      ORDER BY "%%COLUMN_NAME%%" DESC
    ) AS "%%COLUMN_NAME%%"
  ';
  query_postfix TEXT := '
      FROM raw.years_all
    ) AS s1
  ';
  query_sections TEXT[]; 
  current_column_name TEXT;
  prepared_query TEXT;
BEGIN
  FOREACH current_column_name IN ARRAY ranked_columns LOOP
    query_sections := query_sections || ARRAY[
      replace(section_raw, '%%COLUMN_NAME%%', current_column_name)
    ];
  END LOOP;
  prepared_query := query_prefix || 
    array_to_string(query_sections, ', ') || 
    query_postfix;
  RETURN QUERY EXECUTE prepared_query;
END;
$$;
