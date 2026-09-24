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
DECLARE
    total integer;
    pos integer := coalesce($2, 0);
    len integer;
BEGIN
    -- Oracle UTL_RAW.SUBSTR is 1-based; a negative position counts from the end,
    -- a position of 0 or NULL is taken as 1, and an omitted or NULL length runs
    -- to the end of the value. Oracle raises VALUE_ERROR (ORA-06502) for a NULL
    -- raw, a length below 1, and a range that is not wholly inside the value.
    IF $1 IS NULL THEN
        RAISE EXCEPTION USING
            ERRCODE = 'null_value_not_allowed',
            MESSAGE = 'argument ''r'' must not be NULL';
    END IF;
    total := pg_catalog.length($1);
    IF pos = 0 THEN
        pos := 1;
    ELSIF pos < 0 THEN
        pos := total + pos + 1;
    END IF;
    IF pos < 1 OR pos > total THEN
        RAISE EXCEPTION USING
            ERRCODE = 'invalid_parameter_value',
            MESSAGE = 'argument ''pos'' is outside the value';
    END IF;
    len := coalesce($3, total - pos + 1);
    IF len < 1 THEN
        RAISE EXCEPTION USING
            ERRCODE = 'invalid_parameter_value',
            MESSAGE = 'argument ''len'' must be a number greater than 0';
    END IF;
    IF pos + len - 1 > total THEN
        RAISE EXCEPTION USING
            ERRCODE = 'invalid_parameter_value',
            MESSAGE = 'argument ''len'' runs past the end of the value';
    END IF;
    RETURN substring($1 FROM pos FOR len);
END;
$$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;
COMMENT ON FUNCTION utl_raw.substr(bytea, integer, integer) IS 'Returns a portion of a raw (bytea) value';

CREATE FUNCTION utl_raw.concat(VARIADIC bytea[])
RETURNS bytea
AS $$ SELECT coalesce(string_agg(part, ''::bytea), ''::bytea) FROM unnest($1) AS part $$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
COMMENT ON FUNCTION utl_raw.concat(VARIADIC bytea[]) IS 'Concatenates raw (bytea) values';

CREATE FUNCTION utl_raw.bit_and(bytea, bytea)
RETURNS bytea
AS 'MODULE_PATHNAME','orafce_utl_raw_bit_and'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
COMMENT ON FUNCTION utl_raw.bit_and(bytea, bytea) IS 'Bitwise AND of two raw (bytea) values';

CREATE FUNCTION utl_raw.bit_or(bytea, bytea)
RETURNS bytea
AS 'MODULE_PATHNAME','orafce_utl_raw_bit_or'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
COMMENT ON FUNCTION utl_raw.bit_or(bytea, bytea) IS 'Bitwise OR of two raw (bytea) values';

CREATE FUNCTION utl_raw.bit_xor(bytea, bytea)
RETURNS bytea
AS 'MODULE_PATHNAME','orafce_utl_raw_bit_xor'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
COMMENT ON FUNCTION utl_raw.bit_xor(bytea, bytea) IS 'Bitwise XOR of two raw (bytea) values';

GRANT USAGE ON SCHEMA utl_raw TO PUBLIC;

-- The USER_* views describe the objects the current user owns, so they are
-- restricted to the current schema. Without that restriction they described
-- every table in the database, PostgreSQL's own catalogs included.
CREATE OR REPLACE VIEW oracle.user_tab_columns AS
    select table_name,
           column_name,
           data_type,
           coalesce(character_maximum_length, numeric_precision) AS data_length,
           numeric_precision AS data_precision,
           numeric_scale AS data_scale,
           is_nullable AS nullable,
           ordinal_position AS column_id,
           is_updatable AS data_upgraded,
           table_schema
    from information_schema.columns
   where table_schema = current_schema();

CREATE OR REPLACE VIEW oracle.user_tables AS
    select table_name
      from information_schema.tables
     where table_type = 'BASE TABLE'
       and table_schema = current_schema();
