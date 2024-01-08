-- This file should undo anything in `up.sql`
DROP EVENT TRIGGER pgrst_ddl_watch;

DROP EVENT TRIGGER pgrst_drop_watch;

DROP FUNCTION pgrst_ddl_watch;

DROP FUNCTION pgrst_drop_watch;
