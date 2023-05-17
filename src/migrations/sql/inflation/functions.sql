DROP FUNCTION inflation.view_all_countries_inflation_data CASCADE;
CREATE OR REPLACE FUNCTION inflation.view_all_countries_inflation_data()
  RETURNS TABLE (
    "country_id" inflation.country_list.id %TYPE,
    "data_id" inflation.inflation_data.id %TYPE,
    "country_name" inflation.country_list.country_name %TYPE,
    "country_code" inflation.country_list.country_code %TYPE,
    "observation_year" inflation.inflation_data.year %TYPE,
    "inflation_value" inflation.inflation_data.value %TYPE,
    "indicator_name" inflation.indicator_list.indicator_name %TYPE,
    "indicator_code" inflation.indicator_list.indicator_code %TYPE
  )
  LANGUAGE plpgsql
  AS $$
BEGIN
  RETURN QUERY 
    SELECT 
      l."id" AS "country_id",
      d."id" AS "data_id",
      l."country_name" AS "country_name",
      l."country_code" AS "country_code",
      d."year" AS "observation_year",
      d."value" AS "inflation_value",
      i."indicator_name" AS "indicator_name",
      i."indicator_code" AS "indicator_code"
    FROM inflation.inflation_data AS d
    INNER JOIN
      inflation.country_list l ON d.country_id = l.id
    INNER JOIN
       inflation.indicator_list i ON l.indicator_id = i.id;
END;
$$;

CREATE OR REPLACE FUNCTION inflation.view_one_country_inflation_data(
  input_country_code inflation.country_list.country_code %TYPE
)
  RETURNS TABLE (
    "country_id" inflation.country_list.id %TYPE,
    "data_id" inflation.inflation_data.id %TYPE,
    "country_name" inflation.country_list.country_name %TYPE,
    "country_code" inflation.country_list.country_code %TYPE,
    "observation_year" inflation.inflation_data.year %TYPE,
    "inflation_value" inflation.inflation_data.value %TYPE,
    "indicator_name" inflation.indicator_list.indicator_name %TYPE,
    "indicator_code" inflation.indicator_list.indicator_code %TYPE
  )
  LANGUAGE plpgsql
  AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM inflation.view_all_countries_inflation_data() d
    WHERE 
      d.country_code = input_country_code;
END;
$$;

CREATE OR REPLACE FUNCTION inflation.view_multi_country(
  IN input_country_codes TEXT[]
)
  RETURNS TABLE (
    "country_id" inflation.country_list.id % TYPE,
    "data_id" inflation.inflation_data.id % TYPE,
    "country_name" inflation.country_list.country_name % TYPE,
    "country_code" inflation.country_list.country_code % TYPE,
    "observation_year" inflation.inflation_data.year % TYPE,
    "inflation_value" inflation.inflation_data.value % TYPE,
    "indicator_name" inflation.indicator_list.indicator_name % TYPE,
    "indicator_code" inflation.indicator_list.indicator_code % TYPE
  )
  LANGUAGE plpgsql
  AS $$
BEGIN
  RETURN QUERY
    SELECT 
      *
    FROM inflation.view_all_countries_inflation_data() d
    WHERE 
      d.country_code = ANY(input_country_codes);
END;
$$;
