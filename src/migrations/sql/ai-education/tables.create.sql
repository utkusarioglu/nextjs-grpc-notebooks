--
CREATE OR REPLACE PROCEDURE public."create_table_raw_data" ()
LANGUAGE plpgsql
AS $$
BEGIN
  CREATE TABLE public."raw_data" (
    "id" int UNIQUE NOT NULL GENERATED ALWAYS AS IDENTITY,
    "raw_id" int UNIQUE NOT NULL,
    "q1_ai_knowledge" smallint,
    "q2_ai_sources" varchar(110 ),
    "q2_n1_internet" boolean,
    "q2_n2_books_and_papers" boolean,
    "q2_n3_social_media" boolean,
    "q2_n4_discussions" boolean,
    "q2_n5_not_informed" boolean,
    "q3_n1_ai_dehumanization" smallint,
    "q3_n2_job_replacement" smallint,
    "q3_n3_problem_solving" smallint,
    "q3_n4_ai_ruling_society" smallint,
    "q4_n1_ai_costly" smallint,
    "q4_n2_economic_crisis" smallint,
    "q4_n3_economic_growth" smallint,
    "q4_n4_job_loss" smallint,
    "q5_feelings" smallint,
    "q6_domains" varchar(80 ),
    "q6_n1_education" boolean,
    "q6_n2_medicine" boolean,
    "q6_n3_agriculture" boolean,
    "q6_n4_constructions" boolean,
    "q6_n5_marketing" boolean,
    "q6_n6_administration" boolean,
    "q6_n7_art" boolean,
    "q7_utility_grade" smallint,
    "q8_advantage_teaching" smallint,
    "q9_advantage_learning" smallint,
    "q10_advantage_evaluation" smallint,
    "q11_disadvantage_educational_process" smallint,
    "q12_gender" smallint,
    "q13_year_of_study" smallint,
    "q14_major" smallint,
    "q15_passed_exams" boolean,
    "q16_gpa" float,
    PRIMARY KEY ("id" )
  )
  TABLESPACE "ai_education";
END;
$$;

CALL public."create_table_raw_data" ();

COPY public."raw_data" ("raw_id", "q1_ai_knowledge", "q2_ai_sources",
  "q2_n1_internet", "q2_n2_books_and_papers", "q2_n3_social_media",
  "q2_n4_discussions", "q2_n5_not_informed", "q3_n1_ai_dehumanization",
  "q3_n2_job_replacement", "q3_n3_problem_solving", "q3_n4_ai_ruling_society",
  "q4_n1_ai_costly", "q4_n2_economic_crisis", "q4_n3_economic_growth",
  "q4_n4_job_loss", "q5_feelings", "q6_domains", "q6_n1_education",
  "q6_n2_medicine", "q6_n3_agriculture", "q6_n4_constructions",
  "q6_n5_marketing", "q6_n6_administration", "q6_n7_art", "q7_utility_grade",
  "q8_advantage_teaching", "q9_advantage_learning", "q10_advantage_evaluation",
  "q11_disadvantage_educational_process", "q12_gender", "q13_year_of_study",
  "q14_major", "q15_passed_exams", "q16_gpa")
FROM
  '/migrations/data/ai-education/ai-education.csv' CSV HEADER;

CREATE OR REPLACE PROCEDURE public.create_table_domains ()
LANGUAGE plpgsql
AS $$
BEGIN
  CREATE TABLE public."domains" (
    "id" int UNIQUE NOT NULL GENERATED ALWAYS AS IDENTITY,
    "domain_name" varchar(40 )
  )
  TABLESPACE "ai_education";
END;
$$;

CALL public."create_table_domains" ();

CREATE OR REPLACE PROCEDURE public."populate_table_domains" ()
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public."domains" (
    "domain_name")
  SELECT DISTINCT
    unnest(string_to_array("q6_domains", ';')) AS "domain_name"
  FROM
    public."raw_data" s;
END;
$$;

CALL public."populate_table_domains" ();

CREATE OR REPLACE PROCEDURE public."create_table_sources" ()
LANGUAGE plpgsql
AS $$
BEGIN
  CREATE TABLE public."sources" (
    "id" int NOT NULL UNIQUE GENERATED ALWAYS AS IDENTITY,
    "source_name" varchar(60 )
  )
  TABLESPACE "ai_education";
END;
$$;

CALL public."create_table_sources" ();

CREATE OR REPLACE PROCEDURE public."create_table_responses" ()
LANGUAGE plpgsql
AS $$
BEGIN
  CREATE TABLE public."responses" (
    LIKE public."raw_data"
  )
  TABLESPACE "ai_education";
      ALTER TABLE public."responses"
        DROP COLUMN "raw_id",
        DROP COLUMN "q2_ai_sources",
        DROP COLUMN "q6_domains",
        DROP COLUMN "q6_n1_education",
        DROP COLUMN "q6_n2_medicine",
        DROP COLUMN "q6_n3_agriculture",
        DROP COLUMN "q6_n4_constructions",
        DROP COLUMN "q6_n5_marketing",
        DROP COLUMN "q6_n6_administration",
        DROP COLUMN "q6_n7_art";
      ALTER TABLE public."responses"
        ADD CONSTRAINT "unique_id" UNIQUE ("id"),
        ALTER COLUMN "id"
        ADD GENERATED ALWAYS AS IDENTITY,
        ALTER COLUMN "id" SET NOT NULL;
END;
$$;

CALL public."create_table_responses" ();

CREATE OR REPLACE PROCEDURE restricted.create_table_responses ()
LANGUAGE plpgsql
AS $$
BEGIN
  CREATE TABLE restricted."responses" (
    LIKE public.raw_data
  )
  INHERITS (
    public.responses
  )
  TABLESPACE "ai_education";
      ALTER TABLE restricted.responses
        DROP COLUMN "raw_id",
        DROP COLUMN "q2_ai_sources",
        DROP COLUMN "q6_domains";
      ALTER TABLE restricted.responses
        ADD CONSTRAINT unique_id UNIQUE ("id"),
        ALTER COLUMN "id"
        ADD GENERATED ALWAYS AS IDENTITY,
        ALTER COLUMN "id" SET NOT NULL;
END;
$$;

CALL restricted."create_table_responses" ();

CREATE OR REPLACE PROCEDURE public."create_table_responder_domains" ()
LANGUAGE plpgsql
AS $$
BEGIN
  CREATE TABLE public."responder_domains" (
    "id" int UNIQUE NOT NULL GENERATED ALWAYS AS IDENTITY,
    "responder_id" int NOT NULL,
    "domain_id" int NOT NULL,
    CONSTRAINT "responder_fk" FOREIGN KEY ("responder_id" ) REFERENCES
      restricted.responses ("id" ),
    CONSTRAINT "domain_fk" FOREIGN KEY ("domain_id" ) REFERENCES public."domains" ("id" )
  )
  TABLESPACE "ai_education";
END;
$$;

CALL public."create_table_responder_domains" ();

CREATE OR REPLACE PROCEDURE public."create_table_responder_sources" ()
LANGUAGE plpgsql
AS $$
BEGIN
  CREATE TABLE public."responder_sources" (
    "id" int UNIQUE NOT NULL GENERATED ALWAYS AS IDENTITY,
    "responder_id" int NOT NULL,
    "source_id" int NOT NULL,
    CONSTRAINT "responder_fk" FOREIGN KEY ("responder_id" ) REFERENCES
      restricted."responses" ("id" ),
    CONSTRAINT "source_fk" FOREIGN KEY ("source_id" ) REFERENCES public."sources" ("id" )
  )
  TABLESPACE "ai_education";
END;
$$;

CALL public."create_table_responder_sources" ();

CREATE OR REPLACE PROCEDURE restricted."populate_table_responses" ()
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO restricted."responses" (
    "q1_ai_knowledge",
    "q2_n1_internet",
    "q2_n2_books_and_papers",
    "q2_n3_social_media",
    "q2_n4_discussions",
    "q2_n5_not_informed",
    "q3_n1_ai_dehumanization",
    "q3_n2_job_replacement",
    "q3_n3_problem_solving",
    "q3_n4_ai_ruling_society",
    "q4_n1_ai_costly",
    "q4_n2_economic_crisis",
    "q4_n3_economic_growth",
    "q4_n4_job_loss",
    "q5_feelings",
    "q6_n1_education",
    "q6_n2_medicine",
    "q6_n3_agriculture",
    "q6_n4_constructions",
    "q6_n5_marketing",
    "q6_n6_administration",
    "q6_n7_art",
    "q7_utility_grade",
    "q8_advantage_teaching",
    "q9_advantage_learning",
    "q10_advantage_evaluation",
    "q11_disadvantage_educational_process",
    "q12_gender",
    "q13_year_of_study",
    "q14_major",
    "q15_passed_exams",
    "q16_gpa")
  SELECT
    "q1_ai_knowledge",
    "q2_n1_internet",
    "q2_n2_books_and_papers",
    "q2_n3_social_media",
    "q2_n4_discussions",
    "q2_n5_not_informed",
    "q3_n1_ai_dehumanization",
    "q3_n2_job_replacement",
    "q3_n3_problem_solving",
    "q3_n4_ai_ruling_society",
    "q4_n1_ai_costly",
    "q4_n2_economic_crisis",
    "q4_n3_economic_growth",
    "q4_n4_job_loss",
    "q5_feelings",
    "q6_n1_education",
    "q6_n2_medicine",
    "q6_n3_agriculture",
    "q6_n4_constructions",
    "q6_n5_marketing",
    "q6_n6_administration",
    "q6_n7_art",
    "q7_utility_grade",
    "q8_advantage_teaching",
    "q9_advantage_learning",
    "q10_advantage_evaluation",
    "q11_disadvantage_educational_process",
    "q12_gender",
    "q13_year_of_study",
    "q14_major",
    "q15_passed_exams",
    "q16_gpa"
  FROM
    public."raw_data";
END;
$$;

CALL restricted."populate_table_responses" ();

CREATE OR REPLACE PROCEDURE public."populate_table_sources" ()
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public."sources" (
    "source_name")
  SELECT DISTINCT
    unnest(string_to_array(r."q2_ai_sources", ';')) AS "source_name"
  FROM
    public."raw_data" r;
END;
$$;

CALL public."populate_table_sources" ();

CREATE OR REPLACE PROCEDURE public."populate_table_responder_domains" ()
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public."responder_domains" (
    "responder_id",
    "domain_id")
  SELECT
    "responses"."id" AS "responder_id",
    "domains"."id" AS "domain_id"
  FROM (
    SELECT
      "id",
      unnest(string_to_array("q6_domains", ';')) AS "domain_name"
    FROM
      public."raw_data") AS "raw"
  INNER JOIN public."domains" AS "domains" ON "domains"."domain_name" =
    "raw"."domain_name"
  INNER JOIN public."responses" AS "responses" ON "responses"."id" = "raw"."id";
END;
$$;

CALL public."populate_table_responder_domains" ();

CREATE OR REPLACE PROCEDURE public."populate_table_responder_sources" ()
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public."responder_sources" (
    "responder_id",
    "source_id")
  SELECT
    "responses"."id" AS "responder_id",
    "sources"."id" AS "source_id"
  FROM (
    SELECT
      "id",
      unnest(string_to_array("q2_ai_sources", ';')) AS "source_name"
    FROM
      public."raw_data") AS "raw"
  INNER JOIN public."sources" AS "sources" ON "sources"."source_name" =
    "raw"."source_name"
  INNER JOIN public."responses" AS "responses" ON "responses"."id" = "raw"."id";
END;
$$;

CALL public."populate_table_responder_sources" ();
