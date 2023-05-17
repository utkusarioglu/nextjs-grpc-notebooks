GRANT USAGE ON SCHEMA raw TO g_happiness_readonly;
GRANT SELECT ON happiness.raw.year_2015 TO g_happiness_readonly;
GRANT SELECT ON happiness.raw.year_2016 TO g_happiness_readonly;
GRANT SELECT ON happiness.raw.years_all TO g_happiness_readonly;
GRANT SELECT ON happiness.raw.lowest_scores TO g_happiness_readonly;
GRANT SELECT ON happiness.raw.highest_scores TO g_happiness_readonly;
GRANT SELECT ON happiness.raw.highest_and_lowest_scores TO g_happiness_readonly;
