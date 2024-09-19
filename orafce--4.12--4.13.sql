-- remove obsolete signature of dbms_alert.defered_signal
DO $$
BEGIN
  IF EXISTS (SELECT *
               FROM pg_proc p
                    JOIN pg_namespace n ON p.pronamespace = n.oid
             WHERE n.nspname = 'dbms_alert' AND p.proname = 'defered_signal') THEN
    DROP FUNCTION dbms_alert.defered_signal();
  END IF;
END;
$$;