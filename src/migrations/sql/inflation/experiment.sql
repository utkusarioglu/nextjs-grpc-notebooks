CREATE OR REPLACE PROCEDURE create_indicator_table() 
  LANGUAGE plpgsql
  AS $$
BEGIN
  CREATE TEMPORARY TABLE indicators (
    "id" INT GENERATED ALWAYS AS IDENTITY,
    "indicator_name" TEXT NOT NULL,
    "indicator_code" TEXT NOT NULL
  );
END;
$$;

CREATE OR REPLACE PROCEDURE populate_indicator_table()
  LANGUAGE plpgsql
  AS $$
BEGIN
  INSERT INTO indicators (
    "indicator_name",
    "indicator_code"
  ) 
  SELECT DISTINCT 
    "indicator_name",
    "indicator_code"
  FROM inflation.country_list;
END;
$$;

CREATE OR REPLACE FUNCTION with_indicators()
  RETURNS TABLE (
    "id" inflation.country_list.id %TYPE,
    "country_name" inflation.country_list.country_name %TYPE,
    "country_code" inflation.country_list.country_code %TYPE,
    "indicator_id" indicators.id %TYPE,
    "indicator_name" indicators.indicator_name %TYPE
  )
  LANGUAGE plpgsql
  AS $$
BEGIN
  RETURN QUERY SELECT 
    c."id",
    c."country_name",
    c."country_code",
    i."id" as "indicator_id",
    i."indicator_name"
  FROM inflation.country_list c
  LEFT JOIN indicators i ON i."indicator_code" = c."indicator_code";
END;
$$;

CREATE OR REPLACE PROCEDURE try_py()
  language plpython3u
  AS $$
BEGIN
  print("hello");
END;
$$;
