CREATE OR REPLACE FUNCTION oracle.to_date (TEXT, TEXT) RETURNS oracle.date AS $$
SELECT CASE WHEN upper($2) = 'J' THEN
    pg_catalog.to_date($1, $2) + '400 days'::interval
  ELSE
    TO_TIMESTAMP($1,$2)::oracle.date
  END;
$$ LANGUAGE SQL
STRICT IMMUTABLE PARALLEL SAFE;
