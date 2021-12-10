----
-- Add LEAST/GREATEST declaration to return NULL on NULL input.
-- PostgreSQL only returns NULL when all the parameters are NULL.
----

-- GREATEST
CREATE FUNCTION oracle.greatest(VARIADIC text[]) RETURNS text AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN max(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.greatest(VARIADIC bpchar[]) RETURNS bpchar AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN max(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.greatest(VARIADIC bigint[]) RETURNS bigint AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN max(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.greatest(VARIADIC integer[]) RETURNS integer AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN max(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.greatest(VARIADIC smallint[]) RETURNS smallint AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN max(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.greatest(VARIADIC numeric[]) RETURNS numeric AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN max(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.greatest(VARIADIC double precision[]) RETURNS double precision AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN max(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.greatest(VARIADIC timestamp[]) RETURNS timestamp AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN max(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.greatest(VARIADIC timestamptz[]) RETURNS timestamptz AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN max(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.greatest(VARIADIC date[]) RETURNS date AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN max(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.greatest(VARIADIC time[]) RETURNS time AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN max(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

-- LEAST
CREATE FUNCTION oracle.least(VARIADIC text[]) RETURNS text AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN min(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.least(VARIADIC bpchar[]) RETURNS bpchar AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN min(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.least(VARIADIC bigint[]) RETURNS bigint AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN min(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.least(VARIADIC integer[]) RETURNS integer AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN min(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.least(VARIADIC smallint[]) RETURNS smallint AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN min(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.least(VARIADIC numeric[]) RETURNS numeric AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN min(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.least(VARIADIC double precision[]) RETURNS double precision AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN min(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.least(VARIADIC timestamp[]) RETURNS timestamp AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN min(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.least(VARIADIC timestamptz[]) RETURNS timestamptz AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN min(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.least(VARIADIC date[]) RETURNS date AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN min(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION oracle.least(VARIADIC time[]) RETURNS time AS $$
BEGIN
   IF array_position($1, NULL) IS NOT NULL THEN
       RETURN NULL;
   END IF;
   RETURN min(x) FROM unnest($1) x;
END
$$ LANGUAGE PLPGSQL;
