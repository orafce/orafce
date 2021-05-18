CREATE FUNCTION dbms_utility.get_time()
RETURNS integer
AS $$
    SELECT substr((round(extract(epoch FROM clock_timestamp())::numeric, 2)*100)::bigint::text, 4)::integer;
$$
LANGUAGE sql VOLATILE;
COMMENT ON FUNCTION dbms_utility.get_time() IS 'Returns the number of hundredths of seconds that have elapsed since a point in time in the past.';

