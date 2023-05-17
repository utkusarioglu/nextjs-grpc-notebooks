-- PUBLIC
GRANT USAGE ON SCHEMA "public" TO "g_ai_education_reader_public";

GRANT SELECT ON TABLE "public"."raw_data" TO "g_ai_education_reader_public";

GRANT SELECT ON TABLE "public"."domains" TO "g_ai_education_reader_public";

GRANT SELECT ON TABLE "public"."responder_domains" TO "g_ai_education_reader_public";

GRANT SELECT ON TABLE "public"."responses" TO "g_ai_education_reader_public";

GRANT SELECT ON TABLE "public"."sources" TO "g_ai_education_reader_public";

-- RESTRICTED
GRANT USAGE ON SCHEMA "public" TO "g_ai_education_reader_restricted";

GRANT SELECT ON TABLE "public"."raw_data" TO "g_ai_education_reader_public";

GRANT SELECT ON TABLE "public"."domains" TO "g_ai_education_reader_public";

GRANT SELECT ON TABLE "public"."responder_domains" TO "g_ai_education_reader_public";

GRANT SELECT ON TABLE "public"."responses" TO "g_ai_education_reader_public";

GRANT SELECT ON TABLE "public"."sources" TO "g_ai_education_reader_public";

GRANT USAGE ON SCHEMA "restricted" TO "g_ai_education_reader_restricted";

GRANT SELECT ON TABLE "restricted"."responses" TO "g_ai_education_reader_restricted";
