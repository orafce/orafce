CREATE FUNCTION oracle.hextoraw(text)
RETURNS bytea
AS $$ SELECT decode($1, 'hex') $$
LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE;
COMMENT ON FUNCTION oracle.hextoraw(text) IS 'Converts a string of hexadecimal digits to a raw (bytea) value';

CREATE FUNCTION oracle.rawtohex(bytea)
RETURNS text
AS $$ SELECT upper(encode($1, 'hex')) $$
LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE;
COMMENT ON FUNCTION oracle.rawtohex(bytea) IS 'Converts a raw (bytea) value to a string of hexadecimal digits';

CREATE FUNCTION oracle.empty_clob()
RETURNS text
AS $$ SELECT ''::text $$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
COMMENT ON FUNCTION oracle.empty_clob() IS 'Returns an empty character LOB';

CREATE FUNCTION oracle.empty_blob()
RETURNS bytea
AS $$ SELECT ''::bytea $$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
COMMENT ON FUNCTION oracle.empty_blob() IS 'Returns an empty binary LOB';

CREATE FUNCTION oracle.from_tz(timestamp, text)
RETURNS timestamp with time zone
AS $$
    -- A numeric offset ('+02:00') is applied as an interval so it follows the
    -- ISO sign convention (east of UTC is positive), as Oracle does; passing it
    -- straight to AT TIME ZONE as text would use PostgreSQL's inverted POSIX
    -- sign. A region name ('Europe/Prague') is looked up in the zone database.
    SELECT CASE
        WHEN $2 ~ '^[+-]?[0-9]{1,2}:[0-9]{2}$' THEN $1 AT TIME ZONE ($2)::interval
        ELSE $1 AT TIME ZONE $2
    END
$$
LANGUAGE sql STABLE STRICT PARALLEL SAFE;
COMMENT ON FUNCTION oracle.from_tz(timestamp, text) IS 'Interprets a timestamp as being in the given time zone and returns a timestamp with time zone';
