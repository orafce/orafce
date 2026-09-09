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

-- UTL_RAW: Oracle's RAW/bytea manipulation package. CAST_TO_RAW / CAST_TO_VARCHAR2
-- use the database character set (like Oracle, which uses the database charset for
-- the VARCHAR2<->RAW casts). The bitwise operators follow Oracle's rule that, when
-- the operands differ in length, the operation stops at the end of the shorter one
-- and the unprocessed tail of the longer is appended to the result.
CREATE SCHEMA utl_raw;

CREATE FUNCTION utl_raw.cast_to_raw(text)
RETURNS bytea
AS $$ SELECT convert_to($1, current_setting('server_encoding')) $$
LANGUAGE sql STABLE STRICT PARALLEL SAFE;
COMMENT ON FUNCTION utl_raw.cast_to_raw(text) IS 'Converts a value to a raw (bytea) value using the database character set';

CREATE FUNCTION utl_raw.cast_to_varchar2(bytea)
RETURNS text
AS $$ SELECT convert_from($1, current_setting('server_encoding')) $$
LANGUAGE sql STABLE STRICT PARALLEL SAFE;
COMMENT ON FUNCTION utl_raw.cast_to_varchar2(bytea) IS 'Converts a raw (bytea) value to a value using the database character set';

CREATE FUNCTION utl_raw.length(bytea)
RETURNS integer
AS $$ SELECT pg_catalog.length($1) $$
LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE;
COMMENT ON FUNCTION utl_raw.length(bytea) IS 'Returns the number of bytes in a raw (bytea) value';

CREATE FUNCTION utl_raw.substr(bytea, integer, integer DEFAULT NULL)
RETURNS bytea
AS $$
    -- Oracle UTL_RAW.SUBSTR is 1-based; a negative position counts from the end,
    -- and an omitted length runs to the end of the value.
    SELECT CASE
        WHEN $2 = 0 THEN NULL
        WHEN $2 < 0 THEN substring($1 FROM pg_catalog.length($1) + $2 + 1 FOR coalesce($3, pg_catalog.length($1)))
        ELSE substring($1 FROM $2 FOR coalesce($3, pg_catalog.length($1)))
    END
$$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
COMMENT ON FUNCTION utl_raw.substr(bytea, integer, integer) IS 'Returns a portion of a raw (bytea) value';

CREATE FUNCTION utl_raw.concat(VARIADIC bytea[])
RETURNS bytea
AS $$ SELECT coalesce(string_agg(part, ''::bytea), ''::bytea) FROM unnest($1) AS part $$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
COMMENT ON FUNCTION utl_raw.concat(VARIADIC bytea[]) IS 'Concatenates raw (bytea) values';

CREATE FUNCTION utl_raw.bit_and(bytea, bytea)
RETURNS bytea
AS $$
DECLARE
    n integer := least(pg_catalog.length($1), pg_catalog.length($2));
    result bytea := ''::bytea;
    i integer;
BEGIN
    FOR i IN 0 .. n - 1 LOOP
        result := result || decode(lpad(to_hex(get_byte($1, i) & get_byte($2, i)), 2, '0'), 'hex');
    END LOOP;
    IF pg_catalog.length($1) > n THEN result := result || substring($1 FROM n + 1);
    ELSIF pg_catalog.length($2) > n THEN result := result || substring($2 FROM n + 1);
    END IF;
    RETURN result;
END
$$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;
COMMENT ON FUNCTION utl_raw.bit_and(bytea, bytea) IS 'Bitwise AND of two raw (bytea) values';

CREATE FUNCTION utl_raw.bit_or(bytea, bytea)
RETURNS bytea
AS $$
DECLARE
    n integer := least(pg_catalog.length($1), pg_catalog.length($2));
    result bytea := ''::bytea;
    i integer;
BEGIN
    FOR i IN 0 .. n - 1 LOOP
        result := result || decode(lpad(to_hex(get_byte($1, i) | get_byte($2, i)), 2, '0'), 'hex');
    END LOOP;
    IF pg_catalog.length($1) > n THEN result := result || substring($1 FROM n + 1);
    ELSIF pg_catalog.length($2) > n THEN result := result || substring($2 FROM n + 1);
    END IF;
    RETURN result;
END
$$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;
COMMENT ON FUNCTION utl_raw.bit_or(bytea, bytea) IS 'Bitwise OR of two raw (bytea) values';

CREATE FUNCTION utl_raw.bit_xor(bytea, bytea)
RETURNS bytea
AS $$
DECLARE
    n integer := least(pg_catalog.length($1), pg_catalog.length($2));
    result bytea := ''::bytea;
    i integer;
BEGIN
    FOR i IN 0 .. n - 1 LOOP
        result := result || decode(lpad(to_hex(get_byte($1, i) # get_byte($2, i)), 2, '0'), 'hex');
    END LOOP;
    IF pg_catalog.length($1) > n THEN result := result || substring($1 FROM n + 1);
    ELSIF pg_catalog.length($2) > n THEN result := result || substring($2 FROM n + 1);
    END IF;
    RETURN result;
END
$$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;
COMMENT ON FUNCTION utl_raw.bit_xor(bytea, bytea) IS 'Bitwise XOR of two raw (bytea) values';

GRANT USAGE ON SCHEMA utl_raw TO PUBLIC;
