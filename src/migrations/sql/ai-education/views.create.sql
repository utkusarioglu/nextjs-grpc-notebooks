CREATE OR REPLACE VIEW public."responder_source_names" AS
SELECT
  "resp"."id" AS "responder_id",
  "src"."source_name"
FROM
  public."responses" "resp"
  INNER JOIN public."responder_sources" AS "rs" ON "rs"."responder_id" = "resp"."id"
  INNER JOIN public."sources" AS "src" ON "src"."id" = "rs"."source_id";

CREATE OR REPLACE VIEW public."responder_domain_names" AS
SELECT
  "responses"."id" AS "responder_id",
  "domains"."domain_name"
FROM
  public."responses" "responses"
  INNER JOIN public."responder_domains" AS "rd" ON "rd"."responder_id" =
    "responses"."id"
  INNER JOIN public."domains" AS "domains" ON "domains"."id" = "rd"."domain_id";
