-- Test for the RR and RRRR elements of the to_date() format
\set ECHO none
SET client_min_messages = warning;
SET client_encoding = utf8;
\set VERBOSITY terse
\set ECHO all

SET search_path TO oracle, "$user", public, pg_catalog;

-- The century of a two digit year depends on the current year (Oracle's rule), so
-- the expected value is computed from it:
--   current year 00-49: input 00-49 is this century,  50-99 the previous one
--   current year 50-99: input 00-49 is the next one,   50-99 this century
CREATE FUNCTION rr_year(yy int) RETURNS int AS $$
	SELECT (extract(year FROM now())::int / 100
			+ CASE WHEN extract(year FROM now())::int % 100 < 50 AND yy >= 50 THEN -1
				   WHEN extract(year FROM now())::int % 100 >= 50 AND yy < 50 THEN 1
				   ELSE 0 END) * 100 + yy
$$ LANGUAGE sql;

-- every two digit year, both elements
SELECT bool_and(to_date('01.02.' || lpad(yy::text, 2, '0'), 'DD.MM.RR') = make_date(rr_year(yy), 2, 1)) AS rr_all
  FROM generate_series(0, 99) yy;
SELECT bool_and(to_date('01.02.' || lpad(yy::text, 2, '0'), 'DD.MM.RRRR') = make_date(rr_year(yy), 2, 1)) AS rrrr_two_digits
  FROM generate_series(0, 99) yy;

-- RRRR with four digits keeps the year
SELECT to_date('01.02.2024', 'DD.MM.RRRR') = make_date(2024, 2, 1) AS rrrr_four_digits;
SELECT to_date('01.02.1987', 'DD.MM.RRRR') = make_date(1987, 2, 1) AS rrrr_four_digits_1987;

-- lower case, no separators, with a time part
SELECT to_date('010224', 'ddmmrr') = make_date(rr_year(24), 2, 1) AS lower_case_no_separator;
SELECT to_date('01.02.55 13:14:15', 'DD.MM.RR HH24:MI:SS') = make_date(rr_year(55), 2, 1) + time '13:14:15' AS with_time;

-- text in double quotes is not a format element
SELECT to_date('01 RR 02 24', 'DD "RR" MM RR') = make_date(rr_year(24), 2, 1) AS quoted_rr;

-- formats without RR are not changed
SELECT to_date('01.02.24', 'DD.MM.YY') = make_date(2024, 2, 1) AS yy_unchanged;
SELECT to_date('01.02.2024', 'DD.MM.YYYY') = make_date(2024, 2, 1) AS yyyy_unchanged;

-- the default format of the session (orafce.nls_date_format) may use RR as well
SET orafce.nls_date_format = 'DD-MM-RR';
SELECT to_date('01-02-55') = make_date(rr_year(55), 2, 1) AS nls_date_format;
RESET orafce.nls_date_format;

DROP FUNCTION rr_year(int);
