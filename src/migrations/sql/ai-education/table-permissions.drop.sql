REVOKE ALL ON SCHEMA "public" FROM "g_ai_education_reader_public";

REVOKE ALL ON TABLE "public"."raw_data" FROM "g_ai_education_reader_public";

REVOKE ALL ON TABLE "public"."domains" FROM "g_ai_education_reader_public";

REVOKE ALL ON TABLE "public"."responder_domains" FROM "g_ai_education_reader_public";

REVOKE ALL ON TABLE "public"."responses" FROM "g_ai_education_reader_public";

REVOKE ALL ON TABLE "public"."sources" FROM "g_ai_education_reader_public";

-- RESTRICTED
REVOKE ALL ON SCHEMA "public" FROM "g_ai_education_reader_restricted";

REVOKE ALL ON TABLE "public"."raw_data" FROM "g_ai_education_reader_public";

REVOKE ALL ON TABLE "public"."domains" FROM "g_ai_education_reader_public";

REVOKE ALL ON TABLE "public"."responder_domains" FROM "g_ai_education_reader_public";

REVOKE ALL ON TABLE "public"."responses" FROM "g_ai_education_reader_public";

REVOKE ALL ON TABLE "public"."sources" FROM "g_ai_education_reader_public";

REVOKE ALL ON SCHEMA "restricted" FROM "g_ai_education_reader_restricted";

REVOKE ALL ON TABLE "restricted"."responses" FROM "g_ai_education_reader_restricted";
