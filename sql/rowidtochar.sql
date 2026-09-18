-- Test for oracle.rowidtochar()
\set ECHO none
SET client_min_messages = warning;
SET client_encoding = utf8;
\set VERBOSITY terse
\set ECHO all

SET search_path TO oracle, "$user", public, pg_catalog;

-- PostgreSQL has no ROWID type, so rowidtochar() returns its text argument
-- unchanged, letting Oracle SQL that calls ROWIDTOCHAR(...) run unmodified.
-- ORACLE> SELECT ROWIDTOCHAR('AAAAECAABAAAAGaAAA') FROM dual; -> AAAAECAABAAAAGaAAA
SELECT rowidtochar('AAAAECAABAAAAGaAAA') = 'AAAAECAABAAAAGaAAA';
-- an empty string round-trips
SELECT rowidtochar('') = '';
-- STRICT: a NULL argument yields NULL
SELECT rowidtochar(NULL) IS NULL;
