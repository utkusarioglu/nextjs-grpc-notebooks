-- PUBLIC VIEWS
GRANT SELECT ON TABLE public."responder_domain_names" TO "g_ai_education_reader_public";

GRANT SELECT ON TABLE public."responder_source_names" TO "g_ai_education_reader_public";

-- RESTRICTED VIEWS
GRANT SELECT ON TABLE public."responder_domain_names" TO
  "g_ai_education_reader_restricted";

GRANT SELECT ON TABLE public."responder_source_names" TO
  "g_ai_education_reader_restricted";
