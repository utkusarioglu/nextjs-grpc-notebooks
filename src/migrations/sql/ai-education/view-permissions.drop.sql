-- PUBLIC VIEWS
REVOKE ALL ON TABLE public."responder_domain_names" FROM "g_ai_education_reader_public";

REVOKE ALL ON TABLE public."responder_source_names" FROM "g_ai_education_reader_public";

-- RESTRICTED VIEWS
REVOKE ALL ON TABLE public."responder_domain_names" FROM
  "g_ai_education_reader_restricted";

REVOKE ALL ON TABLE public."responder_source_names" FROM
  "g_ai_education_reader_restricted";
