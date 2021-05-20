CREATE FUNCTION dbms_utility.get_time()
RETURNS bigint
AS 'MODULE_PATHNAME','dbms_utility_get_time'
LANGUAGE C VOLATILE;
COMMENT ON FUNCTION dbms_utility.get_time() IS 'Returns the number of hundredths of seconds that have elapsed since a point in time in the past.';
